import 'dart:convert';
import '/statistic.dart'; // 모델 클래스 import 필요
import 'package:http/http.dart' as http;

class StatisticService {
  // 실제 API 엔드포인트
  static const String _baseUrl = 'https://your-server-domain.com'; // 👈 실제 도메인으로 변경하세요.
  static const String _endpoint = '/api/statistic';

  // **(Mock 데이터는 제거합니다)**

  Future<List<statistic>> fetchStatistics(String userId) async {
    try {
      final String url = '$_baseUrl$_endpoint?user_id=$userId'; // GET 요청 URL 구성
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 1. 성공 응답 처리: JSON 리스트 파싱
        
        // 응답 본문을 UTF-8로 디코딩 후 JSON 파싱
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        
        // JSON 리스트를 ServiceStatistic 객체 리스트로 변환하여 반환
        return jsonList.map((jsonItem) => statistic.fromJson(jsonItem)).toList();
        
      } else {
        // 2. 실패 응답 처리 (400, 500 등)
        
        // 실패 Body ({"success": false, "message": "..."})를 파싱
        final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(errorJson);
        
        // 사용자에게 메시지를 보여줄 수 있도록 Exception 발생
        throw Exception('API 호출 실패: ${apiResponse.message} (Status: ${response.statusCode})');
      }
    } catch (e) {
      // 3. 통신 오류, 파싱 오류 등 예외 처리
      print('데이터를 불러오는 중 오류 발생: $e');
      rethrow; 
    }
  }
}