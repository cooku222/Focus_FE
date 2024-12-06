import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://52.78.38.195";

  String? accessToken;
  String? refreshToken;

  // 로그인 요청
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/sign-in"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        accessToken = data['accessToken'];
        refreshToken = data['refreshToken'];
        return true;
      } else {
        print("Sign-in failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error during sign-in: $e");
      return false;
    }
  }

  // 로그아웃 요청
  Future<void> signOut() async {
    accessToken = null;
    refreshToken = null;
  }

  // 토큰 갱신
  Future<bool> refreshAccessToken() async {
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/refresh-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        accessToken = data['accessToken'];
        return true;
      } else {
        print("Token refresh failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error during token refresh: $e");
      return false;
    }
  }

  // 인증 헤더 가져오기
  Map<String, String> getHeaders() {
    if (accessToken != null) {
      return {"Authorization": "Bearer $accessToken"};
    }
    return {};
  }

  // 로그인 상태 확인
  bool isLoggedIn() {
    return accessToken != null;
  }

  // API 요청 예시
  Future<http.Response?> getData(String endpoint) async {
    final headers = getHeaders();

    if (headers.isEmpty) {
      print("No access token found. Please sign in.");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
      );

      if (response.statusCode == 401) {
        // 토큰 만료 시 갱신
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return getData(endpoint); // 갱신 후 재시도
        } else {
          print("Session expired. Please sign in again.");
          return null;
        }
      }

      return response;
    } catch (e) {
      print("Error during API request: $e");
      return null;
    }
  }
}
