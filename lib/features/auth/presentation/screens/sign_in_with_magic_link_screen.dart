import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_integration/common/theme/app_colors.dart';
import 'package:flutter_supabase_integration/common/theme/app_strings.dart';
import '../providers/sign_in_form_provider.dart';

class SignInWithMagicLinkScreen extends ConsumerWidget {
  const SignInWithMagicLinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(signInFormProvider);
    final formNotifier = ref.read(signInFormProvider.notifier);

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
                        TextSpan(text: 'MAGIC'),
                        TextSpan(
                          text: ' LINK',
                          style: TextStyle(color: AppColors.lightBlue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.enterYourEmailToReceiveMagicLink,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.subtitle),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (formState.submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      formState.submitError!,
                      style: TextStyle(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (formState.submitError == null && !formState.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      AppStrings.magicLinkSent,
                      style: TextStyle(color: AppColors.success),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: formState.isLoading
                            ? null
                            : () async {
                                final success = await formNotifier
                                    .signInWithMagicLink();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Magic link sent! Check your email.',
                                      ),
                                    ),
                                  );
                                  // Do not navigate yet; wait for session restoration
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlue,
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
                            ? const CircularProgressIndicator()
                            : const Text('Send Magic Link'),
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
        prefixIcon: Icon(icon, color: AppColors.lightBlue),
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
                  color: AppColors.lightBlue,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
}
