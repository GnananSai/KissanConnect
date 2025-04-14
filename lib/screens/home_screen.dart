import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'post_query_screen.dart';
import 'query_list_screen.dart';
import 'scan_screen.dart'; // Ensure this screen is implemented for crop detection

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  /// Screens list (moved inside build to use updated state)
  List<Widget> get _screens => [
        QueryListScreen(), // Home (Query List)
        ScanScreen(),      // Scan (Crop Detection)
        PostQueryScreen(
          onPostComplete: () {
            setState(() {
              _selectedIndex = 0; // Switch to Query List tab after posting
            });
          },
        ),
      ];

  void _onItemTapped(int index) {
    if (index == 3) { // Logout action
      _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _screens[_selectedIndex], // Now properly updates the widget
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Post Query',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}
