import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
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
        child: Text('Feed Page Content'),
      ),
    );
  }
}
