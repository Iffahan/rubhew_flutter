import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'profile.dart'; // Import หน้า ProfilePage ที่ต้องการนำไป

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // ฟังก์ชันเพื่อตรวจสอบสถานะการล็อกอิน
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // ดึง token ที่บันทึกไว้

    setState(() {
      isLoggedIn = token != null; // ถ้า token ไม่เป็น null ถือว่าล็อกอินแล้ว
      if (isLoggedIn) {
        // ถ้าล็อกอินแล้วให้โยงไปยังหน้า ProfilePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality here
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Implement add functionality here
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoggedIn
                ? const Text("Redirecting to Profile...")
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
