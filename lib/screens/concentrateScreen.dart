import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart';
import 'package:focus/utils/jwt_utils.dart';

class ConcentrateScreen extends StatefulWidget {
  final String userId;
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
  String startTime = ''; // For measurement start time
  Duration elapsedTime = Duration.zero;
  String? userId;

  @override
  void initState() {
    super.initState();
    _decodeToken(); // Decode JWT token at initialization
    _connectToWebSocket();
    _startSession();
    _startCapturing();
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

  void _decodeToken() {
    try {
      final payload = JWTUtils.decodeJWT(widget.token);
      userId = payload['userId'] ?? payload['sub'];
      if (userId == null) throw Exception("User ID is missing in the token.");
      print("Decoded User ID: $userId");
    } catch (e) {
      print("Error decoding token: $e");
    }
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
        "user_id": userId,
        "title": widget.title,
      };

      print("Starting session with body: $requestBody");

      final response = await http.post(
        Uri.parse("http://3.38.191.196/api/video-session/start"),
        headers: {
          "Content-Type": "application/json",
          //"Authorization": "Bearer ${widget.token}",
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

  Future<void> _fetchMeasurementData() async {
    if (userId == null || currentDate.isEmpty) {
      print("Cannot fetch measurement data. User ID or date is missing.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://3.38.191.196/api/video-session/$userId/$currentDate"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        print("Measurement data: ${response.body}");
      } else {
        print("Failed to fetch measurement data: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error fetching measurement data: $e");
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
      try {
        final arrayBuffer = await _blobToArrayBuffer(blob);
        final imageBytes = Uint8List.view(arrayBuffer);

        final metadata = jsonEncode({
          "user_id" : userId,
          "title" : widget.title,
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

  void _startClock() {
    clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      });
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
                child: HtmlElementView(viewType: 'webcam-view'),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _fetchMeasurementData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C9BB8),
                    fixedSize: const Size(248, 88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Fetch Data"),
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
                  child: const Text("End Session"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
