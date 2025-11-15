import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';



// ------------------- NEW: CURRENCY DATA -------------------

// Using simplified, fixed conversion rates relative to USD (USD=1.0)

const Map<String, double> currencyRates = {

  "USD": 1.0,

  "INR": 83.0, // Assuming 1 USD = 83 INR

  "EUR": 0.92, // Assuming 1 USD = 0.92 EUR (or 1 EUR ≈ 1.08 USD)

};



class BudgetPlannerScreen extends StatefulWidget {

  final bool isPremium;

  const BudgetPlannerScreen({super.key, required this.isPremium});



  @override

  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();

}



class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {

  // totalBudget is now always stored in USD

  double totalBudget = 0.0;

  // spent is now calculated dynamically

  double spent = 0.0;

  String selectedCurrency = "USD";



  // 🐛 CHANGE 1: Categories now include a list for expenses

  List<Map<String, dynamic>> categories = [];



  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FirebaseAuth auth = FirebaseAuth.instance;



  @override

  void initState() {

    super.initState();

    _loadDataFromFirebase();

  }



  // ------------------- Conversion Function -------------------

  // Converts an amount FROM its original currency TO the target currency.

  double convertCurrency({

    required double amount,

    required String fromCurrency,

    required String toCurrency

  }) {

    // Prevent division by zero

    if (fromCurrency == toCurrency) return amount;

    if (currencyRates[fromCurrency] == null || currencyRates[toCurrency] == null) return amount;



    // First, convert FROM 'fromCurrency' TO 'USD'

    // Since currencyRates are relative to USD (USD=1.0), we divide by the rate

    // Example: 100 INR / 83.0 = 1.20 USD

    double amountInUSD = amount / currencyRates[fromCurrency]!;



    // Second, convert FROM 'USD' TO 'toCurrency'

    // Example: 1.20 USD * 0.92 = 1.10 EUR

    return amountInUSD * currencyRates[toCurrency]!;

  }

 

  // ------------------- Recalculate Totals (The Core Logic) -------------------

  void _recalculateTotals() {

    // Get the target rate (e.g., INR=83.0 if selectedCurrency=INR)

    final targetCurrencyRate = currencyRates[selectedCurrency] ?? 1.0;

   

    // Calculate total spent based on the selected currency

    double newSpent = 0.0;

    for (var cat in categories) {

      double categorySpentInTargetCurrency = 0.0;

     

      // Cat limit is always stored in USD in the backend, but displayed in selectedCurrency

      cat["limit_display"] = convertCurrency(

        amount: cat["limit"],

        fromCurrency: "USD",

        toCurrency: selectedCurrency

      );

     

      // Calculate total spent for this category

      for (var expense in cat["expenses"]) {

        categorySpentInTargetCurrency += convertCurrency(

          amount: expense["amount"],

          fromCurrency: expense["currency"],

          toCurrency: selectedCurrency,

        );

      }

     

      cat["spent_display"] = categorySpentInTargetCurrency;

      newSpent += categorySpentInTargetCurrency;

    }

   

    setState(() {

      spent = newSpent;

    });

  }



  // ------------------- Firebase Load -------------------

  Future<void> _loadDataFromFirebase() async {

    final uid = auth.currentUser!.uid;

    // ⚠️ Critical null check added

    if (auth.currentUser == null) return;

   

    final userDoc = firestore.collection('users').doc(uid);

    final snapshot = await userDoc.get();



    if (snapshot.exists) {

      final data = snapshot.data()!;

      setState(() {

        // totalBudget is now loaded in USD (Base Currency)

        totalBudget = (data['totalBudget'] ?? 0.0).toDouble();

        selectedCurrency = data['currency'] ?? "USD";



        categories = (data['categories'] as List<dynamic>? ?? []).map((cat) {

          return {

            "name": cat["name"],

            "icon": IconData(cat["icon"], fontFamily: 'MaterialIcons'),

            "color": Color(cat["color"]),

            // 🐛 CHANGE 2: Load expenses list

            "expenses": (cat["expenses"] as List<dynamic>? ?? []).map((e) => {

              "amount": (e["amount"] ?? 0.0).toDouble(),

              "currency": e["currency"] ?? "USD", // NEW FIELD!

            }).toList(),

            // limit is loaded in USD (Base Currency)

            "limit": (cat["limit"] ?? 0.0).toDouble(),

          };

        }).toList();

       

        // Initial calculation of display amounts

        _recalculateTotals();

      });

    }

  }



