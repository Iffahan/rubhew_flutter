import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Mock data for profile
  final Map<String, dynamic> profileData = {
    'id_user': 1, // User's ID
    'email': 'user@example.com',
    'phoneNumber': '123-456-7890',
    'address': '123 Main St, City, Country'
  };

  // Mock data for all requests (both sent and received)
  final List<Map<String, dynamic>> allRequests = [
    {
      'id_sent': 1,
      'id_receive': 2, // Sent to another user
      'id_item': 11,
      'item_image': 'https://via.placeholder.com/150',
      'item_name': 'Vintage Lamp',
      'message': 'I would like to buy this lamp.',
      'status': 'Available',
      'respond_message': '',
    },
    {
      'id_sent': 2,
      'id_receive': 1, // Received by current user
      'id_item': 21,
      'item_image': 'https://via.placeholder.com/150',
      'item_name': 'Modern Chair',
      'message': 'Can you send this chair to me?',
      'status': 'Available',
      'respond_message': '',
    },
    {
      'id_sent': 1,
      'id_receive': 3, // Sent to another user
      'id_item': 12,
      'item_image': 'https://via.placeholder.com/150',
      'item_name': 'Antique Vase',
      'message': 'Is this vase still available?',
      'status': 'Progress',
      'respond_message': '',
    },
    {
      'id_sent': 3,
      'id_receive': 1, // Received by current user
      'id_item': 22,
      'item_image': 'https://via.placeholder.com/150',
      'item_name': 'Wooden Table',
      'message': 'I want this table for my new home.',
      'status': 'Available',
      'respond_message': '',
    },
  ];

  // Method to filter sent requests based on id_user
  List<Map<String, dynamic>> getSentRequests() {
    return allRequests
        .where((request) => request['id_sent'] == profileData['id_user'])
        .toList();
  }

  // Method to filter received requests based on id_user
  List<Map<String, dynamic>> getReceivedRequests() {
    return allRequests
        .where((request) => request['id_receive'] == profileData['id_user'])
        .toList();
  }

  // Method to show the message popup
  void _showMessagePopup(BuildContext context, String merchant) {
    TextEditingController messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ), // Adjusts for keyboard
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send a message to $merchant',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(
                            context); // Close the modal when "X" is pressed
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Type your message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3, // Allows multi-line messages
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const IconButton(
                      icon: Icon(Icons.add, size: 30, color: Colors.grey),
                      onPressed: null, // Not clickable
                    ),
                    IconButton(
                      icon: const Icon(Icons.email),
                      onPressed: () {
                        // Append email to the message box
                        messageController.text += ' ${profileData['email']}';
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () {
                        // Append phone number to the message box
                        messageController.text +=
                            ' ${profileData['phoneNumber']}';
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        // Append address to the message box
                        messageController.text += ' ${profileData['address']}';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context); // Close the modal when "Cancel" is pressed
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Simulate sending the message
                        Navigator.pop(
                            context); // Close the modal after "sending"
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Message sent to $merchant!')),
                        );
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to handle accepting a request
  void _acceptRequest(int index) {
    final request = getReceivedRequests()[index];
    _showMessagePopup(
        context, request['item_name']); // Show message popup with item name
  }

  // Method to handle canceling a sent request
  void _cancelRequest(int index) {
    setState(() {
      allRequests.removeAt(index); // Remove the sent request
    });
  }

  // Method to handle canceling a received request
  void _cancelReceivedRequest(int index) {
    setState(() {
      allRequests.removeAt(index); // Remove the received request
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sentRequests = getSentRequests();
    List<Map<String, dynamic>> receivedRequests = getReceivedRequests();

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
                      leading: Image.network(request['item_image']!),
                      title: Text(request['item_name']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          _cancelRequest(allRequests
                              .indexOf(request)); // Cancel the sent request
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
                      leading: Image.network(request['item_image']!),
                      title: Text(request['item_name']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            request['message'] ?? 'No message provided',
                            style: const TextStyle(
                                fontSize: 12), // Smaller font size
                          ),
                          if (request['respond_message'] !=
                              '') // Display response message if available
                            Text(
                              request['respond_message']['message'],
                              style: const TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              _cancelReceivedRequest(allRequests.indexOf(
                                  request)); // Cancel the received request
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              _acceptRequest(
                                  index); // Accept the received request
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
