// ==================== lib/screens/premium_lock_screen.dart (DYNAMIC CONTENT FIX) ====================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'premium_screen.dart'; 

class PremiumLockScreen extends StatelessWidget {
  // 🟢 NEW: Accept a parameter to specify the feature being locked
  final String featureName; 

  const PremiumLockScreen({
    super.key,
    this.featureName = "Premium Features" // Default value for safety
  });

  // Helper function to dynamically generate the subtitle text
  String _getSubtitle(String feature) {
    if (feature == "Exclusive Shop Access") {
      return "The WanderList Store is reserved for Premium members.\nUnlock now to access exclusive gear and discounts!";
    }
    if (feature == "Advanced Explore Content") {
      return "Access to advanced destination content, detailed itineraries, and local guides is reserved for Premium members.";
    }
    // Default message
    return "This $feature is available only for Premium members.\nUnlock now to get full access!";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 90, color: Colors.orange),
              const SizedBox(height: 25),
              // 🟢 DYNAMIC TITLE
              Text(featureName, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.brown)),
              const SizedBox(height: 12),
              // 🟢 DYNAMIC SUBTITLE
              Text(_getSubtitle(featureName), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700], height: 1.4)),
              const SizedBox(height: 35),
              
              ElevatedButton.icon(
                // 🐛 FIX: Listen for the result from PremiumScreen
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  ).then((value) {
                    // If upgrade successful, we pop the LockScreen and return true 
                    // to the parent (HomeScreen) to trigger a rebuild.
                    if (value == true) {
                      Navigator.pop(context, true); 
                    }
                  });
                },
                icon: const Icon(Icons.star_rounded, color: Colors.white),
                label: Text("Go Premium", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Simply pop the current lock screen. 
                  Navigator.pop(context);
                },
                child: Text("Back", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
// ==================== END premium_lock_screen.dart ====================