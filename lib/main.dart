
import 'dart:async';
import 'package:focus/utils/jwt_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus/screens/errorScreen.dart';
import 'package:focus/screens/login.dart';
import 'package:focus/screens/register.dart';
import 'package:focus/screens/info1.dart';
import 'package:focus/screens/info2.dart';
import 'package:focus/screens/info3.dart';
import 'package:focus/screens/info4.dart';
import 'package:focus/screens/info5.dart';
import 'package:focus/screens/planner.dart';
import 'package:focus/screens/waitingRoom2.dart';
import 'package:focus/screens/concentrateScreen.dart';
import 'package:focus/screens/dailyReport.dart';
import 'package:focus/widgets/auth_guard.dart';
import 'package:focus/widgets/header.dart';
import 'package:focus/screens/myPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // 기본 경로
      routes: {
        '/': (context) => const MainScreen(), // 메인 화면 보호
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(), // 회원가입 화면
        '/register/info1': (context) => const Info1Screen(),
        '/register/info2': (context) => const Info2Screen(),
        '/register/info3': (context) => const Info3Screen(),
        '/register/info4': (context) => const Info4Screen(),
        '/register/info5': (context) => const Info5Screen(),
        '/planner': (context) {
          return AuthGuard(
            child: PlannerScreen(
              userId: -1,
              date: DateTime.now(),
            ),
          );
        },
        '/waitingRoom2': (context) {
          return AuthGuard(
            child: WaitingRoom2(
              token: '', // 기본값, AuthGuard에서 설정
              userId: -1,
            ),
          );
        },
// 대기실 2 화면 보호
        '/concentrateScreen': (context) => AuthGuard(
          child: ConcentrateScreen(
            userId: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>)['userId'],
            token: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>)['accessToken'],
            title: (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>)['title'],
          ),
        ),
        // 집중 화면 보호
        '/dailyReport': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return AuthGuard(
            child: DailyReportScreen(
              userId: args?['userId'] ?? -1,
              token: args?['token'] ?? '',
              date: args?['date'] ?? '',
              title: args?['title'] ?? '',
            ),
          );
        },
        // 일일 리포트 화면 보호
        '/myPage': (context) {
          return AuthGuard(
            child: MyPageScreen()
          );
        }, // 마이페이지 보호
      },
      onUnknownRoute: (settings) {
        // 잘못된 경로 처리
        return MaterialPageRoute(
          builder: (context) => const ErrorScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  const MainScreen({Key? key}) : super(key: key);


  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController(initialPage: 0);// WebSocket 매니저 초기화

  final List<Map<String, String>> contentList = [
    {
      "imagePath": "images/1.png",
      "title": "일일 리포트",
      "description": "매일 집중도를 측정하고\n이를 일일 리포트로\n기록해줍니다.",
    },
    {
      "imagePath": "images/4.png",
      "title": "주간 집중도 현황",
      "description": "주간 집중도를\n그래프로 보여주고\n맞춤형 솔루션을 제공해줍니다.",
    },
    {
      "imagePath": "images/5.png",
      "title": "플래너",
      "description": "플래너 기능을 통해\n오늘 공부할 양을\n기록합니다.",
    },
    {
      "imagePath": "images/2.png",
      "title": "측정 화면",
      "description": "스스로의 집중도를 측정할 수 있습니다.\n실시간 알림을 통해\n 집중도 향상을 도와줍니다.",
    },
  ];

  String username = "Guest";

  @override
  void initState() {
    super.initState();// WebSocket 연결
    _checkLoginStatus();
    _fetchUsername();
  }

  Future<void> _checkLoginStatus() async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'accessToken'); // Check for the token
      if (token != null && token.isNotEmpty) {
        // Decode the token to verify validity
        final payload = JWTUtils.decodeJWT(token);
        final userId = payload['sub']; // Assuming 'sub' contains the user ID

        if (userId != null) {
          print("User is logged in. User ID: $userId");
          setState(() {
            username = userId; // Update username with the userId or actual name
          });
          return; // Prevent navigation to the login screen
        }
      }

      // If not logged in, set username to 'Guest'
      setState(() {
        username = 'Guest';
      });

      // Redirect to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e) {
      print("Error checking login status: $e");

      // Handle login error: set as guest and redirect to login
      setState(() {
        username = 'Guest';
      });
    }
  }

  Future<void> _fetchUsername() async {
    // Simulating fetching username from secure storage or API
    final fetchedUsername = await Future.value("John Doe"); // Replace with actual fetch logic
    setState(() {
      username = fetchedUsername;
    });
  }

  // ignore: unused_field
  int _currentIndex = 0;

  final List<String> _images = [
    'images/download.png',
    'images/download(1).png',
    'images/download(2).png',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child:
            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Header(
                onPlannerTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlannerScreen(
                        userId: 1, // Replace with actual user ID
                        date: DateTime.now(), // Current date
                      ),
                    ),
                  );
                },
                onLoginTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                onRegisterTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(),
                    ),
                  );
                },
                onMyReportTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyReportScreen(
                        userId: 1, // Replace with actual user ID
                        date: '', // Example date in string format
                        title: '',
                        token: '',
                      ),
                    ),
                  );
                },
                onMyPageTap: () { // New functionality added
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyPageScreen(), // Navigate to MyPage screen
                    ),
                  );
                },
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 511,
                    color: Colors.white,
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
                  _TopBlock(
                    onMeasureTap: () async {
                      const storage = FlutterSecureStorage();
                      String? token = await storage.read(key: 'accessToken'); // 저장된 토큰 읽기
                      int? userId; // JWT에서 userId 추출용

                      if (token != null && token.isNotEmpty) {
                        // JWT를 디코딩하여 userId를 가져옵니다.
                        final payload = JWTUtils.decodeJWT(token);
                        userId = payload['user_id']; // JWT에서 userId 추출
                      }
                      if (token == null || userId == null) {
                        // 토큰이나 userId가 없으면 로그인을 요청합니다.
                        print("Access token or user ID is missing. Redirecting to login.");
                        Navigator.pushNamed(context, '/login');
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingRoom2(
                            token: token, // 전달할 accessToken
                            userId: userId ?? -1,     // 전달할 userId
                          ),
                        ),
                      );
                    },
                    username: username,
                  ),
                ],
              ),
              const SizedBox(height: 45),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const Text(
                        "About FOCUS",
                        style: TextStyle(
                          fontSize: 48,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Noto Sans",
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "2000년대 이후로 문제가 되고 있는 청년들의 집중력..! ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontFamily: "Noto Sans",
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Image.asset(
                          'images/3.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (var entry in contentList.asMap().entries)
                        _buildContentSection(entry.value, entry.key % 2 == 0),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildContentSection(Map<String, String> content, bool isImageCenter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isImageCenter) ...[
            Image.asset(
              content['imagePath']!,
              width: 583,
              height: 412,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    content['title']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Noto Sans",
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    content['description']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Noto Sans",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    content['title']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Noto Sans",
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    content['description']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Noto Sans",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Image.asset(
              content['imagePath']!,
              width: 583,
              height: 412,
              fit: BoxFit.cover,
            ),
          ]
        ],
      ),
    );
  }
}


