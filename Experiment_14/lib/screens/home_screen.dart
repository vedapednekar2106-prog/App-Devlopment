// ==================== lib/screens/home_screen.dart (FINAL FEATURE INTEGRATION) ====================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens & Logic
import 'places_to_visit_screen.dart';
import 'explore_screen.dart';
import 'bucket_list_screen.dart';
import 'budget_planner_screen.dart'; 
import 'shopping_screen.dart';
import 'profile_screen.dart';
import 'premium_screen.dart';
import 'premium_lock_screen.dart'; 
// 🟢 NEW IMPORT: Travel Journal Screen
import 'travel_journal_screen.dart'; 

// Data & Reusable Functions
import 'explore_data.dart'; // Import featuredDestinations and exploreItems
import 'reusable_explore_modal.dart'; // Import showExploreModal

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _screens = [];
  bool _isLoading = true;
  bool _isPremium = false; 

  @override
  void initState() {
    super.initState();
    _loadScreens(shouldSetState: true); 
  }

  // CRITICAL: This reloads the premium status from Firestore and rebuilds the screens
  Future<void> _loadScreens({bool shouldSetState = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (shouldSetState) {
        setState(() {
          _isPremium = false;
          _isLoading = false;
          _screens = _buildScreenList(false);
        });
      }
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final isPremium = userDoc.data()?['isPremium'] ?? false;

    if (shouldSetState) {
      setState(() {
        _isPremium = isPremium; 
        _screens = _buildScreenList(isPremium);
        _isLoading = false;
      });
    } else {
      _isPremium = isPremium;
      _screens = _buildScreenList(isPremium);
    }
  }
  
  List<Widget> _buildScreenList(bool isPremium) {
    return [
      // Pass _loadScreens reference down to HomeMainContent to allow manual refresh
      HomeMainContent(
        isPremium: isPremium, 
        onPremiumUpdate: () => _loadScreens(shouldSetState: true)
      ), 
      ExploreScreen(), 
      isPremium ? const ShoppingScreen() : PremiumLockScreen(featureName: "Exclusive Shop Access"), 
      const ProfileScreen(),
    ];
  }

  // CRITICAL: Finalized logic for navigation and instant refresh
  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    if (index == 2 && !_isPremium) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _screens[index]), 
      );
      
      if (result == true) {
        await _loadScreens(shouldSetState: true); 
        setState(() => _selectedIndex = 2); 
      }
      return;
    }
    
    if (index == 1) { 
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _screens[index]), 
      );

      if (result == true) {
        await _loadScreens(shouldSetState: true); 
        setState(() => _selectedIndex = 1); 
      }
      return; 
    }

    if (index == 3) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _screens[index]),
      );

      if (result == true) {
        await _loadScreens(shouldSetState: true);
        setState(() => _selectedIndex = 0);
      }
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE67E22)),
            )
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE67E22),
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Shop'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}

// ------------------- HOME MAIN CONTENT (CONVERTED TO STATEFUL FOR SEARCH) -------------------
class HomeMainContent extends StatefulWidget {
  final bool isPremium; 
  final VoidCallback onPremiumUpdate; 

  const HomeMainContent({
    super.key, 
    required this.isPremium,
    required this.onPremiumUpdate,
  });

  @override
  State<HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends State<HomeMainContent> {
  // 🟢 NEW STATE: Manage search text and filtered list
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredDestinations = featuredDestinations;
  
  @override
  void initState() {
    super.initState();
    // Initialize the filtered list with the featured destinations data
    _filteredDestinations = featuredDestinations; 
    _searchController.addListener(_filterDestinations);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDestinations);
    _searchController.dispose();
    super.dispose();
  }

