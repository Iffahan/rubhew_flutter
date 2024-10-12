import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'feed_page.dart';
import 'notification_page.dart';
import 'me_page.dart';
import 'item_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.promptTextTheme(), // Set GoogleFonts
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _hasToken = false; // Track if token exists

  // Pages that can be shown based on token
  static const List<Widget> _basePages = <Widget>[
    FeedPage(),
    MePage(),
  ];

  // Pages with MyPostPage when token is available
  static const List<Widget> _pagesWithMyPost = <Widget>[
    FeedPage(),
    MyPostPage(),
    NotificationPage(),
    MePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkToken(); // Check token when screen is initialized
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      _hasToken = token != null; // If token exists, _hasToken is true
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Select pages based on token existence
    List<Widget> pages = _hasToken ? _pagesWithMyPost : _basePages;

    return Scaffold(
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          if (_hasToken)
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'My Post',
            ),
          if (_hasToken)
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Color of selected icon and text
        unselectedItemColor: Colors.grey, // Color of unselected icon and text
        onTap: _onItemTapped,
        backgroundColor:
            Colors.white, // Ensures the background color is visible
      ),
    );
  }
}
