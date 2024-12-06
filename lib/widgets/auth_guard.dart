import 'package:flutter/material.dart';
import 'package:focus/services/auth_service.dart';
import 'package:focus/screens/login.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return child; // 로그인 상태면 화면 반환
        } else {
          return const LoginScreen(); // 비로그인 상태면 로그인 화면
        }
      },
    );
  }
}