  // ------------------- Firebase Save -------------------

  Future<void> _saveDataToFirebase() async {

    final uid = auth.currentUser!.uid;

    // ⚠️ Critical null check added

    if (auth.currentUser == null) return;



    await firestore.collection('users').doc(uid).set({

      'totalBudget': totalBudget,

      'currency': selectedCurrency,

      'categories': categories.map((cat) {

        return {

          "name": cat["name"],

          "icon": cat["icon"].codePoint,

          "color": cat["color"].value,

          // 🐛 CHANGE 3: Save the list of expenses

          "expenses": cat["expenses"].map((e) => {

            "amount": e["amount"], // This is the original amount

            "currency": e["currency"], // This is the original currency

          }).toList(),

          // limit is stored in USD (Base Currency)

          "limit": cat["limit"],

        };

      }).toList(),

    }, SetOptions(merge: true));

  }



  // ------------------- Helper Getters -------------------

  // Converts the USD-based totalBudget to the selected display currency

  double get totalBudgetDisplay {

    return convertCurrency(

        amount: totalBudget, fromCurrency: "USD", toCurrency: selectedCurrency);

  }



  double get totalRemaining => totalBudgetDisplay - spent;



  String get currencySymbol {

    switch (selectedCurrency) {

      case "INR":

        return "₹";

      case "EUR":

        return "€";

      default:

        return "\$";

    }

  }



  // ------------------- Dialogs -------------------

