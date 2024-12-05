import 'package:flutter/material.dart';
import '../screens/concentrateScreen.dart'; // ConcentrateScreen import

class WaitingRoom2 extends StatefulWidget {
  const WaitingRoom2({Key? key}) : super(key: key);

  @override
  State<WaitingRoom2> createState() => _WaitingRoom2State();
}

class _WaitingRoom2State extends State<WaitingRoom2> {
  // 더미 데이터 (플래너에서 입력된 데이터)
  final List<String> dummyPlannerData = [
    "Math Study",
    "English Vocabulary",
    "Science Experiment",
    "History Notes",
    "Coding Practice",
  ];

  // 검색 기록 리스트
  List<String> searchHistory = [];
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424), // 검정 배경
      appBar: AppBar(
        title: const Text(
          "데이터 추가",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF242424),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색창 블록
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8), // 검색창 블록 색상
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "검색...",
                        fillColor: Colors.white, // 검색란 배경색
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        // 검색어 입력 시 처리
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            searchHistory.add(value); // 검색 기록에 추가
                            searchController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final value = searchController.text.trim();
                      if (value.isNotEmpty) {
                        setState(() {
                          searchHistory.add(value); // 검색 기록에 추가
                          searchController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 검색 기록 블록
            Expanded(
              child: ListView.builder(
                itemCount: searchHistory.isNotEmpty
                    ? searchHistory.length
                    : dummyPlannerData.length,
                itemBuilder: (context, index) {
                  final item = searchHistory.isNotEmpty
                      ? searchHistory[index]
                      : dummyPlannerData[index];
                  return ListTile(
                    title: Text(
                      item,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () {
                        // 데이터 추가 동작
                        print('Adding: $item');
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // 버튼 추가: ConcentrateScreen으로 이동
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConcentrateScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "측정 화면으로 이동",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
