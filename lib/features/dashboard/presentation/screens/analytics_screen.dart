import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../../domain/model/user_analytics_model.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(analyticsProvider.notifier).fetchAnalytics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(analyticsProvider.notifier).fetchAnalytics(),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading analytics',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(analyticsProvider.notifier).fetchAnalytics(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (analytics) => _buildAnalyticsContent(analytics),
      ),
    );
  }

  Widget _buildAnalyticsContent(AnalyticsSummary analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(analytics),
          const SizedBox(height: 24),
          _buildUserAnalyticsList(analytics.userAnalytics),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AnalyticsSummary analytics) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 16), // Left padding
          _buildSummaryCard(
            'Total Messages',
            analytics.totalMessages.toString(),
            Icons.message,
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Total Users',
            analytics.totalUsers.toString(),
            Icons.people,
            Colors.green,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Avg Messages/User',
            analytics.averageMessagesPerUser.toString(),
            Icons.analytics,
            Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Active Users',
            analytics.userAnalytics.length.toString(),
            Icons.person,
            Colors.purple,
          ),
          const SizedBox(width: 16), // Right padding
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 120,
      height: 160,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAnalyticsList(List<UserAnalytics> userAnalytics) {
    if (userAnalytics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No analytics data available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message Count by User',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userAnalytics.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = userAnalytics[index];
            return _buildUserAnalyticsCard(user, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildUserAnalyticsCard(UserAnalytics user, int rank) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank == 1
              ? Colors.amber
              : rank == 2
              ? Colors.grey[400]
              : rank == 3
              ? Colors.brown[300]
              : Colors.deepPurple[100],
          child: Text(
            rank.toString(),
            style: TextStyle(
              color: rank <= 3 ? Colors.white : Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user.userEmail,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.messageCount.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              'messages',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
