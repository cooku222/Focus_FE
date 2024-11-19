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
        child: Container(
          color: Colors.white, // 전체 배경 흰색 설정
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
                    color: Colors.white, // 배경 흰색
                  ),
                  Positioned(
                    bottom: 50, // 수직 위치 조정
                    left: MediaQuery.of(context).size.width / 2 - 308, // 중앙 정렬 (616 / 2)
                    child: BlockWithText(),
                  ),
                ],
              ),
              SizedBox(height: 35), // 간격
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
                    SizedBox(height: 30), // 간격
                    Text(
                      "2000년대 이후로 문제가 되고 있는 청년들의 집중력...!",
                      style: TextStyle(
                        fontSize: 48,
                        fontFamily: "Noto Sans",
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20), // 문구 아래 간격
                  ],
                ),
              ),
              // images/3.png 전체 표시
              Container(
                width: double.infinity,
                height: 500, // 더 넓은 높이 설정
                child: Image.asset(
                  'images/3.png',
                  fit: BoxFit.contain, // 이미지 비율 유지
                ),
              ),
              SizedBox(height: 30), // 간격
              // 일일 리포트
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 127.0), // 양쪽 간격 127
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/1.png',
                      width: 280,
                      fit: BoxFit.contain, // 원본 비율 유지
                    ),
                    SizedBox(width: 30), // 간격
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
                          SizedBox(height: 15), // 간격
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
              SizedBox(height: 35), // 간격
              // 주간 집중도 현황
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 127.0), // 양쪽 간격 127
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          SizedBox(height: 15), // 간격
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
                    SizedBox(width: 30), // 간격
                    Image.asset(
                      'images/4.png',
                      width: 280,
                      fit: BoxFit.contain, // 원본 비율 유지
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35), // 간격
              // 플래너
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 127.0), // 양쪽 간격 127
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/5.png',
                      width: 280,
                      fit: BoxFit.contain, // 원본 비율 유지
                    ),
                    SizedBox(width: 30), // 간격
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
                          SizedBox(height: 15), // 간격
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
              SizedBox(height: 35), // 간격
              // 측정 화면
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 127.0), // 양쪽 간격 127
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          SizedBox(height: 15), // 간격
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
                    SizedBox(width: 30), // 간격
                    Image.asset(
                      'images/2.png',
                      width: 280,
                      fit: BoxFit.contain, // 원본 비율 유지
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35), // 간격
            ],
          ),
        ),
      ),
    );
  }
}

// Header 위젯
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
                text: "Sign Up",
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

// Header의 텍스트 버튼
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

// Header의 버튼
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

// BlockWithText 위젯
class BlockWithText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 616, // 고정 너비
      height: 280, // 고정 높이
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "(웹 사이트 회원 이름)님의 오늘을 응원합니다",
            style: TextStyle(
              fontSize: 36, // 글자 크기 조정
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "더 효율적인 하루를 만들어드립니다.",
            style: TextStyle(
              fontSize: 20, // 글자 크기 조정
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
              color: Color(0xFFA39797),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // 버튼 클릭 이벤트
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4C9BB8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // 크기 조정
            ),
            child: Text(
              "측정 시작하기",
              style: TextStyle(
                fontSize: 20, // 버튼 글자 크기 조정
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
