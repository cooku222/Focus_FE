import 'dart:html';
import 'dart:ui_web' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConcentrateScreen extends StatefulWidget {
  const ConcentrateScreen({Key? key}) : super(key: key);

  @override
  State<ConcentrateScreen> createState() => _ConcentrateScreenState();
}

class _ConcentrateScreenState extends State<ConcentrateScreen> {
  late VideoElement videoElement;
  bool isWebcamInitialized = false;
  bool isCapturing = false;
  Timer? captureTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebcam();
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    super.dispose();
  }

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

  void _startCapturing() {
    if (isCapturing || !isWebcamInitialized) return;

    setState(() {
      isCapturing = true;
    });

    captureTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!isCapturing) {
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

  void _captureFrame() {
    if (!isWebcamInitialized) return;

    final canvas = CanvasElement(width: 320, height: 240);
    final ctx = canvas.context2D;

    // Draw the current frame onto the canvas
    ctx.drawImage(videoElement, 0, 0);

    // Convert canvas to Base64
    final base64String = canvas.toDataUrl('image/png'); // "data:image/png;base64,..."

    // Extract Base64 content and decode to binary
    final base64Content = base64String.split(',')[1];
    final binaryData = base64Decode(base64Content);

    // Send binary data to the backend
    _sendBinaryToBackend(binaryData);
  }

  Future<void> _sendBinaryToBackend(Uint8List binaryData) async {
    try {
      final response = await http.post(
        Uri.parse('http://52.78.38.195/api/video-frame'),
        headers: {
          'Content-Type': 'application/octet-stream', // Binary MIME type
        },
        body: binaryData, // Binary data as the request body
      );

      if (response.statusCode == 200) {
        print('Frame sent successfully');
      } else {
        print('Failed to send frame: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending frame: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: isWebcamInitialized
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 320,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: HtmlElementView(viewType: 'webcam-view'),
          ),
          const SizedBox(height: 32),
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
            ],
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
