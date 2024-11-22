import 'package:flutter/material.dart';
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

  void _register() {
    final email = emailController.text.trim();
    final nickname = nicknameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || nickname.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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

    // 회원가입 성공 로직 처리 후 페이지 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Info1Screen()),
    );
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
              Header(),
              SizedBox(height: 55), // 헤더와 "회원가입" 간격
              // "회원가입" 제목
              Center(
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
              SizedBox(height: 55), // 제목과 입력 블록 간격
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이메일 입력 블록
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
                    ),
                    SizedBox(height: 20), // 간격
                    // 닉네임 입력 블록
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
                    ),
                    SizedBox(height: 20), // 간격
                    // 비밀번호 및 비밀번호 확인 블록
                    Row(
                      children: [
                        // 비밀번호 입력
                        Expanded(
                          child: _buildPasswordBlock(
                            label: "비밀번호",
                            controller: passwordController,
                            onChanged: checkPasswordMatch,
                          ),
                        ),
                        SizedBox(width: 16),
                        // 비밀번호 확인
                        Expanded(
                          child: _buildPasswordBlock(
                            label: "비밀번호 확인",
                            controller: confirmPasswordController,
                            onChanged: checkPasswordMatch,
                          ),
                        ),
                      ],
                    ),
                    // 비밀번호 불일치 메시지
                    if (!isPasswordMatch)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "비밀번호가 올바르지 않습니다",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF123456),
                          ),
                        ),
                      ),
                    SizedBox(height: 55), // 간격
                    // 회원가입 버튼
                    Center(
                      child: GestureDetector(
                        onTap: _register,
                        child: Container(
                          width: 737,
                          height: 75,
                          decoration: BoxDecoration(
                            color: Color(0x80327B9E), // 투명도 50%
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
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
                    SizedBox(height: 100), // 하단 공간 확보
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 입력 블록 공통 메서드
  Widget _buildInputBlock({
    required String label,
    required TextEditingController controller,
    required bool isFocused,
    required Function(bool) onFocusChange,
    required String buttonLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Noto Sans KR",
            color: Color(0xFF434343),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Focus(
                onFocusChange: onFocusChange,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isFocused ? Color(0xFF1B23D9) : Color(0xFFC4C4C4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "$label 입력",
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 144.83,
              height: 63.09,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0x268AD2E6), // 투명도 15%
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
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

  // 비밀번호 블록 공통 메서드
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
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Noto Sans KR",
            color: Color(0xFF434343),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 347.35,
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xFFC4C4C4),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: controller,
            obscureText: true,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "$label 입력",
            ),
          ),
        ),
      ],
    );
  }
}
