import 'package:riverpod/riverpod.dart';
import '../../../../common/utils/email_validator_mixin.dart';
import '../../data/auth_service.dart';
import 'sign_up_form_state.dart';

class SignUpFormNotifier extends StateNotifier<SignUpFormState>
    with EmailValidatorMixin {
  final AuthService _authService;
  SignUpFormNotifier(this._authService) : super(const SignUpFormState());

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

  Future<bool> signUp() async {
    if (!validate()) return false;
    state = state.copyWith(isLoading: true, submitError: null);
    final error = await _authService.signUp(state.email, state.password);
    state = state.copyWith(isLoading: false, submitError: error);
    return error == null;
  }
}

final signUpFormProvider =
    StateNotifierProvider<SignUpFormNotifier, SignUpFormState>((ref) {
      return SignUpFormNotifier(AuthService());
    });
