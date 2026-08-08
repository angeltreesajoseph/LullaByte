import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_paths.dart';
import '../widgets/placeholder_screen.dart';

/// Placeholder screen for LullaByte (SRS Section 10 placeholder).
///
/// Displays the same title/description/icon as every other placeholder
/// screen, plus a minimal app-shell navigation timer that hands off to
/// Onboarding after a short delay — this is generic startup wiring (no
/// SRS feature logic), needed so the 21 registered routes are actually
/// reachable while each screen is still a placeholder.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(RoutePaths.login);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'LullaByte',
      description:
          'AI Powered Newborn Care Assistant. Preparing your experience...',
      icon: Icons.nightlight_round,
    );
  }
}
