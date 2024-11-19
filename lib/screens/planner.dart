import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _focusedDay = DateTime.now(); // 오늘 날짜
  DateTime? _selectedDay; // 선택한 날짜

  final List<Map<String, dynamic>> _tasks = []; // 할 일 목록
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    setState(() {
      if (_subjectController.text.isNotEmpty &&
          _taskController.text.isNotEmpty) {
        _tasks.add({
          "subject": _subjectController.text,
          "task": _taskController.text,
          "completed": false,
        });
        _subjectController.clear();
        _taskController.clear();
      }
    });
  }

  void _updateTaskStatus(int index, bool? value) {
    setState(() {
      _tasks[index]["completed"] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Header(),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            SizedBox(height: 16),
            // 달력과 체크리스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 좌측: 달력
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
                      },
                      calendarStyle: CalendarStyle(
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
                  SizedBox(width: 16),
                  // 우측: 체크리스트
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // 입력 폼
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _subjectController,
                                decoration: InputDecoration(
                                  labelText: "과목명 입력",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _taskController,
                                decoration: InputDecoration(
                                  labelText: "할 일 입력",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _addTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8AD2E6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "추가",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // 체크리스트
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFB6F9FF).withOpacity(0.24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              var task = _tasks[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    // 과목 원형 표시
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF8AD2E6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          task["subject"][0], // 과목의 첫 글자
                                          style: TextStyle(
                                            color: Color(0xFF4F378A),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // 과목 이름과 할 일
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task["subject"],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            task["task"],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 체크박스
                                    Checkbox(
                                      value: task["completed"],
                                      onChanged: (value) =>
                                          _updateTaskStatus(index, value),
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
          ],
        ),
      ),
    );
  }
}

// 헤더 위젯
class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 118,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "FOCUS",
            style: TextStyle(
              fontSize: 48,
              height: 1.25,
              color: Color(0xFF123456),
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                "플래너",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // 플래너 bold 처리
                  color: Color(0xFF123456),
                ),
              ),
              SizedBox(width: 16),
              Text("리포트", style: _headerTextStyle),
              SizedBox(width: 16),
              Text("챌린지", style: _headerTextStyle),
              SizedBox(width: 16),
              Text("마이페이지", style: _headerTextStyle),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8AD2E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF123456),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF123456),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle get _headerTextStyle => TextStyle(
    fontSize: 16,
    color: Color(0xFF123456),
  );
}
