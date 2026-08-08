import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'auth_palette.dart';

/// Full-screen warm cream → blush pink → lavender mist gradient backdrop,
/// shared by every Authentication hero screen (Login, Register, ...).
class AuthBackgroundGradient extends StatelessWidget {
  const AuthBackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AuthPalette.warmCream,
            AuthPalette.blushPink,
            AuthPalette.lavenderMist,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
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

/// Tiny stars and hearts scattered across the backdrop at very low opacity,
/// gently twinkling. Purely decorative — wrap with `IgnorePointer` at the
/// call site.
class AuthFloatingDecor extends StatefulWidget {
  const AuthFloatingDecor({super.key});

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.08, left: 0.10, size: 16, color: AuthPalette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.favorite_rounded, top: 0.14, left: 0.82, size: 14, color: AuthPalette.mint, phase: 0.3),
    _DecorSpec(icon: Icons.star_rounded, top: 0.22, left: 0.88, size: 10, color: AuthPalette.lavenderMist, phase: 0.6),
    _DecorSpec(icon: Icons.star_rounded, top: 0.05, left: 0.55, size: 12, color: AuthPalette.powderBlue, phase: 0.15),
    _DecorSpec(icon: Icons.favorite_rounded, top: 0.30, left: 0.06, size: 12, color: AuthPalette.softCoral, phase: 0.45),
    _DecorSpec(icon: Icons.star_rounded, top: 0.40, left: 0.92, size: 14, color: AuthPalette.mint, phase: 0.75),
    _DecorSpec(icon: Icons.star_rounded, top: 0.60, left: 0.04, size: 10, color: AuthPalette.lavenderMist, phase: 0.2),
    _DecorSpec(icon: Icons.favorite_rounded, top: 0.75, left: 0.90, size: 12, color: AuthPalette.powderBlue, phase: 0.5),
    _DecorSpec(icon: Icons.star_rounded, top: 0.85, left: 0.12, size: 14, color: AuthPalette.softCoral, phase: 0.65),
    _DecorSpec(icon: Icons.star_rounded, top: 0.92, left: 0.60, size: 10, color: AuthPalette.mint, phase: 0.35),
  ];

  @override
  State<AuthFloatingDecor> createState() => _AuthFloatingDecorState();
}

class _AuthFloatingDecorState extends State<AuthFloatingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final spec in AuthFloatingDecor._specs)
                Positioned(
                  top: constraints.maxHeight * spec.top,
                  left: constraints.maxWidth * spec.left,
                  child: AnimatedBuilder(
                    animation: _twinkleController,
                    builder: (context, child) {
                      final t =
                          (math.sin((_twinkleController.value + spec.phase) * math.pi * 2) + 1) /
                              2;
                      return Opacity(opacity: 0.10 + (t * 0.16), child: child);
                    },
                    child: Icon(spec.icon, size: spec.size, color: spec.color),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Small circular back button shown atop the immersive backdrop, which
/// intentionally has no Material AppBar. Hidden entirely when [onPressed]
/// is null.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({required this.onPressed, super.key});

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
            icon: const Icon(Icons.arrow_back_rounded, color: AuthPalette.textDark),
            tooltip: 'Back',
          ),
        ),
      ),
    );
  }
}
