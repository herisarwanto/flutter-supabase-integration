import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        password: password,
        email: email,
      );

      if (response.user != null) {
        return null;
      }

      return 'An unknown error occurred';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error:$e';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        password: password,
        email: email,
      );

      if (response.user != null) {
        return null;
      }

      return 'Invalid email or password';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error:$e';
    }
  }

  Future<String?> signInWithMagicLink(
    String email, {
    String? redirectTo,
  }) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: redirectTo,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error:$e';
    }
  }

  Future<bool> logout() async {
    try {
      await supabase.auth.signOut();
      return true;
    } on AuthException catch (e) {
      log(e.message);
      return false;
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }
}
