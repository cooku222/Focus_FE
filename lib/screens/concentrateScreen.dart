import 'dart:html';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:js/js_util.dart';

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
  bool isNotificationMode = false; // Toggle between modes
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

  void _connectToWebSocket() {
    final wsUrl = 'ws://3.38.191.196/image';

    try {
      webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      setState(() {
        webSocketStatus = "Connected";
      });

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

  void _captureAndSendImage() {
    if (!isWebcamInitialized || isPaused) return;

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
          'user_id': 1,
          'title': 'TABA',
          'mode': isNotificationMode ? 'real-time' : 'focus',
        });

        final metadataBytes = Uint8List.fromList(utf8.encode(metadata + '\n'));
        final combinedBuffer = Uint8List(metadataBytes.length + imageBytes.length);
        combinedBuffer.setAll(0, metadataBytes);
        combinedBuffer.setAll(metadataBytes.length, imageBytes);

        webSocketChannel?.sink.add(combinedBuffer);
        print("Metadata and image sent in ${isNotificationMode ? 'real-time' : 'focus'} mode.");
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
    if (isCapturing || !isWebcamInitialized || isPaused) return;

    setState(() {
      isCapturing = true;
    });

    captureTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!isCapturing || isPaused) {
        timer.cancel();
      } else {
        _captureAndSendImage();
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

  void _toggleMode() {
    setState(() {
      isNotificationMode = !isNotificationMode;
      messages.clear(); // Clear messages for the new mode
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
                ElevatedButton(
                  onPressed: _toggleMode,
                  child: Text(isNotificationMode ? "Switch to Focus Mode" : "Switch to Real-Time Mode"),
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
                  child: Text(isCapturing ? "Capturing..." : "Start Capturing"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _stopCapturing,
                  child: const Text("Stop Capturing"),
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
