import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_analytics_model.freezed.dart';
part 'user_analytics_model.g.dart';

@freezed
class UserAnalytics with _$UserAnalytics {
  const factory UserAnalytics({
    required String userId,
    required String userName,
    required String userEmail,
    required int messageCount,
    required DateTime lastMessageDate,
  }) = _UserAnalytics;

  factory UserAnalytics.fromJson(Map<String, dynamic> json) =>
      _$UserAnalyticsFromJson(json);
}

@freezed
class AnalyticsSummary with _$AnalyticsSummary {
  const factory AnalyticsSummary({
    @Default([]) List<UserAnalytics> userAnalytics,
    @Default(0) int totalMessages,
    @Default(0) int totalUsers,
    @Default(0) int averageMessagesPerUser,
  }) = _AnalyticsSummary;
}
