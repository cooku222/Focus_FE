import 'dart:html';
import 'dart:convert';

class WebSocketManager {
  WebSocket? _webSocket;
  String _connectionStatus = "Disconnected";

  String get connectionStatus => _connectionStatus;

  void connect() {
    _connectionStatus = "Connecting...";
    try {
      _webSocket = WebSocket('ws://52.78.38.195/image');

      // 연결 성공
      _webSocket?.onOpen.listen((event) {
        print("WebSocket Connected");
        _connectionStatus = "Connected";
      });

      // 메시지 수신
      _webSocket?.onMessage.listen((event) {
        print("Message received: ${event.data}");
        // 메시지를 추가로 처리하려면 여기에 로직 추가
      });

      // 연결 종료
      _webSocket?.onClose.listen((event) {
        print("WebSocket Disconnected");
        _connectionStatus = "Disconnected";
      });

      // 에러 처리
      _webSocket?.onError.listen((event) {
        print("WebSocket Error: $event");
        _connectionStatus = "Error occurred";
      });
    } catch (e) {
      print("Failed to connect: $e");
      _connectionStatus = "Failed to connect";
    }
  }

  void sendMessage(String message) {
    if (_webSocket != null && _connectionStatus == "Connected") {
      final data = jsonEncode({'action': 'test', 'message': message});
      _webSocket?.send(data);
      print("Message sent: $data");
    } else {
      print("WebSocket is not connected. Cannot send message.");
    }
  }

  void disconnect() {
    _webSocket?.close();
    _connectionStatus = "Disconnected";
    print("WebSocket connection closed.");
  }
}
