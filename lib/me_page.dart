import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    // เช็คสถานะว่าล็อกอินหรือไม่ ถ้าล็อกอินแล้วให้แสดง ProfilePage ถ้ายังไม่ให้แสดง MePage
    return isLoggedIn
        ? const ProfilePage() // แสดง ProfilePage ถ้าล็อกอินแล้ว
        : LoginPage();
  }
}
