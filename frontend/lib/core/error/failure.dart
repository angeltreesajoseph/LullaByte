import 'package:equatable/equatable.dart';

/// Base type for all business-meaningful failures surfaced from the Domain
/// Layer up to the Application/Presentation layers (SAD Section 7.4,
/// Section 14.1).
///
/// Concrete failures (e.g. `ValidationFailure`, `NotFoundFailure`) will be
/// defined per feature as business logic is implemented; this base class
/// only establishes the shared contract every feature will build on.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Generic failure for errors that do not yet have a dedicated, typed
/// [Failure] subclass. Feature modules should prefer a specific subclass
/// once implemented, rather than relying on this indefinitely.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}

/// Raised by the Data Layer (SAD Section 7.5) when a network-dependent
/// operation cannot complete because the device is offline. Core tracking
/// features never surface this — it is reserved for network-only
/// operations (e.g. AI Chat, per SRS Section 10.15.1) consistent with the
/// Offline-First architecture (SAD Section 2.4, Section 6.6).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection available.']);
}
