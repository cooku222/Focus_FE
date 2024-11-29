import 'dart:html' as html; // For HTML elements
import 'dart:ui_web' as ui; // For platformViewRegistry in Flutter web
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';

class WebcamView extends StatelessWidget {
  final VoidCallback? onCameraAllowed; // Callback when the camera is activated

  const WebcamView({Key? key, this.onCameraAllowed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if running on the web
    if (!kIsWeb) {
      return const Center(
        child: Text("This feature is only available on the web."),
      );
    }

    // Register the HTML view for web
    ui.platformViewRegistry.registerViewFactory(
      'webcam-view',
          (int viewId) {
        // Create an iframe for the HTML content
        final iframe = html.IFrameElement()
          ..src = 'assets/webcam.html' // Path to your webcam HTML file
          ..style.border = 'none'; // Remove iframe border

        // Listen for iframe load event
        iframe.onLoad.listen((event) {
          if (onCameraAllowed != null) {
            onCameraAllowed!(); // Trigger the camera allowed callback
          }
        });

        return iframe;
      },
    );

    // Render the HTML content using HtmlElementView
    return const HtmlElementView(viewType: 'webcam-view');
  }
}
