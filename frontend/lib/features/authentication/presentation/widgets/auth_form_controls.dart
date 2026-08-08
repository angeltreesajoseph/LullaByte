import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_palette.dart';

/// The rounded, softly-shadowed card frame housing every interactive form
/// element on an Authentication hero screen.
class AuthCard extends StatelessWidget {
  const AuthCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.softCoral.withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AuthPalette.lavenderMist.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

InputDecoration authPastelDecoration({
  required String label,
  required String hint,
  required IconData prefixIcon,
  Widget? suffixIcon,
  String? helperText,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helperText,
    helperMaxLines: 2,
    labelStyle: GoogleFonts.nunito(color: AuthPalette.textMuted, fontSize: 14),
    hintStyle: GoogleFonts.nunito(color: AuthPalette.textMuted.withValues(alpha: 0.6), fontSize: 14),
    helperStyle: GoogleFonts.nunito(color: AuthPalette.textMuted, fontSize: 11.5),
    prefixIcon: Icon(prefixIcon, color: AuthPalette.textMuted),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AuthPalette.blushPink.withValues(alpha: 0.28),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border,
    enabledBorder: border.copyWith(
      borderSide: BorderSide(color: AuthPalette.lavenderMist.withValues(alpha: 0.7)),
    ),
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AuthPalette.softCoral, width: 2),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: AuthPalette.error, width: 1.5),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: AuthPalette.error, width: 2),
    ),
    errorStyle: GoogleFonts.nunito(color: AuthPalette.error, fontSize: 12),
  );
}

/// Pastel-styled single-line text field.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    required this.enabled,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
      cursorColor: AuthPalette.softCoral,
      decoration: authPastelDecoration(label: label, hint: hintText, prefixIcon: prefixIcon),
    );
  }
}

/// Pastel-styled password field with a working Show/Hide toggle.
class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.enabled,
    required this.validator,
    required this.onToggleObscure,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.helperText,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final FormFieldValidator<String> validator;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      textInputAction: onSubmitted != null ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
      cursorColor: AuthPalette.softCoral,
      decoration: authPastelDecoration(
        label: label,
        hint: 'Enter your password',
        prefixIcon: Icons.lock_outline_rounded,
        helperText: helperText,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AuthPalette.textMuted,
          ),
          tooltip: obscureText ? 'Show password' : 'Hide password',
          onPressed: onToggleObscure,
        ),
      ),
    );
  }
}

/// Large, coral-gradient, primary call-to-action button.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    super.key,
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
                colors: [AuthPalette.softCoral, Color(0xFFEF6FA0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AuthPalette.softCoral.withValues(alpha: 0.45),
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
class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onPressed,
    required this.isLoading,
    super.key,
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
                          Icon(icon, size: 22, color: AuthPalette.textDark),
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: GoogleFonts.nunito(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AuthPalette.textDark,
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

/// Small coral text link/button (Forgot Password, Register, Log In, ...).
class AuthTextLink extends StatelessWidget {
  const AuthTextLink({required this.label, required this.onPressed, this.bold = false, super.key});

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
          foregroundColor: AuthPalette.softCoral,
          minimumSize: const Size(0, 40),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13.5,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: AuthPalette.softCoral,
          ),
        ),
      ),
    );
  }
}

/// Generic checkbox + label row (Remember Me, Accept Terms, ...). Accepts
/// any [label] widget so callers can mix plain text with a styled phrase.
class AuthCheckboxRow extends StatelessWidget {
  const AuthCheckboxRow({
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? () => onChanged(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: value,
                  onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                  activeColor: AuthPalette.mint,
                  checkColor: AuthPalette.textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: AuthPalette.textMuted.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 3), child: label)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastel-styled error banner, announced to assistive technology.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AuthPalette.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AuthPalette.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AuthPalette.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  color: AuthPalette.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "OR" divider used between primary submit and social continuation
/// buttons.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AuthPalette.lavenderMist.withValues(alpha: 0.6))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AuthPalette.textMuted,
            ),
          ),
        ),
        Expanded(child: Divider(color: AuthPalette.lavenderMist.withValues(alpha: 0.6))),
      ],
    );
  }
}
