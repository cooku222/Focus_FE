import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/header.dart';

class WeeklyReportScreen extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData = [
    {
      "date": "2024-11-18",
      "userId": 1,
      "totalFocusedTime": 10800,
      "totalNotFocusedTime": 10800,
      "totalDuration": 21600,
      "focusedRatio": 0.5,
      "notFocusedRatio": 0.5
    },
    {
      "date": "2024-11-19",
      "userId": 1,
      "totalFocusedTime": 12000,
      "totalNotFocusedTime": 28000,
      "totalDuration": 40000,
      "focusedRatio": 0.3,
      "notFocusedRatio": 0.7
    },
    {
      "date": "2024-11-20",
      "userId": 1,
      "totalFocusedTime": 12000,
      "totalNotFocusedTime": 18000,
      "totalDuration": 30000,
      "focusedRatio": 0.4,
      "notFocusedRatio": 0.6
    },
    {
      "date": "2024-11-21",
      "userId": 1,
      "totalFocusedTime": 16000,
      "totalNotFocusedTime": 4000,
      "totalDuration": 20000,
      "focusedRatio": 0.8,
      "notFocusedRatio": 0.2
    },
    {
      "date": "2024-11-22",
      "userId": 1,
      "totalFocusedTime": 24000,
      "totalNotFocusedTime": 16000,
      "totalDuration": 40000,
      "focusedRatio": 0.6,
      "notFocusedRatio": 0.4
    },
    {
      "date": "2024-11-23",
      "userId": 1,
      "totalFocusedTime": 4000,
      "totalNotFocusedTime": 16000,
      "totalDuration": 20000,
      "focusedRatio": 0.2,
      "notFocusedRatio": 0.8
    },
    {
      "date": "2024-11-24",
      "userId": 1,
      "totalFocusedTime": 21000,
      "totalNotFocusedTime": 9000,
      "totalDuration": 30000,
      "focusedRatio": 0.7,
      "notFocusedRatio": 0.3
    }
  ];

  final List<Map<String, dynamic>> contentData = [
    {
      "sessionId": 1,
      "sessionName": "Mathmatics",
      "focusedTime": 1800,
      "notFocusedTime": 1800,
      "focusRatio": 0.5,
      "notFocusRatio": 0.5
    },
    {
      "sessionId": 2,
      "sessionName": "English",
      "focusedTime": 1800,
      "notFocusedTime": 1800,
      "focusRatio": 0.5,
      "notFocusRatio": 0.5
    },
    {
      "sessionId": 3,
      "sessionName": "Korean",
      "focusedTime": 1800,
      "notFocusedTime": 1800,
      "focusRatio": 0.5,
      "notFocusRatio": 0.5
    },
    {
      "sessionId": 4,
      "sessionName": "DB",
      "focusedTime": 1800,
      "notFocusedTime": 1800,
      "focusRatio": 0.5,
      "notFocusRatio": 0.5
    },
    {
      "sessionId": 5,
      "sessionName": "OS",
      "focusedTime": 1800,
      "notFocusedTime": 1800,
      "focusRatio": 0.5,
      "notFocusRatio": 0.5
    },
    {
      "sessionId": 6,
      "sessionName": "AI",
      "focusedTime": 1800,
      "notFocusedTime": 1800,
      "focusRatio": 0.5,
      "notFocusRatio": 0.5
    }
  ];

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 30),
                    const Text(
                      '컨텐츠별 집중도 현황',
                      style: TextStyle(
                        fontFamily: 'Hero',
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildContentReportGraph(),
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

            final focusedTimeHours = data['totalFocusedTime'] / 3600;
            final notFocusedTimeHours = data['totalNotFocusedTime'] / 3600;

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
            leftTitles: SideTitles(showTitles: true, getTitles: (value) => '${value.toInt()}h'),
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

  Widget buildContentReportGraph() {
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // 막대 그래프
          BarChart(
            BarChartData(
              barGroups: contentData.map((data) {
                final index = data['sessionId'] - 1;
                final focusedTimeMinutes = data['focusedTime'] / 60;
                final notFocusedTimeMinutes = data['notFocusedTime'] / 60;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      y: focusedTimeMinutes + notFocusedTimeMinutes,
                      rodStackItems: [
                        BarChartRodStackItem(0, notFocusedTimeMinutes, const Color(0xFFBEBEBE)),
                        BarChartRodStackItem(
                          notFocusedTimeMinutes,
                          focusedTimeMinutes + notFocusedTimeMinutes,
                          const Color(0xFF0019FF),
                        ),
                      ],
                      width: 12,
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    if (value % 10 == 0) return '${value.toInt()}분';
                    return '';
                  },
                ),
                rightTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    if (value % 10 == 0) return '${value.toInt()}분';
                    return '';
                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    final index = value.toInt();
                    if (index < contentData.length) {
                      return contentData[index]['sessionName'];
                    }
                    return '';
                  },
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
          // 꺾은선 그래프
          LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: contentData.map((data) {
                    final index = data['sessionId'] - 1;
                    return FlSpot(index.toDouble(), data['focusRatio'] * 100);
                  }).toList(),
                  isCurved: true,
                  colors: [const Color(0xFFFF5722)],
                  barWidth: 4,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitles: (value) {
                    if (value == 0) return '0%';
                    if (value == 50) return '50%';
                    if (value == 100) return '100%';
                    return '';
                  },
                ),
                rightTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitles: (value) {
                    if (value == 0) return '0분';
                    if (value == 50) return '50분';
                    if (value == 100) return '100분';
                    return '';
                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    final index = value.toInt();
                    if (index < contentData.length) {
                      return contentData[index]['sessionName'];
                    }
                    return '';
                  },
                ),
              ),
              maxY: 100,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ],
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
