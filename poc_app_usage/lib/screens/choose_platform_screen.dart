import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_ott_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_music_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_contents_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_AI_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_lifestyle_screen.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poc_app_usage/screens/main_screen.dart';
import '../utils/logger.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChoosePlatformScreen extends StatefulWidget {
  const ChoosePlatformScreen({super.key});

  @override
  State<ChoosePlatformScreen> createState() => _ChoosePlatformScreenState();
}

class _ChoosePlatformScreenState extends State<ChoosePlatformScreen> {
  // ✅ 선택된 구독 서비스
  final Set<String> _selectedServices = {};

  // ✅ 앱 이름 → 가격
  final Map<String, String> _servicePrices = {};

  @override
  void initState() {
    super.initState();
    _loadSelectedServices();
  }

  // ✅ ✅ ✅ 이메일 기준으로 구독 불러오기 (기능 유지)
  Future<void> _loadSelectedServices() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    logger.d('✅ 현재 로그인 이메일: $email');
    logger.d('✅ 전체 저장된 키: ${prefs.getKeys()}');

    if (email == null) return;

    final allKeys = prefs.getKeys();

    setState(() {
      _selectedServices.clear();
      _servicePrices.clear();

      for (String key in allKeys) {
        if (key.startsWith('${email}_') && key.endsWith('_fee')) {
          final appName =
              key.replaceFirst('${email}_', '').replaceAll('_fee', '');

          final price = prefs.getString(key);

          _selectedServices.add(appName);

          if (price != null) {
            _servicePrices[appName] = price;
          }
        }
      }
    });
  }

  // ✅ 서비스 삭제 (이메일 기준)
  Future<void> _removeService(String appName) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return;

    await prefs.remove('${email}_${appName}_fee');

    setState(() {
      _selectedServices.remove(appName);
      _servicePrices.remove(appName);
    });

    logger.d('✅ 서비스 삭제: $appName');
  }

  // ✅ 완료 버튼 → 계정 기준 완료 처리
  Future<void> _completeAndGoMain() async {
    logger.d("✅ _completeAndGoMain 진입함");

  if (_selectedServices.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('최소 1개 이상의 구독 서비스를 선택해주세요.')),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  final token = prefs.getString('auth_token');

  if (email == null || token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
    );
    return;
  }

  // ✅ 1️⃣ 서버 저장 먼저 "완전히" 끝내고
  try {
    await _sendSubscriptionsToServer();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('구독 정보 저장 실패')),
    );
    return;
  }

  // ✅ 2️⃣ 그 다음에 platform_chosen 저장
  await prefs.setBool('platform_chosen_$email', true);

  if (!mounted) return;

  // ✅ 3️⃣ 마지막에 화면 이동
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
  );
}


  Future<void> _sendSubscriptionsToServer() async {
  logger.d("✅ _sendSubscriptionsToServer 실행됨");

  final prefs = await SharedPreferences.getInstance();
  final idToken = prefs.getString('auth_token');
  final email = prefs.getString('email');

  if (idToken == null || email == null) return;

  for (final appName in _selectedServices) {
    final price = _servicePrices[appName];
    if (price == null) continue;

    final body = {
      "app_name": appName,
      "category_id": _convertCategory(appName), // 아래 함수 참고
      "service_monthly_price": int.parse(price),
      "service_usage": 0,
      "service_usage_time": 0,
      "is_active": true,
      "user_satis": 5,
    };

    final response = await http.post(
      Uri.parse("http://10.0.2.2:52141/api/subscriptions/"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(body),
    );

    logger.d("✅ 구독 서버 저장 결과: ${response.statusCode}");
  }
}

int _convertCategory(String appName) {
  if (['Netflix', 'Disney+', 'Wavve', 'TVING', 'WATCHA', 'Coupang Play'].contains(appName)) {
    return 1; // OTT
  }
  if (['Melon', 'Genie', 'FLO'].contains(appName)) {
    return 2; // Music
  }
  if (['YouTube Premium', 'RIDI', 'Millie'].contains(appName)) {
    return 3; // Contents
  }
  if (['ChatGPT', 'Gemini', 'Notion'].contains(appName)) {
    return 4; // AI
  }
  return 5; // LifeStyle
}



  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      'OTT',
      'Music',
      'Contents',
      'Cloud',
      'AI',
      'LifeStyle',
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '구독 서비스',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ 메인 콘텐츠 (예전 UI 그대로 유지)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: '사용자',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                            height: 1.2,
                          ),
                        ),
                        TextSpan(
                          text: ' 님의\n구독 서비스 플랫폼을 알려주세요',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  for (int row = 0; row < 3; row++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int col = 0; col < 2; col++)
                          if (row * 2 + col < buttons.length)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: AspectRatio(
                                  aspectRatio: 1.7,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final label = buttons[row * 2 + col];

                                      if (label == 'OTT') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseOTTScreen(),
                                          ),
                                        ).then((_) => _loadSelectedServices());
                                      } else if (label == 'Music') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseMusicScreen(),
                                          ),
                                        ).then((_) => _loadSelectedServices());
                                      } else if (label == 'Contents') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseContentsScreen(),
                                          ),
                                        ).then((_) => _loadSelectedServices());
                                      } else if (label == 'AI') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseAIScreen(),
                                          ),
                                        ).then((_) => _loadSelectedServices());
                                      } else if (label == 'LifeStyle') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseLifestyleScreen(),
                                          ),
                                        ).then((_) => _loadSelectedServices());
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        side: const BorderSide(
                                          color: Colors.black12,
                                        ),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: Text(
                                      buttons[row * 2 + col],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WriteSubScreen(),
                        ),
                      ).then((_) => _loadSelectedServices());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: const Text(
                      '여기에 없어요 😢',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ 하단 선택 리스트 (예전 UI 그대로)
          if (_selectedServices.isNotEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '선택된 구독 서비스 (${_selectedServices.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _selectedServices.length,
                      itemBuilder: (context, index) {
                        final appName =
                            _selectedServices.elementAt(index);
                        return _buildSelectedServiceChip(appName);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // ✅ 완료 버튼
          if (_selectedServices.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeAndGoMain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '완료하기',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ 선택된 서비스 칩 (예전 디자인 유지)
  Widget _buildSelectedServiceChip(String appName) {
    return Dismissible(
      key: Key(appName),
      direction: DismissDirection.endToStart,
      background: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child:
            const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => _removeService(appName),
      child: Container(
        margin:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFF1A237E)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            if (_servicePrices.containsKey(appName)) ...[
              const SizedBox(width: 6),
              Text(
                '월 ${_servicePrices[appName]}원',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.check_circle,
                size: 18, color: Color(0xFF1A237E)),
          ],
        ),
      ),
    );
  }
}
