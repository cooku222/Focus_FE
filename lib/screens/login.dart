import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus/widgets/header.dart'; // Header 위젯 경로 임포트
import 'package:focus/utils/jwt_utils.dart'; // JWT 디코딩 유틸리티
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

        // Access Token 추출
        final accessToken = responseData['accessToken'];
        if (accessToken == null) {
          throw Exception("Access token is missing in the response.");
        }

        // JWT 디코딩 및 User ID 추출
        final payload = JWTUtils.decodeJWT(accessToken);
        final userId = payload['sub']; // `sub` 키를 User ID로 사용
        if (userId == null) {
          throw Exception("User ID is missing in the token.");
        }

        // Secure Storage에 상태 저장
        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'isLoggedIn', value: 'true');
        await storage.write(key: 'userId', value: userId.toString());

        print("Access Token: $accessToken");
        print("User ID: $userId");

        // 로그인 성공 후 메인 화면으로 이동
        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showErrorDialog("로그인 실패", "이메일 또는 비밀번호가 올바르지 않습니다.");
      }
    } catch (e) {
      print("Error during login: $e");
      _showErrorDialog("로그인 오류", "서버와의 연결에 실패했습니다. 다시 시도해주세요.");
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      // FlutterSecureStorage에서 로그인 정보 확인
      String? token = await storage.read(key: 'accessToken');
      if (token != null) {
        // JWT 디코딩으로 유효성 확인
        final payload = JWTUtils.decodeJWT(token);
        final userId = payload['sub']; // sub 키를 User ID로 사용
        if (userId != null) {
          print("로그인 상태 확인됨. User ID (sub): $userId");
          // 로그인 상태면 그대로 유지
          Navigator.pushReplacementNamed(context, '/');
        } else {
          print("토큰 유효하지 않음. 재로그인 필요");
          await storage.deleteAll();
        }
      } else {
        print("로그인 상태가 아닙니다.");
      }
    } catch (e) {
      print("로그인 상태 확인 오류: $e");
      await storage.deleteAll();
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
            child: const Text("확인"),
          ),
        ],
      ),
    );
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
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                onLoginTap: () {
                  print("Login button clicked");
                },
              ),
              const SizedBox(height: 55),
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
              const SizedBox(height: 55),
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
                    const SizedBox(height: 51),
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
                    const SizedBox(height: 55),
                    Center(
                      child: GestureDetector(
                        onTap: handleLogin,
                        child: Container(
                          width: double.infinity,
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
    );
  }
}
