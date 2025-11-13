import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:poc_app_usage/screens/main_screen.dart';
import 'package:poc_app_usage/screens/choose_platform_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool _isRequesting = false;
  final AppUsage _appUsage = AppUsage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 안드로이드에서만 실행
    if (Platform.isAndroid) {
      _checkAndNavigate();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isAndroid) {
      _checkAndNavigate();
    }
  }

  Future<bool> _checkPermission() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(seconds: 1));
      await _appUsage.getAppUsage(startDate, endDate);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _checkAndNavigate() async {
    // 1. 앱 사용 권한이 있는지 먼저 확인
    if (await _checkPermission()) {
      
      // 2. 권한이 있다면, SharedPreferences (기록 저장소)를 엽니다.
      final prefs = await SharedPreferences.getInstance();
      
      // 3. 'platform_chosen'이라는 '기록'이 있는지 확인합니다. (기본값: false)
      final bool hasChosenPlatform = prefs.getBool('platform_chosen') ?? false;

      if (mounted) {
        if (hasChosenPlatform) {
          // '기록'이 있다면 (재방문) -> 메인 대시보드로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
          );
        } else {
          // '기록'이 없다면 (최초 방문) -> 플랫폼 선택 화면으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChoosePlatformScreen()),
          );
        }
      }
    }
  }

  Future<bool> _isAndroid10OrAbove() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt >= 29;
  }

  Future<void> _handlePermissionButtonClick() async {
    setState(() { _isRequesting = true; });

    final canRun = await _isAndroid10OrAbove();
    if (!canRun) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이 기능은 Android 10 이상에서만 동작합니다.')),
        );
      }
      setState(() { _isRequesting = false; });
      return;
    }

    // [!] Android의 "사용 정보 접근" 설정 화면으로 직접 이동
    // 이 화면에서 사용자가 바로 토글로 권한을 켤 수 있습니다
    try {
      const AndroidIntent intent = AndroidIntent(
        action: 'android.settings.USAGE_ACCESS_SETTINGS',
      );
      await intent.launch();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 화면을 열 수 없습니다: $e')),
        );
      }
    }

    setState(() { _isRequesting = false; });
  }

  @override
  Widget build(BuildContext context) {
    // 안드로이드가 아닐 경우를 대비한 예외 처리 화면
    if (!Platform.isAndroid) {
      return const Scaffold(
        body: Center(child: Text('이 기능은 Android에서만 지원됩니다.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.security, size: 80, color: Color(0xFF1A237E)),
              const SizedBox(height: 32),
              const Text(
                '앱 사용 시간\n접근 권한이 필요합니다',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '구독 서비스의 가치를 정확하게 분석하기 위해,\n사용자님의 앱 사용 기록 접근 권한이 필요합니다.\n\n이 정보는 오직 분석 목적으로만 사용되며,\n외부로 유출되지 않습니다.',
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isRequesting ? null : _handlePermissionButtonClick,
                child: _isRequesting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('권한 설정하러 가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}