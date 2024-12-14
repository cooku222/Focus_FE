import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus/widgets/header.dart'; // Header widget import
import 'package:focus/utils/jwt_utils.dart'; // JWT decoding utility
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  final String? redirectRoute;
  const LoginScreen({Key? key,  this.redirectRoute}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  static const storage = FlutterSecureStorage(); // Secure storage instance

  Future<void> handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://3.38.191.196/api/sign-in'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['accessToken'];
        if (accessToken == null) {
          throw Exception("Access token is missing in the response.");
        }

        // Save the token securely
        await storage.write(key: 'accessToken', value: accessToken);
        print("Token saved successfully: $accessToken");

        // Decode the JWT
        final payload = JWTUtils.decodeJWT(accessToken);
        print("Decoded JWT: $payload");

        Navigator.pushReplacementNamed(context, '/');
      } else {
        print("Login failed. Response: ${response.body}");
        _showErrorDialog("Login Failed", "Invalid email or password.");
      }
    } catch (e) {
      print("Error during login: $e");
      _showErrorDialog("Error", "An error occurred during login.");
    }
  }




  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width, // 헤더의 너비를 화면 전체로 유지
            child: Header(
              onLoginTap: () {
                print("Login button clicked");
              },
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "로그인",
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.25,
                        fontFamily: "Noto Sans",
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 55),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "ID (e-mail)",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF6CB8D1),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "이메일을 입력하세요",
                              ),
                            ),
                          ),
                          const SizedBox(height: 51),
                          const Text(
                            "비밀번호",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF6CB8D1),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "비밀번호를 입력하세요",
                              ),
                            ),
                          ),
                          const SizedBox(height: 55),
                          Center(
                            child: GestureDetector(
                              onTap: handleLogin,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0x80327B9E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    "로그인",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Inter",
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}