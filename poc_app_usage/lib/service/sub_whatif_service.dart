import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:poc_app_usage/utils/logger.dart';
import '../datas/what-if_data.dart';

class WhatifService {
  static const String _baseUrl = 'https://your-server-domain.com';
  static const String _endpoint = '/api/statistic';

  /// 월별 구독 데이터를 가져옵니다.
  Future<List<WhatifData>> fetchWhatifData({
    required String month, // YYYY-MM
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$_endpoint?month=$month');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> jsonList = jsonMap['data'];

        return jsonList
            .map((item) => WhatifData.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        logger.e('API 호출 실패: ${response.statusCode}');
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('fetchWhatifData 오류: $e');
      rethrow;
    }
  }
}
