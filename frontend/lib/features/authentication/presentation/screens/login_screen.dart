import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import 'forgot_password_screen.dart';

/// Log In screen (SRS Section 10.1.2, Login).
///
/// Premium, calm "newborn app at 2 AM" visual treatment: a soft pastel
/// gradient backdrop, a hand-illustrated sleepy moon and cloud, gently
/// floating stars and hearts, and a rounded, softly-shadowed card housing
/// the interactive form. Deliberately styled independently of the app's
/// ambient Material theme (see [_Palette]) so this hero moment stays warm
/// and consistent regardless of system dark/light mode.
///
/// Email/password authentication, Google Sign-In and Phone continuation
/// entry points, and navigation to Registration and Forgot Password.
/// Submission currently simulates the network round-trip locally; it will
/// call into the Authentication data/domain layer once that integration
/// lands, without requiring any change to this screen's UI.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  late final AnimationController _floatController;
  late final AnimationController _twinkleController;

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSubmitting = false;
  _LoginMethod? _activeMethod;
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

    // Gentle, continuous "breathing" float for the moon + cloud illustration.
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Slow twinkle cycle for the scattered stars and hearts.
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _twinkleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
    if (password.isEmpty) return 'Enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _handleEmailLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    await _submit(_LoginMethod.email);
  }

  Future<void> _handleGoogleSignIn() => _submit(_LoginMethod.google);

  Future<void> _handlePhoneContinue() => _submit(_LoginMethod.phone);

  Future<void> _submit(_LoginMethod method) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _activeMethod = method;
      _errorMessage = null;
    });

    try {
      // Simulates the authentication round-trip pending the Authentication
      // data/domain layer integration (AuthRepository is not yet wired to
      // this screen). Field-level validation above is fully functional.
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      context.go(RoutePaths.dashboard);
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

  void _goToRegister() => context.go(RoutePaths.register);

  void _goToForgotPassword() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: _BackgroundGradient()),
          Positioned.fill(
            child: IgnorePointer(
              child: _FloatingDecor(twinkle: _twinkleController),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _BackButton(onPressed: context.canPop() ? () => context.pop() : null),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _floatController,
                              builder: (context, child) {
                                final dy = math.sin(_floatController.value * math.pi) * 6;
                                return Transform.translate(offset: Offset(0, -dy), child: child);
                              },
                              child: const _MoonCloudIllustration(),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Welcome Back',
                              style: GoogleFonts.quicksand(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: _Palette.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Take a breath — your little one\'s world\nis right where you left it.',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                height: 1.4,
                                color: _Palette.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 26),
                            FadeTransition(
                              opacity: _entranceFade,
                              child: SlideTransition(
                                position: _entranceSlide,
                                child: _LoginCard(
                                  formKey: _formKey,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  passwordFocusNode: _passwordFocusNode,
                                  obscurePassword: _obscurePassword,
                                  rememberMe: _rememberMe,
                                  isSubmitting: _isSubmitting,
                                  activeMethod: _activeMethod,
                                  errorMessage: _errorMessage,
                                  onValidateEmail: _validateEmail,
                                  onValidatePassword: _validatePassword,
                                  onToggleObscure: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                  onToggleRememberMe: (value) {
                                    setState(() => _rememberMe = value);
                                  },
                                  onSubmitEmailLogin: _handleEmailLogin,
                                  onGoogleSignIn: _handleGoogleSignIn,
                                  onPhoneContinue: _handlePhoneContinue,
                                  onForgotPassword: _goToForgotPassword,
                                  onRegister: _goToRegister,
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

enum _LoginMethod { email, google, phone }

/// The exact pastel palette specified for this screen. Deliberately kept
/// local — not merged into `core/theme/app_colors.dart` — since this is a
/// bespoke visual treatment for Login only, not the app's ambient theme.
class _Palette {
  const _Palette._();

  static const blushPink = Color(0xFFFDE7EF);
  static const softCoral = Color(0xFFF48FB1);
  static const powderBlue = Color(0xFFA7C7E7);
  static const lavenderMist = Color(0xFFD8C4F1);
  static const warmCream = Color(0xFFFFF9F6);
  static const mint = Color(0xFFB8E6C8);

  static const textDark = Color(0xFF4A3B47);
  static const textMuted = Color(0xFF8C7B87);
}

/// Full-screen warm cream → blush pink → lavender mist gradient backdrop.
class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _Palette.warmCream,
            _Palette.blushPink,
            _Palette.lavenderMist,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}

/// Tiny stars and hearts scattered across the backdrop at very low opacity,
/// gently twinkling. Purely decorative (`IgnorePointer` at the call site).
class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor({required this.twinkle});

  final Animation<double> twinkle;

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.08, left: 0.10, size: 16, color: _Palette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.favorite_rounded, top: 0.14, left: 0.82, size: 14, color: _Palette.mint, phase: 0.3),
    _DecorSpec(icon: Icons.star_rounded, top: 0.22, left: 0.88, size: 10, color: _Palette.lavenderMist, phase: 0.6),
    _DecorSpec(icon: Icons.star_rounded, top: 0.05, left: 0.55, size: 12, color: _Palette.powderBlue, phase: 0.15),
    _DecorSpec(icon: Icons.favorite_rounded, top: 0.30, left: 0.06, size: 12, color: _Palette.softCoral, phase: 0.45),
    _DecorSpec(icon: Icons.star_rounded, top: 0.40, left: 0.92, size: 14, color: _Palette.mint, phase: 0.75),
    _DecorSpec(icon: Icons.star_rounded, top: 0.60, left: 0.04, size: 10, color: _Palette.lavenderMist, phase: 0.2),
    _DecorSpec(icon: Icons.favorite_rounded, top: 0.75, left: 0.90, size: 12, color: _Palette.powderBlue, phase: 0.5),
    _DecorSpec(icon: Icons.star_rounded, top: 0.85, left: 0.12, size: 14, color: _Palette.softCoral, phase: 0.65),
    _DecorSpec(icon: Icons.star_rounded, top: 0.92, left: 0.60, size: 10, color: _Palette.mint, phase: 0.35),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            for (final spec in _specs)
              Positioned(
                top: constraints.maxHeight * spec.top,
                left: constraints.maxWidth * spec.left,
                child: AnimatedBuilder(
                  animation: twinkle,
                  builder: (context, child) {
                    final t = (math.sin((twinkle.value + spec.phase) * math.pi * 2) + 1) / 2;
                    return Opacity(opacity: 0.10 + (t * 0.16), child: child);
                  },
                  child: Icon(spec.icon, size: spec.size, color: spec.color),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DecorSpec {
  const _DecorSpec({
    required this.icon,
    required this.top,
    required this.left,
    required this.size,
    required this.color,
    required this.phase,
  });

  final IconData icon;
  final double top;
  final double left;
  final double size;
  final Color color;
  final double phase;
}

/// Small circular back button, shown only when there is somewhere to go
/// back to — the immersive backdrop intentionally has no Material AppBar.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.white.withValues(alpha: 0.7),
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_back_rounded, color: _Palette.textDark),
            tooltip: 'Back',
          ),
        ),
      ),
    );
  }
}

