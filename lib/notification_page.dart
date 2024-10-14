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
              'id': request['id'],
              'id_sent': request['id_sent'],
              'id_receive': request['id_receive'],
              'id_item': request['id_item'],
              'name_sender': request['sender']['username'],
              'name_receiver': request['receiver']['username'],
              'item_image': request['item']['images'].isNotEmpty
                  ? request['item']['images'][0]
                  : '',
              'item_name': request['item']['name_item'],
              'item_status': request['item']['status'],
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
  void _showMessagePopup(
      BuildContext context, String merchant, int idItem, int requestId) {
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
                      onPressed: () async {
                        // Handle the API call when sending the response
                        final resMessage = messageController.text.trim();
                        if (resMessage.isNotEmpty) {
                          bool success =
                              await _respondToRequest(requestId, resMessage);
                          Navigator.pop(
                              context); // Close the modal after "sending"
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Response sent to $merchant!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to send response.')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Message cannot be empty.')),
                          );
                        }
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

// Method to respond to a request using the API
  Future<bool> _respondToRequest(int requestId, String resMessage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final String apiUrl =
        'http://10.0.2.2:8000/requests/$requestId/respond'; // Update with the correct URL

    // Create the request body
    final body = jsonEncode({
      'res_message': resMessage,
      'item_status': 'Sold', // Set item status to "Sold"
    });

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Check for successful response
        print("Response sent successfully");
        return true;
      } else {
        print("Failed to send response: ${response.statusCode}");
        print("Error response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error sending response: $e");
      return false;
    }
  }

  // Method to delete a request by ID
  Future<void> _deleteRequest(int requestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('requestId $requestId');
    final String apiUrl =
        'http://10.0.2.2:8000/requests/$requestId'; // Update with the correct URL

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        // Check for successful deletion
        print("Request deleted successfully");
      } else {
        print("Failed to delete request: ${response.statusCode}");
        print("Error response body: ${response.body}");
      }
    } catch (e) {
      print("Error deleting request: $e");
    }
  }

// Method to handle accepting a request
  void _acceptRequest(int index) {
    final request = getReceivedRequests()[index];
    _showMessagePopup(context, request['name_sender'], request['id_item'],
        request['id']); // Pass the request ID
  }

// Method to handle canceling a sent request
  void _cancelRequest(int index) async {
    final request =
        getSentRequests()[index]; // Get the specific request to cancel
    final requestId = request['id']; // Assuming this is the request ID

    // Call the API to delete the request
    await _deleteRequest(requestId);

    // Remove the request from the local state after the API call
    setState(() {
      allRequests.removeAt(index); // Remove the sent request
    });
  }

// Method to handle canceling a received request
  void _cancelReceivedRequest(int index) async {
    final request =
        getReceivedRequests()[index]; // Get the specific request to cancel
    final requestId = request['id']; // Assuming this is the request ID

    // Call the API to delete the request
    await _deleteRequest(requestId);

    // Remove the request from the local state after the API call
    setState(() {
      allRequests.removeAt(index); // Remove the received request
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sentRequests = getSentRequests();
    List<Map<String, dynamic>> receivedRequests = getReceivedRequests();

    // Filter for completed requests (status = "Sold")
    List<Map<String, dynamic>> completedRequests = receivedRequests
        .where((request) => request['item_status'] == 'Sold')
        .toList();

    // Filter for active requests (exclude "Sold" items)
    List<Map<String, dynamic>> activeReceivedRequests = receivedRequests
        .where((request) => request['item_status'] != 'Sold')
        .toList();

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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: (request['item_image'] != null &&
                                    request['item_image'].isNotEmpty)
                                ? _getImage(request['item_image'])
                                : const AssetImage(
                                    'assets/NoImage.png'), // Default image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(request['name_receiver']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            request['message'] ?? 'No message provided',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          _cancelRequest(sentRequests
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
                itemCount: activeReceivedRequests.length,
                itemBuilder: (context, index) {
                  final request = activeReceivedRequests[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: (request['item_image'] != null &&
                                    request['item_image'].isNotEmpty)
                                ? _getImage(request['item_image'])
                                : const AssetImage(
                                    'assets/NoImage.png'), // Default image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(request['name_sender']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            request['message'] ?? 'No message provided',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              _cancelReceivedRequest(
                                  activeReceivedRequests.indexOf(
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
            const Divider(height: 40),
            const Text(
              'Completed Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: completedRequests.length,
                itemBuilder: (context, index) {
                  final request = completedRequests[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: (request['item_image'] != null &&
                                    request['item_image'].isNotEmpty)
                                ? _getImage(request['item_image'])
                                : const AssetImage(
                                    'assets/NoImage.png'), // Default image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(request['name_sender']!),
                      subtitle: Text(
                        'Reply: ${request['respond_message']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
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
