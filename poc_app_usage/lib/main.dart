import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SW Project',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E), 
        scaffoldBackgroundColor: Colors.white, 

        fontFamily: 'Pretendard',
        
        // 텍스트 입력 필드 테마
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F6F6), // 배경색 연한 회색
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0), // 아주 연한 회색 테두리
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5), // 포커스 시 남색 테두리
          ),
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)), // 힌트 텍스트 색상
        ),
        
        // Elevated 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E), // 남색
            foregroundColor: Colors.white, // 글자색은 흰색
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Text 버튼 테마 (회원가입, 비밀번호 찾기)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1A237E), // 남색
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}