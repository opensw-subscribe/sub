import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:poc_app_usage/utils/logger.dart';
import '../datas/sub_info_data.dart'; // 모델 클래스 위치에 따라 경로 수정 필요
import 'package:poc_app_usage/Config.dart';

class SubInfoService {
  // 실제 API 엔드포인트로 변경
  static const String _baseUrl =  Config.baseUrl;
  static const String _endpoint = '/api/subscriptions';

  /// 특정 사용자의 구독 서비스 리스트를 저장합니다.

  /// 구독 정보 저장
  Future<void> saveSubInfoData(SubInfoData data) async {
    try {
      final String url = '$_baseUrl$_endpoint';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('구독 정보 저장 성공');
      } else {
        final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
        final apiResponse = ApiResponse.fromJson(errorJson as Map<String, dynamic>);
        throw Exception('저장 실패: ${apiResponse.message} (Status: ${response.statusCode})');
      }
    } catch (e) {
      logger.e('구독 정보 저장 중 오류 발생: $e');
      rethrow;
    }
  }


  /// 특정 사용자의 구독 서비스 리스트를 가져옵니다.
  
  // 함수 반환 타입은 List<SubInfoData>
  Future<List<SubInfoData>> fetchSubInfoData(String userId) async {
    try {
      final String url = '$_baseUrl$_endpoint?user_id=$userId'; 
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 1. 성공 응답 처리: JSON 리스트 파싱
        
        // 응답 본문을 UTF-8로 디코딩 후 JSON 파싱
        // API 응답 본체가 리스트([]) 형태라고 가정
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        
        // JSON 리스트의 각 요소를 SubInfoData 모델 객체로 변환하여 리스트로 반환
        return jsonList
            .map((jsonItem) => SubInfoData.fromJson(jsonItem as Map<String, dynamic>))
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
      // 호출한 UI 위젯에서 처리할 수 있도록 예외를 다시 던집니다.
      rethrow; 
    }
  }
}