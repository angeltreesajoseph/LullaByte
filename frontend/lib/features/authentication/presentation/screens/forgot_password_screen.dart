import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_text_field.dart';

/// Forgot Password screen (SRS Section 10.1.5).
///
/// Reached from [LoginScreen] via a pushed route (not GoRouter — this
/// screen sits outside the app's top-level navigation graph) rather than a
/// named application route.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    final emailPattern = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailPattern.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Simulates the password-reset request round-trip pending the
      // Authentication data/domain layer integration.
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingXl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _isSubmitted ? _buildConfirmation(theme) : _buildForm(theme),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_reset_outlined, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'Reset your password',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            "Enter the email address linked to your account and we'll send you a link to reset your password.",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXl),
          if (_errorMessage != null) ...[
            _ErrorBanner(message: _errorMessage!),
            const SizedBox(height: AppConstants.spacingMd),
          ],
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
            validator: _validateEmail,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: AppConstants.spacingXl),
          AppButton(
            label: 'Send Reset Link',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _handleSubmit,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Center(
            child: AppButton(
              label: 'Back to Log In',
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.secondary),
        const SizedBox(height: AppConstants.spacingLg),
        Text(
          'Check your email',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          'If an account exists for ${_emailController.text.trim()}, a password reset link has been sent.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingXl),
        AppButton(
          label: 'Back to Log In',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
