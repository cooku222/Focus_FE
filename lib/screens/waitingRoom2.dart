import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus/screens/concentrateScreen.dart';
import 'package:focus/utils/jwt_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaitingRoom2 extends StatefulWidget {
  const WaitingRoom2({Key? key, required token, required userId}) : super(key: key);

  @override
  State<WaitingRoom2> createState() => _WaitingRoom2State();
}

class _WaitingRoom2State extends State<WaitingRoom2> {
  final TextEditingController _titleController = TextEditingController();
  int? userId;
  String? date;
  String? token;
  List<String> _plannerTitles = [];
  String? _selectedTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      token = arguments['token'];
      userId = arguments['userId'];
      print("Token received: $token");
      print("User ID received: $userId");
    } else {
      print("No arguments received.");
    }
      _retrieveTokenAndDecode();
  }

  Future<void> _retrieveTokenAndDecode() async {
    try {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null && arguments.containsKey('accessToken')) {
        token = arguments['accessToken'];
      }

      if (token == null) {
        const storage = FlutterSecureStorage();
        token = await storage.read(key: 'accessToken');
        print("Decoded userId: \$token");
      }

      if (token != null) {
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'accessToken');
        final payload = JWTUtils.decodeJWT(token!);
        setState(() {
          userId = payload['user_id'];
          print("Decoded userId: \$userId");
        });
        await _fetchPlannerTitles();
      } else {
        print("Token is null");
      }
    } catch (e) {
      print("Error retrieving or decoding token: \$e");
      _showLoginError();
    }
  }

  Future<void> _fetchPlannerTitles() async {
    if (userId == null) {
      print("UserId is null, cannot fetch planner titles");
      return;
    }

    final date = DateTime.now().toIso8601String().split('T')[0]; // Format date as YYYY-MM-DD
    final url = Uri.parse('http://3.38.191.196/api/planner/$userId/$date'); // Construct the API URL
    print("Fetching planner titles from: \$url");

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token', // Include token for authentication
      });
      print("Response status: \${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _plannerTitles = data.map((item) => item["title"] as String).toList();
          print("Fetched planner titles: \$_plannerTitles");
        });
      } else {
        print("Failed to fetch planner titles: \${response.statusCode}");
        print("Response body: \${response.body}");
      }
    } catch (e) {
      print("Error fetching planner titles: \$e");
    }
  }

  void _showLoginError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: const Text("You are not logged in. Please log in again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _navigateToConcentrateScreen() {
    if (_titleController.text.trim().isEmpty && _selectedTitle == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please enter a title or select one from the list."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    print("Navigating to ConcentrateScreen with title: \${_titleController.text.trim().isNotEmpty ? _titleController.text.trim() : _selectedTitle}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConcentrateScreen(
          userId: userId!,
          token: token!,
          title: _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : _selectedTitle!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      appBar: AppBar(
        title: const Text("Waiting Room"),
        backgroundColor: const Color(0xFF242424),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 918,
              height: 572,
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "측정 컨텐츠 입력",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: "Enter title here...",
                            filled: true,
                            fillColor: Color(0xFFE8E8E8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          print("Add button clicked with input: \${_titleController.text}");
                        },
                        icon: const Icon(Icons.add),
                        color: Colors.black,
                        iconSize: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _plannerTitles.length,
                      itemBuilder: (context, index) {
                        final title = _plannerTitles[index];
                        final isSelected = title == _selectedTitle;

                        print("Building item for title: \$title");

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTitle = title;
                              print("Selected title: \$title");
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE8E8E8) : Colors.white,
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected ? Colors.grey[800] : Colors.black,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, color: Colors.black),
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
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                print("Navigating to ConcentrateScreen");
                _navigateToConcentrateScreen();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
