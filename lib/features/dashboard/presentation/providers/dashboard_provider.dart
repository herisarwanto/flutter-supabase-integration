import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../common/services/shared_prefs.dart';

class DashboardNotifier extends StateNotifier<AsyncValue<void>> {
  DashboardNotifier() : super(const AsyncData(null));

  Future<bool> logout() async {
    state = const AsyncLoading();
    try {
      await Supabase.instance.client.auth.signOut();
      await SharedPrefs.logout();
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<void>>((ref) {
      return DashboardNotifier();
    });
