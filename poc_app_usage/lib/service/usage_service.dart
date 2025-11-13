import 'dart:convert';
import 'package:app_usage/app_usage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsageService {
  // [1] '번역표': 사용자가 저장한 앱 이름 <-> 안드로이드 실제 패키지 이름
  // [!] ChooseFeeScreen에서 저장하는 'platformName'과 이 맵의 'key'가 100% 일치해야 합니다!
  static final Map<String, String> _packageMap = {
    // OTT 서비스
    'Netflix': 'com.netflix.mediaclient',
    'Disney+': 'com.disney.disneyplus',
    'Wavve': 'kr.co.captv.pooq',
    'TVING': 'net.cj.cjhv.tving',
    'WATCHA': 'com.watcha.play',
    'Coupang Play': 'com.coupang.play',

    // 음악 서비스
    'Melon': 'com.iloen.melon',
    'Genie': 'com.ktmusic.genie',
    'FLO': 'com.skt.skaf.l000mt.srt',
    'Bugs': 'com.nhnent.pieapp',
    'Spotify': 'com.spotify.music',
    'Apple Music': 'com.apple.android.music',

    // 콘텐츠 서비스
    'YouTube Premium': 'com.google.android.youtube',
    'Postype': 'com.postype.postype',
    'Millie': 'com.millie.library',
    'RIDI': 'com.ridibooks.ridiapp',

    // AI 서비스
    'ChatGPT': 'com.openai.chatgpt', // ChatGPT 공식 앱
    'Google Gemini': 'com.google.android.apps.bard', // Google Bard/Gemini 앱
    'Notion': 'notion.id', // Notion Android 앱 (패키지명 확인 필요)
    'Canva': 'com.canva.editor', // Canva Android 앱
    // 라이프스타일 서비스
    '쿠팡': 'com.coupang.mobile',
    '배달의 민족': 'com.baemin.app',
    '요기요': 'com.yogiyo.yogiyo',
  };

  // [1-2] 앱 이름 <-> 카테고리 매핑
  static final Map<String, String> _categoryMap = {
    // OTT 서비스
    'Netflix': 'OTT',
    'Disney+': 'OTT',
    'Wavve': 'OTT',
    'TVING': 'OTT',
    'WATCHA': 'OTT',
    'Coupang Play': 'OTT',

    // 음악 서비스
    'Melon': 'Music',
    'Genie': 'Music',
    'FLO': 'Music',
    'Bugs': 'Music',
    'Spotify': 'Music',
    'Apple Music': 'Music',

    // 콘텐츠 서비스
    'YouTube Premium': 'Contents',
    'Postype': 'Contents',
    'Millie': 'Contents',
    'RIDI': 'Contents',

    // AI 서비스
    'ChatGPT': 'AI',
    'Google Gemini': 'AI',
    'Notion': 'AI',
    'Canva': 'AI',

    // 라이프스타일 서비스
    '쿠팡': 'LifeStyle',
    '배달의 민족': 'LifeStyle',
    '요기요': 'LifeStyle',
  };

  // [2] 백엔드로 '앱 사용 시간'과 '구독 정보'를 전송하는 메인 함수
  Future<void> sendUsageDataToBackend() async {
    print("UsageService: 데이터 전송 시작...");
    try {
      // 1. SharedPreferences에서 사용자가 '구독 중'이라고 저장한 앱 찾기
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys(); // 폰에 저장된 모든 키 가져오기

      // 디버그: 모든 SharedPreferences 키 출력
      print("📋 UsageService: SharedPreferences에 저장된 모든 키:");
      for (String key in allKeys) {
        final value = prefs.get(key);
        print("   - $key: $value");
      }

      // 2. 사용자 ID 가져오기 (SharedPreferences 또는 로그인 정보에서)
      // [!] 실제 로그인된 유저 ID로 변경 필요
      final String userId = prefs.getString('user_id') ?? 'test_user_id';

      // 3. 안드로이드 OS에서 '최근 30일간'의 앱 사용 기록 가져오기
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 30));

      final AppUsage appUsage = AppUsage();
      List<AppUsageInfo> usageInfos = await appUsage.getAppUsage(
        startDate,
        endDate,
      );
      print("📱 UsageService: 지난 30일간 ${usageInfos.length}개의 앱 사용 기록을 가져왔습니다.");

      // 디버그: 가져온 앱 사용 기록 상세 출력
      print("📱 UsageService: 가져온 앱 사용 기록 상세:");
      for (var info in usageInfos) {
        final minutes = info.usage.inMinutes;
        final hours = minutes ~/ 60;
        final mins = minutes % 60;
        print(
          "   - 패키지명: ${info.packageName}, 사용시간: $hours시간 $mins분 ($minutes분)",
        );
      }

      // 4. 백엔드로 전송할 데이터 리스트 만들기
      List<Map<String, dynamic>> dataToSend = [];

      // 폰에 저장된 '모든' 키를 확인합니다.
      print("🔍 UsageService: _fee로 끝나는 키 검색 중...");
      int foundFeeKeys = 0;

      for (String key in allKeys) {
        // 키가 "_fee"로 끝나는지 확인 (예: "넷플릭스_fee")
        if (key.endsWith('_fee')) {
          foundFeeKeys++;
          String appName = key.replaceAll('_fee', ''); // "넷플릭스"
          String? feeString = prefs.getString(key); // "17000"
          String? packageName =
              _packageMap[appName]; // "com.netflix.mediaclient"

          print("   ✓ 찾은 키: $key (앱 이름: $appName, 요금: $feeString)");
          print("      → 패키지명 맵에서 찾기: $appName -> $packageName");

          if (feeString != null && packageName != null) {
            print("      ✅ 패키지명 찾음: $packageName");
          } else {
            if (feeString == null) {
              print("      ❌ 요금 정보가 null입니다.");
            }
            if (packageName == null) {
              print(
                "      ❌ 패키지명을 찾을 수 없습니다. _packageMap에 '$appName' 키가 없습니다.",
              );
              print("      📝 사용 가능한 앱 이름들: ${_packageMap.keys.toList()}");
            }
          }

          if (feeString != null && packageName != null) {
            // 3-1. 구독 중인 앱이라면, 가져온 OS 사용 기록에서 해당 패키지 찾기
            AppUsageInfo? matchingInfo;
            try {
              matchingInfo = usageInfos.firstWhere(
                (info) => info.packageName == packageName,
              );
              final minutes = matchingInfo.usage.inMinutes;
              final hours = minutes ~/ 60;
              final mins = minutes % 60;
              print(
                "      ✅ 사용 기록 매칭 성공: $packageName, 사용시간: ${hours}시간 ${mins}분 (${minutes}분)",
              );
            } catch (e) {
              // 패키지가 사용 기록에 없는 경우 (사용 시간이 0분)
              matchingInfo = null;
              print(
                "      ⚠️ 사용 기록 매칭 실패: $packageName 패키지를 사용 기록에서 찾을 수 없습니다.",
              );
              print("      💡 이 앱이 최근 30일간 사용되지 않았거나, 권한이 없을 수 있습니다.");
            }

            // 3-2. 전송할 데이터 만들기 (sub_info_data.dart의 필드명 기준)
            int usageMinutes = 0;
            if (matchingInfo != null) {
              usageMinutes = matchingInfo.usage.inMinutes;
            }

            // 카테고리 가져오기 (없으면 '기타')
            String appCategory = _categoryMap[appName] ?? '기타';

            // 월 가격을 정수로 변환
            int monthlyPrice;
            try {
              monthlyPrice = int.parse(feeString);
            } catch (e) {
              print("⚠️ UsageService: 월 가격 파싱 실패 ($appName): $feeString");
              monthlyPrice = 0;
            }

            dataToSend.add({
              "user_id": userId, // sub_info_data.dart 기준
              "app_name": appName,
              "app_category": appCategory,
              "service_monthly_price": monthlyPrice, // sub_info_data.dart 기준
              "service_usage_time":
                  usageMinutes, // sub_info_data.dart 기준 (분 단위)
              "service_usage": 0, // 일일 이용 횟수는 앱 사용 시간 API에서 추적 불가능하므로 0
              // "user_satis": 0, // 사용자 만족도는 사용자 입력 필요, 백엔드에서 기본값 처리 또는 별도 API
            });

            print(
              "      ✅ 데이터 추가 완료: $appName (카테고리: $appCategory, 가격: $monthlyPrice원, 사용시간: $usageMinutes분)",
            );
          }
        }
      }

      print("🔍 UsageService: 총 $foundFeeKeys개의 _fee 키를 찾았습니다.");
      print("📤 UsageService: 전송할 데이터 개수: ${dataToSend.length}개");

      if (dataToSend.isEmpty) {
        print("❌ UsageService: 백엔드로 전송할 구독 데이터가 없습니다.");
        print("💡 가능한 원인:");
        print("   1. SharedPreferences에 '_fee'로 끝나는 키가 없습니다.");
        print("   2. 저장된 앱 이름이 _packageMap에 없습니다.");
        print("   3. 요금 정보가 null입니다.");
        return;
      }

      print("UsageService: 백엔드로 총 ${dataToSend.length}개의 데이터를 전송합니다.");
      print(dataToSend);

      // 4. 백엔드 서버로 전송 (POST)
      // [!] 실제 서버 주소와 토큰으로 수정 필요
      final response = await http.post(
        Uri.parse('https://your-backend.com/api/usage-data'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // 토큰이 있다면 추가
        },
        body: jsonEncode({
          "user_id": userId, // sub_info_data.dart 기준 (각 항목에도 포함됨)
          "usage_data": dataToSend,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ UsageService: 데이터 전송 성공!");
      } else {
        print("❌ UsageService: 데이터 전송 실패: ${response.body}");
      }
    } catch (e) {
      print("❌ UsageService: 오류 발생: $e");
    }
  }
}
