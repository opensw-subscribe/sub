import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  final String baseUrl = Config.baseUrl;

  // 생성자
  AuthService();

  // [수정완료] 회원가입 (정확히는 '유저 닉네임 DB 저장')
  Future<Map<String, dynamic>> signup({
    required String username, // 닉네임
    String? idToken,          // Firebase 토큰 
  }) async {
    try {
      // 1. 주소 설정: Swagger에 나온 그대로 (/api/users/)
      final url = Uri.parse('$baseUrl/api/users/');
      
      // 2. 헤더 설정 (토큰 실어 보내기)
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }

      // 3. 요청 보내기
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'user_name': username, // Swagger에 적힌 키 값
        }),
      );

      // 4. 응답 처리
      // 한글 깨짐 방지용 디코딩
      final resJson = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return resJson; // 성공!
      } else {
        final message = resJson['detail'] ?? '유저 저장 실패';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('서버 통신 중 오류 발생: $e');
    }
  }
}