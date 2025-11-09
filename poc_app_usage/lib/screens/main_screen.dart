import 'package:flutter/material.dart';
import 'sub_circle_chart_screen.dart'; 

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Insight App',
      // 🎨 앱의 전반적인 디자인 테마 설정
      theme: ThemeData(
        // Primary Color를 남색 계열로 설정하여 통일성을 줍니다.
        primaryColor: const Color(0xFF1A237E), 
        // 앱바, 버튼 등에 사용될 Accent Color 설정
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF4DB6AC), // Teal 색상 (What-If, Chart에서 사용된 색)
          primary: const Color(0xFF1A237E), // 남색
        ),
        // 버튼 스타일 설정 (로그인 버튼에 적용됩니다)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E), // 배경색: 남색
            foregroundColor: Colors.white, // 텍스트 색상: 흰색
            minimumSize: const Size(double.infinity, 50), // 버튼 높이 통일
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.white, // 배경색
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      
      home: const SubCircleChartScreen(userId: 'test_user_id'),
      
    );
  }
}