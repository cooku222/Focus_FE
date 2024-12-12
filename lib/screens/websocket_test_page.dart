import 'dart:html';
import 'dart:typed_data';
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
  String serverResponse = "No response yet.";
  Uint8List? binaryData;

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
  }

  void connectToWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://3.38.191.196/image'),
    );

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

  void testWebSocketConnection(int userId, String title) {
    if (binaryData == null) {
      setState(() {
        serverResponse = "No binary data selected.";
      });
      return;
    }

    // Combine metadata and binary data
    final Map<String, dynamic> metadata = {
      'userId': userId,
      'title': title,
    };
    final metadataJson = Uint8List.fromList(metadata.toString().codeUnits);

    // Send metadata followed by binary data
    channel.sink.add(metadataJson);
    channel.sink.add(binaryData!);

    setState(() {
      serverResponse = "Binary data sent with metadata: $metadata";
    });
  }

  void selectBinaryFile() {
    final fileInput = FileUploadInputElement();
    fileInput.accept = "image/*";
    fileInput.click();

    fileInput.onChange.listen((event) {
      final files = fileInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = FileReader();
        reader.readAsArrayBuffer(files[0]);

        reader.onLoadEnd.listen((_) {
          setState(() {
            binaryData = reader.result as Uint8List?;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    userIdController.dispose();
    titleController.dispose();
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
              keyboardType: TextInputType.number, // Restrict to numbers only
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectBinaryFile,
              child: const Text("Select Binary File"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userIdText = userIdController.text.trim();
                final title = titleController.text.trim();

                if (userIdText.isNotEmpty && title.isNotEmpty) {
                  try {
                    final userId = int.parse(userIdText); // Convert to int
                    testWebSocketConnection(userId, title);
                  } catch (e) {
                    setState(() {
                      serverResponse = "User ID must be a valid number.";
                    });
                  }
                } else {
                  setState(() {
                    serverResponse = "User ID and Title are required.";
                  });
                }
              },
              child: const Text("Send Binary Data to WebSocket"),
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
