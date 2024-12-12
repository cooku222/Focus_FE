import 'dart:html';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';

class WebSocketManager {
  WebSocket? _webSocket;
  bool _isConnected = false;

  void connect() {
    try {
      _webSocket = WebSocket('ws://3.38.191.196/image');

      // 연결 성공
      _webSocket?.onOpen.listen((event) {
        print("WebSocket Connected");
        _isConnected = true;
      });

      // 메시지 수신
      _webSocket?.onMessage.listen((event) {
        print("Message from server: ${event.data}");
      });

      // 연결 종료
      _webSocket?.onClose.listen((event) {
        print("WebSocket Disconnected");
        _isConnected = false;
      });

      // 에러 처리
      _webSocket?.onError.listen((event) {
        print("WebSocket Error: $event");
        _isConnected = false;
      });
    } catch (e) {
      print("Failed to connect WebSocket: $e");
      _isConnected = false;
    }
  }

  Future<void> sendImageAndMetadata(String userId, String title, Uint8List imageBytes) async {
    if (_isConnected && _webSocket != null) {
      try {
        // JSON 메타데이터 생성
        final metadata = jsonEncode({
          'user_id': userId,
          'title': title,
        });

        // JSON과 바이너리 데이터를 결합
        final separator = utf8.encode('\n');
        final metadataBytes = utf8.encode(metadata);
        final combinedBytes = Uint8List(metadataBytes.length + separator.length + imageBytes.length);
        combinedBytes.setAll(0, metadataBytes);
        combinedBytes.setAll(metadataBytes.length, separator);
        combinedBytes.setAll(metadataBytes.length + separator.length, imageBytes);

        // WebSocket으로 전송
        _webSocket?.send(combinedBytes);
        print("Data sent to WebSocket: metadata=$metadata, imageSize=${imageBytes.length} bytes");
      } catch (e) {
        print("Error sending data: $e");
      }
    } else {
      print("WebSocket is not connected.");
    }
  }

  void disconnect() {
    _webSocket?.close();
    _isConnected = false;
    print("WebSocket Disconnected");
  }
}
