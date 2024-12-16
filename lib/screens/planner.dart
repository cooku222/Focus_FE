import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../widgets/header.dart';
import '../utils/jwt_utils.dart';

class PlannerScreen extends StatefulWidget {
  final int userId;
  final DateTime date;

  const PlannerScreen({
    Key? key,
    required this.userId,
    required this.date,
  }) : super(key: key);

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _tasksForSelectedDate = [];
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final TextEditingController _taskTitleController = TextEditingController();

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final String? token = await _secureStorage.read(key: 'accessToken');
    if (token != null) {
      try {
        final decodedToken = JWTUtils.decodeJWT(token);
        print("Decoded Token: $decodedToken");

        setState(() {
          isLoggedIn = true;
        });
        _fetchPlannerData(_focusedDay);
      } catch (e) {
        print("Invalid Token: $e");
        _secureStorage.delete(key: 'accessToken');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchPlannerData(DateTime date) async {
    final String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
        .toString().padLeft(2, '0')}";
    final String apiUrl =
        "http://3.38.191.196/api/planner/${widget.userId}/$formattedDate";

    try {
      final token = await _secureStorage.read(key: 'accessToken');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _tasksForSelectedDate =
              responseData.map<Map<String, dynamic>>((task) {
                return {
                  "title": task['title'] ?? "제목 없음",
                  "completed": task['completed'] ?? false,
                };
              }).toList();
        });
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching planner data: $e");
    }
  }

  Future<void> _createPlanner(String title) async {
    final String formattedDate =
        "${_selectedDay?.year}-${_selectedDay?.month.toString().padLeft(
        2, '0')}-${_selectedDay?.day.toString().padLeft(2, '0')}";

    final String apiUrl = "http://3.38.191.196/api/planner";

    try {
      final token = await _secureStorage.read(key: 'accessToken');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "user_id": widget.userId,
          "title": title,
          "date": formattedDate
        }),
      );

      if (response.statusCode == 200) {
        print("Planner created successfully.");
        _fetchPlannerData(_selectedDay!); // Refresh tasks
      } else {
        print("Failed to create planner: ${response.statusCode}");
      }
    } catch (e) {
      print("Error creating planner: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 추가
          const Header(title: "플래너"),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 캘린더 - 왼쪽에 배치
                  Expanded(
                    flex: 2,
                    child: TableCalendar(
                      firstDay: DateTime.utc(2021, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _fetchPlannerData(selectedDay);
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Color(0xFF8AD2E6),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF4C9BB8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // 간격 추가
                  // 할 일 추가 및 목록 - 오른쪽에 배치
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 할 일 추가 입력 필드 (배경색 추가)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFB6F9FF), // 배경색 설정
                            borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                          ),
                          padding: const EdgeInsets.all(8.0), // 내부 패딩 추가
                          child: SizedBox(
                            width: 500, // 상자의 너비를 줄임
                            child: TextField(
                              controller: _taskTitleController,
                              decoration: const InputDecoration(
                                labelText: "새 할 일 추가",
                                border: InputBorder.none, // 기본 border 제거
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _createPlanner(value);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 할 일 목록
                        Expanded(
                          child: _tasksForSelectedDate.isEmpty
                              ? const Center(
                            child: Text(
                              "No tasks for the selected date.",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          )
                              : ListView.builder(
                            itemCount: _tasksForSelectedDate.length,
                            itemBuilder: (context, index) {
                              final task = _tasksForSelectedDate[index];
                              return ListTile(
                                leading: Icon(
                                  task['completed']
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: task['completed']
                                      ? Colors.green
                                      : Colors.blueAccent,
                                ),
                                title: Text(task["title"]),
                                trailing: Checkbox(
                                  value: task['completed'],
                                  onChanged: (value) {
                                    setState(() {
                                      task['completed'] = value!;
                                    });
                                  },
                                ),
                              );
                            },
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
    );
  }
}