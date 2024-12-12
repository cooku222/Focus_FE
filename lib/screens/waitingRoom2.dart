import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus/screens/concentrateScreen.dart';
import 'package:focus/utils/jwt_utils.dart';

class WaitingRoom2 extends StatefulWidget {
  const WaitingRoom2({Key? key}) : super(key: key);

  @override
  State<WaitingRoom2> createState() => _WaitingRoom2State();
}

class _WaitingRoom2State extends State<WaitingRoom2> {
  final TextEditingController _titleController = TextEditingController();
  String? userId;
  String? token;

  @override
  void initState() {
    super.initState();
    _retrieveTokenAndDecode();
  }

  Future<void> _retrieveTokenAndDecode() async {
    const storage = FlutterSecureStorage();
    try {
      token = await storage.read(key: 'accessToken'); // 토큰 읽기
      if (token != null) {
        print("Retrieved token: $token"); // 디버깅: 토큰 출력
        final payload = JWTUtils.decodeJWT(token!); // JWT 디코딩
        print("Decoded Payload: $payload"); // 디버깅: 디코딩된 페이로드 출력

        setState(() {
          userId = payload['userId']?.toString() ?? payload['sub']?.toString(); // 'sub' fallback
        });

        if (userId != null) {
          print("User ID found: $userId"); // 디버깅: userId 출력
        } else {
          print("No userId or sub found in token payload."); // 디버깅: 페이로드에 userId 없음
          _showLoginError();
        }
      } else {
        print("No token found in storage."); // 디버깅: 토큰 없음
        _showLoginError();
      }
    } catch (e) {
      print("Error during token retrieval or decoding: $e"); // 디버깅: 예외 출력
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

    if (userId == null || token == null) {
      // Show an error if the userId or token is null
      _showLoginError();
      return;
    }

    // Navigate to ConcentrateScreen with userId and title
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConcentrateScreen(
          userId: userId!,
          token: token!,
          title: _titleController.text.trim(),
        ),
        settings: RouteSettings(
          arguments: {
            'userId': userId,
            'token': token,
            'title': _titleController.text.trim(),
          },
        ),
      ),
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

