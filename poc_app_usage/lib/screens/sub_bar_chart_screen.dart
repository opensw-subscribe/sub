import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poc_app_usage/screens/choose_platform_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 개별 구독 데이터 모델
class BarGraphData {
  /// 백엔드에서 내려주는 구독 ID (id / sub_id)
  final int subId;

  final String appName;
  final String appCategory;
  final int serviceMonthlyPrice;
  final int serviceOncePrice;
  int userSatis;

  BarGraphData({
    required this.subId,
    required this.appName,
    required this.appCategory,
    required this.serviceMonthlyPrice,
    required this.serviceOncePrice,
    required this.userSatis,
  });

  /// 백엔드 JSON → BarGraphData 변환
  factory BarGraphData.fromJson(Map<String, dynamic> json) {
    return BarGraphData(
      subId: (json['id'] as num).toInt(), // ✅ 구독 고유 ID
      appName: json['app_name'] as String,
      // category_name / category_id 중 뭐가 오는지에 따라 수정
      appCategory: (json['category_name'] ?? json['app_category'] ?? '').toString(),
      serviceMonthlyPrice:
          (json['service_monthly_price'] as num?)?.toInt() ?? 0,
      // 백엔드에 1회 가격 없으면 0으로 두거나, 나중에 다른 값으로 교체
      serviceOncePrice: (json['service_once_price'] as num?)?.toInt() ?? 0,
      userSatis: (json['user_satis'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 구독 데이터 서비스 (백엔드 연동)
class BarGraphDataService {
  /// 에뮬레이터에서 로컬 백엔드 접속용 주소
  /// minikube service backend --url 결과 포트에 맞춰서 수정할 것
  final String baseUrl;

  BarGraphDataService({
    this.baseUrl = 'http://10.0.2.2:52141',
  });

  /// SharedPreferences에서 idToken 가져오기
  Future<String> _loadIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('저장된 auth_token 없음 (로그인이 안 되어 있음)');
    }
    return token;
  }

  /// 내 구독 전체 조회: GET /api/subscriptions/
  Future<List<BarGraphData>> fetchStatistics() async {
    final idToken = await _loadIdToken();

    final uri = Uri.parse('$baseUrl/api/subscriptions/');
    final response = await http
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $idToken',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('구독 목록 조회 실패: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('구독 목록 응답 형식이 리스트가 아님: $decoded');
    }

    return decoded
        .map((e) => BarGraphData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 만족도 수정: PUT /api/subscriptions/{sub_id}
  Future<void> updateRating({
    required int subId,
    required int newRating,
  }) async {
    final idToken = await _loadIdToken();

    final uri = Uri.parse('$baseUrl/api/subscriptions/$subId');

    final response = await http
        .put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'user_satis': newRating,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(
          '만족도 수정 실패: ${response.statusCode} ${response.body}');
    }
  }
}

class SubBarGraphScreen extends StatefulWidget {
  final String idToken; // 지금은 안 써도 됨(백엔드가 토큰으로 유저 판단)

  const SubBarGraphScreen({super.key, required this.idToken});

  @override
  State<SubBarGraphScreen> createState() => _SubBarGraphScreenState();
}

class _SubBarGraphScreenState extends State<SubBarGraphScreen> {
  final BarGraphDataService _service = BarGraphDataService();
  late Future<List<BarGraphData>> _statisticFuture;
  List<BarGraphData> _statistics = [];

  // 막대 그래프와 목록에 사용될 일관된 색상 정의
  final Color _oncePriceColor = Colors.teal.shade400; // 1회 비용/만족도 막대 (민트색)
  final Color _monthlyPriceColor =
      Colors.blue.shade900; // 월 비용 막대 (네이비색)

  late final List<Color> _listColors = [_monthlyPriceColor, _oncePriceColor];

  @override
  void initState() {
    super.initState();
    // userId는 이제 필요 없으므로 인자 없이 호출
    _statisticFuture = _service.fetchStatistics();
  }

  Future<void> _updateRating(BarGraphData data, int newRating) async {
    final int oldRating = data.userSatis;

    // 1) UI 먼저 업데이트
    setState(() {
      data.userSatis = newRating;
    });

    try {
      // 2) 실제 PUT 요청 (subId 기반)
      await _service.updateRating(
        subId: data.subId,
        newRating: newRating,
      );
    } catch (e) {
      // 3) 실패 → 원상 복귀
      setState(() {
        data.userSatis = oldRating;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("별점 수정 실패: $e")),
      );
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

    // 월 비용 기준 최대값 (임시로 12000, 나중에 동적으로 계산해도 됨)
    const double maxMonthlyPrice = 12000.0;

    final double monthlyPriceHeight =
        maxHeight * (data.serviceMonthlyPrice / maxMonthlyPrice);

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
              // 월 비용 막대
              _buildSingleBar(
                height: monthlyPriceHeight,
                color: _monthlyPriceColor,
                maxHeight: maxHeight,
              ),
              const SizedBox(width: 4),
              // 1회 비용 막대
              _buildSingleBar(
                height: oncePriceHeight,
                color: _oncePriceColor,
                maxHeight: maxHeight,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------
  // 단일 막대 위젯
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
        Container(width: width, height: maxHeight, color: Colors.grey[200]),
        Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ).copyWith(color: color),
        ),
      ],
    );
  }

  // -------------------------
  // 목록 항목 UI
  // -------------------------
  Widget _buildListItem(BarGraphData data) {
    final int index = _statistics.indexOf(data);
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
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: listColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.appName,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            width: 120.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStarRating(
                  rating: data.userSatis,
                  onChanged: (newRating) => _updateRating(data, newRating),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          SizedBox(
            width: 70,
            child: Text(
              formattedPrice,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // AppBar
  // -------------------------
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Chart',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: TextButton(
        onPressed: () {
          // 설정 화면 연결 예정이면 여기에 Navigator.push(...)
        },
        child: const Text(
          '설정',
          style: TextStyle(color: Colors.black),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChoosePlatformScreen(),
              ),
            );
          },
          child: const Text(
            '서비스 추가',
            style: TextStyle(color: Colors.blue),
          ),
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
            return Center(
              child: Text('데이터 로드 실패: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            _statistics = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartPlaceholder(),
                  const SizedBox(height: 24),
                  const Text(
                    '구독 서비스 목록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
