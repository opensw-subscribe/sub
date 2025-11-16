import 'dart:convert';

import 'package:flutter/material.dart'; //service import 후에 삭제 필요
import 'package:http/http.dart' as http; //service import 후에 삭제 필요
//import '../datas/bar_graph_data.dart'; // Statistic 모델 import 필요
//import '../service/sub_bar_graph_service.dart'; // StatisticService import 필요

class BarGraphData {
  final String userId;
  final String appName;
  final String appCategory;
  final int serviceMonthlyPrice;
  final int serviceOncePrice;
  int userSatis;

  BarGraphData({
    required this.userId,
    required this.appName,
    required this.appCategory,
    required this.serviceMonthlyPrice,
    required this.serviceOncePrice,
    required this.userSatis,
  });

  /// JSON (Map)으로부터 ServiceStatistic 객체를 생성합니다.
  factory BarGraphData.mock(Map<String, dynamic> json) {
    return BarGraphData(
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      appCategory: json['app_category'] as String,
      // API 응답의 타입이 확실하지 않다면 .toInt() 또는 안전한 파싱 로직을 추가합니다.
      serviceMonthlyPrice: json['service_monthly_price'] as int,
      serviceOncePrice: json['service_once_price'] as int,
      userSatis: json['user_satis'] as int,
    );
  }
}

class BarGraphDataService {
  Future<List<BarGraphData>> fetchStatistics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final List<Map<String, dynamic>> mockData = [
      {
        "user_id": userId,
        "app_name": "멜론",
        "app_category": "music",
        "service_monthly_price": 5900,
        "service_once_price": 1500,
        "user_satis": 5,
      },
      {
        "user_id": userId,
        "app_name": "넷플릭스",
        "app_category": "ott",
        "service_monthly_price": 12000,
        "service_once_price": 1200,
        "user_satis": 2,
      },
      {
        "user_id": userId,
        "app_name": "유튜브 프리미엄",
        "app_category": "ott",
        "service_monthly_price": 8900,
        "service_once_price": 800,
        "user_satis": 3,
      },
      {
        "user_id": userId,
        "app_name": "웨이브",
        "app_category": "ott",
        "service_monthly_price": 1900,
        "service_once_price": 1980,
        "user_satis": 4,
      },
    ];

    return mockData.map((jsonItem) => BarGraphData.mock(jsonItem)).toList();
  }

  Future<void> updateRating({
    required String userId,
    required String appName,
    required int newRating,
  }) async {
    final url = Uri.parse("http://YOUR_BACKEND_URL/api/subscription/rating");

    final body = {"user_id": userId, "app_name": appName, "rating": newRating};

    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("서버 오류: ${response.statusCode}");
    }
  }
}
//여기까지 임시 데이터

class SubBarGraphScreen extends StatefulWidget {
  final String userId;

  const SubBarGraphScreen({super.key, required this.userId});

  @override
  State<SubBarGraphScreen> createState() => _SubBarGraphScreenState();
}

class _SubBarGraphScreenState extends State<SubBarGraphScreen> {
  // 💡 Statistic -> BarGraphDataService로 변경됨
  final BarGraphDataService _service = BarGraphDataService();
  late Future<List<BarGraphData>> _statisticFuture;
  List<BarGraphData> _statistics = [];

  // 막대 그래프와 목록에 사용될 일관된 색상 정의
  final Color _oncePriceColor = Colors.teal.shade400; // 1회 비용/만족도 막대 (민트색)
  final Color _monthlyPriceColor = Colors.blue.shade900; // 월 비용 막대 (네이비색)

  late final List<Color> _listColors = [_monthlyPriceColor, _oncePriceColor];

  @override
  void initState() {
    super.initState();
    _statisticFuture = _service.fetchStatistics(widget.userId);
  }

  Future<void> _updateRating(BarGraphData data, int newRating) async {
    final int oldRating = data.userSatis;

    // 1) UI 먼저 업데이트
    setState(() {
      data.userSatis = newRating;
    });

    try {
      // 2) 실제 PATCH 요청
      await _service.updateRating(
        userId: data.userId,
        appName: data.appName,
        newRating: newRating,
      );

      // 성공 → 특별히 할 건 없음 (UI는 이미 변경됨)
    } catch (e) {
      // 3) 실패 → 원상 복귀
      setState(() {
        data.userSatis = oldRating;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("별점 수정 실패: $e")));
    }
  }

