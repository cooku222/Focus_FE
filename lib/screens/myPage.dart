import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String? _selectedOption = '회원 정보 수정';
  String _email = 'example@example.com'; // Example email
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status on screen load
  }

  Future<void> _checkLoginStatus() async {
    // Retrieve login status from secure storage
    String? isLoggedIn = await _secureStorage.read(key: 'isLoggedIn');

    if (isLoggedIn != 'true') {
      // Redirect to login screen if not logged in
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      body: Row(
        children: [
          // Sidebar for options
          Container(
            width: 200,
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOption('회원 정보 수정', selected: _selectedOption == '회원 정보 수정'),
                _buildOption('로그아웃', selected: _selectedOption == '로그아웃'),
                _buildOption('회원 탈퇴', selected: _selectedOption == '회원 탈퇴'),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _selectedOption == '회원 정보 수정'
                  ? _buildUserInfo()
                  : _selectedOption == '로그아웃'
                  ? _buildLogout()
                  : _buildWithdrawal(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option, {required bool selected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        color: selected ? const Color(0xFF327B9E) : Colors.transparent,
        child: Text(
          option,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Noto Sans KR',
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF434343),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '회원 정보',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Noto Sans KR',
            fontWeight: FontWeight.bold,
            color: Color(0xFF434343),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '이메일',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Noto Sans KR',
            color: Color(0xFF434343),
          ),
        ),
        Text(
          _email,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Noto Sans KR',
            color: Color(0xFF434343),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '소개',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Noto Sans KR',
            color: Color(0xFF434343),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Implement information edit logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x8AD2E6).withOpacity(0.15),
            minimumSize: const Size(286.85, 65.4),
          ),
          child: const Text(
            '수정하기',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Noto Sans KR',
              color: Color(0xFF123456),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogout() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Clear login status
          await _secureStorage.delete(key: 'isLoggedIn');
          // Redirect to login screen
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: const Text('로그아웃'),
      ),
    );
  }

  Widget _buildWithdrawal() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Implement withdrawal logic
          print('회원 탈퇴 요청');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: const Text('회원 탈퇴'),
      ),
    );
  }
}
