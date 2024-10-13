import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rubhew/add_item_page.dart';
import 'package:rubhew/follower_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({super.key});

  @override
  _MyPostPageState createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  List<dynamic> items = []; // Store fetched items here

  @override
  void initState() {
    super.initState();
    fetchUserItems(); // Fetch items when the page loads
  }

  Future<void> fetchUserItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/items/my-items/'), // Adjust your API URL here
        headers: {
          'Authorization': 'Bearer $token', // Replace with your auth token
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body); // Decode and save the items
        });
      } else {
        print('Failed to load items');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Post',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyFollowerPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPostPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar remains unchanged
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search my items',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),

          // Grid of Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  String status =
                      item['status'] ?? 'Unknown'; // รับสถานะจาก item
                  Color statusColor;

                  // กำหนดสีพื้นหลังตามสถานะ
                  switch (status.toLowerCase()) {
                    case 'available':
                      statusColor = const Color(0xFF73EC8B); // สีเขียว
                      break;
                    case 'sold':
                      statusColor = const Color(0xFF982B1C); // สีแดง
                      break;
                    case 'progress':
                      statusColor = const Color(0xFFFFB22C); // สีเหลือง
                      break;
                    default:
                      statusColor =
                          Colors.black54; // สีเริ่มต้นถ้าไม่ตรงกับเงื่อนไข
                  }

                  return Stack(
                    children: [
                      // การ์ดรายการที่มีภาพ
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: item['images'] != null &&
                                  item['images'].isNotEmpty
                              ? DecorationImage(
                                  image:
                                      NetworkImage(item['images'][0]), // ภาพแรก
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage(
                                      'assets/NoImage.png'), // ภาพเริ่มต้น
                                  fit: BoxFit.cover,
                                ),
                        ),
                        alignment: Alignment.bottomCenter,
                      ),
                      // ไอคอนแก้ไข
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            // จัดการกับการแก้ไข
                          },
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                      // พื้นหลังสถานะครอบคลุมทั้งการ์ด
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: statusColor
                              .withOpacity(0.7), // สีพื้นหลังตามสถานะ
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Available', // สามารถแก้ไขเป็นข้อความที่คุณต้องการแสดง
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center, // จัดกลางข้อความ
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
