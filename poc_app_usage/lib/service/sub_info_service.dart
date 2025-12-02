import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poc_app_usage/config.dart';
import 'dart:convert';
import 'package:poc_app_usage/utils/logger.dart';
import '../datas/sub_info_data.dart'; // 모델 클래스 위치에 따라 경로 수정 필요

class SubInfoService {
  // 실제 API 엔드포인트로 변경
  static const String _baseUrl = Config.baseUrl;
  static const String _endpoint = '/api/subscriptions';

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
  Future<List<SubInfoData>> fetchSubInfoData() async {
    try {
      // 1. Firebase 토큰 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("로그인이 필요합니다.");
      }
      final String? token = await user.getIdToken();
      if (token == null) {
        throw Exception("인증 토큰을 가져올 수 없습니다.");
      }

      final String url = '$_baseUrl$_endpoint'; 
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // 1. 성공 응답 처리: JSON 리스트 파싱
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        
        return jsonList
            .map((jsonItem) => SubInfoData.fromJson(jsonItem as Map<String, dynamic>))
            .toList();
        
      } else {
        // 2. 실패 응답 처리
        final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = "알 수 없는 오류";
        try {
           final apiResponse = ApiResponse.fromJson(errorJson as Map<String, dynamic>);
           errorMessage = apiResponse.message;
        } catch (_) {
           errorMessage = response.body;
        }
        
        throw Exception('API 호출 실패: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      logger.e('데이터를 불러오는 중 오류 발생: $e');
      rethrow; 
    }
  }

  /// 구독 정보 삭제
  Future<void> deleteSubInfoData(String appName) async {
    try {
      // 1. Firebase 토큰 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("로그인이 필요합니다.");
      }
      final String? token = await user.getIdToken();
      if (token == null) {
        throw Exception("인증 토큰을 가져올 수 없습니다.");
      }

      // 2. 먼저 전체 목록을 조회하여 appName에 해당하는 sub_id를 찾음
      final List<SubInfoData> currentSubs = await fetchSubInfoData();
      final targetSub = currentSubs.firstWhere(
        (sub) => sub.appName == appName,
        orElse: () => throw Exception("삭제할 구독 정보를 찾을 수 없습니다: $appName"),
      );

      if (targetSub.subId == null) {
        throw Exception("구독 ID(sub_id)가 없어 삭제할 수 없습니다.");
      }

      // 3. ID 기반으로 삭제 요청 (DELETE /api/subscriptions/{sub_id})
      final String url = '$_baseUrl$_endpoint/${targetSub.subId}';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        logger.i('구독 정보 삭제 성공: $appName (ID: ${targetSub.subId})');
      } else {
        logger.e('삭제 실패: ${response.body}');
        throw Exception('삭제 실패 (Status: ${response.statusCode})');
      }
    } catch (e) {
      logger.e('구독 정보 삭제 중 오류 발생: $e');
      rethrow;
    }
  }
}