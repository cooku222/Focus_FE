import 'dart:html';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;

class WaitingRoom extends StatelessWidget {
  const WaitingRoom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Register the HTML view for webcam preview
    ui.platformViewRegistry.registerViewFactory(
      'webcam-view',
          (int viewId) {
        final video = VideoElement()
          ..width = 320
          ..height = 240
          ..autoplay = true;

        // Get user media (webcam stream)
        window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
          video.srcObject = stream;
        }).catchError((error) {
          print('Error accessing webcam: $error');
        });

        return video;
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Main Image with overlay text
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Image.asset(
                  'assets/images/posture.png',
                  width: 764,
                  height: 666,
                  fit: BoxFit.cover,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 48.0),
                  child: Text(
                    '웹캠을 보면서 자세를 유지해주세요',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16), // Spacing between sections
            // Webcam preview and side message
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 320,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: HtmlElementView(viewType: 'webcam-view'), // Embed webcam view
                ),
                const SizedBox(height: 16),
                const Text(
                  '대기 중인 화면입니다',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to WaitingRoom2 using route-based navigation
                    Navigator.pushNamed(context, '/waitingRoom2');
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue), // Button color
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: const Text(
                    '다음 단계로 이동',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
