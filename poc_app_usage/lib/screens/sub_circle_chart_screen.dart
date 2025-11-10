import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
//import '../datas/circle_graph_data.dart';// CircleGraphData 모델 import 필요
//import '../service/sub_cricle_graph_service.dart'; // CircleGraphService import 필요
import 'dart:math';

class CircleGraphData {
  final String userId;
  final String appName;
  final int serviceMonthlyPrice;

  CircleGraphData({
    required this.userId,
    required this.appName,
    required this.serviceMonthlyPrice,
  });

  factory CircleGraphData.mock(Map<String, dynamic> json) {
    return CircleGraphData(
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      serviceMonthlyPrice: json['service_monthly_price'] as int,
    );
  }
}

class CircleGraphService {
  Future<List<CircleGraphData>> fetchStatistics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final List<Map<String, dynamic>> mockData = [
      {"user_id": userId, "app_name": "멜론", "service_monthly_price": 5900},
      {"user_id": userId, "app_name": "넷플릭스", "service_monthly_price": 12000},
      {
        "user_id": userId,
        "app_name": "유튜브 프리미엄",
        "service_monthly_price": 8900,
      },
      {"user_id": userId, "app_name": "웨이브", "service_monthly_price": 1900},
    ];

    return mockData.map((jsonItem) => CircleGraphData.mock(jsonItem)).toList();
  }
}
//여기까지 임시 데이터 
class SubCircleChartScreen extends StatefulWidget {
  final String userId;

  const SubCircleChartScreen({super.key, required this.userId});

  @override
  State<SubCircleChartScreen> createState() => _SubCircleChartScreenState();
}

class _SubCircleChartScreenState extends State<SubCircleChartScreen> {
  final CircleGraphService _service = CircleGraphService();
  late Future<List<CircleGraphData>> _statisticFuture;
  List<CircleGraphData> _allStatistics = [];

  final List<Color> _chartColors = [
    Color(0xFF5B6BC8),
    Color(0xFF4DB6AC),
    Color(0xFF3949AB),
    Color(0xFF90CAF9),
  ];

  @override
  void initState() {
    super.initState();
    _statisticFuture = _fetchAndProcessData();
  }

  Future<List<CircleGraphData>> _fetchAndProcessData() async {
    _allStatistics = await _service.fetchStatistics(widget.userId);
    _allStatistics.sort(
      (a, b) => b.serviceMonthlyPrice.compareTo(a.serviceMonthlyPrice),
    );
    return _allStatistics;
  }

  int get _totalMonthlyExpense =>
      _allStatistics.fold(0, (sum, item) => sum + item.serviceMonthlyPrice);

  List<PieChartSectionData> _getSections(double total) {
    if (total == 0) return [];

    return List.generate(_allStatistics.length, (i) {
      final data = _allStatistics[i];
      final percentage = data.serviceMonthlyPrice / total * 100;
      final titleText = percentage >= 5
          ? '${percentage.toStringAsFixed(0)}%'
          : '';

      return PieChartSectionData(
        color: _chartColors[i % _chartColors.length],
        value: data.serviceMonthlyPrice.toDouble(),
        title: titleText,
        radius: 25, //반지름 설정
        titlePositionPercentageOffset: 0.5, // 원 퍼센트 텍스트 조정
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_allStatistics.length, (i) {
        final data = _allStatistics[i];
        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _chartColors[i % _chartColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(data.appName, style: const TextStyle(fontSize: 14)),
          ],
        );
      }),
    );
  }

  Widget _buildServiceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "구독 서비스 목록",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ..._allStatistics.map((s) {
          final formattedPrice = s.serviceMonthlyPrice
              .toString()
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => "${m[1]},",
              );
          final index = _allStatistics.indexOf(s);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), //서비스 목록 패딩 조절
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _chartColors[index % _chartColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(s.appName, style: const TextStyle(fontSize: 16)),
                ),
                Text(
                  "$formattedPrice",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Insights",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () {},
          child: const Text("설정", style: TextStyle(color: Colors.black)),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("서비스 추가", style: TextStyle(color: Colors.teal)),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _statisticFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final formattedTotal = _totalMonthlyExpense
              .toString()
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => "${m[1]},",
              );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "구독 서비스 비용",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 7),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$formattedTotal 원",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E)
                          ),
                        ),
                        Text(
                          "종류: ${_allStatistics.length}가지",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Text(
                          "This Month",
                          style: TextStyle(color: Colors.black),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 160, // 원 크기 고정
                          height: 160,
                          child: PieChart(
                            PieChartData(
                              sections: _getSections(
                                _totalMonthlyExpense.toDouble(),
                              ),
                              centerSpaceRadius: 50,
                              sectionsSpace: 3,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20), //  원과 범례 사이 간격
                        Expanded(child: _buildLegend()), // 나머지 공간은 범례가 차지
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                _buildServiceList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
