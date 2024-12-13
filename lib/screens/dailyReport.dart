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
  final String title; // 추가된 title

  const DailyReportScreen({
    Key? key,
    required this.userId,
    required this.token,
    required this.date,
    required this.title, // title 파라미터 추가
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

  late int userId;

  @override
  void initState() {
    _decodeJWT();
    super.initState();
    selectedDate = widget.date;
    fetchDailyReport();
  }

  void _decodeJWT() {
    try {
      final decodedJWT = JWTUtils.decodeJWT(widget.token);
      print("Decoded JWT: $decodedJWT");
    } catch (e) {
      print("Failed to decode JWT: $e");
    }
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
      body: Column(
        children: [
          const Header(title: 'Daily Report'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        final date = DateTime.parse(selectedDate)
                            .subtract(const Duration(days: 1));
                        setState(() {
                          selectedDate = DateFormat('yyyy-MM-dd').format(date);
                          isLoading = true;
                        });
                        fetchDailyReport();
                      },
                    ),
                    GestureDetector(
                      onTap: _openCalendar,
                      child: Text(
                        selectedDate,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        final date = DateTime.parse(selectedDate)
                            .add(const Duration(days: 1));
                        setState(() {
                          selectedDate = DateFormat('yyyy-MM-dd').format(date);
                          isLoading = true;
                        });
                        fetchDailyReport();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Task List
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: taskList.length,
                      itemBuilder: (context, index) {
                        final task = taskList[index];
                        return Card(
                          child: ListTile(
                            title: Text(task['title']),
                            subtitle: Text(
                                '집중도: ${(task['focusRatio'] * 100).toStringAsFixed(1)}%'),
                            onTap: () {
                              // Update pie chart to focus on specific task
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right: Date, Focus Chart, and Title Table
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          selectedDate,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '집중도',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        // Title Table
                        const Text(
                          'Session Title',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DataTable(
                          columns: const [
                            DataColumn(label: Text('Field')),
                            DataColumn(label: Text('Value')),
                          ],
                          rows: [
                            DataRow(cells: [
                              const DataCell(Text('Title')),
                              DataCell(Text(widget.title)),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Weekly Report Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
          ),
        ],
      ),
    );
  }
}
