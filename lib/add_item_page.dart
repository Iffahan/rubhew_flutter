import 'dart:convert'; // For JSON conversion
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:rubhew/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final List<XFile> _imageFiles = []; // Removed nullable declaration
  final ImagePicker _picker = ImagePicker();

  // List to hold additional fields
  final List<Map<String, String>> _additionalFields = [];

  // Text controllers for name, price, and description
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> categories = [];
  // To hold fetched categories
  List<dynamic> _categories = [];
  String? _selectedCategory; // Selected category ID

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the widget is initialized
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/categories/'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body); // Store fetched categories
        });
      } else {
        print("Failed to fetch categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles.addAll(pickedFiles);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _addField() async {
    String fieldName = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Field'),
        content: TextField(
          onChanged: (value) {
            fieldName = value;
          },
          decoration: const InputDecoration(hintText: "Enter field name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (fieldName.isNotEmpty) {
                setState(() {
                  _additionalFields.add({fieldName: ''});
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _updateFieldValue(int index, String value) {
    setState(() {
      String key = _additionalFields[index].keys.first;
      _additionalFields[index][key] = value;
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> postItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Prepare images as base64
    List<String> base64Images = [];
    for (var imageFile in _imageFiles) {
      File file = File(imageFile.path);
      String base64Image = base64Encode(file.readAsBytesSync());
      base64Images.add(base64Image);
    }

    print("Base64 Images: $base64Images"); // ตรวจสอบว่า base64 ถูกแปลงแล้ว

    // Prepare additional fields
    Map<String, dynamic> additionalFieldsMap = {};
    for (var field in _additionalFields) {
      additionalFieldsMap.addAll(field);
    }

    // Prepare item data
    Map<String, dynamic> itemData = {
      "name_item": _nameController.text,
      "description": _descriptionController.text,
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "category_id": int.tryParse(_selectedCategory ?? '0') ?? 0,
      "detail": additionalFieldsMap,
      "images": base64Images,
      "status": "Available",
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/items/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(itemData),
      );

      if (response.statusCode == 201) {
        print(itemData);
        print("Item posted successfully");
        _showDialog("Success", "Item posted successfully!");

        final responseData = json.decode(response.body);
        print(responseData); // Display the response from API
      } else {
        print("Failed to post item: ${response.statusCode}");
        _showDialog("Failed", "Failed to post item: ${response.statusCode}");
      }
    } catch (e) {
      print("Error posting item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF219EBC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        height: double.infinity, // Use double.infinity for the height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF219EBC),
              Color(0xFF8ECAE6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image attachment section
                GestureDetector(
                  onTap: _pickImages,
                  child: Center(
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.white,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 50, color: Colors.black),
                              Text('Add picture',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20)),
                            ],
                          ),
                          if (_imageFiles.isNotEmpty)
                            Positioned.fill(
                              child: Image.file(
                                File(_imageFiles.first.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Display attached images with delete option
                if (_imageFiles.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageFiles.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.file(
                                File(_imageFiles[index].path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                // Text fields for name, price, and category
                _buildTextField('Enter the name', _nameController),
                const SizedBox(height: 10),
                _buildTextField('Price', _priceController, isPrice: true),
                const SizedBox(height: 10),
                // Category selection dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Select Category'),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id_category'].toString(),
                      child: Text(category['name_category']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    filled: true, // Enable filled background
                    fillColor:
                        Colors.white, // Set the background color to white
                  ),
                ),
                const SizedBox(height: 10),
                // Add Field Button
                TextButton.icon(
                  onPressed: _addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                ),
                const SizedBox(height: 10),
                // Display additional fields dynamically
                for (int i = 0; i < _additionalFields.length; i++) ...[
                  _buildAdditionalField(i),
                  const SizedBox(height: 10), // Add space between fields
                ],
                // Description text field
                _buildTextField('Description', _descriptionController),
                const SizedBox(height: 20),
                // Post button
                Center(
                  child: ElevatedButton(
                    onPressed: postItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 204, 76),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                    ),
                    child: const Text('Post Item',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPrice = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPrice ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        filled: true, // Enable filled background
        fillColor: Colors.white, // Set the background color to white
      ),
    );
  }

  // Helper method to build additional fields dynamically
  Widget _buildAdditionalField(int index) {
    String key = _additionalFields[index].keys.first;
    String value = _additionalFields[index][key] ?? '';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => _updateFieldValue(index, val),
                decoration: InputDecoration(
                  labelText: key,
                  border: const OutlineInputBorder(),
                  filled: true, // Enable filled background
                  fillColor: Colors.white, // Set the background color to white
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _additionalFields.removeAt(index);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 5), // Add spacing here between additional fields
      ],
    );
  }
}
