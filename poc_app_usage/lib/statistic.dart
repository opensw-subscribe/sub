import 'dart:convert';

/// 구독 서비스 통계 데이터를 나타내는 모델 클래스
class Statistic {
  final String userId;
  final String appName;
  final String appCategory;
  final int serviceMonthlyPrice;
  final int serviceOncePrice;
  final int userSatis;

  Statistic({
    required this.userId,
    required this.appName,
    required this.appCategory,
    required this.serviceMonthlyPrice,
    required this.serviceOncePrice,
    required this.userSatis,
  });

  /// JSON (Map<String, dynamic>)으로부터 statistic 객체를 생성합니다.
  factory Statistic.fromJson(Map<String, dynamic> json) {
    return Statistic(
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      appCategory: json['app_category'] as String,
      serviceMonthlyPrice: json['service_monthly_price'] as int,
      serviceOncePrice: json['service_once_price'] as int,
      userSatis: json['user_satis'] as int,
    );
  }

  /// 객체를 JSON (Map<String, dynamic>)으로 변환합니다. (선택적)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'app_name': appName,
      'app_category': appCategory,
      'service_monthly_price': serviceMonthlyPrice,
      'service_once_price': serviceOncePrice,
      'user_satis': userSatis,
    };
  }

  /// 월별 총 지출 비용을 계산하는 Getter입니다.
  int get totalPriceMonthly => serviceMonthlyPrice + serviceOncePrice;
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