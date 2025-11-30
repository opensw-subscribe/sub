import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poc_app_usage/config.dart';
import '../datas/bar_graph_data.dart';
import 'package:poc_app_usage/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ★ 토큰 가져오기용 추가

class BarGraphService {
  static const String _baseUrl = Config.baseUrl;
  static const String _endpoint = "/api/statistic";

  Future<List<BarGraphData>> fetchBarGraph(String month) async {
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
              .map((item) => BarGraphData.fromJson(item))
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

  Future<void> updateRating({
  required String userId,
  required String appName,
  required int newRating,
}) async {
  // 1) Firebase Token 가져오기
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("로그인이 필요합니다.");

  final token = await user.getIdToken();

  // 2) URL 준비
  final url = Uri.parse("$_baseUrl/api/subscriptions/rating");

  // 3) 요청 Body
  final body = {
    "user_id": userId,
    "app_name": appName,
    "user_satis": newRating,
  };

  // 4) 인증 포함 PATCH 요청
  final response = await http.patch(
    url,
    headers: {
      "Authorization": "Bearer $token", 
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    throw Exception("서버 오류: ${response.statusCode}");
  }
}

}
