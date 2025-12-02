import 'package:http/http.dart' as http;
import 'package:poc_app_usage/config.dart';
import 'dart:convert';
import 'package:poc_app_usage/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ★ 토큰 가져오기용 추가
import '../datas/what-if_data.dart';

class WhatifService {
  static const String _baseUrl = Config.baseUrl;
  static const String _endpoint = '/api/whatif';

  Future<List<WhatifData>> fetchWhatifData(String month) async {
    try {
      // 1. Firebase 토큰 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        logger.w("❌ 로그인이 안 되어 있어 데이터를 전송할 수 없습니다.");
        return [];
      }

      final String? token = await user.getIdToken();
      if (token == null) return [];

      // 2. API 요청

      final url = Uri.parse("$_baseUrl$_endpoint?month=$month");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final decoded = jsonDecode(body);

        // 여기서 "data" 키 안의 리스트를 꺼내야 함
        if (decoded is Map && decoded["data"] is List) {
          final list = decoded["data"] as List;

          return list
              .map((item) => WhatifData.fromJson(item))
              .toList();
        } else {
          logger.w("Unexpected structure: $decoded");
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      logger.e("API error: $e");
      return [];
    }
  }
}
