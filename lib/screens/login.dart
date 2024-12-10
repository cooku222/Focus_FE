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
  late String accessToken;

  void handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://3.38.191.196/api/sign-in'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        accessToken = responseData['accessToken']; // 초기화 보장
        print("Access Token: $accessToken");

        // Access Token 저장
        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'isLoggedIn', value: 'true');

        // 성공 처리
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
        );
      } else {
        // 로그인 실패 처리
        print("Error: ${response.statusCode}, Body: ${response.body}");
        _showErrorDialog("로그인 실패", "이메일 또는 비밀번호가 올바르지 않습니다.");
      }
    } catch (e) {
      print("Network error: $e");
      _showErrorDialog("네트워크 오류", "서버와의 연결에 실패했습니다. 다시 시도해주세요.");
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

  Future<void> checkLoginStatus() async {
    try {
      // FlutterSecureStorage에서 로그인 정보 확인
      String? token = await storage.read(key: 'accessToken');
      if (token != null) {
        print("로그인 상태 확인됨. 메인 화면으로 이동합니다.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false, // 이전 화면 제거
        );
      } else {
        print("로그인 상태가 아닙니다.");
      }
    } catch (e) {
      print("로그인 상태 확인 오류: $e");
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
