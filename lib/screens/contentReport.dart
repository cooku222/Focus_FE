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
  double concentrationRatio0 = 0;
  double concentrationRatio1 = 0;
  double concentrationRatio2 = 0;
  double concentrationRatio3 = 0;
  double concentrationRatio4 = 0;

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
          concentrationRatio0 = (data['concentrationRatio0'] ?? 0) * 100;
          concentrationRatio1 = (data['concentrationRatio1'] ?? 0) * 100;
          concentrationRatio2 = (data['concentrationRatio2'] ?? 0) * 100;
          concentrationRatio3 = (data['concentrationRatio3'] ?? 0) * 100;
          concentrationRatio4 = (data['concentrationRatio4'] ?? 0) * 100;
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
            color: Colors.blue, // 파란색
            value: concentrationRatio0,
            title: "${concentrationRatio0.toStringAsFixed(1)}%",
            radius: 80,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.blue, // 파란색
            value: concentrationRatio1,
            title: "${concentrationRatio1.toStringAsFixed(1)}%",
            radius: 80,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.yellow, // 노란색
            value: concentrationRatio2,
            title: "${concentrationRatio2.toStringAsFixed(1)}%",
            radius: 80,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          PieChartSectionData(
            color: Colors.yellow, // 노란색
            value: concentrationRatio3,
            title: "${concentrationRatio3.toStringAsFixed(1)}%",
            radius: 80,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          PieChartSectionData(
            color: Colors.red, // 빨간색
            value: concentrationRatio4,
            title: "${concentrationRatio4.toStringAsFixed(1)}%",
            radius: 80,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 50,
      ),
    );
  }

  /// 색상 매칭 테이블
  Widget _buildColorLegendTable() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: Align(
        alignment: Alignment.bottomRight, // 우측 하단에 위치
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "색상 매칭 테이블",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLegendRow("concentrationRatio0~1", Colors.blue, "파란색"),
            _buildLegendRow("concentrationRatio2~3", Colors.yellow, "노란색"),
            _buildLegendRow("concentrationRatio4", Colors.red, "빨간색"),
          ],
        ),
      ),
    );
  }

  /// 개별 색상 설명 줄
  Widget _buildLegendRow(String label, Color color, String description) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color, // 색상 블록
        ),
        const SizedBox(width: 8),
        Text(
          "$label - $description",
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(), // 상단 헤더
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
          _buildColorLegendTable(), // 색상 테이블 우측 하단에 추가
        ],
      ),
    );
  }
}
