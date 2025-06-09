import 'package:flutter/material.dart';
import 'fragment/home.dart';
import 'fragment/likes.dart';
import 'fragment/save.dart';
import 'fragment/profile.dart';
import 'fragment/settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _fragments;
  String? _loggedInUser;
  int? _userId; // Add this line

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    if (args.containsKey('username')) {
      _loggedInUser = args['username'];
      _userId = args['userId']; // Add this line
    }

    // Update fragments with userId
    _fragments = [
      HomeFragment(username: _loggedInUser ?? 'Guest', userId: _userId ?? 0),
      LikesFragment(userId: _userId ?? 0),
      SaveFragment(userId: _userId ?? 0),
      ProfileFragment(username: _loggedInUser ?? 'Guest'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.purpleAccent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/asik.jpeg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _loggedInUser != null
                        ? 'Logged in as: $_loggedInUser'
                        : 'Kelihatan Asik yh',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            // ListTile Profile bisa dihapus dari sini karena sudah ada di bottom nav
            // ListTile( ... ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsFragment(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
            color: Colors.black87), // Agar ikon drawer terlihat
        title:
            const Text('Online Shop', style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black87),
            onPressed: () {
              // TODO: Implement cart
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _fragments,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Likes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Save',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
