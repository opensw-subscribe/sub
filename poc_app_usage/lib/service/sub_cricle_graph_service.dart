import 'package:http/http.dart' as http;
import 'dart:convert';
import '../datas/circle_graph_data.dart';
import 'package:poc_app_usage/utils/logger.dart';

class SubCircleGraphService {
  static const String _baseUrl = "https://YOUR_BACKEND";

  /// 특정 사용자의 월별 원형 그래프 데이터
  Future<List<CircleGraphData>> fetchCircleGraphData({
    required String month,  // YYYY-MM 형식
  }) async {
    try {
      final url = Uri.parse("$_baseUrl/api/circleGraph?month=$month");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        final List<dynamic> jsonList = jsonMap['data'];
        return jsonList
            .map((item) => CircleGraphData.fromJson(item))
            .toList();
      } else {
        final errorMsg = utf8.decode(response.bodyBytes);
        logger.e("API 호출 실패: $errorMsg");
        throw Exception("API 호출 실패: $errorMsg");
      }
    } catch (e) {
      logger.e("fetchCircleGraphData 오류: $e");
      rethrow;
    }
  }
}
