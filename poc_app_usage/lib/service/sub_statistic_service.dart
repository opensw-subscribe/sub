import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:poc_app_usage/utils/logger.dart';
import '../bar_graph_data.dart'; // 모델 클래스 위치에 따라 경로 수정 필요

// 이 파일은 service/service_statistic_service.dart에 위치한다고 가정
class StatisticService {
  // 실제 API 엔드포인트로 변경
  static const String _baseUrl = 'https://your-server-domain.com';
  static const String _endpoint = '/api/statistic';

  /// 특정 사용자의 구독 통계 데이터를 리스트 형태로 가져옵니다.
  /// (GET /api/statistic?user_id={userId})
  
  // 함수 반환 타입은 List<Statistic>
  Future<List<Statistic>> fetchStatistics(String userId) async {
    try {
      final String url = '$_baseUrl$_endpoint?user_id=$userId'; 
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 1. 성공 응답 처리: JSON 리스트 파싱
        
        // 응답 본문을 UTF-8로 디코딩 후 JSON 파싱
        // API 응답 본체가 리스트([]) 형태라고 가정
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        
        // JSON 리스트의 각 요소를 Statistic 모델 객체로 변환하여 리스트로 반환
        return jsonList
            .map((jsonItem) => Statistic.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        
      } else {
        // 2. 실패 응답 처리 (400, 500 등)
        
        // 실패 Body ({"success": false, "message": "..."})를 파싱
        final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(errorJson as Map<String, dynamic>);
        
        throw Exception('API 호출 실패: ${apiResponse.message} (Status: ${response.statusCode})');
      }
    } catch (e) {
      // 3. 통신 오류, 파싱 오류 등 예외 처리
      logger.e('데이터를 불러오는 중 오류 발생: $e');
      rethrow; 
    }
  }
}