class _TopBlock extends StatelessWidget {
  final String username; // Accept username

  const _TopBlock({
    required this.username, required onMeasureTap, // Initialize username
  });

  Future<void> _handleMeasureTap(BuildContext context) async {
    const storage = FlutterSecureStorage();
    try {
      // 토큰 읽기
      final token = await storage.read(key: 'accessToken');
      if (token != null && token.isNotEmpty) {
        // JWT 디코딩을 통해 토큰 유효성 확인
        final payload = JWTUtils.decodeJWT(token);
        final userId = payload['user_id']; // JWT에서 사용자 ID 추출

        if (userId != null) {
          // 로그인 상태라면 WaitingRoom으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaitingRoom2(
                token: token, // 전달할 accessToken
                userId: userId ?? -1,     // 전달할 userId
              ),
            ),
          );
          return;
        }
      }
      // 토큰이 없거나 유효하지 않은 경우 로그인 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      print("Error checking login status: $e");
      // 예외 발생 시 로그인 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }


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
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        children: [
          Text(
            "$username님의 오늘을 응원합니다",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 29),
          const Text(
            "더 효율적인 하루를 만들어드립니다.",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontFamily: "Inter",
              color: Color(0xFFA39797),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 29),
          ElevatedButton(
            onPressed: () => _handleMeasureTap(context), // Updated onPressed
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C9BB8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 32.0),
            ),
            child: const Text(
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