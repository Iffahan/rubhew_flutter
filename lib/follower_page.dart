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
    _fetchProfile(); // Fetch profile data
  }

  // Fetch categories from API
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
        throw Exception('Unable to fetch categories');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Fetch tags from API
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
        throw Exception('Unable to fetch tags');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Fetch profile from API
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

        // Update selected categories and tags based on profile data
        setState(() {
          selectedCategoryIds = List<int>.from(data['category_following']);
          selectedTagIds = List<int>.from(data['tag_following']);
        });
      } else {
        throw Exception('Unable to fetch profile');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Save selected categories and tags via PUT request
  Future<void> _saveFollowing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    const String apiUrl = 'http://10.0.2.2:8000/profiles/updateMyFollowing';

    final body = jsonEncode({
      "tag_following": selectedTagIds,
      "category_following": selectedCategoryIds
    });

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Following preferences updated successfully');
      } else {
        throw Exception('Failed to update following preferences');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveFollowing(); // Save the selected tags and categories
        return true; // Allow the pop to proceed
      },
      child: Scaffold(
        appBar: AppBar(
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
              _buildCategorySection(), // Display categories
              const SizedBox(height: 20),
              _buildTagSection(), // Display tags
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Build category section
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
                      .contains(index + 1); // Based on category_following

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

  // Build tag section
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
                      .contains(index + 1); // Based on tag_following

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
