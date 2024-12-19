import 'dart:ui_web' as ui;
import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:js/js_util.dart';
import 'package:focus/utils/jwt_utils.dart';
import 'package:http/http.dart' as http;
import 'package:focus/screens/contentReport.dart';

void registerWebcamView() {
  ui.platformViewRegistry.registerViewFactory(
    'webcam-view',
        (int viewId) {
      final videoElement = VideoElement()
        ..autoplay = true
        ..width = 640
        ..height = 480;

      // 사용자 카메라 스트림 연결
      window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
        videoElement.srcObject = stream;
      });

      return videoElement;
    },
  );
}

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
  int? sessionId;
  int concentration = 0;
  bool isWebcamInitialized = false;
  bool isCapturing = false;

  String webSocketStatus = "Connecting...";

  @override
  void initState() {
    super.initState();
    registerWebcamView();
    _initializeWebcam();
    _startSession();
    _connectToWebSocket();
    _decodeJWT();
  }

  @override
  void dispose() {
    _closeWebSocket();
    captureTimer?.cancel();
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
        print("Session started successfully with ID: $sessionId");
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
  /// 웹소켓 연결
  void _connectToWebSocket() {
    final wsUrl = 'ws://3.38.191.196/image';

    try {
      webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      setState(() {
        webSocketStatus = "Connected";
      });

      // Listen for WebSocket messages
      webSocketChannel!.stream.listen(
            (message) {
          print("Message from server: $message");

          // Parse JSON data and update concentrate value
          try {
            final data = jsonDecode(message);
            if (data['concentration'] != null) {
              setState(() {
                concentration = data['concentration'];
              });
            }
          } catch (e) {
            print("Error parsing WebSocket message: $e");
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          setState(() {
            webSocketStatus = "Error: $error";
          });
        },
        onDone: () {
          print("WebSocket connection closed.");
          setState(() {
            webSocketStatus = "Disconnected";
          });
        },
      );

      // Send ping messages to keep the WebSocket alive
      pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        webSocketChannel?.sink.add(jsonEncode({"type": "ping"}));
        print("Ping sent to keep connection alive.");
      });
    } catch (e) {
      print("Failed to connect to WebSocket: $e");
      setState(() {
        webSocketStatus = "Failed to connect: $e";
      });
    }
  }

  /// concentrate 값에 따라 테두리 색상 반환
  Color _getBorderColor() {
    if (concentration == 0 || concentration == 1) {
      return Colors.blue; // 0, 1 -> 빨간색
    } else if (concentration == 2 || concentration == 3) {
      return Colors.yellow; // 2, 3 -> 노란색
    } else if (concentration == 4) {
      return Colors.red; // 4 -> 회색
    } else {
      return Colors.transparent; // 예외 값 -> 투명
    }
  }

  void _closeWebSocket() {
    pingTimer?.cancel();
    webSocketChannel?.sink.close();
    print("WebSocket connection closed by user.");
  }

  void _decodeJWT() {
    try {
      final decodedJWT = JWTUtils.decodeJWT(widget.token);
      print("Decoded JWT: $decodedJWT");
    } catch (e) {
      print("Failed to decode JWT: $e");
    }
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

  Future<ByteBuffer> _blobToArrayBuffer(Blob blob) {
    return promiseToFuture(callMethod(blob, 'arrayBuffer', []));
  }

  void _startCapturing() {
    if (isCapturing || !isWebcamInitialized) return;

    setState(() {
      isCapturing = true;
    });

    captureTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _captureAndSendImage();
    });
  }

  void _stopCapturing() {
    if (!isCapturing) return;

    setState(() {
      isCapturing = false;
    });

    captureTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "WebSocket Status: $webSocketStatus",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () {
                    _endSession();
                    _closeWebSocket();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FocusPieChartScreen(
                          sessionId: sessionId!,     // 기존 화면에서 받은 userId
                          token: widget.token,       // 기존 화면에서 받은 token
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Exit"),
                ),
              ],
            ),
          ),
          Expanded(
            child: isWebcamInitialized
                ? Center(
              child: Container(
                width: 320,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _getBorderColor(), width: 8),
                ),
                child: HtmlElementView(viewType: 'webcam-view'),
              ),
            )
                : const Center(child: CircularProgressIndicator()),
          ),
          if (isWebcamInitialized)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startCapturing,
                  child: const Text("Start Capturing"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _stopCapturing,
                  child: const Text("Stop Capturing"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}