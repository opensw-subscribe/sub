// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:poc_app_usage/main.dart';
import 'package:poc_app_usage/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen loads correctly', (WidgetTester tester) async {
    // 앱 전체를 빌드
    await tester.pumpWidget(const MyApp());

    // OnboardingScreen이 존재하는지 확인
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // 화면에 특정 텍스트나 버튼이 있는지도 확인 가능
    // 예: "Get Started" 버튼 존재 여부
    // expect(find.text('Get Started'), findsOneWidget);
  });
}
