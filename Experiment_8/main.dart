import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabs + Drawer Example',
      theme: _isDarkMode
          ? ThemeData.dark()
          : ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(
        onThemeToggle: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = "";

  final List<String> _items = [
    "Apple",
    "Banana",
    "Mango",
    "Orange",
    "Pineapple",
    "Strawberry",
    "Grapes"
  ];

  @override
  Widget build(BuildContext context) {
    // Pages
    final List<Widget> _pages = [
      const Center(
          child: Text("🏠 Home Page", style: TextStyle(fontSize: 22))),

      // Search Page with filter
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search items",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: _items
                  .where((item) =>
                  item.toLowerCase().contains(_searchQuery))
                  .map((item) => ListTile(
                leading: const Icon(Icons.local_grocery_store),
                title: Text(item),
              ))
                  .toList(),
            ),
          )
        ],
      ),

      // Settings Page with Dark Mode toggle
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("⚙️ Settings Page",
                style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onThemeToggle,
              icon: const Icon(Icons.dark_mode),
              label: const Text("Toggle Dark Mode"),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Tabs + Drawer App")),

      // ✅ Drawer Navigation
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Veda Pednekar"),
              accountEmail: Text("vedapednekar@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
              decoration: BoxDecoration(color: Colors.teal),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),

      // ✅ Tab-based Navigation (BottomNavigationBar)
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),

      // ✅ Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("FAB Clicked!")),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: const Center(
        child: Text("👤 This is your profile!",
            style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