/// The hand-illustrated sleepy crescent moon resting on a soft cloud.
class _MoonCloudIllustration extends StatelessWidget {
  const _MoonCloudIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 168,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 8,
            child: _CloudShape(
              color: _Palette.powderBlue.withValues(alpha: 0.55),
              width: 168,
              height: 56,
            ),
          ),
          Positioned(
            bottom: 22,
            child: _CloudShape(
              color: Colors.white.withValues(alpha: 0.95),
              width: 210,
              height: 72,
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _Palette.softCoral.withValues(alpha: 0.28),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _CrescentMoonPainter(
                  moonColor: _Palette.warmCream,
                  faceColor: _Palette.softCoral,
                ),
              ),
            ),
          ),
          const Positioned(top: 6, right: 46, child: _SleepZ(size: 14, opacity: 0.55)),
          const Positioned(top: -8, right: 30, child: _SleepZ(size: 18, opacity: 0.7)),
          const Positioned(top: -22, right: 12, child: _SleepZ(size: 22, opacity: 0.9)),
        ],
      ),
    );
  }
}

class _SleepZ extends StatelessWidget {
  const _SleepZ({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(
        'z',
        style: GoogleFonts.quicksand(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: _Palette.lavenderMist,
        ),
      ),
    );
  }
}

/// A fluffy cloud silhouette built from overlapping soft-edged circles.
class _CloudShape extends StatelessWidget {
  const _CloudShape({required this.color, required this.width, required this.height});

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height * 0.55,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
            ),
          ),
          Positioned(bottom: height * 0.18, left: width * 0.04, child: _puff(width * 0.42, color)),
          Positioned(bottom: height * 0.30, left: width * 0.26, child: _puff(width * 0.5, color)),
          Positioned(bottom: height * 0.20, right: width * 0.06, child: _puff(width * 0.4, color)),
        ],
      ),
    );
  }

  Widget _puff(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Paints a sleepy crescent moon: one circle subtracted from another,
/// plus gently closed eyes and a small contented smile.
class _CrescentMoonPainter extends CustomPainter {
  const _CrescentMoonPainter({required this.moonColor, required this.faceColor});

  final Color moonColor;
  final Color faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final moonPaint = Paint()..color = moonColor;
    final fullMoon = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addOval(
        Rect.fromLTWH(size.width * 0.30, -size.height * 0.06, size.width * 0.98, size.height * 1.12),
      );
    final crescent = Path.combine(PathOperation.difference, fullMoon, cutout);
    canvas.drawPath(crescent, moonPaint);

    final facePaint = Paint()
      ..color = faceColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.34;
    final eyeY = size.height * 0.46;
    const eyeSpacing = 0.15;
    for (final dir in [-1, 1]) {
      final dx = size.width * eyeSpacing * dir;
      final path = Path()
        ..moveTo(cx + dx - size.width * 0.05, eyeY)
        ..quadraticBezierTo(cx + dx, eyeY + size.height * 0.05, cx + dx + size.width * 0.05, eyeY);
      canvas.drawPath(path, facePaint);
    }

    final smile = Path()
      ..moveTo(cx - size.width * 0.06, size.height * 0.60)
      ..quadraticBezierTo(cx, size.height * 0.65, cx + size.width * 0.06, size.height * 0.60);
    canvas.drawPath(smile, facePaint);

    final blushPaint = Paint()..color = _Palette.softCoral.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(cx - size.width * 0.16, size.height * 0.56), size.width * 0.045, blushPaint);
  }

  @override
  bool shouldRepaint(covariant _CrescentMoonPainter oldDelegate) {
    return oldDelegate.moonColor != moonColor || oldDelegate.faceColor != faceColor;
  }
}

