import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String? title; // 추가된 title 파라미터
  final VoidCallback? onPlannerTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onMyPageTap;
  final VoidCallback? onMyReportTap; // 추가된 콜백

  const Header({
    Key? key,
    this.title,
    this.onPlannerTap,
    this.onLoginTap,
    this.onRegisterTap,
    this.onMyPageTap,
    this.onMyReportTap, // 콜백 받기
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 118,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? "FOCUS",
            style: TextStyle(
              fontSize: 48,
              height: 1.25,
              color: Color(0xFF123456),
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onPlannerTap,
                child: const _HeaderTextButton(text: "플래너"),
              ),
              GestureDetector(
                onTap: onMyReportTap, // 마이리포트 이동 연결
                child: const _HeaderTextButton(text: "마이리포트"),
              ),
              GestureDetector(
                onTap: onMyPageTap, // 마이페이지 이동 연결
                child: const _HeaderTextButton(text: "마이페이지"),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onLoginTap,
                child: const _HeaderButton(
                  text: "Login",
                  borderColor: Color(0xFF123456),
                  backgroundColor: Color(0xFF8AD2E6),
                  textColor: Color(0xFF123456),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRegisterTap,
                child: const _HeaderButton(
                  text: "Register",
                  borderColor: Color(0xFF123456),
                  backgroundColor: Color(0xFF123456),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderTextButton extends StatelessWidget {
  final String text;

  const _HeaderTextButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF123456),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;

  const _HeaderButton({
    required this.text,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
      ),
    );
  }
}
