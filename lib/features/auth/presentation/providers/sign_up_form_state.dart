import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_form_state.freezed.dart';

@freezed
class SignUpFormState with _$SignUpFormState {
  const factory SignUpFormState({
    @Default('') String email,
    @Default('') String password,
    String? emailError,
    String? passwordError,
    @Default(true) bool obscurePassword,
    @Default(false) bool isLoading,
    String? submitError,
  }) = _SignUpFormState;
}
