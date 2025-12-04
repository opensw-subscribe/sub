// Frontend/lib/config/api_config.dart
class Config {
  // CI/CD 환경 변수 'API_URL'
  // **만약 CI/CD 환경 변수가 주어지지 않으면 (로컬 실행 시)**
  // **defalut 값은 Android 에뮬레이터에서 호스트(로컬) 서버에 접근하기 위한 주소
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:57584', // 로컬에서 돌릴 때 여기 변경!!
  );
  
  static const String usersEndpoint = '$baseUrl/api/users';
  // ...
}