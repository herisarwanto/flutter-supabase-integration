import 'package:flutter_supabase_integration/common/config/app_config.dart';
import 'package:flutter_supabase_integration/common/services/shared_prefs.dart';
import 'package:flutter_supabase_integration/common/utils/email_validator_mixin.dart';
import 'package:flutter_supabase_integration/features/auth/data/auth_service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_in_form_state.dart';

class SignInFormNotifier extends StateNotifier<SignInFormState>
    with EmailValidatorMixin {
  final AuthService _authService;
  SignInFormNotifier(this._authService) : super(const SignInFormState());

  void setEmail(String value) {
    state = state.copyWith(email: value, emailError: null, submitError: null);
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      passwordError: null,
      submitError: null,
    );
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  bool validate() {
    String? emailError;
    String? passwordError;

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!isValidEmail(state.email)) {
      emailError = 'Enter a valid email';
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      submitError: null,
    );

    return emailError == null && passwordError == null;
  }

  bool validateEmailOnly() {
    String? emailError;

    if (state.email.isEmpty) {
      emailError = 'Email is required';
    } else if (!isValidEmail(state.email)) {
      emailError = 'Enter a valid email';
    }

    state = state.copyWith(emailError: emailError, submitError: null);

    return emailError == null;
  }

  Future<bool> signIn({String? email, String? password}) async {
    if (email != null && password != null) {
      state = state.copyWith(email: email, password: password);
    }

    if (!validate()) return false;
    state = state.copyWith(isLoading: true, submitError: null);
    final error = await _authService.signIn(state.email, state.password);
    state = state.copyWith(isLoading: false, submitError: error);
    if (error == null) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await SharedPrefs.saveLogin(userId: user.id, email: user.email ?? '');
      }
    }
    return error == null;
  }

  Future<bool> signInWithMagicLink() async {
    if (!validateEmailOnly()) return false;
    state = state.copyWith(isLoading: true, submitError: null);
    const redirectTo = AppConfig.redirectTo;
    final error = await _authService.signInWithMagicLink(
      state.email,
      redirectTo: redirectTo,
    );
    state = state.copyWith(isLoading: false, submitError: error);
    return error == null;
  }
}

final signInFormProvider =
    StateNotifierProvider<SignInFormNotifier, SignInFormState>((ref) {
      return SignInFormNotifier(AuthService());
    });
