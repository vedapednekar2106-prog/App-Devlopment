// ==================== lib/screens/travel_journal_screen.dart (DEFINITIVE FUNCTIONALITY FIX) ====================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 
import 'dart:async';

class TravelJournalScreen extends StatefulWidget {
  const TravelJournalScreen({super.key});

  @override
  State<TravelJournalScreen> createState() => _TravelJournalScreenState();
}

class _TravelJournalScreenState extends State<TravelJournalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<QuerySnapshot>? _journalStream;

  @override
  void initState() {
    super.initState();
    _startJournalStream();
  }
  
  void _startJournalStream() {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _journalStream = _firestore
          .collection('users')
          .doc(uid)
          .collection('journalEntries')
          .orderBy('date', descending: true)
          .snapshots();
    }
  }

  // ------------------- CRUD Functions (unchanged) -------------------

  Future<void> _addEntry(String title, String notes, DateTime date) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || title.isEmpty || notes.isEmpty) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('journalEntries')
          .add({
        'title': title,
        'notes': notes,
        'date': Timestamp.fromDate(date),
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Journal entry saved!"), duration: Duration(milliseconds: 700)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving entry: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteEntry(String docId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('journalEntries')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entry deleted."), duration: Duration(milliseconds: 700)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting entry: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // 🟢 FUNCTION: Show full entry content when card is tapped (unchanged)
  void _showFullEntryDialog(Map<String, dynamic> data) {
    final dateTimestamp = data['date'] as Timestamp?;
    final dateString = dateTimestamp != null 
        ? DateFormat('MMM dd, yyyy').format(dateTimestamp.toDate())
        : 'No Date';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(data['title'] ?? 'Untitled Entry', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Date: $dateString", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 10),
              // Display full notes here
              Text(data['notes'] ?? 'No notes...', style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }

  // ------------------- Dialogs (unchanged) -------------------
  void _showAddEntryDialog() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please sign in to add journal entries.")),
        );
        return;
    }
    
    String title = "";
    String notes = "";
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("New Journal Entry", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "Title"),
                    onChanged: (val) => title = val.trim(),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "What did you do?"),
                    maxLines: 4,
                    onChanged: (val) => notes = val.trim(),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}"),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Color(0xFFE67E22)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setInnerState(() => selectedDate = date);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
                onPressed: () {
                  if (title.isNotEmpty && notes.isNotEmpty) {
                    _addEntry(title, notes, selectedDate);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Save Entry"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------- UI -------------------

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return const Center(child: Text("Please sign in to view your journal."));
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        title: Text("Travel Journal", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.brown[800])),
        backgroundColor: const Color(0xFFFDF8F3),
        elevation: 0,
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: _journalStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading journal. Please check your internet connection or try restarting the app.", style: GoogleFonts.poppins(color: Colors.red)));
          }
          
          final entries = snapshot.data?.docs ?? [];
          
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Start your first adventure entry!", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final data = entry.data() as Map<String, dynamic>;
              final dateTimestamp = data['date'] as Timestamp?;
              final dateString = dateTimestamp != null 
                  ? DateFormat('MMM dd, yyyy').format(dateTimestamp.toDate())
                  : 'No Date';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                // 🟢 FIX 4: GestureDetector wraps the Card to make the whole area tappable
                child: GestureDetector( 
                  onTap: () => _showFullEntryDialog(data), // 👈 Tap action is here!
                  child: Padding(
                    // Reduced vertical padding slightly for better fit
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), 
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Entry Text Content ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'] ?? 'Untitled Entry', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 4),
                              // Notes displayed with restricted max lines
                              Text(data['notes'] ?? 'No notes...', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)), // INCREASED maxLines to 3
                            ],
                          ),
                        ),
                        
                        // --- Date and Delete Button ---
                        SizedBox(
                          width: 60, // Constrain width slightly smaller
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(dateString, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              // Removed vertical space (height: 4)
                              IconButton(
                                // FIX: Smaller icon size for better fit
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                onPressed: () => _deleteEntry(entry.id),
                                padding: EdgeInsets.zero, // Remove default padding
                                constraints: const BoxConstraints(minWidth: 30, minHeight: 30), // Minimum size constraints
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}