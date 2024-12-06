import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/header.dart';
import '../screens/weeklyReport.dart';

class DailyReportScreen extends StatefulWidget {
  final int userId;
  final String date;

  const DailyReportScreen({Key? key, required this.userId, required this.date})
      : super(key: key);

  @override
  _DailyReportScreenState createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  Map<String, dynamic>? reportData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchDailyReport();
  }

  Future<void> fetchDailyReport() async {
    final url = 'http://52.78.38.195/api/daily-report/${widget.userId}/${widget.date}/summary';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          reportData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load daily report');
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

    if (hasError || reportData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load daily report',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchDailyReport,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final focusedTime = reportData!['totalFocusedTime'];
    final notFocusedTime = reportData!['totalNotFocusedTime'];
    final totalDuration = reportData!['totalDuration'];
    final focusedRatio = reportData!['focusedRatio'];
    final notFocusedRatio = reportData!['notFocusedRatio'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(title: 'Daily Report'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '오늘 집중도 현황',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildStatItem(
                                  '1', '집중한 시간', formatTime(focusedTime)),
                              buildStatItem('2', '집중하지 않은 시간',
                                  formatTime(notFocusedTime)),
                              buildStatItem(
                                  '3', '전체 시간', formatTime(totalDuration)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              const Text(
                                '집중도',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: focusedRatio * 100,
                                        title:
                                        '${(focusedRatio * 100).toStringAsFixed(1)}%',
                                        titleStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: notFocusedRatio * 100,
                                        title:
                                        '${(notFocusedRatio * 100).toStringAsFixed(1)}%',
                                        titleStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeeklyReportScreen(
                            userId: 1, // 사용자의 ID
                            startDate: "2024-12-01", // 주간 리포트 시작 날짜
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "주간 리포트 보기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatItem(String order, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$order. ',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
