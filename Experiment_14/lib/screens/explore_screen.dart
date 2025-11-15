// ==================== lib/screens/explore_screen.dart (FINAL PREMIUM FIX) ====================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import data and reusable modal function
import 'explore_data.dart'; 
import 'reusable_explore_modal.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int selectedFilter = 0;

  bool _isPremium = false; 
  bool _loading = true;

  final List<String> filters = [
    "All", "Trending", "Hidden Gems", "Adventure", "Luxury", 
    "Beaches & Mountains", "Historical", "Most Visited"
  ];
  
  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _isPremium = doc.data()!['isPremium'] ?? false;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
      );
    }

    final filteredItems = selectedFilter == 0
        ? exploreItems // Using imported global data
        : exploreItems
            .where((item) => item["category"] == filters[selectedFilter])
            .toList();

    return Builder(
      builder: (scaffoldContext) => Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Explore",
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                "Explore the World 🌍",
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Discover breathtaking destinations, adventures, and hidden gems.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // 🔹 Filters (Unchanged)
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedFilter;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFilter = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF8C00)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF8C00)
                                  : Colors.grey.shade300),
                        ),
                        child: Text(
                          filters[index],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Explore Cards (Now using reusable modal)
              ...filteredItems.map(
                (item) => GestureDetector(
                  onTap: () async {
                    // 🟢 PASS FEATURE NAME: Use the modal to show the lock screen
                    final result = await showExploreModal( 
                      context: context, 
                      item: item, 
                      isPremium: _isPremium,
                      featureName: "Advanced Explore Content", // <--- NEW PARAMETER
                    );
                    
                    // CRITICAL FIX: If modal returns true (successful upgrade), 
                    // pop the current screen (Explore tab) and signal true to Home Screen.
                    if (result == true) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, true); 
                      }
                    }
                  }, 
                  child: ExploreCard(
                    title: item["title"]!,
                    subtitle: item["subtitle"]!,
                    imageUrl: item["image"]!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;

  const ExploreCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Image.asset(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50));
              },
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}