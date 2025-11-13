import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/home_screen.dart';
import 'package:poc_app_usage/screens/sub_circle_chart_screen.dart';
import 'package:poc_app_usage/screens/sub_bar_chart_screen.dart';
import 'package:poc_app_usage/screens/sub_whatif_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // 현재 선택된 탭 번호 (0: 메인, 1: 원형, 2: 막대, 3: What-if)
  int _selectedIndex = 0;

  // 테스트용 유저 ID (나중에 로그인 정보에서 받아오도록 수정 가능)
  final String _userId = 'test_user_id';

  // [2] 탭별로 보여줄 화면 리스트 정의
  late final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(userId: _userId),           // 0번: 메인
    SubCircleChartScreen(userId: _userId), // 1번: 원형 차트
    SubBarGraphScreen(userId: _userId),    // 2번: 막대 차트
    SubWhatIfScreen(userId: _userId),      // 3번: What-If
  ];

  // 탭을 눌렀을 때 실행되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [3] 현재 선택된 인덱스에 해당하는 화면을 보여줌
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // [4] 하단 네비게이션 바
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: BottomNavigationBar(
          // 탭이 4개 이상일 때는 fixed로 설정해야 레이아웃이 깨지지 않음
          type: BottomNavigationBarType.fixed, 
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1A237E), // 선택된 아이콘 색상 (남색)
          unselectedItemColor: Colors.grey,           // 선택 안 된 아이콘 색상
          showUnselectedLabels: true,                 // 선택 안 된 라벨도 보이게
          
          // 현재 선택된 탭 번호
          currentIndex: _selectedIndex, 
          onTap: _onItemTapped,
          
          items: const <BottomNavigationBarItem>[
            // 탭 1: 메인
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            // 탭 2: 원형 차트 (Insights)
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: '비용 분석',
            ),
            // 탭 3: 막대 차트 (Chart)
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '만족도',
            ),
            // 탭 4: What-If
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate), // 또는 savings, money_off 등
              label: 'What-If',
            ),
          ],
        ),
      ),
    );
  }
}