/// The rounded, softly-shadowed card housing every interactive form
/// element — the only part of the screen that responds to touch.
class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isSubmitting,
    required this.activeMethod,
    required this.errorMessage,
    required this.onValidateEmail,
    required this.onValidatePassword,
    required this.onToggleObscure,
    required this.onToggleRememberMe,
    required this.onSubmitEmailLogin,
    required this.onGoogleSignIn,
    required this.onPhoneContinue,
    required this.onForgotPassword,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isSubmitting;
  final _LoginMethod? activeMethod;
  final String? errorMessage;
  final FormFieldValidator<String> onValidateEmail;
  final FormFieldValidator<String> onValidatePassword;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool> onToggleRememberMe;
  final VoidCallback onSubmitEmailLogin;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onPhoneContinue;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _Palette.lavenderMist.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: _Palette.softCoral.withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: _Palette.lavenderMist.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (errorMessage != null) ...[
              _ErrorBanner(message: errorMessage!),
              const SizedBox(height: 16),
            ],
            _PastelTextField(
              controller: emailController,
              label: 'Email',
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              validator: onValidateEmail,
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 14),
            _PastelPasswordField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              obscureText: obscurePassword,
              enabled: !isSubmitting,
              validator: onValidatePassword,
              onToggleObscure: onToggleObscure,
              onSubmitted: (_) => onSubmitEmailLogin(),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RememberMeToggle(
                  value: rememberMe,
                  enabled: !isSubmitting,
                  onChanged: onToggleRememberMe,
                ),
                _PastelTextLink(
                  label: 'Forgot Password?',
                  onPressed: isSubmitting ? null : onForgotPassword,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PastelPrimaryButton(
              label: 'Log In',
              isLoading: isSubmitting && activeMethod == _LoginMethod.email,
              onPressed: isSubmitting ? null : onSubmitEmailLogin,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: Divider(color: _Palette.lavenderMist.withValues(alpha: 0.6))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: _Palette.textMuted,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: _Palette.lavenderMist.withValues(alpha: 0.6))),
              ],
            ),
            const SizedBox(height: 18),
            _PastelOutlineButton(
              label: 'Continue with Google',
              icon: Icons.g_mobiledata_rounded,
              accent: _Palette.powderBlue,
              isLoading: isSubmitting && activeMethod == _LoginMethod.google,
              onPressed: isSubmitting ? null : onGoogleSignIn,
            ),
            const SizedBox(height: 12),
            _PastelOutlineButton(
              label: 'Continue with Phone',
              icon: Icons.phone_android_rounded,
              accent: _Palette.mint,
              isLoading: isSubmitting && activeMethod == _LoginMethod.phone,
              onPressed: isSubmitting ? null : onPhoneContinue,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.nunito(fontSize: 13.5, color: _Palette.textMuted),
                ),
                _PastelTextLink(
                  label: 'Register',
                  bold: true,
                  onPressed: isSubmitting ? null : onRegister,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RememberMeToggle extends StatelessWidget {
  const _RememberMeToggle({required this.value, required this.enabled, required this.onChanged});

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Remember me',
      toggled: value,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? () => onChanged(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: value,
                  onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                  activeColor: _Palette.mint,
                  checkColor: _Palette.textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: _Palette.textMuted.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Remember Me',
                style: GoogleFonts.nunito(fontSize: 13.5, color: _Palette.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastelTextLink extends StatelessWidget {
  const _PastelTextLink({required this.label, required this.onPressed, this.bold = false});

  final String label;
  final VoidCallback? onPressed;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          foregroundColor: _Palette.softCoral,
          minimumSize: const Size(0, 40),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13.5,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: _Palette.softCoral,
          ),
        ),
      ),
    );
  }
}

