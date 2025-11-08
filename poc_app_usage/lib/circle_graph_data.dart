import 'dart:convert';

/// 원형 그래프 데이터 항목을 나타내는 모델 클래스
class CircleGraphData {
  final String userId;
  final String appName;
  final int serviceMonthlyPrice;

  CircleGraphData({
    required this.userId,
    required this.appName,
    required this.serviceMonthlyPrice,
  });

  /// JSON (Map<String, dynamic>)으로부터 CircleGraphData 객체를 생성
  factory CircleGraphData.fromJson(Map<String, dynamic> json) {
    return CircleGraphData(
      userId: json['user_id'] as String,
      appName: json['app_name'] as String,
      serviceMonthlyPrice: json['service_monthly_price'] as int,
    );
  }
}

// 응답의 성공/실패 여부를 담는 기본 응답 모델 (이전 답변에서 사용된 것과 동일)
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