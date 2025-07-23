import 'package:flutter/material.dart';
import 'package:flutter_supabase_integration/common/theme/app_colors.dart';
import 'package:flutter_supabase_integration/common/theme/app_strings.dart';
import '../providers/sign_up_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/router/routes.dart';
import '../providers/sign_in_form_provider.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(signUpFormProvider);
    final formNotifier = ref.read(signUpFormProvider.notifier);
    final signInNotifier = ref.read(signInFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.text,
                          ),
                      children: const [
                        TextSpan(text: 'SIGN'),
                        TextSpan(
                          text: ' UP',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTextField(
                      value: formState.email,
                      hintText: 'Email',
                      icon: Icons.email,
                      obscureText: false,
                      errorText: formState.emailError,
                      onChanged: formNotifier.setEmail,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      value: formState.password,
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: formState.obscurePassword,
                      isPassword: true,
                      errorText: formState.passwordError,
                      onChanged: formNotifier.setPassword,
                      onToggleVisibility: formNotifier.toggleObscurePassword,
                      isObscured: formState.obscurePassword,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: formState.isLoading
                            ? null
                            : () async {
                                final success = await formNotifier.signUp();
                                if (success && context.mounted) {
                                  final loginSuccess = await signInNotifier
                                      .signIn(
                                        email: formState.email,
                                        password: formState.password,
                                      );
                                  if (loginSuccess && context.mounted) {
                                    context.go(AppRoutes.dashboard);
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppStrings
                                              .signUpSuccessButLoginFailed,
                                        ),
                                        backgroundColor: AppColors.danger,
                                      ),
                                    );
                                  }
                                } else if (context.mounted &&
                                    formState.submitError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(formState.submitError!),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: formState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(AppStrings.signUp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String value,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    bool isPassword = false,
    String? errorText,
    ValueChanged<String>? onChanged,
    VoidCallback? onToggleVisibility,
    bool isObscured = false,
  }) {
    return TextField(
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        ),
      ),
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
}
