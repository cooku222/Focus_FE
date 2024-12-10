import 'package:flutter/material.dart';
import 'package:focus/screens/concentrateScreen.dart';

class WaitingRoom2 extends StatefulWidget {
  final int userId; // User ID to pass to the next screen

  const WaitingRoom2({Key? key, required this.userId}) : super(key: key);

  @override
  State<WaitingRoom2> createState() => _WaitingRoom2State();
}

class _WaitingRoom2State extends State<WaitingRoom2> {
  final TextEditingController _titleController = TextEditingController();

  void _navigateToConcentrateScreen() {
    print("Navigating to ConcentrateScreen...");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConcentrateScreen(
          userId: widget.userId,
          title: _titleController.text.trim(),
        ),
      ),
    );

    if (_titleController.text.trim().isEmpty) {
      // Show an error if the title is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Title cannot be empty."),
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

    // Navigate to ConcentrateScreen with userId and title
    Navigator.pushNamed(
      context,
      '/concentrateScreen',
      arguments: {
        'userId': 1,
        'title': "Test title",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424), // Black background
      appBar: AppBar(
        title: const Text("Waiting Room"),
        backgroundColor: const Color(0xFF242424),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter a Title",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Enter title here...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _navigateToConcentrateScreen,
                child: const Text("Start Concentration Mode"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
