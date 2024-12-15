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
  bool isWebcamInitialized = false; // 웹캠 초기화 상태 플래그

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
    _captureAndSendImage();
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
    setState(() {
      isWebcamInitialized = true; // 웹캠 초기화 완료
    });
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

  void _captureAndSendImage() {
    if (!isWebcamInitialized || !isCapturing) return;

    final canvas = CanvasElement(width: 640, height: 480);
    final ctx = canvas.context2D;
    ctx.drawImage(videoElement, 0, 0);

    canvas.toBlob().then((blob) async {
      if (blob == null) {
        print("Error: Failed to capture frame as blob.");
        return;
      }

      try {
        final arrayBuffer = await _blobToArrayBuffer(blob);
        final imageBytes = Uint8List.view(arrayBuffer);

        final metadata = jsonEncode({
          'user_id': widget.userId,
          'title': widget.title,
        });

        final metadataBytes = Uint8List.fromList(utf8.encode(metadata + '\n'));
        final combinedBuffer = Uint8List(metadataBytes.length + imageBytes.length);
        combinedBuffer.setAll(0, metadataBytes);
        combinedBuffer.setAll(metadataBytes.length, imageBytes);

        webSocketChannel?.sink.add(combinedBuffer);
        print("Metadata and image sent.");
      } catch (e) {
        print("Error processing image blob: $e");
      }
    }).catchError((error) {
      print("Error converting canvas to Blob: $error");
    });
  }

  // Blob → ArrayBuffer 변환 유틸리티 메서드
  Future<ByteBuffer> _blobToArrayBuffer(Blob blob) {
    final completer = Completer<ByteBuffer>();
    final reader = FileReader();

    reader.readAsArrayBuffer(blob); // Blob을 ArrayBuffer로 읽기
    reader.onLoadEnd.listen((_) {
      if (reader.result != null) {
        completer.complete(reader.result as ByteBuffer); // 변환 성공
      } else {
        completer.completeError("Failed to convert Blob to ArrayBuffer");
      }
    });

    reader.onError.listen((_) {
      completer.completeError(reader.error ?? "Unknown error during Blob to ArrayBuffer conversion");
    });

    return completer.future;
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
          "Content-Type": "application/json",
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

      pingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
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
                const SizedBox(height: 16),
                // New + Button
                GestureDetector(
                  onTap: () async {
                    await _endSession(); // End session and save to database
                    _closeWebSocket(); // Close the WebSocket connection
                    Navigator.pushReplacementNamed(context, '/waitingRoom2'); // Navigate to waitingRoom2
                  },
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
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
