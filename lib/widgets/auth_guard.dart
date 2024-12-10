import 'package:flutter/material.dart';
import 'package:focus/services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(); // 싱글톤 인스턴스 가져오기

    return FutureBuilder<bool>(
      future: Future.value(authService.isLoggedIn()), // 로그인 상태 확인
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