  // 🟢 NEW LOGIC: Filters the destinations based on search input
  void _filterDestinations() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      // If search is empty, revert to the curated featured list
      setState(() {
        _filteredDestinations = featuredDestinations;
      });
    } else {
      // Search across the full list of exploreItems
      setState(() {
        _filteredDestinations = exploreItems 
            .where((item) => item["title"]!.toLowerCase().contains(query))
            .toList()
            .cast<Map<String, String>>();
      });
    }
  }

  void _onPremiumLinkTap(BuildContext context) async {
      final result = await Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const PremiumScreen())
      );
      if (result == true) {
          widget.onPremiumUpdate(); 
      }
  }


  @override
  Widget build(BuildContext context) {
    final isPremium = widget.isPremium;
    final onPremiumUpdate = widget.onPremiumUpdate;
    
    // Determine the list title based on search state
    final isSearching = _searchController.text.isNotEmpty;
    final listTitle = isSearching ? 'Search Results (${_filteredDestinations.length})' : 'Featured Destinations';
    final listToDisplay = isSearching ? _filteredDestinations : featuredDestinations;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hi Wanderer,',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Premium Badge Tap Logic
                GestureDetector(
                  onTap: () => _onPremiumLinkTap(context), 
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isPremium ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFFFFE6C9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPremium ? Icons.star_outline : Icons.lock_outline,
                      color: isPremium ? const Color(0xFFD4AF37) : const Color(0xFFE67E22),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ready for your next\nadventure?',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 18),
            
            // 🟢 Premium Link above Search Bar (THEME COLOR APPLIED)
            if (!isPremium)
                GestureDetector(
                    onTap: () => _onPremiumLinkTap(context),
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                            children: [
                                // Theme color applied
                                const Icon(Icons.star_rounded, size: 18, color: Color(0xFFE67E22)), 
                                const SizedBox(width: 5),
                                Text(
                                    'Unlock Premium Access', 
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        // Theme color applied
                                        color: const Color(0xFFE67E22), 
                                    ),
                                ),
                                // Theme color applied
                                const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFE67E22)), 
                            ],
                        ),
                    ),
                ),

            // 🟢 MODIFIED: Search Bar uses controller
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController, // 🟢 Use controller
                decoration: const InputDecoration(
                  hintText: 'Search for a destination...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // 🟢 DYNAMIC TITLE
                  listTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 🟢 MODIFIED: Display the filtered list
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: listToDisplay.map((item) { // 🟢 Use filtered list
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () async { 
                        final result = await showExploreModal(
                            context: context, 
                            item: item, 
                            isPremium: isPremium,
                            featureName: "Advanced Explore Content" 
                        );
                        
                        if (result == true) {
                          onPremiumUpdate(); 
                        }
                      },
                      child: DestinationCard(
                        imagePath: item["image"]!, 
                        title: item["title"]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // 🟢 Display message if search yields no results
            if (isSearching && listToDisplay.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'No destinations found matching your search.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
              ),


            const SizedBox(height: 30),

            // Home Buttons (Unchanged)
            HomeButton(
              icon: Icons.place_outlined,
              label: 'Places to Visit',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PlacesToVisitScreen()));
              },
            ),
            const SizedBox(height: 12),

            HomeButton(
              icon: Icons.checklist_rtl,
              label: 'Bucket List',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BucketListScreen()));
              },
            ),
            const SizedBox(height: 12),

            HomeButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Budget Planner',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        // FIX: Explicitly pass the isPremium parameter
                        builder: (_) => BudgetPlannerScreen(isPremium: isPremium))); 
              },
            ),
            // 🟢 NEW BUTTON: Travel Journal
            const SizedBox(height: 12),
            HomeButton(
              icon: Icons.book_outlined,
              label: 'Travel Journal',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TravelJournalScreen())); // 🟢 Navigates to new screen
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ------------------- Destination Card & Home Button (Unchanged) -------------------
class DestinationCard extends StatelessWidget {
  final String imagePath;
  final String title;

  const DestinationCard({required this.imagePath, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              imagePath,
              height: 120,
              width: 160,
              fit: BoxFit.cover,
               errorBuilder: (context, error, stackTrace) {
                return Container(
                    height: 120,
                    width: 160,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0E0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE67E22)),
            const SizedBox(width: 15),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}