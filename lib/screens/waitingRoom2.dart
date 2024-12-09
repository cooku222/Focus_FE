import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaitingRoom2 extends StatefulWidget {
  final int userId; // User ID to fetch planner data
  final String date; // Date for the planner query

  const WaitingRoom2({Key? key, required this.userId, required this.date}) : super(key: key);

  @override
  State<WaitingRoom2> createState() => _WaitingRoom2State();
}

class _WaitingRoom2State extends State<WaitingRoom2> {
  List<Map<String, dynamic>> plannerData = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPlannerData();
  }

  /// Fetch planner data from the API
  Future<void> _fetchPlannerData() async {
    final String apiUrl = 'http://52.78.38.195/api/planner/${widget.userId}/${widget.date}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          plannerData = responseData.map<Map<String, dynamic>>((item) {
            return {
              "title": item['title'],
              "state": item['state'],
              "date": item['date'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Failed to load planner data',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchPlannerData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF242424), // Black background
      appBar: AppBar(
        title: const Text(
          "Planner Data",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF242424),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: plannerData.length,
          itemBuilder: (context, index) {
            final item = plannerData[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'State: ${item['state'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${item['date'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
