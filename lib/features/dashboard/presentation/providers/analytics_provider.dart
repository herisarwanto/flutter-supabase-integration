import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/analytics_service.dart';
import '../../domain/model/user_analytics_model.dart';

class AnalyticsNotifier extends StateNotifier<AsyncValue<AnalyticsSummary>> {
  final AnalyticsService _service;

  AnalyticsNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> fetchAnalytics() async {
    state = const AsyncValue.loading();
    try {
      final analytics = await _service.getAnalytics();
      state = AsyncValue.data(analytics);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshAnalytics() async {
    await fetchAnalytics();
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsSummary>>((
      ref,
    ) {
      return AnalyticsNotifier(AnalyticsService());
    });

final analyticsRefreshProvider = StateProvider<int>((ref) => 0);

void refreshAnalytics(WidgetRef ref) {
  ref.read(analyticsRefreshProvider.notifier).state++;
  ref.read(analyticsProvider.notifier).refreshAnalytics();
}