  // -------------------------
  // UI 구성 요소: 별점 위젯
  // -------------------------
  Widget _buildStarRating({
    required int rating,
    required void Function(int newRating) onChanged,
  }) {
    const double iconSize = 20;
    const Color fillColor = Colors.amber;
    const Color borderColor = Colors.black;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            onChanged(index + 1); // 클릭한 위치의 별 개수
          },
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.star_border, color: borderColor, size: iconSize),
                if (index < rating)
                  Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: Icon(
                      Icons.star,
                      color: fillColor,
                      size: iconSize * 0.7,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // -------------------------
  // UI 구성 요소: 막대 그래프 Placeholder
  // -------------------------
  Widget _buildChartPlaceholder() {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _statistics.map((data) => _buildBar(data)).toList(),
      ),
    );
  }

  // -------------------------
  // 개별 막대 위젯 (월 비용/1회 비용을 다른 막대로 표현)
  // -------------------------
  Widget _buildBar(BarGraphData data) {
    const double maxHeight = 120.0;

    // 월 비용 (Monthly Price) - 네이비색 막대
    // Mock 데이터에서 가장 높은 serviceMonthlyPrice인 12000.0을 기준으로 스케일링
    const double maxMonthlyPrice = 12000.0;
    final double monthlyPriceHeight =
        maxHeight * (data.serviceMonthlyPrice / maxMonthlyPrice);

    // 1회 비용 (Once Price) - 민트색 막대 (이미지의 '만족도' 막대로 사용됨)
    // Mock 데이터에서 가장 높은 serviceOncePrice인 1980.0을 기준으로 스케일링
    final double oncePriceHeight =
        maxHeight * (data.serviceOncePrice / maxMonthlyPrice);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2. 월 비용 막대 (오른쪽, 네이비색)
              _buildSingleBar(
                height: monthlyPriceHeight,
                color: _monthlyPriceColor, // 변수 사용
                maxHeight: maxHeight,
              ),

              const SizedBox(width: 4),

              // 1. 1회 비용 막대 (왼쪽, 민트색)
              _buildSingleBar(
                height: oncePriceHeight,
                color: _oncePriceColor, // 변수 사용
                maxHeight: maxHeight,
              ),
            ],
          ),
        ),
        // ... (Item Name (X축 레이블) 유지)
      ],
    );
  }

  // -------------------------
  // 단일 막대 위젯 (재사용성 향상)
  // -------------------------
  Widget _buildSingleBar({
    required double height,
    required Color color,
    required double maxHeight,
    double width = 10.0,
  }) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 배경 (최대 높이)
        Container(width: width, height: maxHeight, color: Colors.grey[200]),
        // 실제 데이터 막대
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ],
    );
  }

  // -------------------------
  // UI 구성 요소: 목록 항목 위젯
  // -------------------------
  Widget _buildListItem(BarGraphData data) {
    final int index = _statistics.indexOf(data);
    //  목록 점 색상을 월 비용 막대의 색상으로 통일
    final Color listColor = _listColors[index % _listColors.length];

    final String formattedPrice = data.serviceMonthlyPrice
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 색상 점 (월 비용 색상으로 통일)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: listColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),

          // 2. 앱 이름 (Expanded로 나머지 공간 모두 확보)
          Expanded(
            child: Text(data.appName, style: const TextStyle(fontSize: 16)),
          ),

          // 3. 별점 표시 (정렬을 위해 고정된 SizedBox 안에 넣습니다)
          //  별점 너비를 고정하여 앱 이름 길이에 상관없이 정렬되도록 함 (대략적인 너비 120.0 사용)
          SizedBox(
            width: 120.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
              children: [
                _buildStarRating(
                  rating: data.userSatis,
                  onChanged: (newRating) => _updateRating(data, newRating),
                ),
              ],
            ),
          ),

          const SizedBox(width: 30),

          // 4. 월 비용 표시 (Text는 기본적으로 콘텐츠 크기만큼 공간 차지)
          SizedBox(
            width: 70,
            child: Text(
              formattedPrice,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // UI 구성 요소: App Bar
  // -------------------------
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Chart', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: TextButton(
        onPressed: () {
          // Navigator.pop(context); // 임시로 현재 화면 닫기
        },
        child: const Text('설정', style: TextStyle(color: Colors.black)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // '서비스 추가' 화면으로 이동하는 기능
          },
          child: const Text('서비스 추가', style: TextStyle(color: Colors.blue)),
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<BarGraphData>>(
        future: _statisticFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('데이터 로드 실패: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            _statistics = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 막대 그래프 영역
                  _buildChartPlaceholder(),
                  const SizedBox(height: 24),

                  // 2. 목록 제목
                  const Text(
                    '구독 서비스 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
/*
}
*/