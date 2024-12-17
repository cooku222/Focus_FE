import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:focus/utils/jwt_utils.dart'; // JWT 유틸리티 import
import '../widgets/header.dart'; // 커스텀 헤더 위젯

class FocusPieChartScreen extends StatefulWidget {
  final int sessionId;
  final String token;

  const FocusPieChartScreen({
    Key? key,
    required this.sessionId,
    required this.token,
  }) : super(key: key);

  @override
  State<FocusPieChartScreen> createState() => _FocusPieChartScreenState();
}

class _FocusPieChartScreenState extends State<FocusPieChartScreen> {
  double focusRatio = 0; // 집중도 값
  double notFocusRatio = 0; // 비집중도 값
  bool isLoading = true; // 로딩 상태
  Map<String, dynamic>? decodedJWT; // 디코딩된 JWT

  @override
  void initState() {
    super.initState();
    _decodeJWT();
    _fetchSessionData();
  }

  /// JWT 토큰 디코딩
  void _decodeJWT() {
    try {
      decodedJWT = JWTUtils.decodeJWT(widget.token);
      print("Decoded JWT: $decodedJWT");
    } catch (e) {
      print("Failed to decode JWT: $e");
    }
  }

  /// 세션 데이터 가져오기
  Future<void> _fetchSessionData() async {
    try {
      final response = await http.get(
        Uri.parse("http://3.38.191.196/api/video-session/${widget.sessionId}"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          focusRatio = (data['focusRatio'] ?? 0) * 100;
          notFocusRatio = (data['notFocusRatio'] ?? 0) * 100;
          isLoading = false;
        });
      } else {
        print("Error fetching data: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 파이 차트 생성
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: focusRatio,
            title: "${focusRatio.toStringAsFixed(1)}%",
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.grey,
            value: notFocusRatio,
            title: "${notFocusRatio.toStringAsFixed(1)}%",
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상단에 헤더 추가
          const Header(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (decodedJWT != null) ...[
                  Text(
                    "User: ${decodedJWT!['sub'] ?? 'Unknown'}", // JWT의 sub 값 표시
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
                const Text(
                  "Focus Distribution",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: _buildPieChart(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
