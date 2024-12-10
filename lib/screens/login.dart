import 'package:flutter/material.dart';
import 'package:focus/main.dart'; // 메인 화면으로 돌아가기 위해 main.dart를 임포트
import 'package:focus/widgets/header.dart'; // Header 위젯 경로 임포트
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage 임포트
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  static const storage = FlutterSecureStorage(); // FlutterSecureStorage 초기화

  void handleLogin() async {
    String email = emailController.text;
    String password = passwordController.text;

    final response = await http.post(
      Uri.parse('http://52.78.38.195/api/sign-in'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    // 이메일 유효성 검사
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("유효하지 않은 이메일"),
          content: const Text("올바른 이메일 형식을 입력하세요."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
      return; // 유효하지 않은 경우 더 이상 진행하지 않음
    }
    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final accessToken = responseData['accessToken'];
      final username = _decodeJWT(accessToken)['username']; // Extract username from token

      print("Access Token: $accessToken");
      print("Username: $username");

      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'username', value: username);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("로그인 실패"),
          content: const Text("이메일 또는 비밀번호가 올바르지 않습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  Map<String, dynamic> _decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<void> checkLoginStatus() async {
    // FlutterSecureStorage에서 로그인 정보 확인
    String? userEmail = await storage.read(key: 'userEmail');
    if (userEmail != null) {
      // 이미 로그인된 상태라면 메인 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false, // 이전 화면 제거
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // 로그인 상태 확인
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // 전체 배경 흰색
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Header(
                onLoginTap: () {
                  print("Login button clicked");
                },
              ),
              const SizedBox(height: 55), // 헤더와 로그인 텍스트 간격
              const Center(
                child: Text(
                  "로그인",
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.25,
                    fontFamily: "Noto Sans",
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 55), // "로그인"과 입력 필드 간격
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ID (e-mail)",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                    const SizedBox(height: 51), // ID와 비밀번호 간 간격
                    const Text(
                      "비밀번호",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                    const SizedBox(height: 55), // 간격
                    Center(
                      child: GestureDetector(
                        onTap: handleLogin,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0x80327B9E), // 투명도 50%
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
    );
  }
}
