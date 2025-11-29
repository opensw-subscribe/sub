import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

// ==========================
// ✅ 데이터 모델
// ==========================
class CircleGraphData {
  final int subId;
  final String userId;
  final String appName;
  final int serviceMonthlyPrice;
  final String month;

  CircleGraphData({
    required this.subId,
    required this.userId,
    required this.appName,
    required this.serviceMonthlyPrice,
    required this.month,
  });

  factory CircleGraphData.fromJson(Map<String, dynamic> json) {
    return CircleGraphData(
      subId: json['sub_id'],
      userId: json['user_id'],
      appName: json['app_name'],
      serviceMonthlyPrice: json['service_monthly_price'],
      month: json['month'],
    );
  }
}

// ==========================
// ✅ 서버 통신 서비스
// ==========================
class SubCircleGraphService {
  static const String _baseUrl = 'http://10.0.2.2:52141';

  Future<List<CircleGraphData>> fetchCircleGraph({
    required String idToken,
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/subscriptions/monthly?year=$year&month=$month',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('원형 차트 데이터 조회 실패: ${response.body}');
    }

    final List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded.map((e) => CircleGraphData.fromJson(e)).toList();
  }
}

// ==========================
// ✅ 서클 차트 화면
// ==========================
class SubCircleChartScreen extends StatefulWidget {
  final String idToken;

  const SubCircleChartScreen({
    super.key,
    required this.idToken,
  });

  @override
  State<SubCircleChartScreen> createState() => _SubCircleChartScreenState();
}

class _SubCircleChartScreenState extends State<SubCircleChartScreen> {
  final SubCircleGraphService _service = SubCircleGraphService();
  late Future<List<CircleGraphData>> _statisticFuture;
  List<CircleGraphData> _allStatistics = [];

  final List<Color> _chartColors = [
    const Color(0xFF5B6BC8),
    const Color(0xFF4DB6AC),
    const Color(0xFF3949AB),
    const Color(0xFF90CAF9),
  ];

  @override
  void initState() {
    super.initState();
    _statisticFuture = _fetchAndProcessData();
  }

  // ✅ ✅ ✅ 여기 핵심 수정 (현재 날짜 기준으로 요청!)
  Future<List<CircleGraphData>> _fetchAndProcessData() async {
    final now = DateTime.now();

    _allStatistics = await _service.fetchCircleGraph(
      idToken: widget.idToken,   // ✅ prefs에서 다시 안 꺼냄
      year: now.year,           // ✅ 현재 연도
      month: now.month,         // ✅ 현재 월
    );

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

      return PieChartSectionData(
        color: _chartColors[i % _chartColors.length],
        value: data.serviceMonthlyPrice.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 25,
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
            Text(data.appName),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _statisticFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_allStatistics.isEmpty) {
            return const Center(child: Text("이번 달 구독 데이터가 없습니다."));
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
                Text("총 구독 비용: $formattedTotal 원"),

                const SizedBox(height: 20),

                SizedBox(
                  width: 160,
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

                const SizedBox(height: 20),
                _buildLegend(),
              ],
            ),
          );
        },
      ),
    );
  }
}
