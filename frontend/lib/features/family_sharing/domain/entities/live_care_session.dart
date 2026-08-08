/// Mock snapshot of who is currently caring for Lily and what's happening
/// right now, shown on the "Live Care Session" card.
class LiveCareSession {
  const LiveCareSession({
    required this.currentCaregiver,
    required this.lastFeedingTime,
    required this.sleepStatus,
    required this.lastCryLabel,
    required this.lastCryConfidence,
    required this.updatedLabel,
  });

  final String currentCaregiver;
  final String lastFeedingTime;
  final String sleepStatus;
  final String lastCryLabel;
  final int lastCryConfidence;
  final String updatedLabel;
}
