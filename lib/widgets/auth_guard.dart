import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, Key? key}) : super(key: key);


  Future<bool> _isLoggedIn() async {
    const storage = FlutterSecureStorage();
    String? isLoggedIn = await storage.read(key: 'isLoggedIn');
    return isLoggedIn == 'true'; // true/false 반환
  }


  @override
  Widget build(BuildContext context) {// 싱글톤 인스턴스 가져오기
    return FutureBuilder<bool>(
      future: _isLoggedIn(), // 로그인 상태 확인
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 로딩 중
        }

        if (snapshot.data == true) {
          return child; // 로그인 상태면 자식 위젯 반환
        } else {
          // 비로그인 상태면 로그인 화면으로 리다이렉트
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const SizedBox.shrink(); // 빈 화면 반환
        }
      },
    );
  }
}
