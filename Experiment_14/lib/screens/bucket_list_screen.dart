// ==================== lib/screens/bucket_list_screen.dart (Final Single-File) ====================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BucketListManager {
  static final BucketListManager _instance = BucketListManager._internal();
  factory BucketListManager() => _instance;
  BucketListManager._internal();

  final List<Map<String, dynamic>> _bucketList = [];
  List<Map<String, dynamic>> get places => _bucketList;

  final _firestore = FirebaseFirestore.instance;
  
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // ✅ Load from Firestore
  Future<void> loadFromFirebase() async {
    final uid = currentUid;
    
    if (uid == null) {
      _bucketList.clear();
      return; 
    }

    final snap = await _firestore
        .collection("users")
        .doc(uid)
        .collection("bucketList")
        .get();

    _bucketList.clear();
    for (var doc in snap.docs) {
      final data = doc.data();

      _bucketList.add({
        "name": data["name"] ?? "",
        "description": data["description"] ?? "",
        "image": data["image"] ?? "",
        "visited": data["visited"] ?? false,
        "favorite": data["favorite"] ?? false,
      });
    }
  }

  // ✅ Add place
  Future<void> addPlace(Map<String, dynamic> place) async {
    final uid = currentUid;
    if (uid == null) return; 

    final safePlace = {
      "name": place["name"] ?? "",
      "description": place["description"] ?? "",
      "image": place["image"] ?? "",
      "visited": place["visited"] ?? false,
      "favorite": place["favorite"] ?? false,
    };

    if (!_bucketList.any((p) => p["name"] == safePlace["name"])) {
      _bucketList.add(safePlace);

      await _firestore
          .collection("users")
          .doc(uid)
          .collection("bucketList")
          .doc(safePlace["name"])
          .set(safePlace);
    }
  }

  // ✅ Remove place
  Future<void> removePlace(String name) async {
    final uid = currentUid;
    if (uid == null) return; 

    _bucketList.removeWhere((p) => p["name"] == name);
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("bucketList")
        .doc(name)
        .delete();
  }

  // ✅ Update visited
  Future<void> toggleVisited(String name, bool visited) async {
    final uid = currentUid;
    if (uid == null) return; 

    final index = _bucketList.indexWhere((p) => p["name"] == name);
    if (index != -1) {
      _bucketList[index]["visited"] = visited;
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("bucketList")
          .doc(name)
          .update({"visited": visited});
    }
  }

  // ✅ Update favorite
  Future<void> toggleFavorite(String name, bool favorite) async {
    final uid = currentUid;
    if (uid == null) return; 

    final index = _bucketList.indexWhere((p) => p["name"] == name);
    if (index != -1) {
      _bucketList[index]["favorite"] = favorite;
      await _firestore
          .collection("users")
          .doc(uid)
          .collection("bucketList")
          .doc(name)
          .update({"favorite": favorite});
    }
  }
}

class BucketListScreen extends StatefulWidget {
  const BucketListScreen({super.key});

  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  int selectedTab = 0;
  final List<String> tabs = ["To Visit", "Visited", "Favorites"];

  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await BucketListManager().loadFromFirebase();
    setState(() {
        _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
        return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
        );
    }
    
    final manager = BucketListManager();
    List<Map<String, dynamic>> displayedPlaces = [];

    if (selectedTab == 0) {
      displayedPlaces = manager.places; 
    } else if (selectedTab == 1) {
      displayedPlaces =
          manager.places.where((p) => p["visited"] == true).toList();
    } else if (selectedTab == 2) {
      displayedPlaces =
          manager.places.where((p) => p["favorite"] == true).toList();
    }

    Future<void> _deletePlaceWithUndo(int index) async {
      final deletedPlace = displayedPlaces[index];
      await manager.removePlace(deletedPlace["name"]);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${deletedPlace["name"]} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await manager.addPlace(deletedPlace);
              setState(() {});
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F3),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF8C00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Bucket List",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

            // TABS
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = index == selectedTab;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFE8D5) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF8C00) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            index == 0 ? Icons.flight_takeoff_rounded
                            : index == 1 ? Icons.check_circle_outline
                            : Icons.favorite_border,
                            size: 18,
                            color: isSelected ? const Color(0xFFFF8C00) : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tabs[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFFFF8C00) : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // LIST
            Expanded(
              child: displayedPlaces.isEmpty
                  ? const Center(child: Text("Your bucket list is empty 😎"))
                  : ListView.builder(
                      itemCount: displayedPlaces.length,
                      itemBuilder: (context, index) {
                        final place = displayedPlaces[index];
                        final isLocalAsset = place["image"].toString().startsWith('assets/');
                        
                        return Dismissible(
                          key: Key(place["name"]),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white, size: 26),
                          ),
                          confirmDismiss: (direction) async {
                            bool confirm = false;
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete"),
                                content: Text("Remove '${place["name"]}'?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                  TextButton(onPressed: () { confirm = true; Navigator.pop(ctx); }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm) await _deletePlaceWithUndo(index);
                            return false;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                // 🟢 FIX: Handle both local (Explore) and network (Places to Visit) images
                                child: isLocalAsset 
                                    ? Image.asset(
                                        place["image"] ?? "",
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                            width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.photo, color: Colors.grey)),
                                    )
                                    : Image.network(
                                        place["image"] ?? "",
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                            width: 60, height: 60, color: Colors.orange.shade50, child: const Icon(Icons.photo, color: Colors.grey)),
                                    ),
                              ),
                              title: Text(place["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text(place["description"] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: place["visited"] ?? false,
                                    activeColor: const Color(0xFFFF8C00),
                                    onChanged: (val) async {
                                      await manager.toggleVisited(place["name"], val!);
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      (place["favorite"] ?? false)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      await manager.toggleFavorite(
                                          place["name"], !(place["favorite"] ?? false));
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}