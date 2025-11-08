import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http 패키지
import 'dart:convert';
import 'package:poc_app_usage/utils/logger.dart'; // logger 사용을 위해 import

import '../bar_statistic.dart'; // Statistic 모델
import '../service/sub_statistic_service.dart'; // StatisticService

class SubWhatIfScreen extends StatefulWidget {
  // 🚨 1. 사용자 ID를 외부에서 필수로 받습니다.
  final String userId;
  
  const SubWhatIfScreen({super.key, required this.userId});

  @override
  State<SubWhatIfScreen> createState() => _SubWhatIfScreenState();
}

class _SubWhatIfScreenState extends State<SubWhatIfScreen> {
  final StatisticService _service = StatisticService();
  late Future<List<Statistic>> _statisticFuture;
  List<Statistic> _statistics = [];

  @override
  void initState() {
    super.initState();
    // 🚨 2. 전달받은 widget.userId를 사용하여 데이터를 요청합니다.
    _statisticFuture = _service.fetchStatistics(widget.userId);
  }

  // 비활성화된 서비스의 절약 가능 금액을 계산
  int get _totalSavings {
    // 🚨 isActive 필드를 사용하여 정확히 계산
    return _statistics
        .where((s) => !s.isActive)
        .fold(0, (sum, s) => sum + s.serviceMonthlyPrice);
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('What - If', style: TextStyle(fontWeight: FontWeight.bold)),
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
  // UI 구성 요소: 목록 항목 위젯 (메인 화면용)
  // -------------------------
  Widget _buildListItem(Statistic data) {
    // 임시 색상 로직: 앱 이름의 해시 코드를 기반으로 색상 생성
    final Color itemColor = data.appName.hashCode % 2 == 0 ? Colors.teal : Colors.blue.shade800;
    final String formattedPrice = data.serviceMonthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(data.appName, style: const TextStyle(fontSize: 16)),
          ),
          
          Text(formattedPrice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          
          const SizedBox(width: 8),
          
          // 활성화/비활성화 토글 버튼
          Switch(
            value: data.isActive,
            onChanged: (bool value) {
              setState(() {
                data.isActive = value; // 🚨 상태 변경
              });
            },
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  // -------------------------
  // UI 구성 요소: 절약액 섹션
  // -------------------------
  Widget _buildSavingsSection() {
    final String formattedSavings = _totalSavings.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 24, color: Colors.black, height: 1.5),
                  children: [
                    const TextSpan(text: '사용자 님의\n월 지출 비용을\n', style: TextStyle(fontWeight: FontWeight.normal)),
                    TextSpan(
                      text: '$formattedSavings만큼 아낄 수 있어요!',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
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
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.savings, size: 80, color: Colors.pinkAccent), 
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 예적금 시 6개월 뒤 000원 (임시 텍스트)
        const Text(
          '예적금 시 6개월 뒤 000원',
          style: TextStyle(fontSize: 16, color: Colors.orange),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<Statistic>>(
        future: _statisticFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Mock 데이터를 사용하지 않는 경우 API 통신 오류 발생 시 표시
            return Center(child: Text('데이터 로드 실패: ${snapshot.error}. 서버 주소를 확인해주세요.'));
          }
          if (snapshot.hasData) {
            _statistics = snapshot.data!;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 절약액 표시 섹션
                  _buildSavingsSection(),
                  
                  // 2. 목록 제목
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('구독 서비스 목록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      // '삭제' 기능이 '서비스 편집'으로 분리된다면 이 부분은 수정 필요
                      const Text('삭제', style: TextStyle(color: Colors.grey)), 
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // 3. 서비스 목록
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _statistics.length,
                    itemBuilder: (context, index) {
                      return _buildListItem(_statistics[index]);
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('데이터를 불러올 수 없습니다.'));
        },
      ),
    );
  }
}