import 'package:flutter/material.dart';
import '../service/sub_whatif_service.dart';
import '../datas/what-if_data.dart'; // Statistic 모델


class SubWhatIfScreen extends StatefulWidget {
  final String userId;

  const SubWhatIfScreen({super.key, required this.userId});

  @override
  State<SubWhatIfScreen> createState() => _SubWhatIfScreenState();
}

class _SubWhatIfScreenState extends State<SubWhatIfScreen> {
  final WhatifService _service = WhatifService();
  late Future<List<WhatifData>> _statisticFuture;
  List<WhatifData> _statistics = [];

  // 현재 월을 YYYY-MM 형식으로 저장
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
    _statisticFuture = _fetchAndGroupDataByMonth();
  }

  Future<List<WhatifData>> _fetchAndGroupDataByMonth() async {
    final data = await _service.fetchWhatifData(_currentMonth);
    _statistics = data;
    return data;
  }

  // 비활성화된 서비스의 월 절약 가능 금액을 계산
  int get _totalSavings {
    return _statistics
        .where((s) => !s.isActive)
        .fold(0, (sum, s) => sum + s.serviceMonthlyPrice);
  }

  // 추가: 6개월 예상 저축액 계산
  int get _sixMonthSavings => _totalSavings * 6;

  AppBar _buildAppBar() {
    // ... (AppBar 로직 유지) ...
    return AppBar(
      title: const Text(
        'What - If',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: TextButton(
        onPressed: () {
          // '설정' 화면으로 이동하거나 Chart 모드로 전환하는 로직
        },
        child: const Text('설정', style: TextStyle(color: Colors.black)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // '서비스 추가' 화면으로 이동하는 로직
          },
          child: const Text('서비스 추가', style: TextStyle(color: Colors.blue)),
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  // -------------------------
  // UI 구성 요소: 목록 항목 위젯
  // -------------------------
  // -------------------------
  // UI 구성 요소: 목록 항목 위젯 (색상 로직 수정)
  // -------------------------
  Widget _buildListItem(WhatifData data) {
    // 수정: isActive 상태에 따라 색상 지정
    final Color itemColor = data.isActive
        ? Colors
              .teal // 유지된 서비스 (민트)
        : Colors.blue.shade800; // 삭제된 서비스 (파랑)

    final String formattedPrice = data.serviceMonthlyPrice
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 색상 점 (수정된 itemColor 사용)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Text(data.appName, style: const TextStyle(fontSize: 16)),
          ),

          Text(
            formattedPrice,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 8),

          // 활성화/비활성화 토글 버튼
          Switch(
            key: ValueKey('toggle_${data.appName}_${data.userId}'),
            value: data.isActive,
            onChanged: (bool value) {
              setState(() {
                data.isActive = value; // 상태 변경
              });
            },
            activeColor: Colors.teal,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  // -------------------------
  // UI 구성 요소: 절약액 섹션 (6개월 예상 저축액 반영)
  // -------------------------
  Widget _buildSavingsSection() {
    final String formattedSavings = _totalSavings.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    // 6개월 예상 저축액 포매팅
    final String formattedSixMonthSavings = _sixMonthSavings
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: '사용자 님의\n월 지출 비용을\n',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: '$formattedSavings원만큼 아낄 수 있어요!', // '원' 추가
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ), // 이미지에 가까운 진한 파란색
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 저금통 이미지 Placeholder (실제 이미지 경로 사용 필요)
            Image.asset(
              'assets/images/piggy_bank.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.savings, size: 80, color: Colors.pinkAccent),
            ),
          ],
        ),

        const SizedBox(height: 8),
        // 🚨 수정: 6개월 예상 저축액 표시
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: [
              const TextSpan(text: '예적금 시 6개월 뒤 '),
              TextSpan(
                text: '$formattedSixMonthSavings원', // 6개월 금액 표시
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------
  // 빌드 함수
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<WhatifData>>(
        future: _statisticFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('데이터 로드 실패: ${snapshot.error}'));
          }

          // 데이터가 로드된 후 _statistics 리스트를 사용하여 목록을 구성
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSavingsSection(),

                const Text(
                  '구독 서비스 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                ..._statistics.map((data) => _buildListItem(data)).toList(),

                // 추가적인 여백
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
