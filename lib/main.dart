import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Header(),
            // 사진 공간 및 블록
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 511,
                  color: Colors.white,
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: BlockWithText(),
                ),
              ],
            ),
            SizedBox(height: 45),
            // About FOCUS 섹션
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About FOCUS",
                    style: TextStyle(
                      fontSize: 48,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 45),
                  Text(
                    "2000년대 이후로 문제가 되고 있는 청년들의 집중력..!",
                    style: TextStyle(
                      fontSize: 48,
                      fontFamily: "Noto Sans",
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 45),
                  Container(
                    height: 400, // 도표 공간 (공백)
                    color: Colors.white,
                  ),
                  SizedBox(height: 45),
                ],
              ),
            ),
            // 일일 리포트
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/1.png',
                    width: 300, // 적당한 이미지 크기 설정
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 45),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "일일 리포트",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 29),
                        Text(
                          "매일 집중도를 측정하고\n이를 일일 리포트로\n기록해줍니다.",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 45),
            // 주간 집중도 현황
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "주간 집중도 현황",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 29),
                        Text(
                          "주간 집중도를\n그래프로 보여주고\n맞춤형 솔루션을 제공해줍니다.",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 45),
                  Image.asset(
                    'images/4.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SizedBox(height: 45),
            // 플래너
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/5.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 45),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "플래너",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 29),
                        Text(
                          "플래너 기능을 통해\n오늘 공부할 양을\n기록합니다.",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 45),
            // 측정 화면
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "측정 화면",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 29),
                        Text(
                          "스스로의 집중도를\n측정할 수 있습니다.\n실시간 알림을 통해\n집중도 향상을\n도와줍니다.",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Noto Sans",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 45),
                  Image.asset(
                    'images/2.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SizedBox(height: 45),
          ],
        ),
      ),
    );
  }
}

// 블록 위젯과 헤더 코드는 동일
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
          // FOCUS 텍스트
          Text(
            "FOCUS",
            style: TextStyle(
              fontSize: 48,
              height: 1.25,
              color: Color(0xFF123456),
              fontWeight: FontWeight.bold,
            ),
          ),
          // 버튼 섹션
          Row(
            children: [
              _HeaderTextButton(text: "플래너"),
              _HeaderTextButton(text: "리포트"),
              _HeaderTextButton(text: "챌린지"),
              _HeaderTextButton(text: "마이페이지"),
              SizedBox(width: 16),
              _HeaderButton(
                text: "Sign Up",
                borderColor: Color(0xFF123456),
                backgroundColor: Color(0xFF8AD2E6),
                textColor: Color(0xFF123456),
              ),
              SizedBox(width: 8),
              _HeaderButton(
                text: "Register",
                borderColor: Color(0xFF123456), // Border/Brand/Default 색상
                backgroundColor: Color(0xFF123456),
                textColor: Colors.white, // Text/Brand/On Brand 색상
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 헤더 내 글자 버튼
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

// 헤더 내 버튼
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

// 블록 위젯
class BlockWithText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        children: [
          Text(
            "(웹 사이트 회원 이름)님의 오늘을 응원합니다",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600, // Semi Bold
              fontFamily: "Inter",
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 29),
          Text(
            "더 효율적인 하루를 만들어드립니다.",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500, // Medium
              fontFamily: "Inter",
              color: Color(0xFFA39797),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 29),
          // 버튼
          ElevatedButton(
            onPressed: () {
              // 버튼 클릭 이벤트
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4C9BB8), // 버튼 색상
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            ),
            child: Text(
              "측정 시작하기",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600, // Semi Bold
                fontFamily: "Inter",
                color: Colors.white, // 문구 색상
              ),
            ),
          ),
        ],
      ),
    );
  }
}