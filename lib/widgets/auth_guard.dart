import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:focus/utils/jwt_utils.dart';
import 'package:focus/screens/waitingRoom2.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  Future<Map<String, dynamic>> _getAuthData() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token != null && token.isNotEmpty) {
      final payload = JWTUtils.decodeJWT(token);
      final userId = payload['user_id']; // JWT에서 userId 추출
      return {'accessToken': token, 'userId': userId};
    }
    return {'accessToken': '', 'userId': -1}; // 비인증 상태
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getAuthData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final authData = snapshot.data!;
          if (authData['accessToken'] != '' && authData['userId'] != -1) {
            // 인증 성공: WaitingRoom2로 데이터 전달
            return WaitingRoom2(
              token: authData['accessToken'],
              userId: authData['userId'],
            );
          }
        }
        // 인증 실패: 로그인 화면으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return const SizedBox(); // 빈 화면 반환
      },
    );
  }
}
