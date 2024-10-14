import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Mock data for sent requests
  final List<Map<String, dynamic>> sentRequests = [
    {
      'item_name': 'Vintage Lamp',
      'merchant': 'John Doe',
      'image': 'https://via.placeholder.com/150',
      'message': 'I would like to buy this lamp.',
    },
    {
      'item_name': 'Antique Vase',
      'merchant': 'Jane Smith',
      'image': 'https://via.placeholder.com/150',
      'message': 'Is this vase still available?',
    },
  ];

  // Mock data for received requests
  final List<Map<String, dynamic>> receivedRequests = [
    {
      'item_name': 'Modern Chair',
      'merchant': 'Alice Johnson',
      'image': 'https://via.placeholder.com/150',
      'message': 'Can you send this chair to me?',
    },
    {
      'item_name': 'Wooden Table',
      'merchant': 'Bob Brown',
      'image': 'https://via.placeholder.com/150',
      'message': 'I want this table for my new home.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sent Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sentRequests.length,
                itemBuilder: (context, index) {
                  final request = sentRequests[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(request['image']!),
                      title: Text(request['item_name']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Merchant: ${request['merchant']}'),
                          const SizedBox(height: 4),
                          Text(
                            request['message'] ?? 'No message provided',
                            style: const TextStyle(
                                fontSize: 12), // Smaller font size
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          // Implement unsend functionality
                          print(
                              'Request to send ${request['item_name']} canceled');
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 40),
            const Text(
              'Received Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: receivedRequests.length,
                itemBuilder: (context, index) {
                  final request = receivedRequests[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(request['image']!),
                      title: Text(request['item_name']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Merchant: ${request['merchant']}'),
                          const SizedBox(height: 4),
                          Text(
                            request['message'] ?? 'No message provided',
                            style: const TextStyle(
                                fontSize: 12), // Smaller font size
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              // Implement cancel functionality
                              print(
                                  'Request for ${request['item_name']} canceled');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              // Implement accept functionality
                              print(
                                  'Request for ${request['item_name']} accepted');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
