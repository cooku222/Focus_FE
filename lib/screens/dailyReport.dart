import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../widgets/header.dart';
import '../screens/weeklyReport.dart';
import '../utils/jwt_utils.dart';

class DailyReportScreen extends StatefulWidget {
  final int userId;
  final String token;
  final String date;
  final String title;

  const DailyReportScreen({
    Key? key,
    required this.userId,
    required this.token,
    required this.date,
    required this.title,
  }) : super(key: key);

  @override
  _DailyReportScreenState createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  Map<String, dynamic>? reportData;
  List<dynamic> taskList = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedDate = "";

  @override
  void initState() {
    super.initState();
    _decodeJWT();
    selectedDate = widget.date;
    fetchDailyReport();
  }

  Future<void> fetchDailyReport() async {
    final url =
        'http://3.38.191.196/api/daily-report/${widget.userId}/$selectedDate/summary';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reportData = data;
          taskList = data['tasks'] ?? [];
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

  void _decodeJWT() {
    try {
      final decodedJWT = JWTUtils.decodeJWT(widget.token);
      print("Decoded JWT: $decodedJWT");
    } catch (e) {
      print("Failed to decode JWT: $e");
    }
  }
  void _openCalendar() {
    showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          isLoading = true;
        });
        fetchDailyReport();
      }
    });
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

    final focusedRatio = reportData!['focusedRatio'];
    final notFocusedRatio = reportData!['notFocusedRatio'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const Header(title: 'Daily Report'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Title, Task Table
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "일일 리포트",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Title Hero',
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "오늘 집중도 현황",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: ListView.builder(
                                itemCount: taskList.length,
                                itemBuilder: (context, index) {
                                  final task = taskList[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(task['title']),
                                      subtitle: Text(
                                          '집중도: ${(task['focusRatio'] * 100).toStringAsFixed(1)}%'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Right: Date, Focus Chart
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _openCalendar,
                              child: Text(
                                selectedDate,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "집중도",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: const Color(0xFF5EC5EB),
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
                                      color: const Color(0xFF4C9BB8),
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
              ),
            ],
          ),

          // Right Bottom: Weekly Report Button
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyReportScreen(
                      userId: widget.userId,
                      startDate: selectedDate,
                    ),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    ">",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
