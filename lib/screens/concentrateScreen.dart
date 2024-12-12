import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:focus/screens/dailyReport.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart';
import 'package:focus/utils/jwt_utils.dart'; // JWT 디코더 유틸 추가

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
  Timer? clockTimer;

  bool isWebcamInitialized = false;
  bool isCapturing = false;
  bool isPaused = false;
  bool isSessionActive = false;
  int? sessionId;

  String currentTime = '';
  String currentDate = '';
  String startTime = '';
  Duration elapsedTime = Duration.zero;

  Map<String, dynamic>? decodedJWT;

  @override
  void initState() {
    super.initState();
    _decodeJWT();
    _initializeScreen();
  }

  void _decodeJWT() {
    try {
      decodedJWT = JWTUtils.decodeJWT(widget.token);
      print("Decoded JWT: $decodedJWT");
    } catch (e) {
      print("Failed to decode JWT: $e");
    }
  }

  Future<void> _initializeScreen() async {
    await _startSession();
    _connectToWebSocket();
    _startCapturing();
    await _initializeWebcam();
    _startClock();
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    clockTimer?.cancel();
    webSocketChannel?.sink.close();
    videoElement.srcObject?.getTracks().forEach((track) => track.stop());
    super.dispose();
  }

  Future<void> _initializeWebcam() async {
    videoElement = VideoElement()
      ..width = 640
      ..height = 480
      ..autoplay = true;

    try {
      final stream = await window.navigator.mediaDevices?.getUserMedia({'video': true});
      videoElement.srcObject = stream;
      setState(() {
        isWebcamInitialized = true;
      });
    } catch (error) {
      print('Error accessing webcam: $error');
    }
  }

  Future<void> _startSession() async {
    if (sessionId != null) {
      print("Session already started with ID: $sessionId");
      return;
    }

    try {
      final requestBody = {
        "user_id": widget.userId,
        "title": widget.title,
      };

      final response = await http.post(
        Uri.parse("http://3.38.191.196/api/video-session/start"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        sessionId = responseData['sessionId'];
        setState(() {
          isSessionActive = true;
          elapsedTime = Duration.zero;
          final now = DateTime.now();
          startTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        });
        print("Session started successfully with ID: $sessionId");
      } else {
        print("Failed to start session: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error starting session: $e");
    }
  }

  Future<void> _endSession() async {
    if (sessionId == null) {
      print("Cannot end session. Session ID is missing.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://3.38.191.196/api/video-session/end/$sessionId"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        print("Session ended successfully.");
        setState(() {
          isSessionActive = false;
        });
      } else {
        print("Failed to end session: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error ending session: $e");
    }
  }

  Future<ByteBuffer> _blobToArrayBuffer(Blob blob) async {
    return await promiseToFuture(callMethod(blob, 'arrayBuffer', []));
  }

  void _connectToWebSocket() {
    try {
      webSocketChannel = WebSocketChannel.connect(
        Uri.parse("ws://3.38.191.196/image"),
      );
      webSocketChannel!.stream.listen(
            (message) {
          print("Message from WebSocket: $message");
        },
        onError: (error) {
          print("WebSocket error: $error");
        },
        onDone: () {
          print("WebSocket connection closed.");
        },
      );
    } catch (e) {
      print("Failed to connect to WebSocket: $e");
    }
  }

  void _startCapturing() {
    captureTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!isCapturing || isPaused || sessionId == null) return;
      _captureAndSendImage();
      setState(() {
        elapsedTime += const Duration(seconds: 2);
      });
    });
  }

  void _captureAndSendImage() {
    final canvas = CanvasElement(width: 640, height: 480);
    final ctx = canvas.context2D;
    ctx.drawImage(videoElement, 0, 0);

    canvas.toBlob().then((blob) async {
      if (blob == null) return;

      try {
        final arrayBuffer = await _blobToArrayBuffer(blob);
        final imageBytes = Uint8List.view(arrayBuffer);

        final metadata = jsonEncode({
          "user_id": widget.userId,
          "title": widget.title,
        });

        final metadataBytes = Uint8List.fromList(utf8.encode(metadata + '\n'));
        final combinedBuffer = Uint8List(metadataBytes.length + imageBytes.length);
        combinedBuffer.setAll(0, metadataBytes);
        combinedBuffer.setAll(metadataBytes.length, imageBytes);

        webSocketChannel?.sink.add(combinedBuffer);
        print("Image and metadata sent to WebSocket: $metadata");
      } catch (e) {
        print("Error processing image blob: $e");
      }
    });
  }

  void _startClock() {
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      });
    });
  }

  void _exitToDailyReport() {
    if (sessionId != null) {
      _endSession();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReportScreen(
          userId: widget.userId,
          date: currentDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentTime,
            style: const TextStyle(
              fontSize: 64,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (startTime.isNotEmpty)
            Text(
              "Measurement Start Time: $startTime",
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          Text(
            currentDate,
            style: const TextStyle(
              fontSize: 32,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (isSessionActive)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Elapsed Time: ${elapsedTime.inSeconds}s",
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          if (isWebcamInitialized)
            Expanded(
              child: Center(
                child: Container(
                  width: 640,
                  height: 480,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HtmlElementView(viewType: 'webcam-view'),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _endSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C9BB8),
                    fixedSize: const Size(248, 88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("End Session"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _exitToDailyReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C9BB8),
                    fixedSize: const Size(248, 88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Exit"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}