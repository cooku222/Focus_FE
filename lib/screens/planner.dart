import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PlannerScreen extends StatefulWidget {
  final int userId;

  const PlannerScreen({Key? key, required this.userId, required int date}) : super(key: key);

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check if the user is logged in
    _fetchPlannerData(_focusedDay);
  }

  /// Checks if the user is logged in and redirects to the login screen if not
  Future<void> _checkLoginStatus() async {
    final String? isLoggedIn = await _secureStorage.read(key: 'isLoggedIn');

    if (isLoggedIn != 'true') {
      // Redirect to the login screen if the user is not logged in
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchPlannerData(DateTime date) async {
    final String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final String apiUrl =
        "http://52.78.38.195/api/planner/${widget.userId}/$formattedDate";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          _tasksByDate[date] = responseData.map<Map<String, dynamic>>((task) {
            return {
              "subject": task['title'],
              "task": task['state'],
              "completed": false,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "플래너",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Hero",
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          color: Color(0xFF4F378A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tasksForSelectedDate.length,
                      itemBuilder: (context, index) {
                        var task = _tasksForSelectedDate[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8AD2E6),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    task["subject"][0],
                                    style: const TextStyle(
                                      color: Color(0xFF4F378A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task["subject"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      task["task"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: task["completed"],
                                onChanged: (value) {
                                  setState(() {
                                    task["completed"] = value ?? false;
                                  });
                                },
                              ),
                            ],
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
    );
  }
}
