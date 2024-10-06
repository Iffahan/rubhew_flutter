import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  List<XFile>? _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  // List to hold additional fields
  List<Map<String, String>> _additionalFields = [];

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles!.addAll(pickedFiles);
      });
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _imageFiles!.removeAt(index);
    });
  }

  // Function to add a new field
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
                  // Add new field with empty value
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

  // Function to update the value of a field
  void _updateFieldValue(int index, String value) {
    setState(() {
      String key = _additionalFields[index].keys.first;
      _additionalFields[index][key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New post',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
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
                      color: const Color.fromARGB(255, 75, 75, 75),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Add picture text/icon (always visible)
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 50, color: Colors.white),
                              Text('Add picture',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),

                          // Display selected image(s) on top (if any)
                          if (_imageFiles!.isNotEmpty)
                            Positioned.fill(
                              child: Image.file(
                                File(_imageFiles!
                                    .first.path), // Show the first image
                                fit: BoxFit
                                    .cover, // Fill the container and crop to fit
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Display attached images with delete option
                _imageFiles!.isNotEmpty
                    ? Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageFiles!.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(
                                    File(_imageFiles![index].path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : const SizedBox(),

                const SizedBox(height: 20),

                // Text fields for name, price, and category
                _buildTextField('Enter the name'),
                const SizedBox(height: 10),
                _buildTextField('Price', isPrice: true),
                const SizedBox(height: 10),
                _buildTextField('Category'),
                const SizedBox(height: 10),

                // Add Field Button
                TextButton.icon(
                  onPressed: _addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add field'),
                ),
                const SizedBox(height: 10),

                // Display additional fields
                if (_additionalFields.isNotEmpty)
                  Column(
                    children: List.generate(_additionalFields.length, (index) {
                      String fieldName = _additionalFields[index].keys.first;
                      return Column(
                        children: [
                          TextField(
                            onChanged: (value) =>
                                _updateFieldValue(index, value),
                            decoration: InputDecoration(
                              labelText: fieldName,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }),
                  ),

                // Description field
                const TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter description',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // Cancel and Post buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Cancel logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(150, 50),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Post logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(150, 50),
                      ),
                      child: const Text('Post',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPrice = false}) {
    return TextField(
      keyboardType: isPrice ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
