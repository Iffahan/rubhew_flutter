import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyFollowerPage extends StatefulWidget {
  const MyFollowerPage({super.key});

  @override
  _MyFollowerPageState createState() => _MyFollowerPageState();
}

class _MyFollowerPageState extends State<MyFollowerPage> {
  List<String> categories = [];
  List<String> selectedCategories = ['Sneaker', 'Shirt'];
  final List<String> tags = [
    '#มือสอง',
    '#หาดใหญ่',
    '#เสื้อวินเทจ',
    '#มือหนึ่ง',
    '#ของแท้',
    '#ลิมิเต็ด'
  ];
  final List<String> selectedTags = ['#มือสอง', '#หาดใหญ่', '#เสื้อวินเทจ'];
  final List<String> keywords = ['Nike Air Jordan 1 Low', 'Nike Air max'];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

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
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Follower',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyFollowerPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildCategorySection(),
            const SizedBox(height: 20),
            _buildTagSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        categories.isEmpty
            ? const CircularProgressIndicator()
            : Wrap(
                spacing: 10,
                children: categories.map((category) {
                  bool isSelected = selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedCategories.add(category);
                        } else {
                          selectedCategories.remove(category);
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

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: tags.map((tag) {
            bool isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedTags.add(tag);
                  } else {
                    selectedTags.remove(tag);
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
