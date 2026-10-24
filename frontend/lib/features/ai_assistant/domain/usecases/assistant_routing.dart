import '../../../baby_management/application/baby_profile_store.dart';

/// Conservative routing: a general question about a tracker topic is not a
/// request for personal records (e.g. "explain newborn vaccine doses").
class AssistantRouting {
  static String normalize(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  static List<Map<String, dynamic>> mentionedBabies(String text) {
    final q = ' ${normalize(text)} ';
    final babies = <String, Map<String, dynamic>>{
      for (final baby in BabyProfileStore.babies)
        if (baby['id'] is String) baby['id'] as String: baby,
      if (BabyProfileStore.id != null)
        BabyProfileStore.id!: BabyProfileStore.data,
    };
    return babies.values.where((baby) {
      final name = normalize(baby['name']?.toString() ?? '');
      return name.isNotEmpty &&
          RegExp(
            r'\b' + name.split(' ').map(RegExp.escape).join(r'\s*') + r'\b',
          ).hasMatch(q);
    }).toList();
  }

  static bool usesRecords(String text) {
    final q = text.toLowerCase().trim();
    if (RegExp(
          r'\b(profile|profiles|internal|tracker|trackers)\b',
        ).hasMatch(q) ||
        RegExp(
          r'\b(my|our|both|these)\s+(baby|babies|twins)\b.*\b(detail|summary|information|data)',
        ).hasMatch(q) ||
        (mentionedBabies(text).isNotEmpty &&
            !RegExp(
              r'why|normal|enough|should|how to|advice|recommend',
            ).hasMatch(q))) {
      return true;
    }
    final topic = RegExp(
      r'feed|sleep|diaper|nappy|growth|weight|height|head|vaccin|immun|milestone|cry|blood|allerg|doctor|pediatric|hospital|profile|birth|gender|contact',
    ).hasMatch(q);
    if (!topic) return false;
    if (RegExp(
      r'record|logged|saved|latest|last |today|yesterday|next.*vaccin',
    ).hasMatch(q))
      return true;
    if (RegExp(
      r'why|normal|enough|should|explain|how to|advice|recommend',
    ).hasMatch(q))
      return false;
    return RegExp(r'\bmy\b|\bour\b').hasMatch(q) ||
        (BabyProfileStore.name != 'Your baby' &&
            q.contains(BabyProfileStore.name.toLowerCase()));
  }
}
