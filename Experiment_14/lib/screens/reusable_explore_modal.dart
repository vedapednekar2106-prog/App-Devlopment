// ==================== lib/screens/reusable_explore_modal.dart (FINAL MODIFIED) ====================

import 'package:flutter/material.dart';
import 'explore_detail_screen.dart'; 
import 'premium_lock_screen.dart'; 
import 'bucket_list_screen.dart'; // To access BucketListManager
import 'explore_data.dart'; // To access categoryHighlights

/// Displays the Modal Bottom Sheet for an Explore Destination.
/// It returns `true` if the user successfully upgrades to Premium via the modal.
Future<bool?> showExploreModal({
  required BuildContext context, 
  required Map<String, String> item, 
  required bool isPremium,
  // 🟢 NEW: Accept the feature name to pass to the Lock Screen
  required String featureName, 
}) async {
  final category = item["category"]!;
  final highlights = categoryHighlights[category] ?? ["Explore the area"];
  
  // Local function to handle adding to the bucket list
  void addToBucketList(Map<String, dynamic> placeItem, BuildContext modalContext) {
    final manager = BucketListManager();
    final exists = manager.places.any((p) => p["name"] == placeItem["title"]);

    if (exists) {
      Navigator.pop(modalContext);
      ScaffoldMessenger.of(modalContext).showSnackBar(
        SnackBar(content: Text("${placeItem["title"]} is already in your bucket list")),
      );
      return;
    }

    manager.addPlace({
      "name": placeItem["title"],
      "description": placeItem["subtitle"],
      "image": placeItem["image"],
      "visited": false,
      "favorite": false,
    });

    Navigator.pop(modalContext);
    ScaffoldMessenger.of(modalContext).showSnackBar(
      SnackBar(content: Text("${placeItem["title"]} added to your bucket list!")),
    );
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item["image"]!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(item["title"]!,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item["subtitle"]!,
                style: const TextStyle(
                    fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            const Text("Highlights:",
                style:
                    TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...highlights.map(
              (h) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $h"),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Discover Button with Lock Logic
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (isPremium) {
                    Navigator.pop(context); // Close modal first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExploreDetailScreen(place: item),
                      ),
                    );
                  } else {
                    // Navigate to PremiumLockScreen and wait for result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        // 🟢 PASS FEATURE NAME TO LOCK SCREEN
                        builder: (_) => PremiumLockScreen(featureName: featureName),
                      ),
                    );
                    
                    // If the result is true (successful upgrade), pass that signal back
                    if (result == true) {
                        Navigator.pop(context, true); 
                    }
                  }
                },
                child: const Text("Discover",
                    style: TextStyle(
                        fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Add to Bucket List
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => addToBucketList(item, context),
                child: const Text("Add to Bucket List",
                    style: TextStyle(
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
// ==================== END reusable_explore_modal.dart ====================