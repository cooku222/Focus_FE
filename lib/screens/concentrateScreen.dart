import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:js/js_util.dart';
import 'package:http/http.dart' as http;

class ConcentrateScreen extends StatefulWidget {
  const ConcentrateScreen({Key? key, required this.userId, required this.title}) : super(key: key);

  final int userId;
  final String title;

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
  String displayMode = 'Default'; // Modes: 'Default', 'Fullscreen'
  String webSocketStatus = "Connecting...";
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
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

  // Initialize webcam
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

  // Start the clock
  void _startClock() {
    clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now().toLocal().toIso8601String().split('T').first;
      });
    });
  }

  // Start session
  Future<void> _startSession() async {
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

  // Connect to WebSocket
  void _connectToWebSocket() {
    try {
      webSocketChannel = WebSocketChannel.connect(
        Uri.parse("ws://3.38.191.196/image"),
      );

      setState(() {
        webSocketStatus = "Connected";
      });

      webSocketChannel!.stream.listen(
            (message) {
          setState(() {
            messages.add("Received: $message");
          });
          print("Message from server: $message");
        },
        onError: (error) {
          setState(() {
            webSocketStatus = "Error: $error";
          });
          print("WebSocket error: $error");
        },
        onDone: () {
          setState(() {
            webSocketStatus = "Disconnected";
          });
          print("WebSocket connection closed.");
        },
      );
    } catch (e) {
      setState(() {
        webSocketStatus = "Failed to connect: $e";
      });
      print("Failed to connect to WebSocket: $e");
    }
  }

  // End session
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
      } else {
        print("Failed to end session: ${response.body}");
      }
    } catch (e) {
      print("Error ending session: $e");
    }
  }

  // Fetch session summary
  Future<void> _fetchSessionSummary() async {
    try {
      final response = await http.get(
        Uri.parse("http://3.38.191.196/api/video-session/${widget.userId}/$currentTime"),
      );

      if (response.statusCode == 200) {
        final summary = jsonDecode(response.body);
        print("Session Summary: $summary");
      } else {
        print("Failed to fetch session summary: ${response.body}");
      }
    } catch (e) {
      print("Error fetching session summary: $e");
    }
  }

  // Start capturing
  void _startCapturing() {
    captureTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!isCapturing || !isSessionActive || sessionId == null) return;
      _captureAndSendImage();
    });
  }

  // Capture and send image
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
          'session_id': sessionId,
          'timestamp': DateTime.now().toIso8601String(),
        });

        final metadataBytes = Uint8List.fromList(utf8.encode(metadata + '\n'));
        final combinedBuffer = Uint8List(metadataBytes.length + imageBytes.length);
        combinedBuffer.setAll(0, metadataBytes);
        combinedBuffer.setAll(metadataBytes.length, imageBytes);

        webSocketChannel?.sink.add(combinedBuffer);
        print("Image and metadata sent to WebSocket.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Concentration - ${widget.title}"),
      ),
      body: Column(
        children: [
          if (isWebcamInitialized)
            Expanded(
              child: Center(
                child: HtmlElementView(viewType: 'webcam-view'),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: isSessionActive ? null : _startSession,
                child: const Text("Start Session"),
              ),
              ElevatedButton(
                onPressed: isSessionActive ? _endSession : null,
                child: const Text("End Session"),
              ),
              ElevatedButton(
                onPressed: isSessionActive ? _fetchSessionSummary : null,
                child: const Text("Fetch Summary"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
