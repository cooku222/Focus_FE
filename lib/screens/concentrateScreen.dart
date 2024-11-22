import 'dart:async';
import 'package:flutter/material.dart';
import 'package:focus/widgets/webcam_view.dart';

class ConcentrateScreen extends StatefulWidget {
  const ConcentrateScreen({Key? key}) : super(key: key);

  @override
  _ConcentrateScreenState createState() => _ConcentrateScreenState();
}

class _ConcentrateScreenState extends State<ConcentrateScreen> {
  String _currentTime = ""; // Initialize with an empty string
  String _currentDate = ""; // Initialize with an empty string
  Duration _elapsedTime = const Duration();
  DateTime? _startTime; // Optional to handle null safely
  String _currentMode = "Check"; // "Check" or "Mode"
  bool _isPaused = false; // Pause state
  bool _isRecording = false; // Recording state

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime(); // Initialize current time
    _currentDate = _getCurrentDate(); // Initialize current date
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.year}년 ${now.month}월 ${now.day}일 (${_weekdayToKorean(now.weekday)})";
  }

  void _updateTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && _startTime != null) {
        final now = DateTime.now();
        setState(() {
          _currentTime = _getCurrentTime();
          _currentDate = _getCurrentDate();
          _elapsedTime = now.difference(_startTime!);
        });
      }
    });
  }

  String _weekdayToKorean(int weekday) {
    const weekdays = ["월", "화", "수", "목", "금", "토", "일"];
    return weekdays[weekday - 1];
  }

  void _toggleMode() {
    setState(() {
      _currentMode = _currentMode == "Check" ? "Mode" : "Check";
    });
  }

  void _pauseWebcam() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _isRecording = false; // Stop recording
      } else {
        _isRecording = true; // Resume recording
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsedTimeStr = _startTime == null
        ? "00시간 00분 00초"
        : "${_elapsedTime.inHours.toString().padLeft(2, '0')}시간 ${(_elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}분 ${(_elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}초";

    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Stack(
        children: [
          // Central UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentTime,
                  style: const TextStyle(
                    fontSize: 128,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentDate,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "총 측정 시간: $elapsedTimeStr",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SizedBox(
                      width: 428,
                      height: 241,
                      child: WebcamView(
                        onCameraAllowed: () {
                          setState(() {
                            _startTime = DateTime.now();
                            _isRecording = true; // Start recording
                            _updateTime();
                          });
                        },
                      ),
                    ),
                    if (_isRecording)
                      Positioned(
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "녹화 중",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Right-side button area
          Positioned(
            right: 30,
            bottom: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Mode toggle
                Container(
                  width: 248,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5C5C5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: _currentMode == "Check" ? 0 : 131,
                        child: Container(
                          width: 117,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C9BB8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _currentMode == "Check" ? "집중도 체크" : "집중 모드",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleMode,
                        child: Container(width: 248, height: 88, color: Colors.transparent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Pause button
                ElevatedButton(
                  onPressed: _pauseWebcam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF535353),
                    fixedSize: const Size(248, 88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _isPaused ? "Resume" : "Pause",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Exit button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C9BB8),
                    fixedSize: const Size(248, 88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Exit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
