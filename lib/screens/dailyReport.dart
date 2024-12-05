import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/header.dart';
import 'weeklyReport.dart'; // WeeklyReportScreen import

class DailyReportScreen extends StatelessWidget {
  final Map<String, dynamic> dummyData = {
    "totalFocusedTime": 21000,
    "totalNotFocusedTime": 9000,
    "totalDuration": 30000,
    "focusedRatio": 0.7,
    "notFocusedRatio": 0.3,
  };

  @override
  Widget build(BuildContext context) {
    final focusedTime = dummyData['totalFocusedTime'];
    final notFocusedTime = dummyData['totalNotFocusedTime'];
    final totalDuration = dummyData['totalDuration'];
    final focusedRatio = dummyData['focusedRatio'];
    final notFocusedRatio = dummyData['notFocusedRatio'];

    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.white, // 배경 색상 흰색으로 설정
      body: Column(
        children: [
          const Header(title: 'Daily Report'), // Header 추가
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
                        formattedDate,
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
                          builder: (context) => WeeklyReportScreen(),
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