  void _editTotalBudgetDialog() {

    double tempBudget = totalBudgetDisplay; // Show/edit the budget in selected currency

    showDialog(

      context: context,

      builder: (ctx) => AlertDialog(

        title: Text("Edit Total Budget (${selectedCurrency})"),

        content: TextField(

          keyboardType: TextInputType.number,

          decoration: InputDecoration(hintText: tempBudget.toStringAsFixed(2)),

          onChanged: (val) => tempBudget = double.tryParse(val) ?? totalBudgetDisplay,

        ),

        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),

          ElevatedButton(

            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22)),

            onPressed: () {

              // 🐛 FIX 4: Convert the displayed amount back to USD before saving

              double newTotalBudgetUSD = convertCurrency(

                  amount: tempBudget, fromCurrency: selectedCurrency, toCurrency: "USD");



              setState(() => totalBudget = newTotalBudgetUSD);

              _recalculateTotals(); // Recalculate to update display

              _saveDataToFirebase();

              Navigator.pop(ctx);

            },

            child: const Text("Save"),

          ),

        ],

      ),

    );

  }



  void _addCategoryDialog() {

    String name = "";

    double limit = 0.0;

    IconData? selectedIcon;

    Color? selectedColor;



    showDialog(

      context: context,

      builder: (ctx) => StatefulBuilder(builder: (context, setInnerState) {

        return AlertDialog(

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

          title: const Text("Add New Category"),

          content: SingleChildScrollView(

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                TextField(

                  decoration: const InputDecoration(labelText: "Category Name"),

                  onChanged: (val) => name = val,

                ),

                TextField(

                  decoration: InputDecoration(labelText: "Budget Limit (${selectedCurrency})"),

                  keyboardType: TextInputType.number,

                  onChanged: (val) => limit = double.tryParse(val) ?? 0.0,

                ),

                const SizedBox(height: 10),

                Text("Choose Icon:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),

                Wrap(

                  spacing: 8,

                  children: [

                    Icons.restaurant,

                    Icons.hotel,

                    Icons.directions_bus,

                    Icons.hiking,

                    Icons.shopping_bag,

                    Icons.movie,

                    Icons.local_drink,

                    Icons.flight,

                  ].map((icon) {

                    return InkWell(

                      onTap: () => setInnerState(() => selectedIcon = icon),

                      child: CircleAvatar(

                        backgroundColor: selectedIcon == icon ? Colors.orange : Colors.grey.shade200,

                        child: Icon(icon, color: selectedIcon == icon ? Colors.white : Colors.black54),

                      ),

                    );

                  }).toList(),

                ),

                const SizedBox(height: 10),

                Text("Choose Color:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),

                Wrap(

                  spacing: 8,

                  children: [

                    Colors.red.shade300,

                    Colors.green.shade300,

                    Colors.orange.shade300,

                    Colors.blue.shade300,

                    Colors.purple.shade300,

                    Colors.teal.shade300,

                  ].map((c) {

                    return InkWell(

                      onTap: () => setInnerState(() => selectedColor = c),

                      child: CircleAvatar(

                        backgroundColor: c,

                        child: selectedColor == c ? const Icon(Icons.check, color: Colors.white) : const SizedBox.shrink(),

                      ),

                    );

                  }).toList(),

                ),

              ],

            ),

          ),

          actions: [

            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),

            ElevatedButton(

              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22)),

              onPressed: () {

                if (name.isNotEmpty && limit > 0) {

                  // 🐛 FIX 5: Convert the limit from selected currency to USD before saving

                  double limitUSD = convertCurrency(

                      amount: limit, fromCurrency: selectedCurrency, toCurrency: "USD");

                     

                  setState(() {

                    categories.add({

                      "name": name,

                      "icon": (selectedIcon ?? Icons.category),

                      "color": (selectedColor ?? Colors.purple.shade200),

                      "expenses": [], // New: Initialize with an empty expenses list

                      "limit": limitUSD, // Store USD limit

                      "limit_display": limit, // Temporary display limit

                      "spent_display": 0.0, // Temporary display spent

                    });

                  });

                  _recalculateTotals(); // Recalculate totals

                  _saveDataToFirebase();

                  Navigator.pop(ctx);

                }

              },

              child: const Text("Add"),

            )

          ],

        );

      }),

    );

  }



  void _addExpenseDialog(int index) {

    String expenseCurrency = selectedCurrency; // Default to selected currency

    double amount = 0.0;

   

    showDialog(

      context: context,

      builder: (ctx) => StatefulBuilder(

        builder: (context, setInnerState) {

          return AlertDialog(

            title: Text("Add Expense to ${categories[index]['name']}"),

            content: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                // Dropdown to select the expense currency

                DropdownButtonHideUnderline(

                  child: DropdownButton<String>(

                    value: expenseCurrency,

                    items: currencyRates.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),

                    onChanged: (val) => setInnerState(() => expenseCurrency = val!),

                  ),

                ),

                TextField(

                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(

                    labelText: "Amount spent in $expenseCurrency"

                  ),

                  onChanged: (val) => amount = double.tryParse(val) ?? 0.0,

                ),

              ],

            ),

            actions: [

              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),

              ElevatedButton(

                onPressed: () {

                  if (amount > 0) {

                    // 🐛 FIX 6: Add expense object to the category's expenses list

                    categories[index]["expenses"].add({

                        "amount": amount,

                        "currency": expenseCurrency,

                    });

                   

                    // The rest of the category/total spent logic is handled by recalculate

                    _recalculateTotals();

                    _saveDataToFirebase();

                    Navigator.pop(ctx);

                  }

                },

                child: const Text("Add"),

              ),

            ],

          );

        },

      ),

    );

  }



  void _deleteCategory(int index) {

    setState(() {

      categories.removeAt(index);

    });

    _recalculateTotals();

    _saveDataToFirebase();

  }



  // ------------------- UI -------------------

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFFFF6EE),

      appBar: AppBar(

        backgroundColor: const Color(0xFFFFF6EE),

        elevation: 0,

        leading: IconButton(

          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),

          onPressed: () => Navigator.pop(context),

        ),

        title: Text("Budget Planner", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black)),

        actions: [

          Container(

            margin: const EdgeInsets.only(right: 15),

            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),

            child: DropdownButtonHideUnderline(

              child: DropdownButton<String>(

                value: selectedCurrency,

                items: ["USD", "INR", "EUR"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),

                onChanged: (val) {

                  setState(() => selectedCurrency = val!);

                  _recalculateTotals(); // 🐛 FIX 7: Recalculate totals every time currency changes

                  _saveDataToFirebase();

                },

              ),

            ),

          )

        ],

      ),



      body: SingleChildScrollView(

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          GestureDetector(

            onTap: _editTotalBudgetDialog,

            child: Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [

                BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10)

              ]),

              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Stack(alignment: Alignment.center, children: [

                  SizedBox(

                    height: 80, width: 80,

                    // Use totalBudgetDisplay for ratio calculation

                    child: CircularProgressIndicator(

                      value: spent / (totalBudgetDisplay == 0 ? 1 : totalBudgetDisplay).toDouble() > 1

                              ? 1 : spent / (totalBudgetDisplay == 0 ? 1 : totalBudgetDisplay).toDouble(),

                      strokeWidth: 10,

                      backgroundColor: Colors.grey.shade200,

                      valueColor: AlwaysStoppedAnimation(spent > totalBudgetDisplay ? Colors.red : const Color(0xFFE67E22)),

                    ),

                  ),

                  Text("${totalBudgetDisplay == 0 ? 0 : ((spent / totalBudgetDisplay) * 100).toStringAsFixed(0)}%", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),

                ]),

                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text("Total Budget", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),

                  Text("$currencySymbol${totalBudgetDisplay.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),

                  const SizedBox(height: 8),

                  Text("Spent: $currencySymbol${spent.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),

                  Text("Remaining: $currencySymbol${totalRemaining.toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: totalRemaining < 0 ? Colors.red : Colors.green)),

                ]),

              ]),

            ),

          ),

          const SizedBox(height: 25),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text("Categories", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),

            IconButton(onPressed: _addCategoryDialog, icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE67E22)))

          ]),

          const SizedBox(height: 10),

          SizedBox(

            height: 130,

            child: ListView.separated(

              scrollDirection: Axis.horizontal,

              itemCount: categories.length,

              separatorBuilder: (_, __) => const SizedBox(width: 12),

              itemBuilder: (context, i) {

                final cat = categories[i];

                return Stack(children: [

                  Container(

                    width: 150,

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(color: cat["color"], borderRadius: BorderRadius.circular(20)),

                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Icon(cat["icon"], color: Colors.white, size: 30),

                      const SizedBox(height: 10),

                      Text(cat["name"], style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),

                      // 🐛 FIX 8: Use the calculated display limit

                      Text("$currencySymbol${(cat["limit_display"] ?? cat["limit"]).toStringAsFixed(2)}", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),

                    ]),

                  ),

                  Positioned(

                    top: 4,

                    right: 4,

                    child: InkWell(

                      onTap: () => _deleteCategory(i),

                      child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.delete, size: 16, color: Colors.white)),

                    ),

                  ),

                ]);

              },

            ),

          ),

          const SizedBox(height: 25),

          Text("Budget Usage", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),

          const SizedBox(height: 10),

          ListView.builder(

            physics: const NeverScrollableScrollPhysics(),

            shrinkWrap: true,

            itemCount: categories.length,

            itemBuilder: (context, index) {

              final cat = categories[index];

              // 🐛 FIX 9: Use the displayed spent and limit values for progress bar

              final displaySpent = cat["spent_display"] ?? 0.0;

              final displayLimit = cat["limit_display"] ?? 1.0;

             

              double progress = (displaySpent / (displayLimit == 0 ? 1 : displayLimit)).clamp(0.0, 1.0);

              bool overLimit = displaySpent > displayLimit;



              return Container(

                margin: const EdgeInsets.only(bottom: 15),

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),

                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)]),

                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    Row(children: [

                      Icon(cat["icon"], color: const Color(0xFFE67E22)),

                      const SizedBox(width: 10),

                      Text(cat["name"], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),

                    ]),

                    // 🐛 FIX 10: Display the calculated spent/limit amounts

                    Text("$currencySymbol${displaySpent.toStringAsFixed(2)} / $currencySymbol${displayLimit.toStringAsFixed(2)}",

                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),

                  ]),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(

                    value: progress,

                    minHeight: 8,

                    backgroundColor: Colors.grey.shade200,

                    borderRadius: BorderRadius.circular(8),

                    valueColor: AlwaysStoppedAnimation(overLimit ? Colors.red : const Color(0xFFE67E22)),

                  ),

                  Align(

                    alignment: Alignment.centerRight,

                    child: TextButton(onPressed: () => _addExpenseDialog(index), child: const Text("Add Expense")),

                  )

                ]),

              );

            },

          ),

        ]),

      ),

    );

  }

}