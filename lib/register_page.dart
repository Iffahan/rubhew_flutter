import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Implement registration logic here
      print("User Registered!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      backgroundColor:
          const Color(0xFFF3E5D7), // Background color similar to the design
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // This pushes the bottom row down
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and Title
                    const SizedBox(height: 50),
                    Image.asset(
                      'assets/logo.png', // Replace with your logo path
                      height: 100,
                    ),
                    const SizedBox(height: 40),

                    // Registration Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username Field
                          SizedBox(
                            width:
                                300, // Fixed width for text fields and buttons
                            child: TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                labelText: 'Username',
                                filled: true,
                                fillColor: Colors.grey[300],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),

// First Name and Last Name (side by side)
                          Row(
                            children: [
                              // First Name
                              Expanded(
                                child: SizedBox(
                                  width:
                                      160, // Set a consistent width for the first name field
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.person_outline),
                                      labelText: 'First Name',
                                      filled: true,
                                      fillColor: Colors.grey[300],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              // Last Name
                              Expanded(
                                child: SizedBox(
                                  width:
                                      160, // Set a consistent width for the last name field
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.person_outline),
                                      labelText: 'Last Name',
                                      filled: true,
                                      fillColor: Colors.grey[300],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your last name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),

                          // Email Field
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.grey[300],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Password Field with Eye Icon
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible =
                                          !_isPasswordVisible; // Toggle visibility
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey[300],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Confirm Password Field with Eye Icon
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                labelText: 'Confirm Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey[300],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: !_isConfirmPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Register Button
                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: _register,
                              child: const Text('Register',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Register Link Row with white background
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to login page
                  },
                  child:
                      const Text('Login', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
