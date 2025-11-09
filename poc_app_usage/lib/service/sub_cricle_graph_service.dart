import 'package:http/http.dart' as http;
import 'package:poc_app_usage/utils/logger.dart';
import 'dart:convert';

// 모델 클래스 import. 실제 파일 구조에 맞게 경로 수정 필요
import '../datas/circle_graph_data.dart'; // 예시: lib/service 폴더에서 lib/circle_graph_data.dart를 가져오는 경우

class SubCircleGraphService {
  // 실제 API 엔드포인트
  static const String _baseUrl = 'https://your-server-domain.com';
  static const String _endpoint = '/api/circleGraph';

  /// 특정 사용자의 원형 그래프 통계 데이터를 리스트 형태로 가져옵니다.
  /// (GET /api/circleGraph?user_id={userId})
  Future<List<CircleGraphData>> fetchCircleGraphData(String userId) async {
    try {
      final String url = '$_baseUrl$_endpoint?user_id=$userId'; 
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 1. 성공 응답 처리: JSON 리스트 파싱
        
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        
        // JSON 리스트의 각 항목을 CircleGraphData 모델 객체로 변환하여 리스트로 반환
        return jsonList
            .map((jsonItem) => CircleGraphData.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        
      } else {
        // 2. 실패 응답 처리 (400, 500 등)
        
        final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(errorJson as Map<String, dynamic>);
        
        throw Exception('API 호출 실패: ${apiResponse.message} (Status: ${response.statusCode})');
      }
    } catch (e) {
      // 3. 통신 오류, 파싱 오류 등 예외 처리
      logger.e('원형 그래프 데이터를 불러오는 중 오류 발생: $e');
      rethrow; 
    }
  }
}