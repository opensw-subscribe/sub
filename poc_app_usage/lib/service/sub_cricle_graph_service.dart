import 'package:http/http.dart' as http;
import 'dart:convert';
import '../datas/circle_graph_data.dart';
import 'package:poc_app_usage/utils/logger.dart';

class SubCircleGraphService {
  static const String _baseUrl = "https://YOUR_BACKEND";

  Future<List<CircleGraphData>> fetchCircleGraph(String month) async {
  try {
    final url = "$_baseUrl/api/circleGraph?month=$month";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(body);

      // 1) 데이터 리스트 추출
      final List<dynamic> list =
          decoded is Map && decoded['data'] is List
              ? decoded['data']
              : (decoded is List ? decoded : []);

      // 2) 안전한 데이터 변환
      return list
          .map((json) => CircleGraphData.fromJson(json))
          .toList();
    }

    return [];
  } catch (e) {
    logger.e("CircleGraph error: $e");
    return [];
  }
}

}