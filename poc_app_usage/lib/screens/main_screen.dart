import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poc_app_usage/screens/home_screen.dart';
import 'package:poc_app_usage/screens/sub_circle_chart_screen.dart';
import 'package:poc_app_usage/screens/sub_bar_chart_screen.dart';
import 'package:poc_app_usage/screens/sub_whatif_screen.dart';
import 'package:poc_app_usage/service/usage_service.dart';

import '../utils/logger.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;

  String? _idToken;
  String? _email;

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _loadAuthAndInit();
  }

  /// ✅ SharedPreferences에서 로그인 정보 + 토큰 불러오기
  Future<void> _loadAuthAndInit() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');
    final email = prefs.getString('email');

    logger.d("✅ MainDashboard idToken: $token");
    logger.d("✅ MainDashboard email: $email");

    if (token == null || email == null) {
      logger.e("❌ 로그인 정보 없음 → 대시보드 초기화 실패");
      return;
    }

    setState(() {
      _idToken = token;
      _email = email;

      _widgetOptions = <Widget>[
        HomeScreen(username: email),
        SubCircleChartScreen(idToken: token),
        SubBarGraphScreen(idToken: token),
        SubWhatIfScreen(idToken: token),
      ];
    });

    // ✅ 앱 usage 서버로 전송 (토큰 기반)
    _analyzeAndSendUsage();
  }

  /// ✅ UsageService 실행
  Future<void> _analyzeAndSendUsage() async {
    logger.d("MainDashboard: UsageService 실행 시작...");
    await UsageService().sendUsageDataToBackend();
    logger.d("MainDashboard: UsageService 실행 완료.");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 토큰 로딩 전 대기 처리
    if (_idToken == null || _widgetOptions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1A237E),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),

          currentIndex: _selectedIndex,
          onTap: _onItemTapped,

          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              activeIcon: Icon(Icons.pie_chart),
              label: '비용 분석',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: '만족도',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: 'What-If',
            ),
          ],
        ),
      ),
    );
  }
}
