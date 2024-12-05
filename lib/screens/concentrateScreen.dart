import 'dart:html';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;

class ConcentrateScreen extends StatefulWidget {
  const ConcentrateScreen({Key? key}) : super(key: key);

  @override
  State<ConcentrateScreen> createState() => _ConcentrateScreenState();
}

class _ConcentrateScreenState extends State<ConcentrateScreen> {
  DateTime startTime = DateTime.now();
  String currentTime = '';
  String currentDate = '';
  Duration elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeWebcam();
    _startClock();
  }

  void _initializeWebcam() {
    ui.platformViewRegistry.registerViewFactory(
      'webcam-view',
          (int viewId) {
        final video = VideoElement()
          ..width = 320
          ..height = 240
          ..autoplay = true;

        window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
          video.srcObject = stream;
        }).catchError((error) {
          print('Error accessing webcam: $error');
        });

        video.style.height = '100%';
        video.style.width = '100%';

        return video;
      },
    );
  }

  void _startClock() {
    currentTime = _getFormattedTime();
    currentDate = _getFormattedDate();

    // Update the time every second
    Future.delayed(Duration.zero, () {
      setState(() {
        elapsedTime = DateTime.now().difference(startTime);
        currentTime = _getFormattedTime();
      });
    });
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} (${weekdays[now.weekday - 1]})';
  }

  String _getFormattedElapsedTime() {
    final hours = elapsedTime.inHours.toString().padLeft(2, '0');
    final minutes = (elapsedTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsedTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours시간 $minutes분 $seconds초';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424), // 검정 바탕
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentTime,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 128,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentDate,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '측정 시작 시간: ${_getFormattedElapsedTime()}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 320,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: HtmlElementView(viewType: 'webcam-view'), // 웹캠 화면
            ),
          ],
        ),
      ),
    );
  }
}
