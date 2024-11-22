import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WebcamView extends StatelessWidget {
  final ui.VoidCallback? onCameraAllowed; // 카메라 활성화 콜백

  const WebcamView({Key? key, this.onCameraAllowed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(
        child: Text("This feature is only available on the web."),
      );
    }

    // 웹에서 'webcam'이라는 이름으로 HTML 뷰를 등록
    ui.platformViewRegistry.registerViewFactory(
      'webcam-view',
          (int viewId) {
        final iframe = IFrameElement()
          ..src = 'assets/webcam.html' // HTML 파일 경로
          ..style.border = 'none';

        iframe.onLoad.listen((event) {
          // 카메라 활성화 시 콜백 호출
          if (onCameraAllowed != null) {
            onCameraAllowed!();
          }
        });

        return iframe;
      },
    );

    return const HtmlElementView(viewType: 'webcam-view');
  }
}

