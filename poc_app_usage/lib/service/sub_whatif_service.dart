import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:poc_app_usage/utils/logger.dart';
import '../datas/what-if_data.dart';

class WhatifService {
  static const String _baseUrl = 'http://10.0.2.2:52141';
  static const String _endpoint = '/api/statistic';

Future<List<WhatifData>> fetchWhatifData(String userId) async {
  try {
    final String url = '$_baseUrl$_endpoint?user_id=$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);

      final decoded = jsonDecode(body);

      if (decoded is List) {
        return decoded
            .map((item) => WhatifData.fromJson(item))
            .toList();
      } else if (decoded is Map && decoded['data'] is List) {
        // 백엔드가 { success: true, data: [...] } 형태일 경우
        return (decoded['data'] as List)
            .map((item) => WhatifData.fromJson(item))
            .toList();
      } else {
        // 예상치 못한 구조 → 빈 리스트
        return [];
      }
    }

    // 서버 응답이 실패하더라도 앱은 죽지 않음
    return [];

  } catch (e) {
    // 예외 발생해도 빈 리스트 반환 (앱 안 죽음)
    logger.e("API error: $e");
    return [];
  }
}

}