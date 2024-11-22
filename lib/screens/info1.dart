import 'package:flutter/material.dart';
import 'package:focus/screens/info2.dart'; // 다음 페이지
import '../widgets/header.dart'; // 헤더 가져오기

class Info1Screen extends StatelessWidget {
  const Info1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Info2Screen()),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Header(),
          toolbarHeight: 118, // 헤더 높이 조정
          automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "매일 집중도를 측정하고\n이를 일일 리포트로\n기록해줍니다.",
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
