import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;

  UserService({
    this.baseUrl = 'http://10.0.2.2:52141',
  });

  // ✅ 사용자 생성: POST /api/users/
  Future<void> createUser({
    required String idToken,
    required String username,
  }) async {
    final uri = Uri.parse('$baseUrl/api/users/');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'user_name': username,
          }),
        )
        .timeout(const Duration(seconds: 5)); // ✅ 타임아웃 추가

    if (response.statusCode != 200) {
      throw Exception('유저 생성 실패: ${response.statusCode} ${response.body}');
    }
  }

  // ✅ 내 정보 조회: GET /api/users/me
  Future<Map<String, dynamic>> getMe({
    required String idToken,
  }) async {
    final uri = Uri.parse('$baseUrl/api/users/me');

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json', // ✅ 이 줄 반드시 필요
            'Authorization': 'Bearer $idToken',
          },
        )
        .timeout(const Duration(seconds: 5)); // ✅ 무한 로딩 방지

    if (response.statusCode != 200) {
      throw Exception('내 정보 조회 실패: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body);
    if (json is Map<String, dynamic>) {
      return json;
    } else {
      throw Exception('잘못된 응답 형식');
    }
  }
}
