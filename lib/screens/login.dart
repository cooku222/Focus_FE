import 'package:flutter/material.dart';
import 'package:focus/main.dart'; // 메인 화면으로 돌아가기 위해 main.dart를 임포트

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 임시로 하드 코딩된 로그인 데이터
  final String correctEmail = "admin@test.ac.kr";
  final String correctPassword = "admin";

  void handleLogin() {
    String email = emailController.text;
    String password = passwordController.text;

    if (email == correctEmail && password == correctPassword) {
      // 로그인 성공
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false, // 이전 화면을 모두 제거
      );
    } else {
      // 로그인 실패
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("로그인 실패"),
          content: Text("이메일 또는 비밀번호가 올바르지 않습니다."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
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
                  // 현재 화면 유지 또는 다른 동작 추가 가능
                  print("Login button clicked");
                },
              ),
              SizedBox(height: 55), // 헤더와 로그인 텍스트 간격
              // "로그인" 제목
              Center(
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
              SizedBox(height: 55), // "로그인"과 입력 필드 간격
              // ID 입력 필드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID (e-mail)",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF6CB8D1),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "이메일을 입력하세요",
                        ),
                      ),
                    ),
                    SizedBox(height: 51), // ID와 비밀번호 간 간격
                    Text(
                      "비밀번호",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFF6CB8D1),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "비밀번호를 입력하세요",
                        ),
                      ),
                    ),
                    SizedBox(height: 55), // 간격
                    // 로그인 버튼
                    Center(
                      child: GestureDetector(
                        onTap: handleLogin,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0x80327B9E), // 투명도 50%
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
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
                    SizedBox(height: 55), // 간격
                    // 회원가입 버튼
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0x80327B9E), // 투명도 50%
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "회원가입",
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

// 헤더 UI (기존과 동일)
class Header extends StatelessWidget {
  final VoidCallback onLoginTap;

  const Header({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 118,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "FOCUS",
            style: TextStyle(
              fontSize: 48,
              height: 1.25,
              color: Color(0xFF123456),
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _HeaderTextButton(text: "플래너"),
              _HeaderTextButton(text: "리포트"),
              _HeaderTextButton(text: "챌린지"),
              _HeaderTextButton(text: "마이페이지"),
              SizedBox(width: 16),
              GestureDetector(
                onTap: onLoginTap,
                child: _HeaderButton(
                  text: "Login",
                  borderColor: Color(0xFF123456),
                  backgroundColor: Color(0xFF8AD2E6),
                  textColor: Color(0xFF123456),
                ),
              ),
              SizedBox(width: 8),
              _HeaderButton(
                text: "Register",
                borderColor: Color(0xFF123456),
                backgroundColor: Color(0xFF123456),
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 헤더 텍스트 버튼
class _HeaderTextButton extends StatelessWidget {
  final String text;

  const _HeaderTextButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF123456),
        ),
      ),
    );
  }
}

// 헤더 버튼
class _HeaderButton extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const _HeaderButton({
    required this.text,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }
}
