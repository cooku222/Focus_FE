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
  String sessionName = ""; // 세션 이름 저장 변수
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
        final decodeBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodeBody);
        setState(() {
          sessionName = data['sessionName'] ?? "Focus Distribution"; // 기본값 설정
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
            value: concentrationRatio0 + concentrationRatio1,
            title: "${(concentrationRatio0 + concentrationRatio1).toStringAsFixed(1)}%",
            radius: 110, // 그래프 크기 증가
            titleStyle: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // 글자 크기 증가
          ),
          PieChartSectionData(
            color: Colors.yellow, // 노란색
            value: concentrationRatio2 + concentrationRatio3,
            title: "${(concentrationRatio2 + concentrationRatio3).toStringAsFixed(1)}%",
            radius: 110, // 그래프 크기 증가
            titleStyle: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), // 글자 크기 증가
          ),
          PieChartSectionData(
            color: Colors.red, // 빨간색
            value: concentrationRatio4,
            title: "${concentrationRatio4.toStringAsFixed(1)}%",
            radius: 110, // 그래프 크기 증가
            titleStyle: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // 글자 크기 증가
          ),
        ],
        sectionsSpace: _getSectionSpace(), // 동적으로 구분선 제거
        centerSpaceRadius: 50, // 그래프 중심 공간 조정
      ),
    );
  }


  /// 같은 색상 구분선 제거 로직
  double _getSectionSpace() {
    // 같은 색상이 있는 경우 구분선 제거
    bool sameColors = (concentrationRatio0 > 0 && concentrationRatio1 > 0) ||
        (concentrationRatio2 > 0 && concentrationRatio3 > 0);
    return sameColors ? 0 : 2; // 같은 색상일 경우 0, 아니면 2
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
            _buildLegendRow("집중상태", Colors.blue, "파란색"),
            _buildLegendRow("비집중상태", Colors.yellow, "노란색"),
            _buildLegendRow("졸음", Colors.red, "빨간색"),
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
          width: 28, // 색상 블록 크기 증가
          height: 28, // 색상 블록 크기 증가
          color: color, // 색상 블록
        ),
        const SizedBox(width: 10), // 간격 증가
        Text(
          "$label - $description",
          style: const TextStyle(fontSize: 20), // 텍스트 크기 증가
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
                Text(
                  sessionName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 310,
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
