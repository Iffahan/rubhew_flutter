import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:rubhew/main.dart';
import 'package:rubhew/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  // Declare TextEditingController variables
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['access_token'];
      print("Login successful, Token: $token");

      // Save the token using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );

      // Save the token locally for authenticated requests (Secure storage recommended)
    } else {
      // Show a SnackBar if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3), // SnackBar duration
        ),
      );
    }
  }

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Login'), backgroundColor: const Color(0xFF219EBC)),
      // Background color similar to the design
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF219EBC), Color(0xFF8ECAE6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // This pushes the bottom row down
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
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

                        // Username/Email Field
                        SizedBox(
                          width: 300, // Fixed width for text fields and buttons
                          child: TextField(
                            controller:
                                usernameController, // Bind the controller
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'username/email',
                              filled: true,
                              fillColor: const Color(0xFFFFB703),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller:
                                passwordController, // Bind the controller
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'password',
                              suffixIcon: const Icon(Icons.visibility_off),
                              filled: true,
                              fillColor: const Color(0xFFFFB703),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        // Forgot Password?
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: 300, // Same width as text fields
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF023047),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {
                              _login(context);
                            },
                            child: const Text('Login',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OR Divider
                        const Row(
                          children: [
                            Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('OR'),
                            ),
                            Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Media Login Buttons
                        SizedBox(
                          width: 300, // Same width as text fields
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF023047),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {},
                            icon:
                                const Icon(Icons.facebook, color: Colors.white),
                            label: const Text('Login with Facebook',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 300, // Same width as text fields
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF023047),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/iconsgoogle.svg', // Path to your custom SVG icon
                              height: 24, // Adjust the size of your icon
                              color: Colors
                                  .white, // Optional: Change the icon color
                            ),
                            label: const Text('Login with Google',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Register Link Row with white background
            Container(
              width: double.infinity,
              color: Colors.white, // White background for the last row

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don’t have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text('Register',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
