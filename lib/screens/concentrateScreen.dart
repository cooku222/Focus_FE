import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focus/widgets/webcam_view.dart';

class ConcentrateScreen extends StatefulWidget {
  const ConcentrateScreen({Key? key}) : super(key: key);

  @override
  _ConcentrateScreenState createState() => _ConcentrateScreenState();
}

class _ConcentrateScreenState extends State<ConcentrateScreen> {
  late String _currentTime;
  late String _currentDate;
  late Duration _elapsedTime;
  late DateTime _startTime;
  String _currentMode = "Check"; // "Check" or "Mode"
  bool _isPaused = false; // Pause 상태
  bool _isRecording = true; // 녹화 상태

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _elapsedTime = const Duration();
    _updateTime();
  }

  void _updateTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        final now = DateTime.now();
        setState(() {
          _currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
          _currentDate = "${now.year}년 ${now.month}월 ${now.day}일 (${_weekdayToKorean(now.weekday)})";
          _elapsedTime = now.difference(_startTime);
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
        _timer.cancel();
      } else {
        _updateTime();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsedTimeStr =
        "${_elapsedTime.inHours.toString().padLeft(2, '0')}시간 ${(_elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}분 ${(_elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}초";

    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Stack(
        children: [
          // 중앙 UI
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
                      child: _isPaused
                          ? const Center(
                        child: Text(
                          "웹캠이 일시 중지되었습니다.",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                          : const WebcamView(),
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
          // 우측 버튼 영역
          Positioned(
            right: 30, // 여백 추가
            bottom: 90, // 여백 추가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 집중 모드와 체크 토글
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
                        left: _currentMode == "Check" ? 0 : 131, // 버튼 이동
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
                // Pause 버튼
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
                // Exit 버튼
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
