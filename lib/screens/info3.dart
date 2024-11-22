import 'package:flutter/material.dart';
import 'package:focus/screens/info4.dart'; // 다음 페이지
import '../widgets/header.dart'; // 헤더 가져오기

class Info3Screen extends StatelessWidget {
  const Info3Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Info4Screen()),
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
                "스스로의 집중도를\n측정할 수 있습니다.",
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
                  'assets/images/2.png',
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
