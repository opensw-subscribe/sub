import 'dart:convert';
import 'package:app_usage/app_usage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // ★ 토큰 가져오기용 추가
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../utils/native_usage.dart';
import '../config.dart';

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
    'Spotify': 'com.spotify.music', // 패키지명 수정 (http 주소 아님)
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

  // 백엔드는 category_id(숫자)를 원하므로 매핑용 맵 추가
  static final Map<String, int> _categoryIdMap = {
    'OTT': 1,
    'Music': 2,
    'Contents': 3,
    'AI': 4,
    'LifeStyle': 5,
  };

  static final Map<String, String> _categoryStringMap = {
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
      // 1. [중요] 파이어베이스 토큰 먼저 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        logger.w("❌ 로그인이 안 되어 있어 데이터를 전송할 수 없습니다.");
        return;
      }
      final String? token = await user.getIdToken();
      if (token == null) return;

      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 30));

      // 사용 시간 & 실행 횟수 가져오기
      final AppUsage appUsage = AppUsage();
      List<AppUsageInfo> usageInfos = await appUsage.getAppUsage(startDate, endDate);
      Map<String, int> launchCounts = await NativeUsage.getLaunchCounts(startDate, endDate);

      int successCount = 0;

      // 2. 반복문 시작
      for (String key in allKeys) {
        if (!key.endsWith('_fee')) continue;
        
        String appName = key.replaceAll('_fee', '');
        String? feeString = prefs.getString(key);
        String? packageName = _packageMap[appName];

        if (feeString != null && packageName != null) {
          // 사용 시간 매칭
          AppUsageInfo? matchingInfo;
          try {
            matchingInfo = usageInfos.firstWhere((info) => info.packageName == packageName);
          } catch (_) {
            matchingInfo = null;
          }

          int usageMinutes = matchingInfo?.usage.inMinutes ?? 0;
          
          // 카테고리 ID 변환 (문자열 -> 숫자)
          String categoryStr = _categoryStringMap[appName] ?? '기타';
          int categoryId = _categoryIdMap[categoryStr] ?? 1; // 없으면 기본값 1
          
          // 가격 변환
          double monthlyPrice = double.tryParse(feeString) ?? 0.0;

          // 실행 횟수 매칭
          int launchCount = launchCounts[packageName] ?? 0;

          // 3. [중요] 백엔드 스키마(SubscriptionCreate)에 맞춰서 데이터 포장
          Map<String, dynamic> bodyData = {
            "app_name": appName,
            "category_id": categoryId, // 숫자여야 함
            "service_monthly_price": monthlyPrice,
            "service_once_price": 0,
            "service_usage_time": usageMinutes, // 분 단위
            "service_usage": launchCount,       // 실행 횟수
            "weekly_usage_hours": 0,
            "user_satis": 5, // 기본값
            "is_active": true
          };

          // 4. [중요] 반복문 안에서 하나씩 전송
          final response = await http.post(
            Uri.parse('${Config.baseUrl}/api/subscriptions/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // 헤더에 토큰 필수!
            },
            body: jsonEncode(bodyData),
          );

          if (response.statusCode >= 200 && response.statusCode < 300) {
            logger.i("✅ $appName 전송 성공!");
            successCount++;
          } else {
            logger.e("❌ $appName 전송 실패: ${response.body}");
          }
        }
      }

      logger.i("🏁 총 $successCount개의 앱 데이터 전송 완료!");

    } catch (e) {
      logger.e("오류 발생: $e");
    }
  }
}