/// Keyword-matched "Offline Helper" responses, answered entirely from
/// Lily's local mock data — no network access, no backend. Used whenever
/// [AssistantMode.offline] is active (see `application/assistant_providers.dart`).
class LocalResponseEngine {
  const LocalResponseEngine();

  static const _sleepToday = '13h 20m';
  static const _lastFeedingTime = '11:16 AM';
  static const _lastDiaperTime = '10:48 AM';
  static const _weight = '6.2 kg';
  static const _nextVaccine = 'DTP 2 in 5 days';
  static const _milestoneProgress = '8/10 for the 2–4 month range';

  /// Matches [question] against known topics (cry, sleep, feeding, diaper,
  /// vaccine, growth, milestones) and answers from local data. Falls back
  /// to a friendly redirect when nothing matches.
  String respond(String question) {
    final q = question.toLowerCase();

    if (_matchesAny(q, const ['cry', 'crying', 'fussy', 'upset', 'won\'t stop'])) {
      return "Babies cry to communicate — it's often hunger, a diaper change, tiredness, or just wanting a cuddle. "
          "Lily's last diaper change was at $_lastDiaperTime and her last feeding was at $_lastFeedingTime, so "
          "those are good first things to check. If crying continues and nothing seems to soothe her, it's worth "
          'mentioning to your pediatrician.';
    }
    if (_matchesAny(q, const ['sleep', 'nap', 'bedtime', 'tired'])) {
      return "Lily has slept $_sleepToday so far today, which is a healthy amount for her age. A consistent "
          'wind-down routine before naps and bedtime can help keep her sleep steady.';
    }
    if (_matchesAny(q, const ['feed', 'feeding', 'milk', 'bottle', 'breastfeed', 'hungry'])) {
      return "Lily's last feeding was at $_lastFeedingTime. Most babies her age feed roughly every 2–3 hours, so "
          'her next feeding is likely coming up soon.';
    }
    if (_matchesAny(q, const ['diaper', 'nappy', 'wet', 'poop', 'poo'])) {
      return "Lily's last diaper change was at $_lastDiaperTime. Around 6–8 diaper changes a day is typical for "
          "her age and a good sign she's feeding well.";
    }
    if (_matchesAny(q, const ['vaccine', 'vaccination', 'shot', 'immuniz'])) {
      return "Lily's next scheduled vaccine is $_nextVaccine. It's worth noting the date on your calendar and "
          'bringing her vaccination record along to the appointment.';
    }
    if (_matchesAny(q, const ['weight', 'grow', 'growth', 'percentile', 'height'])) {
      return "Lily currently weighs $_weight and her growth trend has been steady and healthy. Regular checkups "
          'are the best way to keep track of this over time.';
    }
    if (_matchesAny(q, const ['milestone', 'development', 'crawl', 'smile', 'roll over'])) {
      return "Lily is currently at $_milestoneProgress — right on track! Every baby reaches milestones at their "
          'own pace, so try not to compare too closely with other babies.';
    }

    return "I don't have local data on that yet — I can help with sleep, feeding, diapers, vaccines, growth, and "
        "milestones for Lily. Try asking about one of those, or reconnect to the internet for more general "
        'parenting questions.';
  }

  bool _matchesAny(String question, List<String> keywords) => keywords.any(question.contains);
}
