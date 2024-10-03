import 'package:flutter/material.dart';
import 'package:rubhew/change_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String username = "Username";
  String gender = "";
  String birthDate = "";
  String phoneNumber = "";
  String email = "";
  String address = "";
  String profileImage = "";
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _getProfile(); // Fetch profile data on initialization
  }

  Future<void> _getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/profiles/me'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data);
          setState(() {
            gender = data['gender'];
            address = data['address'];
            birthDate = data['birthday'];
            phoneNumber = data['phoneNumber'];
            profileImage = data['profile_image'];
          });
        }

        final responseUser = await http.get(
          Uri.parse('http://10.0.2.2:8000/users/me'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (responseUser.statusCode == 200) {
          final data = json.decode(responseUser.body);
          setState(() {
            email = data['email'];
            username = data['username']; // username can't be edited
          });
        }
      } catch (e) {
        print("Error fetching profile data: $e");
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        try {
          String? base64Image;
          if (_imageFile != null) {
            List<int> imageBytes = await _imageFile!.readAsBytes();
            base64Image = base64Encode(imageBytes);
          }

          final response = await http.put(
            Uri.parse('http://10.0.2.2:8000/profiles/updateMyprofile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json'
            },
            body: json.encode({
              'gender': gender,
              'birthday': birthDate,
              'phoneNumber': phoneNumber,
              'address': address,
              'profile_image': base64Image ?? profileImage, // Send the image
            }),
          );

          if (response.statusCode == 200) {
            print('Profile updated successfully!');
            Navigator.pop(context); // Go back after saving
          } else {
            print("Failed to update profile");
          }
        } catch (e) {
          print("Error saving profile: $e");
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF219EBC),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile, // Save the profile when pressing save
          ),
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
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildProfileImage(),
                _buildProfileDetailRow(
                  icon: Icons.person,
                  label: 'Username',
                  value: username,
                  readOnly: true,
                ),
                _buildProfileDetailRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: email,
                  readOnly: true,
                ),
                _buildGenderDropdown(),
                _buildBirthdayField(),
                _buildEditableField(
                  label: 'Phone Number',
                  value: phoneNumber,
                  onSaved: (value) => phoneNumber = value!,
                ),
                _buildEditableField(
                  label: 'Address',
                  value: address,
                  onSaved: (value) => address = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 184, 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 48, 71),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage, // Open the image picker
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _imageFile != null
            ? FileImage(_imageFile!)
            : (profileImage.isNotEmpty
                ? NetworkImage(profileImage) as ImageProvider
                : const AssetImage('assets/default_profile.png')),
        child: _imageFile == null
            ? const Icon(
                Icons.camera_alt,
                size: 50,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: gender.isNotEmpty ? gender : null,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              gender = value!;
            });
          },
          onSaved: (value) {
            setState(() {
              gender = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          onSaved: onSaved,
          validator: (value) {
            // Validation for phone number
            if (label == 'Phone Number') {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              } else if (value.length != 10 ||
                  !RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Phone number must be 10 digits';
              }
            }

            // General validation
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null; // Return null if the value is valid
          },
        ),
      ),
    );
  }

  Widget _buildBirthdayField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(
              text: birthDate.isNotEmpty ? birthDate : 'Select your birthday'),
          decoration: const InputDecoration(
            labelText: 'Birthday',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                birthDate =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
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
