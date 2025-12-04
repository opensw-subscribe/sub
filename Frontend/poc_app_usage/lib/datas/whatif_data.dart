/// 구독 서비스 통계 데이터를 나타내는 모델 클래스
class WhatifData {
  final String userId;
  final String appName;
  final String appCategory;
  final int serviceMonthlyPrice;
  bool isActive;

  WhatifData({
    required this.userId,
    required this.appName,
    required this.appCategory,
    required this.serviceMonthlyPrice,
    this.isActive = true,
  });

  /// JSON (Map)으로부터 ServiceStatistic 객체를 생성합니다.
  factory WhatifData.fromJson(Map<String, dynamic> json) {
    return WhatifData(
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      appCategory: json['app_category'] as String,
      // API 응답의 타입이 확실하지 않다면 .toInt() 또는 안전한 파싱 로직을 추가합니다.
      serviceMonthlyPrice: (json['service_monthly_price'] as num).toInt(),
      isActive: true,
    );
  }

  /// 객체를 JSON (Map)으로 변환합니다. (선택적)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'app_name': appName,
      'app_category': appCategory,
      'service_monthly_price': serviceMonthlyPrice,
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