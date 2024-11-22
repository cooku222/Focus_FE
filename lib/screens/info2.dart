import 'package:flutter/material.dart';
import 'package:focus/screens/info3.dart'; // 다음 페이지
import '../widgets/header.dart'; // 헤더 가져오기

class Info2Screen extends StatelessWidget {
  const Info2Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Info3Screen()),
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
                "주간 집중도를\n그래프로 보여주고\n맞춤형 솔루션을 제공해줍니다.",
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
                  'assets/images/4.png',
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
