import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'waitingRoom2.dart'; // Import WaitingRoom2

class PlannerScreen extends StatefulWidget {
  final int userId;
  final DateTime date;

  const PlannerScreen({
    Key? key,
    required this.userId,
    required this.date, // Update type to DateTime
  }) : super(key: key);

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
    _checkLoginStatus();
    _fetchPlannerData(_focusedDay);
  }

  Future<void> _checkLoginStatus() async {
    final String? isLoggedIn = await _secureStorage.read(key: 'isLoggedIn');

    if (isLoggedIn != 'true') {
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

  void _navigateToWaitingRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaitingRoom2(userId: 1, date: '2024-12-09'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                      return ListTile(
                        title: Text(task["subject"]),
                        subtitle: Text(task["task"]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _navigateToWaitingRoom,
              child: const Text("Proceed to Waiting Room"),
            ),
          ),
        ],
      ),
    );
  }
}
