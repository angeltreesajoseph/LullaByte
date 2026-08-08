import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_form_controls.dart';
import '../widgets/auth_palette.dart';
import '../widgets/moon_cloud_illustration.dart';

/// Create Account screen (SRS Section 10.1.1, Registration).
///
/// Matches the Login screen's pastel "calm, safe, caring — 2 AM newborn
/// care" visual treatment exactly, via the shared widgets in
/// `features/authentication/presentation/widgets/`. Submission currently
/// simulates the network round-trip locally; it will call into the
/// Authentication data/domain layer once that integration lands, without
/// requiring any change to this screen's UI.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _confirmPasswordFocusNode = FocusNode();

  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _isSubmitting = false;
  String _password = '';
  _RegisterMethod? _activeMethod;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name';
    if (name.length < 2) return 'Name is too short';
    final namePattern = RegExp(r"^[A-Za-z\s'\-]+$");
    if (!namePattern.hasMatch(name)) return 'Enter a valid name';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    final emailPattern = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailPattern.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Create a password';
    if (password.length < 8) return 'Use at least 8 characters';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    if (!hasLetter || !hasDigit) return 'Include at least one letter and one number';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) return 'Confirm your password';
    if (confirm != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleEmailRegister() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    await _attemptSubmit(_RegisterMethod.email);
  }

  Future<void> _handleGoogleSignUp() => _attemptSubmit(_RegisterMethod.google);

  Future<void> _handlePhoneContinue() => _attemptSubmit(_RegisterMethod.phone);

  Future<void> _attemptSubmit(_RegisterMethod method) async {
    if (!_acceptedTerms) {
      setState(() {
        _showTermsError = true;
        _errorMessage = 'Please accept the Terms & Privacy Policy to continue.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _activeMethod = method;
      _errorMessage = null;
    });

    try {
      // Simulates the account-creation round-trip pending the
      // Authentication data/domain layer integration (AuthRepository is
      // not yet wired to this screen). Field-level validation above is
      // fully functional. Mock-only — no Firebase/backend integration.
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      context.go(RoutePaths.babyRegistration);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _activeMethod = null;
        });
      }
    }
  }

  void _goToLogin() => context.go(RoutePaths.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: AuthFloatingDecor()),
          SafeArea(
            child: Column(
              children: [
                AuthBackButton(onPressed: _goToLogin),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          children: [
                            const MoonCloudIllustration(),
                            const SizedBox(height: 14),
                            Text(
                              'Create Account',
                              style: GoogleFonts.quicksand(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AuthPalette.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'For new parents and caregivers —\nlet\'s set up a gentle space for your little one.',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                height: 1.4,
                                color: AuthPalette.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 26),
                            FadeTransition(
                              opacity: _entranceFade,
                              child: SlideTransition(
                                position: _entranceSlide,
                                child: AuthCard(
                                  child: Form(
                                    key: _formKey,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        if (_errorMessage != null) ...[
                                          AuthErrorBanner(message: _errorMessage!),
                                          const SizedBox(height: 16),
                                        ],
                                        AuthTextField(
                                          controller: _fullNameController,
                                          label: 'Full Name',
                                          hintText: 'e.g. Priya Sharma',
                                          keyboardType: TextInputType.name,
                                          textCapitalization: TextCapitalization.words,
                                          prefixIcon: Icons.badge_outlined,
                                          validator: _validateFullName,
                                          enabled: !_isSubmitting,
                                        ),
                                        const SizedBox(height: 14),
                                        AuthTextField(
                                          controller: _emailController,
                                          label: 'Email',
                                          hintText: 'you@example.com',
                                          keyboardType: TextInputType.emailAddress,
                                          prefixIcon: Icons.mail_outline_rounded,
                                          validator: _validateEmail,
                                          enabled: !_isSubmitting,
                                        ),
                                        const SizedBox(height: 14),
                                        AuthPasswordField(
                                          controller: _passwordController,
                                          label: 'Password',
                                          obscureText: _obscurePassword,
                                          enabled: !_isSubmitting,
                                          validator: _validatePassword,
                                          onToggleObscure: () {
                                            setState(() => _obscurePassword = !_obscurePassword);
                                          },
                                          onChanged: (value) => setState(() => _password = value),
                                          onSubmitted: (_) =>
                                              FocusScope.of(context)
                                                  .requestFocus(_confirmPasswordFocusNode),
                                        ),
                                        _PasswordStrengthMeter(password: _password),
                                        const SizedBox(height: 6),
                                        AuthPasswordField(
                                          controller: _confirmPasswordController,
                                          focusNode: _confirmPasswordFocusNode,
                                          label: 'Confirm Password',
                                          obscureText: _obscureConfirmPassword,
                                          enabled: !_isSubmitting,
                                          validator: _validateConfirmPassword,
                                          onToggleObscure: () {
                                            setState(
                                              () => _obscureConfirmPassword =
                                                  !_obscureConfirmPassword,
                                            );
                                          },
                                          onSubmitted: (_) => _handleEmailRegister(),
                                        ),
                                        const SizedBox(height: 6),
                                        AuthCheckboxRow(
                                          value: _acceptedTerms,
                                          enabled: !_isSubmitting,
                                          onChanged: (value) {
                                            setState(() {
                                              _acceptedTerms = value;
                                              if (value) _showTermsError = false;
                                            });
                                          },
                                          label: Text.rich(
                                            TextSpan(
                                              style: GoogleFonts.nunito(
                                                fontSize: 13,
                                                color: AuthPalette.textDark,
                                              ),
                                              children: [
                                                const TextSpan(text: 'I agree to the '),
                                                TextSpan(
                                                  text: 'Terms & Privacy Policy',
                                                  style: GoogleFonts.nunito(
                                                    fontWeight: FontWeight.w800,
                                                    color: AuthPalette.softCoral,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (_showTermsError)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 34, bottom: 4),
                                            child: Text(
                                              'Please accept the Terms & Privacy Policy',
                                              style: GoogleFonts.nunito(
                                                fontSize: 11.5,
                                                color: AuthPalette.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 12),
                                        AuthPrimaryButton(
                                          label: 'Create Account',
                                          isLoading: _isSubmitting &&
                                              _activeMethod == _RegisterMethod.email,
                                          onPressed: _isSubmitting ? null : _handleEmailRegister,
                                        ),
                                        const SizedBox(height: 22),
                                        const AuthOrDivider(),
                                        const SizedBox(height: 18),
                                        AuthOutlineButton(
                                          label: 'Continue with Google',
                                          icon: Icons.g_mobiledata_rounded,
                                          accent: AuthPalette.powderBlue,
                                          isLoading: _isSubmitting &&
                                              _activeMethod == _RegisterMethod.google,
                                          onPressed: _isSubmitting ? null : _handleGoogleSignUp,
                                        ),
                                        const SizedBox(height: 12),
                                        AuthOutlineButton(
                                          label: 'Continue with Phone',
                                          icon: Icons.phone_android_rounded,
                                          accent: AuthPalette.mint,
                                          isLoading: _isSubmitting &&
                                              _activeMethod == _RegisterMethod.phone,
                                          onPressed: _isSubmitting ? null : _handlePhoneContinue,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Already have an account? ',
                                              style: GoogleFonts.nunito(
                                                fontSize: 13.5,
                                                color: AuthPalette.textMuted,
                                              ),
                                            ),
                                            AuthTextLink(
                                              label: 'Log In',
                                              bold: true,
                                              onPressed: _isSubmitting ? null : _goToLogin,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _RegisterMethod { email, google, phone }

/// Live password strength indicator: four segments filling from Weak
/// (coral) through Strong (mint) based on length and character variety.
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.password});

  final String password;

  int get _score {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  ({String label, Color color}) get _descriptor {
    switch (_score) {
      case 0:
      case 1:
        return (label: 'Weak', color: AuthPalette.strengthWeak);
      case 2:
        return (label: 'Fair', color: AuthPalette.strengthFair);
      case 3:
        return (label: 'Good', color: AuthPalette.strengthGood);
      default:
        return (label: 'Strong', color: AuthPalette.strengthStrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final descriptor = _descriptor;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (index) {
                final filled = index < _score;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
                    height: 5,
                    decoration: BoxDecoration(
                      color: filled
                          ? descriptor.color
                          : AuthPalette.lavenderMist.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            descriptor.label,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: descriptor.color,
            ),
          ),
        ],
      ),
    );
  }
}
