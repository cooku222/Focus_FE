import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:focus/screens/info1.dart'; // Info1 화면을 import
import 'package:focus/widgets/header.dart'; // Header 위젯 경로 임포트

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordMatch = true;
  bool isEmailFocused = false;
  bool isNicknameFocused = false;

  @override
  void dispose() {
    emailController.dispose();
    nicknameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void checkPasswordMatch(String _) {
    setState(() {
      isPasswordMatch = passwordController.text == confirmPasswordController.text;
    });
  }

  Future<void> _register() async {
    final email = emailController.text.trim();
    final username = nicknameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력하세요.')),
      );
      return;
    }

    if (!isPasswordMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://52.78.38.195/api/sign-up'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "username": username,
          "roles": ["USER"]
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공!')),
        );
        Navigator.pushReplacementNamed(context, '/register/info1'); // Updated Route Transition
      } else {
        final error = jsonDecode(response.body)['message'] ?? '회원가입 실패';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다. 다시 시도하세요.')),
      );
    }
  }

  void handleRegister() async {
    final response = await http.post(
      Uri.parse('http://52.78.38.195/api/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "username": nicknameController.text.trim(),
      }),
    );

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("회원가입 완료"),
          content: const Text("회원가입이 완료되었습니다. 로그인 화면으로 이동합니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 로그인 화면으로 이동
              },
              child: const Text("확인"),
            ),
          ],
        ),
      );
    } else {
      final error = jsonDecode(response.body)['message'] ?? '회원가입 실패';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _checkEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일을 입력하세요.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://52.78.38.195/api/users/check-email'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 이메일입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일이 이미 사용 중입니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다. 다시 시도하세요.')),
      );
    }
  }

  Future<void> _checkNickname() async {
    final username = nicknameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력하세요.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://52.78.38.195/api/users/check-name'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 닉네임입니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임이 이미 사용 중입니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다. 다시 시도하세요.')),
      );
    }
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
              Header(),
              const SizedBox(height: 55),
              const Center(
                child: Text(
                  "회원가입",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: "Noto Sans",
                    fontWeight: FontWeight.w500,
                    height: 1.3,
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
                    _buildInputBlock(
                      label: "이메일",
                      controller: emailController,
                      isFocused: isEmailFocused,
                      onFocusChange: (focus) {
                        setState(() {
                          isEmailFocused = focus;
                        });
                      },
                      buttonLabel: "이메일 중복 확인",
                      onButtonPressed: _checkEmail,
                    ),
                    const SizedBox(height: 20),
                    _buildInputBlock(
                      label: "닉네임",
                      controller: nicknameController,
                      isFocused: isNicknameFocused,
                      onFocusChange: (focus) {
                        setState(() {
                          isNicknameFocused = focus;
                        });
                      },
                      buttonLabel: "닉네임 중복 확인",
                      onButtonPressed: _checkNickname,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPasswordBlock(
                            label: "비밀번호",
                            controller: passwordController,
                            onChanged: checkPasswordMatch,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPasswordBlock(
                            label: "비밀번호 확인",
                            controller: confirmPasswordController,
                            onChanged: checkPasswordMatch,
                          ),
                        ),
                      ],
                    ),
                    if (!isPasswordMatch)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "비밀번호가 올바르지 않습니다",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF123456),
                          ),
                        ),
                      ),
                    const SizedBox(height: 55),
                    Center(
                      child: GestureDetector(
                        onTap: handleRegister,
                        child: Container(
                          width: 737,
                          height: 75,
                          decoration: BoxDecoration(
                            color: const Color(0x80327B9E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              "회원가입",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Noto Sans",
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBlock({
    required String label,
    required TextEditingController controller,
    required bool isFocused,
    required Function(bool) onFocusChange,
    required String buttonLabel,
    required Function() onButtonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Noto Sans KR",
            color: Color(0xFF434343),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Focus(
                onFocusChange: onFocusChange,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isFocused ? const Color(0xFF1B23D9) : const Color(0xFFC4C4C4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "입력하세요",
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 144.83,
              height: 63.09,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x268AD2E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF123456),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordBlock({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Noto Sans KR",
            color: Color(0xFF434343),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 347.35,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFC4C4C4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: controller,
            obscureText: true,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "비밀번호 입력",
            ),
          ),
        ),
      ],
    );
  }
}
