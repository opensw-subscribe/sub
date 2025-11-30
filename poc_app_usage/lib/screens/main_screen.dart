import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poc_app_usage/screens/home_screen.dart';
import 'package:poc_app_usage/screens/sub_circle_chart_screen.dart';
import 'package:poc_app_usage/screens/sub_bar_chart_screen.dart';
import 'package:poc_app_usage/screens/sub_whatif_screen.dart';
import 'package:poc_app_usage/service/usage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poc_app_usage/config.dart';
import '../utils/logger.dart';

// StatelessWidget에서 StatefulWidget으로 변경
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {

  static const String _baseUrl = Config.baseUrl;
  static const String _endpoint = "/api/user/me";

  String? userName;

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final response = await http.get(
      Uri.parse('$_baseUrl$_endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userName = data['userName']; // 백엔드 응답 구조에 맞게
      });
    }
  }
  // 현재 선택된 탭 번호 (0: 홈, 1: 원형, 2: 막대, 3: What-if)
  int _selectedIndex = 0;
  final now = DateTime.now();
  late final String _month = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";

  // 탭별로 보여줄 화면 리스트 정의 (순서대로)
  late final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(userName: userName ?? "사용자"),           // 0번: 메인 홈 (사용자님이 보내주신 파일)
    SubCircleChartScreen(_month), // 1번: 원형 차트 (Insights)
    SubBarGraphScreen(_month),    // 2번: 막대 차트 (Chart)
    SubWhatIfScreen(_month),      // 3번: What-If
  ];

  // initState() 추가: 이 화면이 켜질 때 '한 번만' 실행됨
  @override
  void initState() {
    super.initState();
    // 앱 사용 시간 가져와서 백엔드에 넘기는 함수 호출
    _analyzeAndSendUsage();
  }

  // UsageService를 실행하는 함수
  Future<void> _analyzeAndSendUsage() async {
    logger.d("MainDashboard: UsageService 실행 시작...");
    // (사용자 눈에 안 보이게 백그라운드에서 조용히 실행)
    await UsageService().sendUsageDataToBackend();
    logger.d("MainDashboard: UsageService 실행 완료.");
  }

  // 탭을 눌렀을 때 실행되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp 대신 Scaffold를 리턴합니다.
    // (MaterialApp과 ThemeData는 lib/main.dart에 있어야 합니다)
    return Scaffold(
      // 현재 선택된 인덱스에 해당하는 화면을 보여줌
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // 하단 네비게이션 바
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // 4개 탭 고정
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1A237E), // 선택된 아이콘 색상 (남색)
          unselectedItemColor: Colors.grey,           // 선택 안 된 아이콘 색상
          showUnselectedLabels: true,                 // 선택 안 된 라벨도 보이게
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          
          currentIndex: _selectedIndex, 
          onTap: _onItemTapped,
          
          items: const <BottomNavigationBarItem>[
            // 탭 1: 홈
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            // 탭 2: 원형 차트 (Insights)
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline),
              activeIcon: Icon(Icons.pie_chart),
              label: '비용 분석',
            ),
            // 탭 3: 막대 차트 (Chart)
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: '만족도',
            ),
            // 탭 4: What-If
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