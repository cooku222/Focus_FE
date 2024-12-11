import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../widgets/header.dart';

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
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool isLoggedIn = false;
  final TextEditingController _taskTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final String? loginStatus = await _secureStorage.read(key: 'isLoggedIn');
    if (loginStatus == 'true') {
      setState(() {
        isLoggedIn = true;
      });
      _fetchPlannerData(_focusedDay);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchPlannerData(DateTime date) async {
    final String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final String apiUrl =
        "http://3.38.191.196/api/planner/${widget.userId}/$formattedDate";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          _tasksByDate[date] = responseData.map<Map<String, dynamic>>((task) {
            return {
              "subject": task['title'] ?? "제목 없음",
              "task": task['state'] ?? "대기 중",
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

  Future<void> _addTask(String title) async {
    if (_selectedDay == null) return;
    final String formattedDate =
        "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
    final String apiUrl =
        "http://3.38.191.196/api/planner/${widget.userId}/$formattedDate";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "state": "대기 중"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _tasksByDate[_selectedDay!] ??= [];
          _tasksByDate[_selectedDay!]!.add({
            "subject": title,
            "task": "대기 중",
            "completed": false,
          });
        });
        _taskTitleController.clear();
      } else {
        print("Failed to add task: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  List<Map<String, dynamic>> get _tasksForSelectedDate {
    if (_selectedDay != null) {
      final selectedDate = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );
      return _tasksByDate[selectedDate] ?? [];
    }
    return [];
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
          const Header(title: "플래너"),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "플래너",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar on the left
                Expanded(
                  flex: 2,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2021, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                const SizedBox(width: 16),
                // Task List and Input on the right
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      TextField(
                        controller: _taskTitleController,
                        decoration: const InputDecoration(
                          labelText: "새 할 일 추가",
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _addTask(value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
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
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4C9BB8),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    task["subject"][0], // First letter of the subject
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                task["subject"],
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "상태: ${task['task']}",
                                style: const TextStyle(
                                  color: Color(0xFF8AD2E6),
                                  fontSize: 14,
                                ),
                              ),
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
        ],
      ),
    );
  }
}
