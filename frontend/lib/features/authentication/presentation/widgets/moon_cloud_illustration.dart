import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_palette.dart';

/// The hand-illustrated sleepy crescent moon resting on a soft cloud, used
/// atop every Authentication hero screen. Self-animates a gentle,
/// continuous "breathing" float so every screen that uses it looks and
/// moves identically without re-implementing the animation.
class MoonCloudIllustration extends StatefulWidget {
  const MoonCloudIllustration({super.key});

  @override
  State<MoonCloudIllustration> createState() => _MoonCloudIllustrationState();
}

class _MoonCloudIllustrationState extends State<MoonCloudIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final dy = math.sin(_floatController.value * math.pi) * 6;
        return Transform.translate(offset: Offset(0, -dy), child: child);
      },
      child: const _MoonCloudArt(),
    );
  }
}

class _MoonCloudArt extends StatelessWidget {
  const _MoonCloudArt();

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
              color: AuthPalette.powderBlue.withValues(alpha: 0.55),
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
                    color: AuthPalette.softCoral.withValues(alpha: 0.28),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _CrescentMoonPainter(
                  moonColor: AuthPalette.warmCream,
                  faceColor: AuthPalette.softCoral,
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
          color: AuthPalette.lavenderMist,
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

/// Paints a sleepy crescent moon: one circle subtracted from another, plus
/// gently closed eyes and a small contented smile.
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

    final blushPaint = Paint()..color = AuthPalette.softCoral.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(cx - size.width * 0.16, size.height * 0.56), size.width * 0.045, blushPaint);
  }

  @override
  bool shouldRepaint(covariant _CrescentMoonPainter oldDelegate) {
    return oldDelegate.moonColor != moonColor || oldDelegate.faceColor != faceColor;
  }
}
