class SubInfoData {
  final int? subId; // 구독 ID (삭제/수정 시 필요)
  final String userId; // 사용자 ID
  final String appName; // 앱 이름
  final String appCategory; // 앱 카테고리
  final int serviceMonthlyPrice; // 서비스 월 가격
  final int serviceUsageTime; // 일일 사용 시간 (분)
  final int serviceUsage; // 일일 이용 횟수 (회)
  final int userSatis; // 사용자 만족도 (0~5)

  static final Map<int, String> _idToCategory = {
    1: 'OTT',
    2: 'Music',
    3: 'Contents',
    4: 'AI',
    5: 'LifeStyle',
  };

  SubInfoData({
    this.subId,
    required this.userId,
    required this.appName,
    required this.appCategory,
    required this.serviceMonthlyPrice,
    required this.serviceUsageTime,
    required this.serviceUsage,
    required this.userSatis,
  });

  factory SubInfoData.fromJson(Map<String, dynamic> json) {
    int catId = json['category_id'] ?? 1;
    String category = _idToCategory[catId] ?? '기타';

    return SubInfoData(
      subId: json['sub_id'],
      userId: json['user_id'] ?? '', 
      appName: json['app_name'] ?? '',
      appCategory: category, 
      serviceMonthlyPrice: (json['service_monthly_price'] as num?)?.toInt() ?? 0,
      serviceUsageTime: (json['service_usage_time'] as num?)?.toInt() ?? 0,
      serviceUsage: (json['service_usage'] as num?)?.toInt() ?? 0,
      userSatis: (json['user_satis'] as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (subId != null) 'sub_id': subId,
      'user_id': userId,
      'app_name': appName,
      'app_category': appCategory,
      'service_monthly_price': serviceMonthlyPrice,
      'service_usage_time': serviceUsageTime,
      'service_usage': serviceUsage,
      'user_satis': userSatis,
    };
  }
}

// 응답의 성공/실패 여부를 담는 기본 응답 모델
class ApiResponse {
  final bool success;
  final String message;

  ApiResponse({required this.success, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}