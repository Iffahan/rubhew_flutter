import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _boxPageController = PageController();
  int _currentBoxPage = 0;
  Timer? _boxTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _boxPageController.dispose();
    _boxTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _boxTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentBoxPage < 3) {
        // Since we have 4 pages (index 0 to 3)
        _currentBoxPage++;
      } else {
        _currentBoxPage = 0;
      }
      _boxPageController.animateToPage(
        _currentBoxPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Box1 section with sliding pages
            SizedBox(
              width: screenWidth,
              height: 260,
              child: PageView(
                controller: _boxPageController,
                children: [
                  _buildBox(Colors.blueAccent, "Box 1"),
                  _buildBox(Colors.greenAccent, "Box 2"),
                  _buildBox(Colors.redAccent, "Box 3"),
                  _buildBox(Colors.orangeAccent, "Box 4"),
                ],
              ),
            ),
            Container(
              width: screenWidth,
              height: 130,
              color: const Color.fromARGB(255, 255, 132, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Category",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        fontFamily: String.fromEnvironment("Promp"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SizedBox(
                      height: 60, // Set height for circles container
                      child: PageView(
                        children: [
                          _buildCircleRow([
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                            Colors.yellow
                          ]),
                          _buildCircleRow([
                            Colors.purple,
                            Colors.orange,
                            Colors.brown,
                            Colors.pink
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Suggestion",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 300, // Limit the height for scrolling cards
                  child: ListView(
                    scrollDirection: Axis.horizontal, // Scroll horizontally
                    children: [
                      _buildSuggestionCard(
                          'assets/image1.png', 'Card 1', 'Label 1'),
                      _buildSuggestionCard(
                          'assets/image2.jpg', 'Card 2', 'Label 2'),
                      _buildSuggestionCard(
                          'assets/image3.jpg', 'Card 3', 'Label 3'),
                      _buildSuggestionCard(
                          'assets/image4.jpg', 'Card 4', 'Label 4'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(Color color, String label) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCircleRow(List<Color> colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: colors
          .map(
            (color) => CircleShape(color: color),
          )
          .toList(),
    );
  }

  Widget _buildSuggestionCard(String imagePath, String title, String label) {
    return Container(
      width: 160, // Set width for each card
      margin: const EdgeInsets.all(8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            // Bottom left corner text
            Positioned(
              bottom: 8,
              left: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
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

class CircleShape extends StatelessWidget {
  final Color color;

  const CircleShape({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
