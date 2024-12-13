import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final String baseUrl = "http://3.38.191.196";
  final AuthService authService;

  ApiService(this.authService);

  Future<Map<String, dynamic>?> fetchDailyReport(int userId, String date) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/daily-report/$userId/$date/summary"),
      headers: authService.getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<dynamic>?> fetchWeeklyReport(int userId, String startDate) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/weekly-report/$userId/$startDate/summary"),
      headers: authService.getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<dynamic>?> fetchVideoSession(int userId, String date) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/video-session/$userId/$date"),
      headers: authService.getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
