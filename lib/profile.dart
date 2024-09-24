import 'package:flutter/material.dart';
import 'package:rubhew/main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to HomePage or another page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Help icon functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Save functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Section
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, size: 60, color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),

            // Profile Details
            const ProfileDetailRow(
              icon: Icons.person,
              label: 'Username',
              value: 'username',
              isEditable: true,
            ),
            const ProfileDetailRow(
              icon: Icons.male,
              label: 'Gender',
              value: 'Male',
              isEditable: true,
            ),
            const ProfileDetailRow(
              icon: Icons.calendar_today,
              label: 'Birth Date',
              value: '23/04/1999',
              isEditable: true,
            ),
            const ProfileDetailRow(
              icon: Icons.phone,
              label: 'Tel No.',
              value: '08x xxx xxxx',
              isEditable: true,
            ),
            const ProfileDetailRow(
              icon: Icons.email,
              label: 'Email',
              value: 'usxxxx@gmail.com',
              isEditable: true,
            ),
            const SizedBox(height: 20),

            // Change Password Button
            ElevatedButton(
              onPressed: () {
                // Change password functionality
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditable;

  const ProfileDetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          if (isEditable)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                // Edit functionality
              },
            ),
        ],
      ),
    );
  }
}
