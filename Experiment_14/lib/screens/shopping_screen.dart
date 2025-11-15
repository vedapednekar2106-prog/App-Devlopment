// ==================== lib/screens/shopping_screen.dart (FINAL FIXED) ====================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'premium_lock_screen.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool? isPremium;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  @override
  void initState() {
    super.initState();
    _startPremiumListener();
  }

  // 🔥 REALTIME PREMIUM LISTENER (Fixes lock issue)
  void _startPremiumListener() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      setState(() => isPremium = false);
      return;
    }

    _userSub = _firestore.collection("users").doc(uid).snapshots().listen(
      (snap) {
        final data = snap.data();
        final premiumFlag = data == null ? false : (data["isPremium"] ?? false);

        if (mounted) {
          setState(() => isPremium = premiumFlag);
        }
      },
      onError: (_) {
        if (mounted) setState(() => isPremium = false);
      },
    );
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  // PRODUCT LIST
  // ----------------------------------------------------------

  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": "tee01",
      "title": "WanderList Classic Tee",
      "category": "T-Shirts",
      "price": 1199.0,
      "image": "assets/images/shop/classic_tee.jpg",
    },
    {
      "id": "tsh02",
      "title": "Vintage Stamp Tee",
      "category": "T-Shirts",
      "price": 1399.0,
      "image": "assets/images/shop/stamp_tee.jpg",
    },
    {
      "id": "gls01",
      "title": "UV Shield Sunglasses",
      "category": "Sunglasses",
      "price": 1599.0,
      "image": "assets/images/shop/uv_shield.jpg",
    },
    {
      "id": "sng02",
      "title": "CityLite Sunglasses",
      "category": "Sunglasses",
      "price": 1299.0,
      "image": "assets/images/shop/citylite.jpg",
    },
    {
      "id": "bag01",
      "title": "TrailPro Backpack 28L",
      "category": "Backpacks",
      "price": 3499.0,
      "image": "assets/images/shop/trail_backpack.jpg",
    },
    {
      "id": "bag02",
      "title": "Weekender Duffle",
      "category": "Backpacks",
      "price": 3899.0,
      "image": "assets/images/shop/weekender_duffle.jpg",
    },
    {
      "id": "lug01",
      "title": "Nomad Hardcase Luggage 40L",
      "category": "Luggage",
      "price": 4999.0,
      "image": "assets/images/shop/hardcase_luggage.jpg",
    },
    {
      "id": "jrnl01",
      "title": "WanderList Travel Journal",
      "category": "Travel Journal",
      "price": 899.0,
      "image": "assets/images/shop/travel_journal.jpg",
    },
  ];

  String _selectedCategory = "All";
  String _priceSort = "Default";

  List<String> get categories =>
      ["All", ..._allProducts.map((p) => p["category"] as String)].toSet().toList();

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> list = _selectedCategory == "All"
        ? [..._allProducts]
        : _allProducts.where((p) => p["category"] == _selectedCategory).toList();

    if (_priceSort == "Low → High") {
      list.sort((a, b) => (a["price"] as num).compareTo(b["price"] as num));
    } else if (_priceSort == "High → Low") {
      list.sort((a, b) => (b["price"] as num).compareTo(a["price"] as num));
    }

    return list;
  }

  Map<String, dynamic> _getProductFromId(String id) {
    return _allProducts.firstWhere((p) => p["id"] == id, orElse: () => {});
  }

  // ----------------------------------------------------------
  // CART FUNCTIONS
  // ----------------------------------------------------------

  void _showAuthPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please sign in to save items to your cart!"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      _showAuthPrompt();
      return;
    }

    final ref = _firestore
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(product["id"]);

    final snap = await ref.get();
    final qty = snap.exists ? (snap.data()?["qty"] ?? 0) : 0;

    await ref.set({"product_id": product["id"], "qty": qty + 1});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product["title"]} added to cart!"),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  Future<void> _updateQty(String id, int newQty) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = _firestore.collection("users").doc(uid).collection("cart").doc(id);

    if (newQty > 0) {
      await ref.set({"product_id": id, "qty": newQty});
    } else {
      await ref.delete();
    }
  }

  // ----------------------------------------------------------
  // CART BOTTOM SHEET
  // ----------------------------------------------------------

  void _showCart() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _showAuthPrompt();
      return;
    }

    final cartRef =
        _firestore.collection("users").doc(uid).collection("cart");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => StreamBuilder<QuerySnapshot>(
        stream: cartRef.snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            );
          }

          final docs = snap.data!.docs;

          final cartData = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            final prod = _getProductFromId(data["product_id"]);
            return {
              "product": prod,
              "qty": data["qty"],
            };
          }).toList();

          final cartEmpty = cartData.isEmpty;

          final total = cartData.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item["product"]["price"] as num) *
                    (item["qty"] as int)),
          );

          final count = cartData.fold<int>(
            0,
            (sum, item) => sum + (item["qty"] as int),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 6,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3)),
                ),
                const SizedBox(height: 12),

                Text(
                  "Your Cart ($count)",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 15),

                if (cartEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Your cart is empty :)",
                        style: TextStyle(color: Colors.grey)),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: cartData.map((item) {
                        final p =
                            item["product"] as Map<String, dynamic>;
                        final qty = item["qty"] as int;

                        return Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  p["image"],
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p["title"],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _updateQty(p["id"], qty - 1),
                                icon: const Icon(
                                    Icons.remove_circle_outline),
                              ),
                              Text(
                                "$qty",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _updateQty(p["id"], qty + 1),
                                icon: const Icon(
                                    Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                if (!cartEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text("Total:",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(
                        "₹${total.toStringAsFixed(0)}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () async {
                      final ctx = context;

                      Navigator.pop(ctx);

                      final batch = _firestore.batch();
                      final snap = await cartRef.get();
                      for (var d in snap.docs) {
                        batch.delete(d.reference);
                      }
                      await batch.commit();

                      showDialog(
                        context: ctx,
                        builder: (_) => AlertDialog(
                          title: const Text("Order Placed 🎉"),
                          content: const Text(
                              "Thanks for shopping!\nYour items are on the way!"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("OK"),
                            )
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      "Buy Now",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (isPremium == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF6EE),
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    if (isPremium == false) {
      return const PremiumLockScreen(
        featureName: "Exclusive Shop Access",
      );
    }

    final uid = _auth.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: uid != null
          ? _firestore.collection("users").doc(uid).collection("cart").snapshots()
          : null,
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];

        final cartCount = docs.fold<int>(
          0,
          (sum, d) =>
              sum + ((d.data() as Map<String, dynamic>)["qty"] as int? ?? 0),
        );

        return Scaffold(
          backgroundColor: const Color(0xFFFFF6EE),

          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF6EE),
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: [
                Text("WanderList Store",
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.brown[800])),
                Text("Premium gear for travelers ✈️",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown[500])),
              ],
            ),
          ),

          body: Column(
            children: [
              // FILTERS
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                child: Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _selectedCategory,
                        items: categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v!),
                      ),
                    ),
                    const SizedBox(width: 18),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _priceSort,
                        items: ["Default", "Low → High", "High → Low"]
                            .map(
                                (c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _priceSort = v!),
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: _showCart,
                          icon: const Icon(Icons.shopping_cart_outlined),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: CircleAvatar(
                              radius: 9,
                              backgroundColor: Colors.red,
                              child: Text(
                                "$cartCount",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),

              // GRID OF PRODUCTS
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredProducts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (_, i) {
                    final p = filteredProducts[i];

                    return GestureDetector(
                      onTap: () => _addToCart(p),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18)),
                              child: Image.asset(
                                p["image"],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p["title"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        "₹${(p["price"] as num).toStringAsFixed(0)}",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.add_shopping_cart_rounded,
                                          color: Colors.deepOrange),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== END FILE ====================
