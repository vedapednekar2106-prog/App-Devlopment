// lib/screens/admin_panel_screen.dart
// ==================== ADMIN PANEL (dedupe + toggle fixed + guest delete kept) ====================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot>? _usersStream;
  bool _isAdminVerified = false;
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.toLowerCase();
      });
    });
    _verifyAdminStatusAndStartStream();
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _verifyAdminStatusAndStartStream() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        // stream all users; we'll filter & dedupe client-side
        _usersStream = _firestore.collection('users').snapshots();
        if (mounted) {
          setState(() {
            _isAdminVerified = true;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Robust toggle helper (merge to avoid clobbering other fields)
  Future<void> _togglePremiumStatus(String userId, bool currentStatus) async {
    final newStatus = !currentStatus;
    try {
      await _firestore.collection('users').doc(userId).set({
        'isPremium': newStatus,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("User set to ${newStatus ? 'PREMIUM' : 'STANDARD'}"),
          backgroundColor: newStatus ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e")),
      );
    }
  }

  // Delete guest users button (unchanged)
  Future<void> _deleteGuestUsers() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: const Text(
                "Are you sure you want to delete ALL anonymous guest user data? This action is permanent."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("DELETE ALL",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Processing guest deletion...")));

    try {
      final guestSnapshot = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: 'guest_')
          .where('email', isLessThan: 'guest_z')
          .get();

      if (guestSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No guest users found.")));
        return;
      }

      final batch = _firestore.batch();
      for (var doc in guestSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Successfully deleted ${guestSnapshot.docs.length} guest user(s)."),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting guests: $e")),
      );
    }
  }

  Widget _buildUserTile(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>? ?? {};
    final userId = userDoc.id;
    final email = (data['email'] ?? 'Unknown').toString();
    final displayName = (data['displayName'] ?? 'User').toString();
    final isPremium = data['isPremium'] == true;
    final isCurrentUser = userId == _auth.currentUser?.uid;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPremium ? Colors.amber : Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isPremium ? const Color(0xFFE67E22) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPremium ? 'Premium' : 'Standard',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            // Use the robust toggle helper (disabled for current admin)
            Switch(
              value: isPremium,
              onChanged: isCurrentUser
                  ? null
                  : (val) => _togglePremiumStatus(userId, isPremium),
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.shade100,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE67E22))));
    }

    if (_auth.currentUser == null || !_isAdminVerified) {
      return const Scaffold(
          body: Center(child: Text("Access Denied: Admin privileges required.")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Admin Panel",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services, color: Colors.red),
            onPressed: _deleteGuestUsers,
            tooltip: "Delete All Guest Users",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Management Dashboard",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by Name or Email...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchTerm = "");
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _usersStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("FATAL ERROR: Could not list users. Error: ${snapshot.error}"));
                  }

                  final allUsers = snapshot.data?.docs ?? [];

                  // Filter invalid/deleted
                  final validDocs = allUsers.where((d) {
                    final data = d.data() as Map<String, dynamic>?; 
                    if (data == null) return false;
                    if (data['deleted'] == true) return false;
                    if (data['email'] == null) return false;
                    return true;
                  }).toList();

                  // Dedupe by email (lowercased)
                  final Map<String, DocumentSnapshot> latestByEmail = {};
                  for (var doc in validDocs) {
                    final data = doc.data() as Map<String, dynamic>?;
                    final email = (data?['email'] as String?)?.toLowerCase() ?? '';
                    if (email.isEmpty) continue;
                    if (!latestByEmail.containsKey(email)) {
                      latestByEmail[email] = doc;
                    }
                  }

                  final deduped = latestByEmail.values.toList();

                  // Search filter
                  final filtered = deduped.where((userDoc) {
                    if (_searchTerm.isEmpty) return true;
                    final data = userDoc.data() as Map<String, dynamic>?;
                    final email = (data?['email'] as String?)?.toLowerCase() ?? '';
                    final name = (data?['displayName'] as String?)?.toLowerCase() ?? '';
                    return email.contains(_searchTerm) || name.contains(_searchTerm);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(child: Text(_searchTerm.isNotEmpty ? "No users match your search." : "No users found."));
                  }

                  filtered.sort((a, b) {
                    final ad = (a.data() as Map<String, dynamic>?)?['displayName'] ?? '';
                    final bd = (b.data() as Map<String, dynamic>?)?['displayName'] ?? '';
                    return ad.toString().toLowerCase().compareTo(bd.toString().toLowerCase());
                  });

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildUserTile(filtered[index]);
                    },
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
