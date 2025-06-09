import 'package:flutter/material.dart';
import 'fragment/home.dart';
import 'fragment/profile.dart';
import 'fragment/settings.dart';
import 'fragment/likes.dart';
import 'fragment/save.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _fragments = [
    const HomeFragment(username: ''), // Placeholder for username
    const LikesFragment(),
    const SaveFragment(),
  ];

  String? _loggedInUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the logged-in username from the arguments
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      _loggedInUser = args; // Set the logged-in user
      _fragments[0] = HomeFragment(
        username: _loggedInUser!,
      ); // Update HomeFragment with username
    }
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
                  CircleAvatar(
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
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProfileFragment(username: _loggedInUser!),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
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
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Aplikasi Saya')),
      body: _fragments[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Likes'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Save'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
