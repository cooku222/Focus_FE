import 'package:flutter/material.dart';
import '../main.dart'; // 메인 화면
import '../widgets/header.dart'; // 헤더 가져오기

class Info5Screen extends StatelessWidget {
  const Info5Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Header(),
          toolbarHeight: 118,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "플래너 기능을 통해\n오늘 공부할 양을 기록합니다.",
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: "Noto Sans",
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/images/1.png',
                  width: 700,
                  height: 700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
