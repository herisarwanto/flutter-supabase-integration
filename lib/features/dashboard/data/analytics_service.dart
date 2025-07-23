import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/model/user_analytics_model.dart';

class AnalyticsService {
  final _client = Supabase.instance.client;

  Future<AnalyticsSummary> getAnalytics() async {
    try {

      final response = await _client
          .from('messages')
          .select('*')
          .order('created_at', ascending: false);

      final messages = response as List;

      if (messages.isEmpty) {
        return const AnalyticsSummary();
      }

      // Group messages by user
      final Map<String, List<dynamic>> userMessages = {};
      for (final message in messages) {
        final userId = message['user_id'] as String;
        if (!userMessages.containsKey(userId)) {
          userMessages[userId] = [];
        }
        userMessages[userId]!.add(message);
      }


      // Create user analytics
      final List<UserAnalytics> userAnalytics = [];
      for (final entry in userMessages.entries) {
        final userId = entry.key;
        final userMsgs = entry.value;

        // Get user info from first message
        final firstMsg = userMsgs.first;
        final userName = firstMsg['name'] as String? ?? 'Unknown User';

        // Use a simple identifier for email since we can't access other users' emails
        final userEmail = 'User ${userId.substring(0, 8)}...';

        // Calculate analytics
        final messageCount = userMsgs.length;
        final lastMessageDate = DateTime.parse(
          userMsgs.first['created_at'] as String,
        );

        userAnalytics.add(
          UserAnalytics(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            messageCount: messageCount,
            lastMessageDate: lastMessageDate,
          ),
        );
      }

      userAnalytics.sort((a, b) => b.messageCount.compareTo(a.messageCount));

      // Calculate summary
      final totalMessages = messages.length;
      final totalUsers = userAnalytics.length;
      final averageMessagesPerUser = totalUsers > 0
          ? (totalMessages / totalUsers).round()
          : 0;

      return AnalyticsSummary(
        userAnalytics: userAnalytics,
        totalMessages: totalMessages,
        totalUsers: totalUsers,
        averageMessagesPerUser: averageMessagesPerUser,
      );
    } catch (e) {
      log('Analytics error: $e'); 
      return const AnalyticsSummary();
    }
  }
}
