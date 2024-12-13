import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus/screens/concentrateScreen.dart';
import 'package:focus/utils/jwt_utils.dart';

class WaitingRoom2 extends StatefulWidget {
  const WaitingRoom2({Key? key, required token, required userId}) : super(key: key);

  @override
  State<WaitingRoom2> createState() => _WaitingRoom2State();
}

class _WaitingRoom2State extends State<WaitingRoom2> {
  final TextEditingController _titleController = TextEditingController();
  int? userId;
  String? token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _retrieveTokenAndDecode();
  }

  Future<void> _retrieveTokenAndDecode() async {
    try {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (arguments != null && arguments.containsKey('token')) {
        token = arguments['token'];
      }

      if (token == null) {
        const storage = FlutterSecureStorage();
        token = await storage.read(key: 'accessToken');
      }

      if (token != null) {
        final payload = JWTUtils.decodeJWT(token!);
        setState(() {
          userId = payload['user_id'];
        });
      }
    } catch (e) {
      print("Error retrieving or decoding token: $e");
      _showLoginError();
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
    if (_titleController.text.trim().isEmpty) {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConcentrateScreen(
          userId: userId!,
          token: token!,
          title: _titleController.text.trim(),
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
      body: Center(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter a Title",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    color: Colors.black,
                    iconSize: 24,
                  ),
                ],
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
