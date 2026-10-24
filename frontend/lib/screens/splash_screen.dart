import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/router/route_paths.dart';
import '../features/family_sharing/application/shared_care_connection.dart';

/// Waits for Firebase's persisted session before choosing a startup route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.sessionChanges,
    this.minimumDisplay = const Duration(seconds: 2)});
  final Stream<bool> Function()? sessionChanges;
  final Duration minimumDisplay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;
  int _attempt = 0;
  final _visible = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final attempt = ++_attempt;
    setState(() => _error = null);
    try {
      final changes =
          widget.sessionChanges?.call() ??
          FirebaseAuth.instance.authStateChanges().map((user) => user != null);
      final signedIn = await changes.first.timeout(const Duration(seconds: 15));
      final remaining = widget.minimumDisplay - _visible.elapsed;
      if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      if (!mounted || attempt != _attempt) return;
      context.go(
        !signedIn
            ? RoutePaths.login
            : PendingCareInvitation.id != null
            ? RoutePaths.familySharing
            : RoutePaths.dashboard,
      );
    } catch (_) {
      if (mounted && attempt == _attempt)
        setState(
          () => _error =
              'Could not restore your session. Please retry. You have not been signed out.',
        );
    }
  }

  @override
  void dispose() {
    _attempt++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrandedLoadingScreen(error: _error, onRetry: _restoreSession);
  }
}

/// Also shown before Firebase/notification startup so branding is not hidden
/// behind Android's icon-only launch window for the entire initialization.
class BrandedLoadingScreen extends StatelessWidget {
  const BrandedLoadingScreen({super.key, this.error, this.onRetry});
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/lullabyte_emblem.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    semanticLabel: 'Baby cradled by a crescent moon',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LullaByte',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF59405E), fontSize: 36,
                      fontWeight: FontWeight.w800, letterSpacing: .3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Track your baby’s care. Stay connected, wherever you are.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF59405E),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (error == null) ...[
                    const SizedBox(
                      width: 72,
                      child: LinearProgressIndicator(
                        color: Color(0xFFE985AD),
                        backgroundColor: Color(0xFFEDE0FC),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Text(
                    error ?? 'Getting things ready...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF65546B), fontSize: 14),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
