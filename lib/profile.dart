import 'dart:convert'; // ใช้สำหรับการแปลง Base64
import 'dart:typed_data'; // สำหรับการจัดการกับ ByteData
import 'package:flutter/material.dart';
import 'package:rubhew/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:http/http.dart' as http; // ใช้สำหรับการดึงข้อมูลจาก API
import 'package:rubhew/main.dart'; // Import MainScreen หรือหน้าแรกที่ต้องการ

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  String email = "";
  String phone = "";
  String birthDate = "";
  String gender = "";
  String address = "";
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    _getProfile(); // เรียกใช้เมื่อตอนเริ่มต้น
  }

  Future<void> _getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // ดึง token ที่เก็บไว้

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/profiles/me'), // เปลี่ยน URL ของ API ที่ถูกต้อง
        headers: {
          'Authorization': 'Bearer $token', // ส่ง token ไปด้วยใน header
        },
      );

      if (response.statusCode == 200) {
        // แปลงข้อมูล JSON เป็น Map
        final data = json.decode(response.body);
        print(data);
        setState(() {
          gender = data['gender'];
          address = data['address'];
          phone = data['phoneNumber'];
          birthDate = data['birthday'];
          profileImage = data['profile_image'];
        });
      } else {
        // Handle error
        print("Failed to load profile data");
      }
    } catch (e) {
      print("Error: $e");
    }

    try {
      final responseUser = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/users/me'), // เปลี่ยน URL ของ API ที่ถูกต้อง
        headers: {
          'Authorization': 'Bearer $token', // ส่ง token ไปด้วยใน header
        },
      );

      if (responseUser.statusCode == 200) {
        // แปลงข้อมูล JSON เป็น Map
        final data = json.decode(responseUser.body);
        print(data);
        setState(() {
          email = data['email'];
          username = data['username'];
        });
      } else {
        // Handle error
        print("Failed to load profile data");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // ลบ token เมื่อ logout

    // นำผู้ใช้กลับไปยังหน้าหลักหรือหน้าล็อกอิน
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false, // ลบทุกหน้าก่อนหน้านี้
    );
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่า profileImage มีค่า base64 หรือไม่
    Uint8List? imageBytes;
    if (profileImage.isNotEmpty) {
      imageBytes =
          base64Decode(profileImage.split(',').last); // แปลง base64 เป็นไบต์
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Page',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF219EBC),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Help icon functionality
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF219EBC), Color(0xFF8ECAE6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Image Section
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageBytes != null
                    ? MemoryImage(
                        imageBytes) // แสดงภาพจาก Base64 ที่ถูกแปลงแล้ว
                    : null, // ถ้าไม่มี base64 ให้แสดงเป็นไอคอน
                child: imageBytes == null
                    ? Icon(Icons.person,
                        size: 60,
                        color: Colors.grey[800]) // ถ้าไม่มีภาพให้แสดงไอคอน
                    : null,
              ),
              const SizedBox(height: 20),

              // Profile Details
              ProfileDetailRow(
                icon: Icons.person,
                label: 'Username    ',
                value: username, // แสดงข้อมูลที่ดึงมา
              ),
              ProfileDetailRow(
                icon: Icons.male,
                label: 'Gender       ',
                value: gender, // แสดงข้อมูลที่ดึงมา
              ),
              ProfileDetailRow(
                icon: Icons.calendar_today,
                label: 'Birth Date   ',
                value: birthDate, // แสดงข้อมูลที่ดึงมา
              ),
              ProfileDetailRow(
                icon: Icons.phone,
                label: 'Tel No        ',
                value: phone, // แสดงข้อมูลที่ดึงมา
              ),
              ProfileDetailRow(
                icon: Icons.email,
                label: 'Email         ',
                value: email, // แสดงข้อมูลที่ดึงมา
              ),
              ProfileDetailRow(
                icon: Icons.home,
                label: 'Address     ',
                value: address, // แสดงข้อมูลที่ดึงมา
              ),
              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 184, 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Edit Profile',
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18)),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _logout(context); // เรียกใช้ฟังก์ชัน logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 54, 54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Logout',
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // สีพื้นหลัง
          borderRadius: BorderRadius.circular(10), // ทำให้ขอบกล่องโค้งมน
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // สีเงา
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // การเยื้องของเงา
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
