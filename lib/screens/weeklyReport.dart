import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/header.dart';

class WeeklyReportScreen extends StatefulWidget {
  final int userId; // 유저 ID
  final String startDate; // 주간 리포트의 시작 날짜

  const WeeklyReportScreen({Key? key, required this.userId, required this.startDate})
      : super(key: key);

  @override
  _WeeklyReportScreenState createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  List<Map<String, dynamic>> weeklyData = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchWeeklyReport();
  }

  Future<void> fetchWeeklyReport() async {
    final url = 'http://3.38.191.196/api/weekly-report/${widget.userId}/${widget.startDate}/summary';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weeklyData = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load weekly report');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || weeklyData.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load weekly report',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchWeeklyReport,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(title: 'Weekly Report'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '주간 집중도 현황',
                      style: TextStyle(
                        fontFamily: 'Hero',
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildStackedBarChart(),
                    const SizedBox(height: 30),
                    buildSolutionBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStackedBarChart() {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: weeklyData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;

            final focusedTimeHours = (data['totalFocusedTime'] ?? 0) / 3600;
            final notFocusedTimeHours = (data['totalNotFocusedTime'] ?? 0) / 3600;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  y: focusedTimeHours + notFocusedTimeHours,
                  rodStackItems: [
                    BarChartRodStackItem(0, notFocusedTimeHours, const Color(0xFFBEBEBE)),
                    BarChartRodStackItem(notFocusedTimeHours, focusedTimeHours + notFocusedTimeHours,
                        const Color(0xFF0019FF)),
                  ],
                  width: 12,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              getTitles: (value) => '${value.toInt()}h',
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                final index = value.toInt();
                if (index < weeklyData.length) {
                  return weeklyData[index]['date'].split('-').last;
                }
                return '';
              },
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget buildSolutionBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF327B9E),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주간 집중 솔루션',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '1. 학습 세션 단축 및 단계적 증가\n'
                '2. 내용 다양화 및 분할\n'
                '3. 운동과 신체활동 루틴 추가\n'
                '4. 보상 시스템 도입\n'
                '5. 학습 환경 변화\n'
                '6. 잠재적 스트레스 요인 파악\n'
                '7. 마인드 리프레시 시간 도입\n'
                '8. 포기 대신 전환의 원칙 적용\n',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}