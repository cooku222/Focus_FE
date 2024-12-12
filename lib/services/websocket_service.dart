import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  void testWebSocketConnection(String userId, String title, String image) {
    // WebSocket 서버 URL
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://3.38.191.196/image'),
    );

    // 전송할 데이터
    final payload = jsonEncode({
      'user_id': userId,
      'title': title,
      'image': image,
    });

    // 서버로 데이터 전송
    channel.sink.add(payload);

    // 서버로부터의 응답 처리
    channel.stream.listen(
          (message) {
        print("Response from server: $message");
        channel.sink.close(); // 테스트 후 연결 종료
      },
      onError: (error) {
        print("Error: $error");
        channel.sink.close(); // 에러 발생 시 연결 종료
      },
    );
  }
}
