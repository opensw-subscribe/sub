// Frontend/integration_test/integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:poc_app_usage/config.dart'; // 수정된 설정 파일 import

void main() {
  group('Backend API Integration Tests', () {
    // 1. 서버의 연결 상태를 확인하는 테스트
    testWidgets('Backend health check (GET /api/users)', (WidgetTester tester) async {
      // 1단계: API 주소 확인 (환경 변수가 잘 들어왔는지 확인)
      print('Testing Base URL: ${Config.baseUrl}');

      // 2단계: HTTP GET 요청
      final response = await http.get(Uri.parse(Config.usersEndpoint));

      // 3단계: 응답 검증
      expect(response.statusCode, 200, 
        reason: 'Failed to connect to backend or received non-200 status. '
                'URL used: ${Config.usersEndpoint}');
      
    });
  });
}