import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../data/repositories/simulated_ai_response_service.dart';
import '../domain/entities/assistant_mode.dart';
import '../domain/repositories/ai_response_service.dart';
import '../domain/usecases/local_response_engine.dart';

/// Real device connectivity, read once on subscribe and then live-updated —
/// built on the existing app-wide `networkCheckerProvider`
/// (`core/di/providers.dart`, read-only reuse) rather than introducing a
/// second connectivity mechanism.
final assistantConnectivityProvider = StreamProvider<bool>((ref) async* {
  final checker = ref.watch(networkCheckerProvider);
  yield await checker.isConnected;
  yield* checker.onConnectivityChanged;
});

/// Derives [AssistantMode] from real connectivity — Online AI when the
/// device has a network connection, Offline Helper otherwise. Defaults to
/// offline while the first connectivity check is still in flight.
final assistantModeProvider = Provider<AssistantMode>((ref) {
  final isOnline = ref.watch(assistantConnectivityProvider).maybeWhen(
        data: (value) => value,
        orElse: () => false,
      );
  return isOnline ? AssistantMode.online : AssistantMode.offline;
});

final localResponseEngineProvider = Provider<LocalResponseEngine>((ref) {
  return const LocalResponseEngine();
});

/// Bound to [SimulatedAiResponseService] today. Swap this binding for a
/// real network-backed implementation (see `AiResponseService`'s doc
/// comment) when one exists — nothing else in the chat feature changes.
final aiResponseServiceProvider = Provider<AiResponseService>((ref) {
  return const SimulatedAiResponseService();
});
