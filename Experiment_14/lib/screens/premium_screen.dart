// ==================== lib/screens/premium_screen.dart (FINAL GUEST BLOCK FIX) ====================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  // 🟢 Dummy function to simulate a successful purchase and status update
  Future<bool> _processUpgrade(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      // 🟢 CRITICAL FIX: Block anonymous (guest) users from purchasing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please sign in or register to purchase Premium!"),
          backgroundColor: Colors.orange,
        ),
      );
      // We do not return true, so the parent screen does not try to refresh.
      return false; 
    }
    
    final uid = user.uid;

    // --- 1. SIMULATE PURCHASE/SET PREMIUM FLAG ---
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'isPremium': true},
      SetOptions(merge: true),
    );

    // --- 2. SUCCESS FEEDBACK ---
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Upgrade Successful! Welcome to Premium! 🎉"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Return true to signal the parent screen (Home/Explore) to refresh
    return true; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EB), // Light cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F2EB),
        elevation: 0,
        title: Text("WanderList Premium", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.black87)),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // --- STAR ICON (Sizing reduced) ---
            Icon(Icons.star_rounded, size: 80, color: Colors.amber.shade600),
            
            const SizedBox(height: 20),

            Text(
              "Unlock Your Full Adventure Potential",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.brown[800],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- FEATURE LIST CARDS ---
            
            // 1. Explore Content Lock
            _buildFeatureTile(
              Icons.explore, 
              "Advanced Destination Guides", 
              "Get exclusive access to detailed itineraries, local hidden gems, and advanced map features.",
              Colors.teal,
            ),
            
            // 2. Shopping Lock
            _buildFeatureTile(
              Icons.shopping_bag_outlined, 
              "Exclusive Gear & Discounts", 
              "Unlock the entire WanderList Pro Gear Shop, special member discounts, and VIP collections.",
              const Color(0xFFE67E22), // Deep Orange
            ),
            
            // 3. Other Value-Added Feature
            _buildFeatureTile(
              Icons.sync, 
              "Secure Cloud Sync & Backup", 
              "Enjoy secure, real-time synchronization for your bucket list and budgets across all devices.",
              Colors.blue,
            ),
            
            const SizedBox(height: 40),

            // --- UPGRADE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: Text(
                  "Upgrade Now - ₹599/Year", // Placeholder pricing
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22), // Deep Orange
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                onPressed: () async {
                  final success = await _processUpgrade(context);
                  if (success) {
                    // Navigate back only if purchase succeeded (and user is not anonymous)
                    Navigator.pop(context, true); 
                  }
                },
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}