InputDecoration _pastelDecoration({
  required String label,
  required String hint,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.nunito(color: _Palette.textMuted, fontSize: 14),
    hintStyle: GoogleFonts.nunito(color: _Palette.textMuted.withValues(alpha: 0.6), fontSize: 14),
    prefixIcon: Icon(prefixIcon, color: _Palette.textMuted),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: _Palette.blushPink.withValues(alpha: 0.28),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border,
    enabledBorder: border.copyWith(
      borderSide: BorderSide(color: _Palette.lavenderMist.withValues(alpha: 0.7)),
    ),
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: _Palette.softCoral, width: 2),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: Color(0xFFE0645B), width: 1.5),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: Color(0xFFE0645B), width: 2),
    ),
    errorStyle: GoogleFonts.nunito(color: const Color(0xFFE0645B), fontSize: 12),
  );
}

class _PastelTextField extends StatelessWidget {
  const _PastelTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    required this.enabled,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunito(fontSize: 15, color: _Palette.textDark),
      cursorColor: _Palette.softCoral,
      decoration: _pastelDecoration(label: label, hint: hintText, prefixIcon: prefixIcon),
    );
  }
}

/// Pastel-styled password field with a working Show/Hide toggle.
class _PastelPasswordField extends StatelessWidget {
  const _PastelPasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    required this.enabled,
    required this.validator,
    required this.onToggleObscure,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final bool enabled;
  final FormFieldValidator<String> validator;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      style: GoogleFonts.nunito(fontSize: 15, color: _Palette.textDark),
      cursorColor: _Palette.softCoral,
      decoration: _pastelDecoration(
        label: 'Password',
        hint: 'Enter your password',
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: _Palette.textMuted,
          ),
          tooltip: obscureText ? 'Show password' : 'Hide password',
          onPressed: onToggleObscure,
        ),
      ),
    );
  }
}

/// Large, coral-gradient, primary call-to-action button.
class _PastelPrimaryButton extends StatelessWidget {
  const _PastelPrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled && !isLoading ? 0.6 : 1,
      child: SizedBox(
        height: 56,
        child: Material(
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [_Palette.softCoral, Color(0xFFEF6FA0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _Palette.softCoral.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onPressed,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft, cream-filled outline button used for Google / Phone continuation.
class _PastelOutlineButton extends StatelessWidget {
  const _PastelOutlineButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled && !isLoading ? 0.6 : 1,
      child: SizedBox(
        height: 54,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.5),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.3, color: accent),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 22, color: _Palette.textDark),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: GoogleFonts.nunito(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: _Palette.textDark,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xFFE0645B);
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: errorColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: errorColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: errorColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(color: errorColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
