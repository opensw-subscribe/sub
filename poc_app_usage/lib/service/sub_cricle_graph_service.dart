import 'package:http/http.dart' as http;
import 'dart:convert';
import '../datas/circle_graph_data.dart';
import '../utils/logger.dart';

class SubCircleGraphService {
  static const String _baseUrl = "http://10.0.2.2:52141";

  Future<List<CircleGraphData>> fetchCircleGraph({
    required String idToken,
    required int year,
    required int month,
  }) async {
    logger.d("✅ CircleChart 요청 토큰: $idToken");
    try {
      final url =
          "$_baseUrl/api/subscriptions/monthly?year=$year&month=$month";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
        },

      );


      

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final List<dynamic> decoded = jsonDecode(body);

        return decoded
            .map((json) => CircleGraphData.fromJson(json))
            .toList();
      }

      throw Exception("서버 오류: ${response.statusCode}");
    } catch (e) {
      throw Exception("CircleGraph error: $e");
    }
  

  }
  
}

