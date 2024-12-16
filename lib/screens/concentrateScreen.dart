import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:js/js_util.dart';
import 'package:http/http.dart' as http;

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
  Timer? measureTimer;
  Timer? clockTimer;

  bool isWebcamInitialized = false;
  bool isCapturing = false;
  Duration elapsedTime = Duration.zero; // 측정 시간
  String currentTime = ''; // 현재 시간
  String webSocketStatus = "Connecting...";

  @override
  void initState() {
    super.initState();
    _initializeWebcam();
    _connectToWebSocket();
    _startClock();
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    measureTimer?.cancel();
    clockTimer?.cancel();
    _closeWebSocket();
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
    clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = _formatTime(DateTime.now());
      });
    });
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }

  void _startCapturing() {
    if (isCapturing || !isWebcamInitialized) return;

    setState(() {
      isCapturing = true;
      elapsedTime = Duration.zero;
    });

    measureTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsedTime += const Duration(seconds: 1);
      });
    });

    captureTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _captureAndSendImage();
    });
  }

  void _stopCapturing() {
    setState(() {
      isCapturing = false;
    });
    captureTimer?.cancel();
    measureTimer?.cancel();
  }

  void _connectToWebSocket() {
    final wsUrl = 'ws://3.38.191.196/image';

    try {
      webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      setState(() {
        webSocketStatus = "Connected";
      });
    } catch (e) {
      print("Failed to connect to WebSocket: $e");
    }
  }

  void _closeWebSocket() {
    webSocketChannel?.sink.close();
    print("WebSocket connection closed.");
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
        final arrayBuffer = await  _blobToArrayBuffer(blob);

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
    });
  }

  Future<ByteBuffer> _blobToArrayBuffer(Blob blob) {
    return promiseToFuture(callMethod(blob, 'arrayBuffer', []));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 현재 시간
          Text(
            currentTime,
            style: const TextStyle(fontSize: 48, color: Colors.white),
          ),
          // 측정 시간
          Text(
            "측정 시간: ${elapsedTime.inMinutes.toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 32, color: Colors.white),
          ),
          const SizedBox(height: 20),
          // 웹캠 화면
          Expanded(
            child: Center(
              child: Container(
                width: 320,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isWebcamInitialized
                    ? HtmlElementView(viewType: 'webcam-view')
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 시작/일시정지 버튼
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isCapturing) {
                      _stopCapturing();
                    } else {
                      _startCapturing();
                    }
                  });
                },
                icon: Icon(
                  isCapturing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 48,
                  color: Colors.white,
                ),
                tooltip: isCapturing ? "Pause Capturing" : "Start Capturing",
              ),
              const SizedBox(width: 32),

              // 정지 버튼
              IconButton(
                onPressed: () {
                  _stopCapturing();
                },
                icon: const Icon(
                  Icons.stop_circle,
                  size: 48,
                  color: Colors.red,
                ),
                tooltip: "Stop Capturing",
              ),
              const SizedBox(width: 32),

              // 종료 버튼
              IconButton(
                onPressed: () {
                  _closeWebSocket();
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.exit_to_app,
                  size: 48,
                  color: Colors.blue,
                ),
                tooltip: "Exit",
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
