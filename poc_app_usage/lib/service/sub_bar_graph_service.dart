import 'dart:convert';
import 'package:http/http.dart' as http;
import '../datas/bar_graph_data.dart';
import 'package:poc_app_usage/utils/logger.dart';

class StatisticService {
  static const String _baseUrl = "https://YOUR_BACKEND";

  /// 특정 사용자의 월별 구독 통계
  Future<List<BarGraphData>> fetchStatistics({
    required String month,  // YYYY-MM 형식
  }) async {
    try {
      final url = Uri.parse("$_baseUrl/api/statistic?month=$month");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List<dynamic> jsonList = jsonMap['data'];
        return jsonList
            .map((item) => BarGraphData.fromJson(item))
            .toList();
      } else {
        logger.e("API 호출 실패: ${response.statusCode}");
        throw Exception("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("fetchStatistics 오류: $e");
      rethrow;
    }
  }

  /// 별점 수정
  Future<void> updateRating({
    required String userId,
    required String appName,
    required int newRating,
    String? month, // 필요시 month 전달 가능
  }) async {
    final url = Uri.parse("$_baseUrl/api/subscription/rating");

    final body = {
      "user_id": userId,
      "app_name": appName,
      "user_satis": newRating,
      if (month != null) "month": month,
    };

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
