import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality here
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Implement add functionality here
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Notification Page Content'),
      ),
    );
  }
}
