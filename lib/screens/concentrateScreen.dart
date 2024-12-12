import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart';

class ConcentrateScreen extends StatefulWidget {
  final int userId;
  final String title;

  const ConcentrateScreen({Key? key, required this.userId, required this.title}) : super(key: key);

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
  bool isSessionStarted = false; // Guard variable to prevent duplicate sessions
  int? sessionId;

  String currentTime = '';
  String currentDate = '';
  Duration elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();

    _startSession();
    _initializeWebcam();
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

  void _startClock() {
    clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} (${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][now.weekday - 1]})";
      });
    });
  }

  Future<void> _startSession() async {
    if (isSessionStarted) return; // Prevent duplicate calls

    setState(() {
      isSessionStarted = true; // Mark session as started
    });

    try {
      final response = await http.post(
        Uri.parse("http://3.38.191.196/api/video-session/start"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "title": widget.title,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        sessionId = responseData['sessionId'];
        setState(() {
          isSessionActive = true;
          elapsedTime = Duration.zero;
        });
        print("Session started successfully with ID: $sessionId");
        _connectToWebSocket();
        _startCapturing();
      } else {
        print("Failed to start session: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error starting session: $e");
    }
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

      print("WebSocket connected.");
    } catch (e) {
      print("Failed to connect to WebSocket: $e");
    }
  }

  Future<void> _endSession() async {
    if (sessionId == null) return;

    try {
      final response = await http.post(
        Uri.parse("http://3.38.191.196/api/video-session/end/$sessionId"),
      );

      if (response.statusCode == 200) {
        print("Session ended successfully.");
        setState(() {
          isSessionActive = false;
          isCapturing = false;
        });
        Navigator.pushNamed(context, '/dailyReport');
      } else {
        print("Failed to end session: ${response.body}");
      }
    } catch (e) {
      print("Error ending session: $e");
    }
  }

  void _startCapturing() {
    setState(() {
      isCapturing = true;
    });

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
      if (blob == null) {
        print("Error: Failed to capture frame as blob.");
        return;
      }

      try {
        final arrayBuffer = await _blobToArrayBuffer(blob);
        final imageBytes = Uint8List.view(arrayBuffer);

        final metadata = jsonEncode({
          'user_id': widget.userId,
          'timestamp': DateTime.now().toIso8601String(),
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
    }).catchError((error) {
      print("Error converting canvas to Blob: $error");
    });
  }

  Future<ByteBuffer> _blobToArrayBuffer(Blob blob) {
    return promiseToFuture(callMethod(blob, 'arrayBuffer', []));
  }

  void _pauseCapturing() {
    setState(() {
      isPaused = true;
      isCapturing = false;
    });
  }

  void _resumeCapturing() {
    setState(() {
      isPaused = false;
      isCapturing = true;
    });
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
              fontSize: 128,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
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
                child: HtmlElementView(viewType: 'webcam-view'),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _pauseCapturing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF535353),
                    fixedSize: const Size(248, 88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Pause"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _endSession,
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
