class SubInfoData {
  final String userId; // 사용자 ID
  final String appName; // 앱 이름
  final String appCategory; // 앱 카테고리
  final int serviceMonthlyPrice; // 서비스 월 가격
  final int serviceUsageTime; // 일일 사용 시간 (분)
  final int serviceUsage; // 일일 이용 횟수 (회)
  final int userSatis; // 사용자 만족도 (0~5)

  SubInfoData({
    required this.userId,
    required this.appName,
    required this.appCategory,
    required this.serviceMonthlyPrice,
    required this.serviceUsageTime,
    required this.serviceUsage,
    required this.userSatis,
  });

  factory SubInfoData.fromJson(Map<String, dynamic> json) {
    return SubInfoData(
      userId: json['user_id'],
      appName: json['app_name'],
      appCategory: json['app_category'],
      serviceMonthlyPrice: json['service_monthly_price'],
      serviceUsageTime: json['service_usage_time'],
      serviceUsage: json['service_usage'],
      userSatis: json['user_satis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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