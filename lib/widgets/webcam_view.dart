import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WebcamView extends StatefulWidget {
  const WebcamView({Key? key}) : super(key: key);

  @override
  State<WebcamView> createState() => _WebcamViewState();
}

class _WebcamViewState extends State<WebcamView> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // 웹에서 'webcam'이라는 이름으로 HTML 뷰를 등록
      ui.platformViewRegistry.registerViewFactory(
        'webcam-view',
            (int viewId) => IFrameElement()
          ..src = 'assets/webcam.html' // HTML 파일 경로
          ..style.border = 'none',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(
        child: Text("This feature is only available on the web."),
      );
    }

    return const HtmlElementView(viewType: 'webcam-view');
  }
}
