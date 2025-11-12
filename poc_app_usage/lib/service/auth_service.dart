import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;
  AuthService({this.baseUrl = 'https://your-backend.com'});

  // 회원가입
  Future<Map<String, dynamic>> signup({
    required String user_id, // email
    required String username, // nickname
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user_id,
          'user_name': username,
          'password': password,
        }),
      );

      final resJson = jsonDecode(response.body);

      // 성공 조건: HTTP 200 + success true
      if (response.statusCode == 200 && resJson['success'] == true) {
        final data = resJson['data'] as Map<String, dynamic>? ?? {};
        return data; // token, user_id, user_name 포함
      } else {
        final message = resJson['message'] ?? '회원가입 실패';
        throw Exception(message);
      }
    } catch (e) {
      // 네트워크/파싱 오류 처리
      throw Exception('회원가입 중 오류 발생: $e');
    }
  }

  // 로그인
  Future<Map<String, dynamic>> login({
    required String user_id, // email
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user_id,
          'password': password,
        }),
      );

      final resJson = jsonDecode(response.body);

      if (response.statusCode == 200 && resJson['success'] == true) {
        final data = resJson['data'] as Map<String, dynamic>? ?? {};
        return data; // token, user_id, user_name 포함
      } else {
        final message = resJson['message'] ?? '로그인 실패';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('로그인 중 오류 발생: $e');
    }
  }
}