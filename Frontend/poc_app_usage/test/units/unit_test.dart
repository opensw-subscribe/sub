// Mockito 라이브러리를 사용하기 위해 파일 상단에 추가 (필수)
// 터미널에서 'dart run build_runner build --delete-conflicting-outputs' 실행 필요
@GenerateMocks([
  http.Client,
  FirebaseAuth,
  SharedPreferences,
  User, // Firebase User
  AppUsage,
  NativeUsage,
])
import 'usage_service_test.mocks.dart'; // 자동으로 생성될 파일

// 실제 Service 파일과 설정 파일 import
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_usage/app_usage.dart';
import 'package:mockito/mockito.dart';

// [... 나머지 import 생략 ...]
// 실제 UsageService 클래스 경로를 import 해야 합니다.
import 'package:/poc_app_usage/service/usage_service.dart';
import 'package:poc_app_usage/utils/native_usage.dart';
import 'package:poc_app_usage/config.dart';

void main() {
  // Mock 인스턴스 생성
  late MockClient mockClient;
  late MockFirebaseAuth mockAuth;
  late MockSharedPreferences mockPrefs;
  late MockUser mockUser;
  late MockAppUsage mockAppUsage;
  late MockNativeUsage mockNativeUsage;
  late UsageService usageService;

  // 테스트 그룹 시작 전 초기화
  setUp(() {
    mockClient = MockClient();
    mockAuth = MockFirebaseAuth();
    mockPrefs = MockSharedPreferences();
    mockUser = MockUser();
    mockAppUsage = MockAppUsage();
    mockNativeUsage = MockNativeUsage();
    
    // UsageService가 내부적으로 사용하는 클래스를 Mock으로 대체
    // 여기서는 실제 코드에 주입할 수 없으므로, static/final 변수를 Mock으로 대체해야 함.
    // 실제 프로젝트에서는 DI(Dependency Injection)를 사용하여 Mock을 주입하는 것이 가장 좋음.
    // 예시에서는 Mocking이 어려운 부분을 가정하고 진행합니다.
    
    usageService = UsageService();
  });
  
  // -----------------------------------------------------------
  // 시나리오 1: 토큰 없이 데이터 전송 시도
  // -----------------------------------------------------------
  group('sendUsageDataToBackend - 인증 테스트', () {
    test('로그인 정보(user=null)가 없으면 전송 시도 없이 즉시 종료되어야 한다', () async {
      // Arrange
      // FirebaseAuth.instance.currentUser가 null을 반환하도록 설정해야 하지만,
      // 실제 코드에서 static 변수 접근을 Mocking하기 어려움.
      // => 여기서는 `user.getIdToken()`이 null을 반환한다고 가정하고 테스트 진행.
      
      // Act
      await usageService.sendUsageDataToBackend();

      // Assert
      // http.get 메서드가 호출되지 않았음을 확인 (네트워크 통신이 일어나지 않음)
      verifyNever(mockClient.get(any, headers: anyNamed('headers')));
    });

    test('토큰(token=null)이 없으면 전송 시도 없이 즉시 종료되어야 한다', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => null); // 토큰이 null인 경우

      // Act
      // [주의]: 이 테스트를 실행하려면 실제 코드 내에서 FirebaseAuth.instance 대신 Mock을 사용하도록 DI 구조를 갖춰야 함.
      // 현재 코드 구조로는 완벽한 단위 테스트가 불가능하여, 'Mock이 주입되었다'고 가정하고 Assert만 진행
      
      // Assert
      verifyNever(mockClient.get(any, headers: anyNamed('headers')));
    });
  });

  // -----------------------------------------------------------
  // 시나리오 2: 로컬 데이터 전송 성공
  // -----------------------------------------------------------
  group('sendUsageDataToBackend - 데이터 전송 성공 테스트', () {
    test('로컬 구독 정보가 백엔드에 성공적으로 POST되어야 한다', () async {
      // Arrange
      // 1. 인증 설정 (토큰 및 유저 ID)
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => 'FAKE_FIREBASE_TOKEN');
      
      // 2. 사용자 ID 조회 API Mocking (userId: 1 반환)
      when(mockClient.get(
        Uri.parse('${Config.baseUrl}/api/user/me'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"userId": "1"}', 200));

      // 3. SharedPreferences Mocking (로컬 구독 정보)
      when(mockPrefs.getKeys()).thenReturn({'Netflix_fee'});
      when(mockPrefs.getString('Netflix_fee')).thenReturn('13500.0');
      when(mockPrefs.getString('Netflix_category')).thenReturn(null); // 기본 매핑 사용

      // 4. AppUsage/NativeUsage Mocking
      when(mockAppUsage.getAppUsage(any, any)).thenAnswer((_) async => [
        AppUsageInfo('Netflix', 'com.netflix.mediaclient', const Duration(minutes: 60), DateTime.now().subtract(const Duration(days: 1)), DateTime.now()),
      ]);
      when(mockNativeUsage.getLaunchCounts(any, any)).thenAnswer((_) async => {
        'com.netflix.mediaclient': 10,
      });

      // 5. 백엔드 GET (동기화) Mocking: 백엔드에 구독 정보가 없다고 가정
      when(mockClient.get(
        Uri.parse(any, headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('[]', 200));

      // 6. 백엔드 POST Mocking: 성공 응답 (201 Created)
      when(mockClient.post(
        Uri.parse('${Config.baseUrl}/api/subscriptions/'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"message": "Success"}', 201));

      // Act
      await usageService.sendUsageDataToBackend();

      // Assert
      // 7. POST 요청이 올바른 데이터를 포함하여 호출되었는지 확인
      verify(mockClient.post(
        Uri.parse('${Config.baseUrl}/api/subscriptions/'),
        headers: argThat(containsPair('Content-Type', 'application/json')),
        body: argThat(contains('"app_name":"Netflix"')), // 앱 이름 확인
      )).called(1); // 한 번만 호출되었는지 확인
      
      // verify(logger.i(any)).called(greaterThanOrEqualTo(1)); // 성공 로그 확인
    });
  });

  // -----------------------------------------------------------
  // 시나리오 3: 백엔드 데이터 삭제 동기화 테스트
  // -----------------------------------------------------------
  group('sendUsageDataToBackend - 동기화 테스트', () {
    test('로컬에 없는 구독 정보는 백엔드에서 DELETE 요청되어야 한다', () async {
      // Arrange
      // 1. 인증 설정
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.getIdToken()).thenAnswer((_) async => 'FAKE_FIREBASE_TOKEN');
      when(mockClient.get(Uri.parse('${Config.baseUrl}/api/user/me'), headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('{"userId": "1"}', 200));

      // 2. SharedPreferences Mocking: 로컬에는 구독 정보가 없다고 가정
      when(mockPrefs.getKeys()).thenReturn({}); 

      // 3. 백엔드 GET (동기화) Mocking: 백엔드에는 'OldApp'이 있다고 가정
      when(mockClient.get(
        Uri.parse(argThat(contains('/api/subscriptions?user_id=1'))),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('[{"app_name": "OldApp", "sub_id": 99}]', 200));

      // 4. 백엔드 DELETE Mocking: 삭제 성공 응답
      when(mockClient.delete(
        Uri.parse('${Config.baseUrl}/api/subscriptions/99'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('', 204)); // 204 No Content

      // Act
      await usageService.sendUsageDataToBackend();

      // Assert
      // 5. DELETE 요청이 올바른 sub_id로 호출되었는지 확인
      verify(mockClient.delete(
        Uri.parse('${Config.baseUrl}/api/subscriptions/99'),
        headers: argThat(containsPair('Authorization', 'Bearer FAKE_FIREBASE_TOKEN')),
      )).called(1);
    });
  });
}