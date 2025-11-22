import 'dart:convert';
import 'package:app_usage/app_usage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../utils/native_usage.dart';

class UsageService {
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

      // 1) 기존: 사용 시간 데이터
      final AppUsage appUsage = AppUsage();
      List<AppUsageInfo> usageInfos = await appUsage.getAppUsage(
        startDate,
        endDate,
      );

      // 2) 추가된 코드: 실행 횟수 데이터
      Map<String, int> launchCounts = await NativeUsage.getLaunchCounts(
        startDate,
        endDate,
      );

      logger.d("📱 지난 30일 실행횟수 데이터: $launchCounts");

      List<Map<String, dynamic>> dataToSend = [];
      int foundFeeKeys = 0;

      for (String key in allKeys) {
        if (!key.endsWith('_fee')) continue;
        foundFeeKeys++;
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

        int usageMinutes = matchingInfo?.usage.inMinutes ?? 0;
        String appCategory = _categoryMap[appName] ?? '기타';
        int monthlyPrice = int.tryParse(feeString) ?? 0;

        // 실행 횟수 매칭
        int launchCount = launchCounts[packageName] ?? 0;

        logger.d("➡ $appName 사용횟수: $launchCount");

        dataToSend.add({
          "user_id": userId,
          "app_name": appName,
          "app_category": appCategory,
          "service_monthly_price": monthlyPrice,
          "service_usage_time": usageMinutes,
          "service_usage": launchCount, // ⭐ 실행 횟수!!
        });


       logger.d("      ✅ 데이터 추가 완료: $appName (카테고리: $appCategory, 가격: $monthlyPrice원, 사용시간: $usageMinutes분)");
      } else {
        if (feeString == null) logger.w("      ❌ 요금 정보가 null입니다.");
        if (packageName == null) logger.w("      ❌ 패키지명을 찾을 수 없습니다. _packageMap에 '$appName' 키가 없습니다.");
      }
    }

        logger.d("🔍 총 $foundFeeKeys개의 _fee 키를 찾았습니다.");
        logger.d("📤 전송할 데이터 개수: ${dataToSend.length}개");

        if (dataToSend.isEmpty) {
        logger.w("❌ 백엔드로 전송할 구독 데이터가 없습니다.");
        return;
        }

      await http.post(
        Uri.parse('https://your-backend.com/api/usage-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userId, "usage_data": dataToSend}),
      );

      logger.i("전송 완료!");
    } catch (e) {
      logger.e("오류: $e");
    }
  }
}
