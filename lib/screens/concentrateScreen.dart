import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ConcentrateScreen extends StatefulWidget {
  const ConcentrateScreen({Key? key}) : super(key: key);

  @override
  State<ConcentrateScreen> createState() => _ConcentrateScreenState();
}

class _ConcentrateScreenState extends State<ConcentrateScreen> {
  late VideoElement videoElement;
  WebSocketChannel? webSocketChannel;

  bool isWebcamInitialized = false;
  bool isCapturing = false;
  bool isPaused = false;
  Timer? captureTimer;
  Timer? clockTimer;

  String currentTime = '';
  String displayMode = 'Default'; // Modes: 'Default', 'Fullscreen'
  String webSocketStatus = "Connecting...";
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeWebcam();
    _startClock();
    _connectToWebSocket();
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    clockTimer?.cancel();
    webSocketChannel?.sink.close();
    super.dispose();
  }

  // Initialize webcam
  Future<void> _initializeWebcam() async {
    videoElement = VideoElement()
      ..width = 320
      ..height = 240
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

  // WebSocket 연결
  void _connectToWebSocket() {
    final wsUrl = 'ws://52.78.38.195/image';

    try {
      webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      webSocketStatus = "Connected";

      webSocketChannel!.stream.listen((message) {
        setState(() {
          messages.add("Received: $message");
        });
        print("Message from server: $message");
      }, onError: (error) {
        setState(() {
          webSocketStatus = "Error: $error";
        });
        print("WebSocket Error: $error");
      }, onDone: () {
        setState(() {
          webSocketStatus = "Disconnected";
        });
        print("WebSocket connection closed.");
      });
    } catch (e) {
      setState(() {
        webSocketStatus = "Failed to connect: $e";
      });
      print("Failed to connect to WebSocket: $e");
    }
  }

  void _startClock() {
    clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now().toLocal().toIso8601String().split('T').last.split('.').first;
      });
    });
  }

  // 메시지 전송
  void _sendMessage() {
    if (webSocketChannel != null) {
      final message = jsonEncode({'user_id': 1, 'title': 'test_title', 'message': 'Hello Server!'});
      webSocketChannel!.sink.add(message);
      setState(() {
        messages.add("Sent: $message");
      });
    }
  }

  void _startCapturing() {
    if (isCapturing || !isWebcamInitialized || isPaused) return;

    setState(() {
      isCapturing = true;
    });

    captureTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isCapturing || isPaused) {
        timer.cancel();
      } else {
        _captureFrame();
      }
    });
  }

  void _stopCapturing() {
    if (!isCapturing) return;

    setState(() {
      isCapturing = false;
    });

    captureTimer?.cancel();
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _captureFrame() {
    if (!isWebcamInitialized || isPaused) return;

    final canvas = CanvasElement(width: 80, height: 60); // 크기를 80x60으로 축소
    final ctx = canvas.context2D;
    ctx.drawImage(videoElement, 0, 0);

    final base64Image = canvas.toDataUrl('image/jpeg', 0.5).split(',').last;

    try {
      final decoded = base64Decode(base64Image);
      print("Decoded image size: ${decoded.length} bytes");
    } catch (e) {
      print("Base64 decoding failed: $e");
      return;
    }

    final data = {
      'user_id': 1,
      'title': 'test_title',
      'image': base64Image,
    };

    webSocketChannel?.sink.add(jsonEncode(data));
    print('Data sent to WebSocket');
  }

  void _switchMode() {
    setState(() {
      displayMode = displayMode == 'Default' ? 'Fullscreen' : 'Default';
    });
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
                  "Current Time: $currentTime",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _switchMode,
                      child: Text("Switch Mode: $displayMode"),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "WebSocket Status: $webSocketStatus",
                      style: TextStyle(
                        fontSize: 14,
                        color: webSocketStatus == "Connected" ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isWebcamInitialized
                ? Center(
              child: Container(
                width: displayMode == 'Fullscreen' ? double.infinity : 320,
                height: displayMode == 'Fullscreen' ? double.infinity : 240,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCapturing ? Colors.grey : Colors.green,
                  ),
                  child: Text(isCapturing ? "Capturing..." : "Start Capturing"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _stopCapturing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Stop Capturing"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _togglePause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaused ? Colors.orange : Colors.blue,
                  ),
                  child: Text(isPaused ? "Resume" : "Pause"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text("Send Test Message"),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    messages[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
