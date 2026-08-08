import '../../domain/repositories/ai_response_service.dart';

/// Stand-in "Online AI" implementation used while there is no real LLM
/// integration. Produces a warmer, more conversational, more detailed
/// reply than the offline engine, simulating what a hosted model would
/// feel like — but every response here is still a static, hand-written
/// string; nothing is generated and no network call is made.
///
/// [getResponse] is the single method a future real implementation needs
/// to override — e.g. a `GeminiResponseService` or `OpenAiResponseService`
/// that calls out to the actual Gemini/OpenAI API and returns the model's
/// reply. Swapping `aiResponseServiceProvider`
/// (`application/assistant_providers.dart`) to bind that implementation
/// instead of this one is the only change needed to go live.
class SimulatedAiResponseService implements AiResponseService {
  const SimulatedAiResponseService();

  @override
  Future<String> getResponse(String question) async {
    // Simulated network latency so the typing indicator reads naturally.
    await Future.delayed(const Duration(milliseconds: 1100));

    final q = question.toLowerCase();

    if (_matchesAny(q, const ['cry', 'crying', 'fussy', 'upset'])) {
      return "That sounds like a tough moment! Crying is completely normal — it's Lily's main way of telling you "
          "something right now. Beyond the usual checks (hunger, a diaper change, tiredness, overstimulation), "
          "some babies also cry from gas discomfort or simply needing close contact. Try working through her "
          'needs one at a time, and know that a period of extra fussiness, especially in the evening, is common '
          "at this age and usually passes as she grows. If it ever feels different from her normal crying — "
          "more intense, or paired with fever — it's always worth a call to your pediatrician.";
    }
    if (_matchesAny(q, const ['sleep', 'nap', 'bedtime', 'tired'])) {
      return "Sleep at this age is still finding its rhythm, and that's completely expected! A predictable "
          'wind-down — dim lights, a short cuddle or song, the same order of steps each night — helps a lot of '
          'babies settle more easily. Daytime naps matter too: an overtired baby often sleeps worse at night, so '
          "keeping an eye on her awake windows can help. If you'd like, I can walk through a simple age-appropriate "
          'nap and bedtime routine.';
    }
    if (_matchesAny(q, const ['feed', 'feeding', 'milk', 'bottle', 'breastfeed', 'hungry'])) {
      return "Feeding patterns shift a lot in the first year, so it's great that you're paying attention to hers. "
          "Most babies at this stage feed every couple of hours, though growth spurts can temporarily increase "
          "that. Watching for hunger cues — rooting, hands to mouth, fussing — is usually more reliable than the "
          'clock alone. If feeding ever feels like a struggle or you have concerns about intake, a lactation '
          "consultant or your pediatrician can offer more tailored guidance.";
    }
    if (_matchesAny(q, const ['diaper', 'nappy', 'wet', 'poop', 'poo'])) {
      return "Diaper output is actually one of the best signs of how feeding is going! A steady mix of wet and "
          "dirty diapers each day is reassuring. Stool color and texture can vary quite a bit and still be normal "
          '— it tends to shift with diet changes too as solids are introduced later on. A noticeable, sudden change '
          "(very hard, very watery, or blood-tinged) is the kind of thing worth flagging to your pediatrician.";
    }
    if (_matchesAny(q, const ['vaccine', 'vaccination', 'shot', 'immuniz'])) {
      return "Staying on top of the vaccine schedule is one of the best things you can do for her long-term "
          "health. It's normal for babies to be a little fussier or sleepier for a day after a shot, and mild "
          "soreness at the injection site is common too. Keeping her vaccination record handy and jotting down "
          "any reactions can be genuinely helpful context for future visits.";
    }
    if (_matchesAny(q, const ['weight', 'grow', 'growth', 'percentile', 'height'])) {
      return "Growth percentiles are useful, but the trend over time matters far more than any single number — "
          "a baby steadily tracking along her own curve is usually a great sign, even if that curve isn't at the "
          '50th percentile. Regular weigh-ins at checkups are the best way to keep an eye on this together with '
          'your pediatrician.';
    }
    if (_matchesAny(q, const ['milestone', 'development', 'crawl', 'smile', 'roll over'])) {
      return "Milestones are really just gentle guideposts, not a race — babies reach them in their own order and "
          'on their own timeline. Little things like tummy time, talking to her throughout the day, and giving her '
          "safe things to reach for all support the skills behind those milestones. If something feels notably "
          "delayed across more than one area, that's a good conversation to have with your pediatrician.";
    }

    return "That's a thoughtful question. While I don't have a specific local answer for it, I'm happy to talk "
        "through general newborn and infant care with you — feel free to ask about sleep, feeding, diapers, "
        "vaccines, growth, or development, or just tell me a bit more about what's on your mind.";
  }

  bool _matchesAny(String question, List<String> keywords) => keywords.any(question.contains);
}
