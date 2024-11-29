import 'package:flutter/material.dart';
import 'concentrateScreen.dart'; // 웹캠 화면 경로 임포트

class WaitingRoom2 extends StatefulWidget {
  final List<String> subheadings; // 플래너에서 입력 받은 항목들

  const WaitingRoom2({Key? key, required this.subheadings}) : super(key: key);

  @override
  _WaitingRoom2State createState() => _WaitingRoom2State();
}

class _WaitingRoom2State extends State<WaitingRoom2> {
  List<String> filteredSubheadings = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredSubheadings = widget.subheadings;
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredSubheadings = widget.subheadings
          .where((subheading) =>
          subheading.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addNewItem(String newItem) {
    if (newItem.isNotEmpty) {
      setState(() {
        widget.subheadings.add(newItem);
        filteredSubheadings = widget.subheadings;
        searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Waiting Room 2'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: '검색',
                hintText: '항목 검색...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: filterSearchResults,
            ),
            const SizedBox(height: 16),
            const Text(
              'today',
              style: TextStyle(
                color: Color(0xFFA6A5A5),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: filteredSubheadings.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredSubheadings[index]),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '항목 추가...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addNewItem(searchController.text),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // "웹캠 화면으로 이동" 버튼 추가
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConcentrateScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('웹캠 화면으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
