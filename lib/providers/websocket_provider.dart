import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketProvider extends ChangeNotifier {
  void connectWebSocket(String userId, String title, String image) {
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://3.38.191.196/image'),
    );

    final payload = jsonEncode({
      'user_id': userId,
      'title': title,
      'image': image,
    });

    channel.sink.add(payload);

    channel.stream.listen(
          (message) {
        print("Response from server: $message");
        channel.sink.close();
        notifyListeners();
      },
      onError: (error) {
        print("Error: $error");
        channel.sink.close();
        notifyListeners();
      },
    );
  }
}
