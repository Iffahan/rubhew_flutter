import 'dart:convert'; // For JSON conversion
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:rubhew/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditItemPage extends StatefulWidget {
  final int itemId; // Pass item ID to this page

  const EditItemPage({super.key, required this.itemId});

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final List<XFile> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _categories = [];
  String? _selectedCategory;
  String? _selectedStatus; // Status dropdown value
  Map<String, dynamic> _itemDetails = {};

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> _additionalFields = [];

  List<String> tags = [];
  List<int> selectedTagIds = [];
  List<String> selectedTags = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchItemDetails(); // Fetch item data for editing
    _fetchTags();
  }

  // Function to delete the item
  Future<void> _deleteItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      print('Token not found');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/items/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        if (mounted) {
          _showDialog('Success', 'Item deleted successfully!');
        }
        print("Item deleted successfully");

        // Navigate back to the main page after deletion
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        print("Failed to delete item: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  // ฟังก์ชันเพื่อดึงข้อมูลแท็กจาก API
  Future<void> _fetchTags() async {
    const String apiUrl = 'http://10.0.2.2:8000/tags/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print('ok');
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

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/categories/'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body);
        });
      } else {
        print("Failed to fetch categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _fetchItemDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/items/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer $token', // ใส่ token ใน header
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _itemDetails = json.decode(response.body);
          _nameController.text = _itemDetails['name_item'] ?? '';
          _priceController.text = _itemDetails['price'].toString();
          _descriptionController.text = _itemDetails['description'] ?? '';
          _selectedCategory = _itemDetails['category_id'].toString();
          _selectedStatus = _itemDetails['status']; // Load status
          _loadAdditionalFields(_itemDetails['detail']);
          // Load images if any
        });
      } else {
        print("Failed to fetch item details: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching item details: $e");
    }
  }

  void _loadAdditionalFields(Map<String, dynamic> detail) {
    detail.forEach((key, value) {
      _additionalFields.add({key: value.toString()});
    });
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

  void _addField() {
    _showAddFieldDialog();
  }

  Future<void> _showAddFieldDialog() async {
    String? fieldName;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Additional Field'),
          content: TextField(
            onChanged: (value) {
              fieldName = value; // Get the input field name
            },
            decoration: const InputDecoration(hintText: 'Field Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (fieldName != null && fieldName!.isNotEmpty) {
                  setState(() {
                    _additionalFields.add(
                        {fieldName!: ''}); // Add the new field with empty value
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show dialog after deleting
  void _showDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pop(); // Close dialog
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    List<String> base64Images = [];
    for (var imageFile in _imageFiles) {
      File file = File(imageFile.path);
      String base64Image = base64Encode(file.readAsBytesSync());
      base64Images.add(base64Image);
    }

    Map<String, dynamic> additionalFieldsMap = {};
    for (var field in _additionalFields) {
      additionalFieldsMap.addAll(field);
    }

    Map<String, dynamic> itemData = {
      "name_item": _nameController.text,
      "description": _descriptionController.text,
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "category_id": int.tryParse(_selectedCategory ?? '0') ?? 0,
      "detail": additionalFieldsMap,
      "images": base64Images,
      "status": _selectedStatus ?? 'Available', // Use the selected status
      "tags": selectedTagIds,
    };

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/items/${widget.itemId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(itemData),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ; // _showDialog("Success", "Item updated successfully!");
        }
        print("Item updated successfully");

        // Show success message and navigate back
      } else {
        print("Failed to update item: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF219EBC),
        title: const Text('Edit Item', style: TextStyle(fontSize: 24)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Enter the name', _nameController),
              const SizedBox(height: 10),
              _buildTextField('Price', _priceController, isPrice: true),
              const SizedBox(height: 10),
              _buildTagSection(),
              const SizedBox(height: 10),
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
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                hint: const Text('Select Status'),
                items: const [
                  DropdownMenuItem(
                      value: 'Available', child: Text('Available')),
                  DropdownMenuItem(value: 'Sold', child: Text('Sold')),
                  DropdownMenuItem(value: 'Progress', child: Text('Progress')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Pick Images'),
              ),
              const SizedBox(height: 10),
              _buildImagePreview(),
              const SizedBox(height: 20),
              const Text('Additional Fields', style: TextStyle(fontSize: 18)),
              ..._additionalFields.map((field) {
                String key = field.keys.first;
                String value = field.values.first;

                return _buildDynamicField(key, value, field);
              }).toList(),
              TextButton(
                onPressed: _addField,
                child: const Text('Add Field'),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _updateItem();
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 204, 76),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                  ),
                  child: const Text('Update Item',
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    bool confirmDelete = await _showConfirmDeleteDialog();
                    if (confirmDelete) {
                      _deleteItem();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                  ),
                  child: const Text('Delete Item',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirmation dialog before deleting
  Future<bool> _showConfirmDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this item?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPrice = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPrice ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDynamicField(
      String key, String value, Map<String, String> field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(labelText: key),
            onChanged: (newValue) {
              setState(() {
                field[key] = newValue; // Update the field value
              });
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _additionalFields.remove(field); // Remove the field
            });
          },
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Wrap(
      children: _imageFiles.map((file) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Image.file(
              File(file.path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeImage(_imageFiles.indexOf(file)),
            ),
          ],
        );
      }).toList(),
    );
  }
}
