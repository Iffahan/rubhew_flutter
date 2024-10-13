import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyFollowerPage extends StatefulWidget {
  const MyFollowerPage({super.key});

  @override
  _MyFollowerPageState createState() => _MyFollowerPageState();
}

class _MyFollowerPageState extends State<MyFollowerPage> {
  List<String> categories = [];
  List<int> selectedCategoryIds = [];
  List<String> selectedCategories = [];

  List<String> tags = [];
  List<int> selectedTagIds = [];
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchTags();
    _fetchProfile(); // ดึงข้อมูลโปรไฟล์
  }

  // ฟังก์ชันเพื่อดึงข้อมูลหมวดหมู่จาก API
  Future<void> _fetchCategories() async {
    const String apiUrl = 'http://10.0.2.2:8000/categories/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data
              .map((category) => category['name_category'].toString())
              .toList();
        });
      } else {
        throw Exception('ไม่สามารถดึงข้อมูลหมวดหมู่ได้');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // ฟังก์ชันเพื่อดึงข้อมูลแท็กจาก API
  Future<void> _fetchTags() async {
    const String apiUrl = 'http://10.0.2.2:8000/tags/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          tags = data.map((tag) => tag['name_tags'].toString()).toList();
        });
      } else {
        throw Exception('ไม่สามารถดึงข้อมูลแท็กได้');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // ฟังก์ชันเพื่อดึงข้อมูลโปรไฟล์จาก API
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    const String apiUrl = 'http://10.0.2.2:8000/profiles/me';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // อัปเดตหมวดหมู่และแท็กที่เลือกโดยอ้างอิงจาก tag_following และ category_following
        setState(() {
          selectedCategoryIds = List<int>.from(data['category_following']);
          selectedTagIds = List<int>.from(data['tag_following']);
        });
      } else {
        throw Exception('ไม่สามารถดึงข้อมูลโปรไฟล์ได้');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // ฟังก์ชันเพื่ออัปเดตข้อมูลแท็กและหมวดหมู่
  Future<void> _updateFollowing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    const String apiUrl = 'http://10.0.2.2:8000/profiles/updateMyFollowing';

    final body = {
      "tag_following": selectedTagIds,
      "category_following": selectedCategoryIds,
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Updated successfully');
      } else {
        throw Exception('ไม่สามารถอัปเดตข้อมูลได้');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _updateFollowing(); // เรียกใช้ฟังก์ชันอัปเดตก่อนกลับ
            Navigator.of(context).pop(); // กลับไปยังหน้าก่อนหน้า
          },
        ),
        title: const Text(
          'My Follower',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildCategorySection(), // ส่วนหมวดหมู่
            const SizedBox(height: 20),
            _buildTagSection(), // ส่วนแท็ก
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงหมวดหมู่
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        categories.isEmpty
            ? const CircularProgressIndicator()
            : Wrap(
                spacing: 10,
                children: categories.asMap().entries.map((entry) {
                  int index = entry.key;
                  String category = entry.value;
                  bool isSelected = selectedCategoryIds
                      .contains(index + 1); // อ้างอิงจาก category_following

                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedCategoryIds.add(index + 1);
                        } else {
                          selectedCategoryIds.remove(index + 1);
                        }
                      });
                    },
                    selectedColor: Colors.lightGreenAccent,
                  );
                }).toList(),
              ),
      ],
    );
  }

  // ฟังก์ชันสำหรับแสดงแท็ก
  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        tags.isEmpty
            ? const CircularProgressIndicator()
            : Wrap(
                spacing: 10,
                children: tags.asMap().entries.map((entry) {
                  int index = entry.key;
                  String tag = entry.value;
                  bool isSelected = selectedTagIds
                      .contains(index + 1); // อ้างอิงจาก tag_following

                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTagIds.add(index + 1);
                        } else {
                          selectedTagIds.remove(index + 1);
                        }
                      });
                    },
                    selectedColor: Colors.lightGreenAccent,
                  );
                }).toList(),
              ),
      ],
    );
  }
}
