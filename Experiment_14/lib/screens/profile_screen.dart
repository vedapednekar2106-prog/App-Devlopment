// ==================== lib/screens/profile_screen.dart ====================
// FINAL VERSION — MULTI-ADMIN + SIGN OUT FIX + PREMIUM GUEST FIX + PREMIUM REFRESH FIX

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'account_settings_screen.dart';
import 'notifications_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'admin_panel_screen.dart';
import 'premium_screen.dart';
import 'login_screen.dart';

// 🟢 MULTIPLE ADMIN EMAILS
const adminEmails = [
  'wanderlist.admin@gmail.com',
  'vpg@gmail.com',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String displayName = "";
  String username = "";
  int visitedCount = 0;
  int bucketCount = 0;
  bool loading = true;
  bool isAdmin = false;
  bool isPremium = false;

  bool _upgradeStatusChanged = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ====================== LOAD PROFILE ======================
  Future<void> _loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final uid = user.uid;
    final userDoc = await _firestore.collection("users").doc(uid).get();

    isAdmin = adminEmails.contains(user.email);

    if (userDoc.exists) {
      final data = userDoc.data()!;
      displayName = data["displayName"] ?? "Your Name";
      username = data["username"] ?? "@username";
      isPremium = data["isPremium"] ?? false;
    }

    final bucketSnap = await _firestore
        .collection("users")
        .doc(uid)
        .collection("bucketList")
        .get();

    bucketCount = bucketSnap.docs.length;
    visitedCount = bucketSnap.docs.where((d) => d.data()["visited"] == true).length;

    setState(() => loading = false);
  }

  // ====================== PREMIUM FIX (UPDATED) ======================
  void _navigateToPremium() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final userDoc = await _firestore.collection("users").doc(uid).get();
    final email = userDoc.data()?["email"] ?? "";

    // 🔥 TRUE GUEST DETECTION
    final bool isGuest = email.startsWith("guest_");

    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign in to unlock premium features."),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      return;
    }

    // ⭐ WAIT FOR PREMIUM SCREEN TO RETURN RESULT
    final upgraded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );

    // ⭐ PREMIUM PURCHASE SUCCESS → REFRESH PROFILE AND PROPAGATE RESULT
    if (upgraded == true) {
      await _loadProfile();
      setState(() {});
      // Return true so the caller (HomeScreen) can refresh screens
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }
  }

  // ====================== SIGN OUT CONFIRM ======================
  void _signOutConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sign Out?"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);

              final uid = _auth.currentUser?.uid;
              if (uid != null) {
                await _firestore.collection("users").doc(uid).set({
                  'isPremium': FieldValue.delete(),
                  'isAdmin': FieldValue.delete(),
                }, SetOptions(merge: true));
              }

              await _auth.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF6EE),
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _upgradeStatusChanged);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF6EE),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 35),
              Text("Profile",
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown)),
              const SizedBox(height: 25),

              // ====================== PROFILE CARD ======================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.orange.shade200,
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(displayName,
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: _editName,
                          child: const Icon(Icons.edit,
                              size: 18, color: Colors.orange),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _editUsername,
                      child: Text(
                        username,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          _statBox("Visited", visitedCount, Icons.check_circle),
                          const SizedBox(width: 14),
                          _statBox("Wishlist", bucketCount, Icons.favorite),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _settingsTile(Icons.lock_outline, "Account Settings",
                  const AccountSettingsScreen()),
              _settingsTile(Icons.notifications_none, "Notifications",
                  const NotificationsScreen()),
              _settingsTile(Icons.privacy_tip_outlined, "Privacy Policy",
                  const PrivacyPolicyScreen()),
              _settingsTile(Icons.help_outline, "Help & Support",
                  const HelpSupportScreen()),

              if (isAdmin)
                _settingsTile(Icons.admin_panel_settings, "Admin Panel",
                    const AdminPanelScreen()),

              const SizedBox(height: 15),

              // ====================== PREMIUM BUTTON ======================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 22),
                    label: Text(
                      isPremium ? "Premium Member" : "Go Premium",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPremium
                          ? Colors.green.shade400
                          : const Color(0xFFE67E22),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: isPremium ? null : _navigateToPremium,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ====================== SIGN OUT ======================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signOutConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text("Sign Out",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== HELPERS ======================
  void _editName() {
    TextEditingController controller =
        TextEditingController(text: displayName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String newName = controller.text.trim();
              if (newName.isEmpty) return;

              await _firestore
                  .collection("users")
                  .doc(_auth.currentUser!.uid)
                  .update({"displayName": newName});

              setState(() => displayName = newName);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _editUsername() {
    TextEditingController controller = TextEditingController(
      text: username.startsWith("@") ? username.substring(1) : username,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: "Enter username (without @)"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String newUsername = controller.text.trim();
              if (newUsername.isEmpty) return;

              newUsername = "@$newUsername";

              await _firestore
                  .collection("users")
                  .doc(_auth.currentUser!.uid)
                  .update({"username": newUsername});

              setState(() => username = newUsername);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6EE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE67E22), size: 26),
            const SizedBox(height: 6),
            Text("$value",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, Widget screen) {
    final bool isAdminPanel = title == "Admin Panel";

    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.grey),
      onTap: () {
        if (isAdminPanel && !isAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Access Denied: Admin privileges required."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }
}
