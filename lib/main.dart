import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus/screens/login.dart'; // Login 페이지 임포트
import 'package:focus/screens/register.dart'; // Register 페이지 임포트

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

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  final List<String> _images = [
    'images/download.png',
    'images/download(1).png',
    'images/download(2).png',
  ];

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentIndex < _images.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // 전체 배경 흰색
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 헤더
              Header(
                onLoginTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                onRegisterTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
              ),
              // 사진 영역과 블록
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 511,
                    color: Colors.white, // 이미지 배경 흰색
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _images[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  _TopBlock(), // 이미지 위에 고정된 블록
                ],
              ),
              SizedBox(height: 45), // 간격
              // About FOCUS
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "About FOCUS",
                        style: TextStyle(
                          fontSize: 48,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Noto Sans",
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "2000년대 이후로 문제가 되고 있는 청년들의 집중력..!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontFamily: "Noto Sans",
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Image.asset(
                          'images/3.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 45),
              // 공통 섹션 생성
              _buildImageTextSection(
                imagePath: 'images/1.png',
                title: "일일 리포트",
                description: "매일 집중도를 측정하고\n이를 일일 리포트로\n기록해줍니다.",
                isImageLeft: true,
              ),
              SizedBox(height: 45),
              _buildImageTextSection(
                imagePath: 'images/4.png',
                title: "주간 집중도 현황",
                description:
                "주간 집중도를\n그래프로 보여주고\n맞춤형 솔루션을 제공해줍니다.",
                isImageLeft: false,
              ),
              SizedBox(height: 45),
              _buildImageTextSection(
                imagePath: 'images/5.png',
                title: "플래너",
                description: "플래너 기능을 통해\n오늘 공부할 양을\n기록합니다.",
                isImageLeft: true,
              ),
              SizedBox(height: 45),
              _buildImageTextSection(
                imagePath: 'images/2.png',
                title: "측정 화면",
                description:
                "스스로의 집중도를 측정할 수 있습니다.\n실시간 알림을 통해\n 집중도 향상을 도와줍니다.",
                isImageLeft: false,
              ),
              SizedBox(height: 45),
            ],
          ),
        ),
      ),
    );
  }

  // 공통 섹션 생성 메서드
  Widget _buildImageTextSection({
    required String imagePath,
    required String title,
    required String description,
    required bool isImageLeft,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: isImageLeft
            ? [
          Image.asset(
            imagePath,
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 74),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Noto Sans",
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  description,
                  textAlign: TextAlign.start,
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
        ]
            : [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Noto Sans",
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  description,
                  textAlign: TextAlign.start,
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
          SizedBox(width: 74),
          Image.asset(
            imagePath,
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// 헤더 UI
class Header extends StatelessWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const Header({required this.onLoginTap, required this.onRegisterTap});

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
              GestureDetector(
                onTap: onRegisterTap,
                child: _HeaderButton(
                  text: "Register",
                  borderColor: Color(0xFF123456),
                  backgroundColor: Color(0xFF123456),
                  textColor: Colors.white,
                ),
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

// 블록 위젯
class _TopBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 616,
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
              fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
              color: Color(0xFFA39797),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 29),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4C9BB8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            ),
            child: Text(
              "측정 시작하기",
              style: TextStyle(
                fontSize: 40,
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
