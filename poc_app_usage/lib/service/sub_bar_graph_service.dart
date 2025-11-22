import 'dart:convert';
import 'package:http/http.dart' as http;
import '../datas/bar_graph_data.dart';
import 'package:poc_app_usage/utils/logger.dart';

class StatisticService {
  static const String _baseUrl = "https://YOUR_BACKEND";

  Future<List<BarGraphData>> fetchBarGraph(String month) async {
  try {
    final url = "$_baseUrl/api/statistic?month=$month";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(body);

      final List<dynamic> list =
          decoded is Map && decoded['data'] is List
              ? decoded['data']
              : (decoded is List ? decoded : []);

      return list.map((json) => BarGraphData.fromJson(json)).toList();
    }

    return [];
  } catch (e) {
    logger.e("BarGraph error: $e");
    return [];
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
