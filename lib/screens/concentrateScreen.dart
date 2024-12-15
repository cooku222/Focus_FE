import 'dart:ui_web' as ui;
import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:js/js_util.dart';
import 'package:focus/utils/jwt_utils.dart';
import 'package:http/http.dart' as http;
import 'package:focus/screens/dailyReport.dart';

class ConcentrateScreen extends StatefulWidget {
  final int userId;
  final String token;
  final String title;

  const ConcentrateScreen({
    Key? key,
    required this.userId,
    required this.token,
    required this.title,
  }) : super(key: key);

  @override
  State<ConcentrateScreen> createState() => _ConcentrateScreenState();
}

class _ConcentrateScreenState extends State<ConcentrateScreen> {
  late VideoElement videoElement;
  WebSocketChannel? webSocketChannel;
  Timer? captureTimer;
  Timer? pingTimer;
  Timer? clockTimer;

  int? sessionId;
  bool isCapturing = false;
  Duration elapsedTime = Duration.zero;

  String currentTime = '';
  String todayDate = '';
  String webSocketStatus = "Connecting...";

  @override
  void initState() {
    super.initState();
    _decodeJWT();
    _initializeWebcam();
    _startSession();
    _connectToWebSocket();
    _startClock();
  }

  @override
  void dispose() {
    _closeWebSocket();
    captureTimer?.cancel();
    clockTimer?.cancel();
    super.dispose();
  }
  static bool isViewFactoryRegistered = false;

  void _initializeWebcam() async {
    videoElement = VideoElement()
      ..width = 640
      ..height = 480
      ..autoplay = true;

    if (!isViewFactoryRegistered) {
      ui.platformViewRegistry.registerViewFactory(
        'webcam-view',
            (int viewId) => videoElement,
      );
      isViewFactoryRegistered = true;
    }

    final stream = await window.navigator.mediaDevices?.getUserMedia({'video': true});
    videoElement.srcObject = stream;
  }

  void _decodeJWT() {
    try {
      final payload = JWTUtils.decodeJWT(widget.token);
      print("Decoded JWT: $payload");
    } catch (e) {
      print("Failed to decode JWT: $e");
    }
  }


  void _startClock() {
    final now = DateTime.now();
    setState(() {
      currentTime = _formatTime(now);
      todayDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    });

    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        currentTime = _formatTime(now);
      });
    });
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }

  Future<void> _startSession() async {
    try {
      final response = await http.post(
        Uri.parse("http://3.38.191.196/api/video-session/start"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}"
        },
        body: jsonEncode({"user_id": widget.userId, "title": widget.title}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        sessionId = responseData['sessionId'];
      } else {
        print("Failed to start session: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error starting session: $e");
    }
  }

  Future<void> _endSession() async {
    if (sessionId == null) return;

    try {
      final response = await http.post(
        Uri.parse("http://3.38.191.196/api/video-session/end/$sessionId"),
        headers: {
          "Authorization": "Bearer ${widget.token}"
        },
      );

      if (response.statusCode == 200) {
        print("Session ended successfully.");
      } else {
        print("Failed to end session: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error ending session: $e");
    }
  }

  void _connectToWebSocket() {
    final wsUrl = 'ws://3.38.191.196/image';

    try {
      webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      setState(() {
        webSocketStatus = "Connected";
      });

      webSocketChannel!.stream.listen(
            (message) {
          print("Message from server: $message");
        },
        onError: (error) {
          setState(() {
            webSocketStatus = "Error: $error";
          });
        },
        onDone: () {
          setState(() {
            webSocketStatus = "Disconnected";
          });
        },
      );

      pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        webSocketChannel?.sink.add(jsonEncode({"type": "ping"}));
      });
    } catch (e) {
      setState(() {
        webSocketStatus = "Failed to connect: $e";
      });
    }
  }

  void _closeWebSocket() {
    pingTimer?.cancel();
    webSocketChannel?.sink.close();
  }

  void _toggleCapture() {
    if (isCapturing) {
      captureTimer?.cancel();
    } else {
      captureTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          elapsedTime += const Duration(seconds: 1);
        });
      });
    }

    setState(() {
      isCapturing = !isCapturing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Stack(
        children: [
          // Current Time (Top Center)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                currentTime,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 128,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Webcam (Center Bottom)
          Center(
            child: Container(
              width: 320,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: HtmlElementView(viewType: 'webcam-view'),
            ),
          ),

          // Bottom Info (Date & Time)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  todayDate,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Elapsed Time: ${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Right Bottom Buttons
          Positioned(
            bottom: 80,
            right: 20,
            child: Column(
              children: [
                // Start/Pause Button
                GestureDetector(
                  onTap: _toggleCapture,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      isCapturing ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Power Button
                GestureDetector(
                  onTap: () {
                    _endSession();
                    _closeWebSocket();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyReportScreen(
                          userId: widget.userId,
                          token: widget.token,
                          date: todayDate,
                          title: widget.title,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.power_settings_new,
                      color: Colors.red,
                      size: 32,
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
