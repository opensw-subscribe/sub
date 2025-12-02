# Android 앱 실행 가이드

## 1. 개발 환경 준비
- Flutter SDK 설치 (https://docs.flutter.dev/get-started/install)
- Android Studio 또는 VS Code 설치
- Android 에뮬레이터 또는 실제 기기 준비

## 2. 프로젝트 의존성 설치
```bash
flutter pub get
```

## 3. 앱 실행 방법
### 에뮬레이터에서 실행
1. Android 에뮬레이터 실행
2. 아래 명령어로 앱 실행
```bash
flutter run
```

### 실제 기기에서 실행
1. USB 디버깅 활성화 및 기기 연결
2. 아래 명령어로 앱 실행
```bash
flutter run
```

## 4. 서버 주소 설정
- 기본 서버 주소는 `lib/config.dart` 파일의 `baseUrl`에서 설정합니다.
- 에뮬레이터에서는 `10.0.2.2`로 자동 설정되어 있습니다.

## 5. 주요 오픈소스 패키지
- pubspec.yaml 참고 
