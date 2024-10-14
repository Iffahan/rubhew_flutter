import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Profile data variables
  Map<String, dynamic> profileData = {
    'id_user': 0,
    'email': '',
    'phoneNumber': '',
    'address': '',
  };

  // All requests combined
  List<Map<String, dynamic>> allRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile(); // Fetch profile data on init
    _fetchRequests(); // Fetch request data on init
  }

  // Fetch user profile data from API
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    const String apiUrl = 'http://10.0.2.2:8000/profiles/me';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          profileData = {
            'id_user': data['user_id'],
            'email': data['email'] ?? '',
            'phoneNumber': data['phoneNumber'] ?? '',
            'address': data['address'] ?? '',
          };
        });
      } else {
        throw Exception('Unable to fetch profile data');
      }
    } catch (e) {
      print(e.toString());
    }
  }

// Fetch requests data from API
  Future<void> _fetchRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    const String apiUrl = 'http://10.0.2.2:8000/requests';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Print the raw data to see the structure
        print('Raw fetched data: $data');

        setState(() {
          allRequests = data.map((request) {
            // Print individual request data before mapping
            print('Mapping request: $request');

            return {
              'id_sent': request['id_sent'],
              'id_receive': request['id_receive'],
              'id_item': request['id_item'],
              'item_image': request['item']['images'].isNotEmpty
                  ? request['item']['images'][0]
                  : '',
              'item_name': request['item']['name_item'],
              'message': request['message'] ?? '',
              'respond_message': request['res_message'] ?? '',
              'sender_email': request['sender']['email'],
              'receiver_email': request['receiver']['email'],
            };
          }).toList();

          // Print mapped requests to verify after processing
          print('Mapped requests: $allRequests');
        });
      } else {
        throw Exception('Unable to fetch request data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

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

  ImageProvider<Object> _getImage(String imageBase64) {
    // Decode base64 string into bytes and return as ImageProvider
    Uint8List bytes = base64Decode(imageBase64);
    return MemoryImage(bytes);
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
                      leading: Container(
                        width:
                            50, // Optional: Set the width of the image container
                        height:
                            50, // Optional: Set the height of the image container
                        decoration: BoxDecoration(
                          shape: BoxShape
                              .rectangle, // Change this if you want circular images
                          image: DecorationImage(
                            image: (request['item_image'] != null &&
                                    ['item_image'].isNotEmpty)
                                ? _getImage(request['item_image'])
                                : const AssetImage(
                                    'assets/NoImage.png'), // Default image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
