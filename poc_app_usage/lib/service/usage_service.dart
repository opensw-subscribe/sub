import 'dart:convert';
import 'package:app_usage/app_usage.dart';
import 'package:http/http.dart' as http;
import 'package:poc_app_usage/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../utils/native_usage.dart';
import '../datas/sub_info_data.dart';        // ⬅ 중요! (모델)
import '../service/sub_info_service.dart'; // ⬅ SubInfoService 불러오기

class UsageService {
  final SubInfoService _subService = SubInfoService();
  static const String _baseUrl = Config.baseUrl;

  static final Map<String, String> _packageMap = {
    'Netflix': 'com.netflix.mediaclient',
    'Disney+': 'com.disney.disneyplus',
    'Wavve': 'kr.co.captv.pooq',
    'TVING': 'net.cj.cjhv.tving',
    'WATCHA': 'com.watcha.play',
    'Coupang Play': 'com.coupang.play',
    'Melon': 'com.iloen.melon',
    'Genie': 'com.ktmusic.genie',
    'FLO': 'com.skt.skaf.l000mt.srt',
    'Bugs': 'com.nhnent.pieapp',
    'Spotify': 'com.spotify.music',
    'Apple Music': 'com.apple.android.music',
    'YouTube Premium': 'com.google.android.youtube',
    'Postype': 'com.postype.postype',
    'Millie': 'com.millie.library',
    'RIDI': 'com.ridibooks.ridiapp',
    'ChatGPT': 'com.openai.chatgpt',
    'Google Gemini': 'com.google.android.apps.bard',
    'Notion': 'notion.id',
    'Canva': 'com.canva.editor',
    '쿠팡': 'com.coupang.mobile',
    '배달의 민족': 'com.baemin.app',
    '요기요': 'com.yogiyo.yogiyo',
  };

  static final Map<String, String> _categoryMap = {
    'Netflix': 'OTT',
    'Disney+': 'OTT',
    'Wavve': 'OTT',
    'TVING': 'OTT',
    'WATCHA': 'OTT',
    'Coupang Play': 'OTT',
    'Melon': 'Music',
    'Genie': 'Music',
    'FLO': 'Music',
    'Bugs': 'Music',
    'Spotify': 'Music',
    'Apple Music': 'Music',
    'YouTube Premium': 'Contents',
    'Postype': 'Contents',
    'Millie': 'Contents',
    'RIDI': 'Contents',
    'ChatGPT': 'AI',
    'Google Gemini': 'AI',
    'Notion': 'AI',
    'Canva': 'AI',
    '쿠팡': 'LifeStyle',
    '배달의 민족': 'LifeStyle',
    '요기요': 'LifeStyle',
  };

  Future<void> sendUsageDataToBackend() async {
    logger.d("UsageService: 데이터 전송 시작...");

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      logger.d("📋 SharedPreferences에 저장된 모든 키: $allKeys");

      final String userId = prefs.getString('user_id') ?? 'test_user_id';

      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 30));

      final AppUsage appUsage = AppUsage();
      List<AppUsageInfo> usageInfos = await appUsage.getAppUsage(startDate, endDate);
      Map<String, int> launchCounts = await NativeUsage.getLaunchCounts(startDate, endDate);
      logger.d("📱 지난 30일 실행횟수 데이터: $launchCounts");
      List<Map<String, dynamic>> usageDataList = [];

      for (String key in allKeys) {
        if (!key.endsWith('_fee')) continue;

        String appName = key.replaceAll('_fee', '');
        String? feeString = prefs.getString(key);
        String? packageName = _packageMap[appName];

        logger.d("   ✓ 찾은 키: $key (앱 이름: $appName, 요금: $feeString)");
        logger.d("      → 패키지명 맵에서 찾기: $appName -> $packageName");

        if (feeString != null && packageName != null) {
            AppUsageInfo? matchingInfo;
            try {
              matchingInfo = usageInfos.firstWhere((info) => info.packageName == packageName);
              final minutes = matchingInfo.usage.inMinutes;
              final hours = minutes ~/ 60;
              final mins = minutes % 60;
              logger.d("      ✅ 사용 기록 매칭 성공: $packageName, 사용시간: ${hours}시간 ${mins}분 (${minutes}분)");
            } catch (_) {
              matchingInfo = null;
              logger.w("      ⚠️ 사용 기록 매칭 실패: $packageName 패키지를 사용 기록에서 찾을 수 없습니다.");
            }

          // ✔ 사용시간 조회
          AppUsageInfo? usageInfo;
          try {
            usageInfo = usageInfos.firstWhere((info) => info.packageName == packageName);
          } catch (_) {
            usageInfo = null;
          }
          int usageMinutes = usageInfo?.usage.inMinutes ?? 0;

          // ✔ 실행 횟수
          int launchCount = launchCounts[packageName] ?? 0;

          // ✔ 카테고리
          String appCategory = _categoryMap[appName] ?? '기타';

          // ✔ 월 요금
          int monthlyPrice = int.tryParse(feeString) ?? 0;

          // =====================================
          //          📌 구독 정보 저장
          // =====================================

          SubInfoData subInfo = SubInfoData(
            userId: userId,
            appName: appName,
            appCategory: appCategory,
            serviceMonthlyPrice: monthlyPrice, 
            serviceUsageTime: 0, 
            serviceUsage: 0, 
            userSatis: 0,
          );

          await _subService.saveSubInfoData(subInfo);
          logger.d("✔ 구독 정보 저장 완료: $appName");

          // =====================================
          //       📌 사용량 데이터 저장용 리스트
          // =====================================

          usageDataList.add({
            "user_id": userId,
            "app_name": appName,
            "app_category": appCategory,
            "service_monthly_price": monthlyPrice,
            "service_usage_time": usageMinutes,
            "service_usage": launchCount,
          });

           await http.post(
            Uri.parse('$_baseUrl/api/subscriptions/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(subInfo.toJson()),
          );

        }
      }

      logger.d("📤 사용량 데이터 ${usageDataList.length}개 전송 중...");
      logger.i("🎉 전체 데이터 전송 완료!");

    } catch (e) {
      logger.e("오류 발생: $e");
    }
  }
}

