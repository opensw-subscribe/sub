import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_ott_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_music_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_contents_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_AI_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_lifestyle_screen.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poc_app_usage/screens/main_screen.dart';
import 'package:poc_app_usage/service/usage_service.dart';
import 'package:poc_app_usage/service/sub_info_service.dart';
import 'package:poc_app_usage/datas/sub_info_data.dart';
import '../utils/logger.dart';

class ChoosePlatformScreen extends StatefulWidget {
  const ChoosePlatformScreen({super.key});
  
  @override
  State<ChoosePlatformScreen> createState() => _ChoosePlatformScreenState();
}

class _ChoosePlatformScreenState extends State<ChoosePlatformScreen> {
  // 선택된 구독 서비스 목록 (앱 이름들)
  final Set<String> _selectedServices = {};

  // 앱 이름과 가격 매핑
  final Map<String, String> _servicePrices = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // 초기화: 백엔드 동기화 후 로컬 데이터 로드
  Future<void> _initData() async {
    await _syncWithBackend();
    if (mounted) {
      await _loadSelectedServices();
    }
  }

  // SharedPreferences에서 선택된 서비스 목록 불러오기 (동기화 X)
  Future<void> _loadSelectedServices() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    setState(() {
      _selectedServices.clear();
      _servicePrices.clear();
      for (String key in allKeys) {
        if (key.endsWith('_fee')) {
          String appName = key.replaceAll('_fee', '');
          String? price = prefs.getString(key);
          _selectedServices.add(appName);
          if (price != null) {
            _servicePrices[appName] = price;
          }
        }
      }
    });
  }

  // 백엔드 데이터와 로컬 데이터 동기화
  Future<void> _syncWithBackend() async {
    try {
      final subInfoService = SubInfoService();
      // 백엔드에서 구독 목록 가져오기
      final List<SubInfoData> backendData = await subInfoService.fetchSubInfoData();
      
      final prefs = await SharedPreferences.getInstance();
      
      // 1. 서버 데이터를 로컬에 저장/업데이트
      final Set<String> serverAppNames = {};
      for (var item in backendData) {
        serverAppNames.add(item.appName);
        await prefs.setString('${item.appName}_fee', item.serviceMonthlyPrice.toString());
        await prefs.setString('${item.appName}_category', item.appCategory);
      }
      
      // 2. 서버에 없는 로컬 데이터 삭제 (완전 동기화)
      final allKeys = prefs.getKeys().where((k) => k.endsWith('_fee')).toList();
      for (var key in allKeys) {
        String appName = key.replaceAll('_fee', '');
        if (!serverAppNames.contains(appName)) {
           await prefs.remove(key);
           await prefs.remove('${appName}_category');
           logger.d('🗑️ 로컬 삭제 (서버 동기화): $appName');
        }
      }
      logger.d('✅ 백엔드 동기화 완료 (${backendData.length}개)');
      
    } catch (e) {
      logger.w('⚠️ 백엔드 동기화 실패: $e');
    }
  }

  // 서비스 삭제
  Future<void> _removeService(String appName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${appName}_fee');
    await prefs.remove('${appName}_category'); // 카테고리도 삭제

    // 백엔드에서도 삭제 시도
    try {
      final subInfoService = SubInfoService();
      await subInfoService.deleteSubInfoData(appName);
      logger.d('✅ 백엔드 삭제 성공: $appName');
    } catch (e) {
      logger.w('⚠️ 백엔드 삭제 실패 (로컬에서만 삭제됨): $e');
    }

    setState(() {
      _selectedServices.remove(appName);
      _servicePrices.remove(appName);
    });
    logger.d('✅ 서비스 삭제: $appName');
  }

  // 완료 - 백엔드 전송 후 메인으로 이동
  Future<void> _completeAndGoMain() async {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1개 이상의 구독 서비스를 선택해주세요.')),
      );
      return;
    }

    // 로딩 표시
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 백엔드로 데이터 전송
      final usageService = UsageService();
      await usageService.sendUsageDataToBackend();

      // SharedPreferences에 완료 표시
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('platform_chosen', true);

      if (!mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
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
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // 메인 콘텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
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

                  // 6개 버튼
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
                                        ).then((_) {
                                          if (mounted) _loadSelectedServices();
                                        });
                                      } else if (label == 'Music') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseMusicScreen(),
                                          ),
                                        ).then((_) {
                                          if (mounted) _loadSelectedServices();
                                        });
                                      } else if (label == 'Contents') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseContentsScreen(),
                                          ),
                                        ).then((_) {
                                          if (mounted) _loadSelectedServices();
                                        });
                                      } else if (label == 'Cloud') {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cloud 화면은 아직 준비 중입니다.',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else if (label == 'AI') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseAIScreen(),
                                          ),
                                        ).then((_) {
                                          if (mounted) _loadSelectedServices();
                                        });
                                      } else if (label == 'LifeStyle') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseLifestyleScreen(),
                                          ),
                                        ).then((_) {
                                          if (mounted) _loadSelectedServices();
                                        });
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
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
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
                        ).then((_) {
                          if (mounted) _loadSelectedServices();
                        });
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

          // 하단 선택된 서비스 리스트
          if (_selectedServices.isNotEmpty)
            Container(
              height: 200, // 세로 리스트를 위해 높이 증가
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                    child: Scrollbar( // 스크롤바 추가
                      thumbVisibility: true,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical, // 세로 스크롤
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _selectedServices.length,
                        itemBuilder: (context, index) {
                          final appName = _selectedServices.elementAt(index);
                          return _buildSelectedServiceChip(appName);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 완료 버튼 (선택된 서비스가 있을 때만 표시)
          if (_selectedServices.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeAndGoMain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '완료하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 선택된 서비스 칩 위젯 (스와이프 삭제 가능)
  Widget _buildSelectedServiceChip(String appName) {
    return Dismissible(
      key: Key(appName),
      direction: DismissDirection.endToStart, // 좌측으로 스와이프 (오른쪽에서 왼쪽으로)
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12), // 둥근 모서리 수정
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) {
        _removeService(appName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$appName 삭제됨'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity, // 가로 꽉 차게
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A237E)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                appName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
            if (_servicePrices.containsKey(appName)) ...[
              const SizedBox(width: 8),
              Text(
                '월 ${_servicePrices[appName]}원',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(width: 12),
            const Icon(Icons.check_circle, size: 20, color: Color(0xFF1A237E)),
          ],
        ),
      ),
    );
  }
}
