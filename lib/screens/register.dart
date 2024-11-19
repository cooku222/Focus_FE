import 'package:flutter/material.dart';

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

// 헤더 위젯
class Header extends StatelessWidget {
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
              _HeaderButton(
                text: "Login",
                borderColor: Color(0xFF123456),
                backgroundColor: Color(0xFF8AD2E6),
                textColor: Color(0xFF123456),
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
