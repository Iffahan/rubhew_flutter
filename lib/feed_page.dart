import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  // Mock data for items
  List<Map<String, dynamic>> items_mock = [
    {
      'name': 'Stylish Shoes',
      'merchant': 'FashionHub',
      'image': 'https://via.placeholder.com/300x200.png?text=Stylish+Shoes+2',
      'description': 'These stylish shoes are perfect for everyday wear.',
      'price': '3,500 THB',
      'category': 'Footwear', // Single category
      'tags': ['Stylish', 'Comfort'], // Multiple tags
      'brand': 'Nike',
      'model': 'Air Max',
      'size': '42',
      'other': {
        'Limited Edition': 'Yes',
        'Waterproof': 'Yes',
        'Fire Portect': 'Yes'
      },
    },
    {
      'name': 'Smart Watch',
      'merchant': 'TechStore',
      'image': 'https://via.placeholder.com/300x200.png?text=Smart+Watch',
      'description': 'Stay connected with this amazing smart watch.',
      'price': '6,000 THB',
      'category': 'Electronics', // Single category
      'tags': ['Tech', 'Fitness'], // Multiple tags
      'brand': 'Samsung',
      'model': 'Galaxy Watch',
      'size': 'One Size',
      'other': {'Water Resistant': 'Yes'},
    },
    {
      'name': 'Classic Handbag',
      'merchant': 'AccessoriesGalore',
      'image': 'https://via.placeholder.com/300x200.png?text=Classic+Handbag',
      'description': 'A classic handbag that goes with any outfit.',
      'price': '4,500 THB',
      'category': 'Accessories', // Single category
      'tags': ['Elegant', 'Stylish'], // Multiple tags
      'brand': 'Gucci',
      'model': 'GG Marmont',
      'size': 'Medium',
      'other': {'Material': 'Leather'},
    },
    {
      'name': 'Gaming Laptop',
      'merchant': 'TechWorld',
      'image': 'https://via.placeholder.com/300x200.png?text=Gaming+Laptop',
      'description': 'Experience gaming like never before with this laptop.',
      'price': '12,000 THB',
      'category': 'Electronics', // Single category
      'tags': ['Gaming', 'High Performance'], // Multiple tags
      'brand': 'Asus',
      'model': 'ROG Strix',
      'size': '15.6 inches',
      'other': {'RGB Keyboard': 'Yes'},
    },
  ];

  List<Map<String, dynamic>> items = [];
  int currentIndex = 0; // Index to track the currently displayed item
  String searchQuery = ''; // Query for search
  List<Map<String, dynamic>> filteredItems = [];

  // Variables to store profile data
  int? userId; // Store user ID
  List<int> tagFollowing = []; // Store followed tags
  List<int> categoryFollowing = []; // Store followed categories

  final TextEditingController messageController = TextEditingController();
  int selectedItemId = 0; // ID of the selected item to send message about

  @override
  void initState() {
    super.initState();
    fetchItems(); // Fetch items from the API
    _fetchProfile(); // Fetch profile data
  }

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

        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            userId = data['user_id']; // Store user ID
            tagFollowing =
                List<int>.from(data['tag_following']); // Store followed tags
            categoryFollowing = List<int>.from(
                data['category_following']); // Store followed categories
          });

          // After fetching profile, fetch items
          fetchItems(); // Call to fetch items now that profile data is available
        }
      } else {
        throw Exception('Unable to fetch profile data');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> fetchItems() async {
    final url = Uri.parse('http://10.0.2.2:8000/items');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Filter and map the fetched items
      items = data.where((item) {
        // Include only items that are "Available" and not owned by the user
        return item['status'] == 'Available' && item['id_user'] != userId;
      }).map<Map<String, dynamic>>((item) {
        // Create a new list of tag IDs
        List<int> tagIds =
            List<int>.from(item['tags'].map((tag) => tag['id_tags']));

        return {
          'id_item': item['id_item'],
          'name': item['name_item'] ?? 'Unknown',
          'merchant': item['user_profile'] != null
              ? item['user_profile']['username'] ?? 'Unknown User'
              : 'Unknown User',
          'image': item['images'].isNotEmpty ? item['images'][0] : '',
          'description': item['description'] ?? 'No description available',
          'price': '${item['price'] ?? 0} THB',
          'category': item['category_details'] != null
              ? item['category_details']['name_category'] ?? 'Unknown Category'
              : 'Unknown Category',
          'tags': List<String>.from(
              item['tags'].map((tag) => tag['name_tags'] ?? '')),
          'tags_id': tagIds, // New variable for tag IDs
          'other': item['detail'] ?? {}, // Map the detail field to other
          'category_id': item['category_id'], // Include category ID for sorting
        };
      }).toList();

      // Sort items based on category and tags following
      items.sort((a, b) {
        // Check if both items are in followed categories
        bool aInCategory = categoryFollowing.contains(a['category_id']);
        bool bInCategory = categoryFollowing.contains(b['category_id']);

        // Sort by category first
        if (aInCategory && !bInCategory) {
          return -1; // a comes before b
        } else if (!aInCategory && bInCategory) {
          return 1; // b comes before a
        }

        // If both or neither are in followed categories, sort by tags
        int aTagMatch =
            a['tags_id'].any((tagId) => tagFollowing.contains(tagId)) ? 1 : 0;
        int bTagMatch =
            b['tags_id'].any((tagId) => tagFollowing.contains(tagId)) ? 1 : 0;

        // If both items have tag matches, keep their order; otherwise, sort accordingly
        return bTagMatch.compareTo(aTagMatch);
      });

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          filteredItems =
              items; // Update the state with filtered and sorted items
        });
      }
    } else {
      print('Failed to load items: ${response.statusCode}');
    }
  }

  // Function to go to the next item when X button is pressed
  void _showNextItem() {
    setState(() {
      if (filteredItems.isNotEmpty) {
        // Only proceed if filteredItems is not empty
        if (currentIndex < filteredItems.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0; // Reset to first item after the last item
        }
      }
    });
  }

  void _showMessagePopup(BuildContext context, String merchant, int itemId) {
    selectedItemId = itemId; // Set the selected item ID
    print('Selected item ID: $selectedItemId'); // Debugging

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ), // Adjust for keyboard
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
                        Navigator.pop(context); // Close the modal
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController, // Assign the controller
                  decoration: const InputDecoration(
                    labelText: 'Type your message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3, // Allows multi-line messages
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the modal
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Send message logic within the popup
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? token = prefs.getString('token');
                        const String apiUrl = 'http://10.0.2.2:8000/requests/';
                        String message = messageController.text;
                        print(
                            'Sending message: $message to item ID: $selectedItemId');

                        try {
                          final response = await http.post(
                            Uri.parse(apiUrl),
                            headers: {
                              'Authorization': 'Bearer $token',
                              'Content-Type': 'application/json',
                            },
                            body: json.encode({
                              'id_item': selectedItemId,
                              'message': message,
                            }),
                          );

                          if (response.statusCode == 201) {
                            print("Message sent successfully");

                            final responseData = json.decode(response.body);
                            print(
                                responseData); // Display the response from API
                            Navigator.pop(
                                context); // Close the modal after sending
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Message sent to $merchant!')),
                            );
                          } else {
                            print(
                                "Failed to send message: ${response.statusCode}");
                            print("Error response body: ${response.body}");
                          }
                        } catch (e) {
                          print("Error sending message: $e");
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

  // Function to handle search when enter or search button is pressed
  void _performSearch() {
    setState(() {
      filteredItems = items
          .where((item) =>
              item['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      // Reset to the first item, and handle if no items are found
      currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = filteredItems.isNotEmpty
        ? filteredItems[currentIndex]
        : {'name': 'No items found', 'merchant': '', 'image': ''};

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Logo (Shopping Cart Icon)
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 16),

            // Search Bar
            Expanded(
              child: TextField(
                onChanged: (value) {
                  searchQuery = value; // Update search query
                },
                onSubmitted: (value) {
                  _performSearch(); // Search when 'Enter' is pressed
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _performSearch(); // Search when search icon is pressed
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Report Button
            IconButton(
              icon: const Icon(Icons.error_outline), // Exclamation mark button
              onPressed: () {
                // Report functionality
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF219EBC),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF219EBC), Color(0xFF8ECAE6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          // White Background
          Container(
            color: Colors.white,
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
            height: MediaQuery.of(context).size.height * 0.5,
          ),
          // Content Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Funca(
                  key: ValueKey<int>(currentIndex),
                  item: currentItem,
                  onNext: _showNextItem,
                  onShowMessagePopup: () => _showMessagePopup(context,
                      currentItem['merchant'] ?? '', currentItem['id_item']),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

ImageProvider<Object> _getImage(String imageBase64) {
  // Decode base64 string into bytes and return as ImageProvider
  Uint8List bytes = base64Decode(imageBase64);
  return MemoryImage(bytes);
}

class Funca extends StatelessWidget {
  final Map<String, dynamic> item; // Data type for the feed item
  final VoidCallback onNext; // Callback to show next item
  final VoidCallback
      onShowMessagePopup; // Callback for showing the message popup

  const Funca({
    super.key,
    required this.item,
    required this.onNext,
    required this.onShowMessagePopup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Added padding
      child: SingleChildScrollView(
        // Make the content scrollable
        child: Column(
          children: [
            // Square Image Frame
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: (item['image'] != null && item['image'].isNotEmpty)
                          ? _getImage(item['image']) // ถอดรหัส base64 จากภาพแรก
                          : const AssetImage(
                              'assets/NoImage.png'), // ภาพเริ่มต้น
                      fit: BoxFit.cover,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Gradient overlay for text visibility
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                // Text Overlay
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${item['merchant']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons and price display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // X button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onNext,
                    ),
                  ),
                ),
                // Price Display Column
                Column(
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      item['price'] ??
                          'N/A', // Provide a default value like 'N/A'
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                // Heart icon button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
                      onPressed:
                          onShowMessagePopup, // Show message popup when heart button is pressed
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description Label
            _buildInfoLabel('Description'),

            // Item Description Box
            _buildInfoBox(item['description'] ?? 'No description available'),

            const SizedBox(height: 16),

            // Row for Category and Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Display
                _buildLabelWithValues(
                    'Category', [item['category'] ?? 'No category']),

                // Tags Display
                _buildTags(item['tags'] as List<String>? ??
                    []), // Fallback to an empty list if null
              ],
            ),

            const SizedBox(height: 16),

            // Display "Other" fields in a row
            if (item['other'] != null) _buildOtherFields(),
          ],
        ),
      ),
    );
  }

// Function to build a label with values
  Widget _buildLabelWithValues(String label, List<String?> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        for (var value in values)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(value ?? 'N/A'), // Provide fallback if value is null
          ),
      ],
    );
  }

// Function to build a widget for the "Other" fields
  Widget _buildOtherFields() {
    List<Widget> fields = [];
    item['other'].forEach((key, value) {
      fields.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(value.toString()), // Display value below the key
          ],
        ),
      );
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: fields,
    );
  }

  // Function to build an info label
  Widget _buildInfoLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

// Function to build an info box for description
  Widget _buildInfoBox(String? description) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child:
          Text(description ?? 'N/A'), // Provide fallback if description is null
    );
  }

// Function to build tags
  Widget _buildTags(List<String>? tags) {
    return Row(
      children: [
        const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        if (tags != null &&
            tags.isNotEmpty) // Check if tags are not null or empty
          for (var tag in tags)
            Container(
              margin: const EdgeInsets.only(right: 4.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(tag),
            )
        else
          const Text('N/A'),
      ],
    );
  }
}
