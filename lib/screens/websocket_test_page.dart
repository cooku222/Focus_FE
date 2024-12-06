import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketTestPage extends StatefulWidget {
  const WebSocketTestPage({Key? key}) : super(key: key);

  @override
  _WebSocketTestPageState createState() => _WebSocketTestPageState();
}

class _WebSocketTestPageState extends State<WebSocketTestPage> {
  late WebSocketChannel channel;
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  String serverResponse = "No response yet.";

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
  }

  void connectToWebSocket() {
    // Replace 'ws://your-websocket-server-url' with your actual WebSocket server URL
    channel = WebSocketChannel.connect(
      Uri.parse('ws://52.78.38.195/image'),
    );

    // Listen to the WebSocket stream
    channel.stream.listen(
          (message) {
        setState(() {
          serverResponse = message;
        });
      },
      onError: (error) {
        setState(() {
          serverResponse = 'Error: $error';
        });
      },
      onDone: () {
        setState(() {
          serverResponse = 'Connection closed.';
        });
      },
    );
  }

  void testWebSocketConnection(String userId, String title, String image) {
    final Map<String, dynamic> data = {
      'userId': userId,
      'title': title,
      'image': image,
    };

    // Send data to the WebSocket server
    channel.sink.add(data.toString());
    setState(() {
      serverResponse = "Data sent: $data";
    });
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    channel.sink.close(status.goingAway);
    userIdController.dispose();
    titleController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebSocket Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(labelText: "User ID"),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: "Image (Base64)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userId = userIdController.text.trim();
                final title = titleController.text.trim();
                final image = imageController.text.trim();

                if (userId.isNotEmpty && title.isNotEmpty && image.isNotEmpty) {
                  testWebSocketConnection(userId, title, image);
                } else {
                  setState(() {
                    serverResponse = "All fields are required.";
                  });
                }
              },
              child: const Text("Send Data to WebSocket"),
            ),
            const SizedBox(height: 20),
            Text(
              "Server Response: $serverResponse",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
