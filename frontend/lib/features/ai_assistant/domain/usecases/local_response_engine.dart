import '../../../baby_management/application/baby_profile_store.dart';
import '../../../feeding/domain/feeding_records.dart';
import '../../../sleep/domain/sleep_records.dart';
import '../../../diaper/domain/diaper_records.dart';
import '../../../growth/domain/growth_records.dart';
import 'package:intl/intl.dart';
import 'assistant_routing.dart';

class LocalResponseEngine {
  const LocalResponseEngine();
  String respond(String question) {
    var babies = AssistantRouting.mentionedBabies(question);
    if (RegExp(
      r'\bboth\b|\ball (my |our )?bab(y|ies)\b|\btwins\b|\bbaby profiles\b',
      caseSensitive: false,
    ).hasMatch(question)) {
      babies = BabyProfileStore.babies;
    }
    if (babies.isNotEmpty) {
      return babies
          .map(
            (baby) =>
                _respondFor(question, baby, baby['name']?.toString() ?? 'Baby'),
          )
          .join('\n\n');
    }
    if (BabyProfileStore.id == null) {
      return 'Select a baby profile first so I can show the right records.';
    }
    return _respondFor(question, BabyProfileStore.data, BabyProfileStore.name);
  }

  String _respondFor(String question, Map<String, dynamic> data, String name) {
    final q = question.toLowerCase();
    final trackers = data['tracker_data'] as Map? ?? {};
    List<Map<String, dynamic>> rows(String kind) =>
        ((trackers[kind] as List?) ?? [])
            .whereType<Map>()
            .map((r) => Map<String, dynamic>.from(r))
            .toList();
    DateTime? at(Map r) => DateTime.tryParse(
      '${r['occurred_at'] ?? r['start_at'] ?? r['time'] ?? r['date'] ?? ''}',
    )?.toLocal();
    String when(Map r) => at(r) == null
        ? 'Date not recorded'
        : DateFormat('d MMM yyyy, h:mm a').format(at(r)!);
    List<Map<String, dynamic>> sorted(String kind) => rows(kind)
      ..sort(
        (a, b) => (at(b) ?? DateTime(1900)).compareTo(at(a) ?? DateTime(1900)),
      );
    for (final topic in ['feeding', 'sleep', 'diaper', 'milestones']) {
      if (q.contains(topic) ||
          (topic == 'feeding' && q.contains('feed')) ||
          (topic == 'milestones' && q.contains('milestone'))) {
        if (data['tracker_data'] is! Map) {
          return "$name's saved records have not loaded on this device. Open the baby's tracker once while connected, then retry.";
        }
        final entries = sorted(
          topic,
        ).where((r) => r['record_type'] != 'reminder').toList();
        if (entries.isEmpty)
          return "No $topic records are available for $name yet.";
        if (topic == 'milestones') {
          return "$name has ${entries.where((e) => e['achieved'] == true).length} milestones marked as achieved.";
        }
        final latest = entries.first;
        final detail = switch (topic) {
          'feeding' => FeedingRecords.detail(latest),
          'sleep' =>
            SleepRecords.active(latest)
                ? 'Sleep timer running'
                : '${SleepRecords.label(latest['type'])} · ${SleepRecords.duration(SleepRecords.elapsed(latest, DateTime.now()))}',
          'diaper' => DiaperRecords.label(latest['type'] as String?),
          _ => '',
        };
        return "$name has ${entries.length} saved $topic records.\nLatest: $detail\n${when(latest)}.\nThese are recorded entries, not an assessment of what is normal or sufficient.";
      }
    }
    String recorded(String key, String unit) =>
        data[key] == null ? 'not recorded' : '${data[key]}$unit';
    if (q.contains('weight') ||
        q.contains('height') ||
        q.contains('growth') ||
        q.contains('head')) {
      final measurements = rows('growth');
      final values = GrowthMetric.values
          .map((metric) {
            final latest = GrowthRecords.latest(measurements, metric);
            return latest == null
                ? '${metric.label}: not recorded in Growth'
                : '${metric.label}: ${GrowthRecords.number(GrowthRecords.value(latest, metric)!)} ${metric.unit} (${DateFormat('d MMM yyyy').format(GrowthRecords.date(latest)!)})';
          })
          .join('\n');
      return "$name's saved growth measurements:\n$values\nRegistration: weight ${recorded('birth_weight_kg', ' kg')}, height ${recorded('birth_length_cm', ' cm')}, head ${recorded('head_circumference_cm', ' cm')}.";
    }
    if (q.contains('vaccin') || q.contains('immun')) {
      final entries = rows(
        'vaccinations',
      ).where((r) => r['excluded'] != true).toList();
      if (entries.isEmpty)
        return 'No vaccination records are saved for $name. Open Vaccinations to review suggested dates and set reminders.';
      final completed = entries.where((r) => r['done'] == true).length;
      final planned =
          entries
              .where(
                (r) =>
                    r['done'] != true &&
                    DateTime.tryParse('${r['due_date']}') != null,
              )
              .toList()
            ..sort(
              (a, b) => DateTime.parse(
                '${a['due_date']}',
              ).compareTo(DateTime.parse('${b['due_date']}')),
            );
      return '$name: $completed of ${entries.length} saved doses marked received.' +
          (planned.isEmpty
              ? '\nNo dated planned dose is saved.'
              : '\nEarliest uncompleted saved dose: ${planned.first['name'] ?? 'Vaccination'} · ${DateFormat('d MMM yyyy').format(DateTime.parse('${planned.first['due_date']}'))}.') +
          '\nConfirm timing with your pediatrician.';
    }
    if (q.contains('cry') || q.contains('crying')) {
      final entries = sorted('cry');
      if (entries.isEmpty)
        return 'No cry analyses are saved for $name. Open Cry Analyser to record or upload audio.';
      return '$name has ${entries.length} saved cry recordings. Latest: ${when(entries.first)}.\nOpen Cry Analyser to play it and review its saved result. A sound-pattern match does not establish why a baby is crying.';
    }
    if (q.contains('blood'))
      return "$name's blood group: ${recorded('blood_group', '')}.";
    if (q.contains('allerg'))
      return "$name's allergy notes: ${recorded('allergies', '')}.";
    if (q.contains('doctor') ||
        q.contains('pediatrician') ||
        q.contains('hospital'))
      return "$name's pediatrician: ${recorded('pediatrician', '')}. Hospital: ${recorded('hospital', '')}.";
    if (q.contains('birth') || q.contains('gender'))
      return "$name's birth date: ${recorded('birth_date', '')}. Gender: ${recorded('gender', '')}.";
    if (RegExp(
      r'profile|detail|summary|overview|information|\bdata\b|\babout\b',
    ).hasMatch(q)) {
      final counts = data['tracker_data'] is Map
          ? [
                  'feeding',
                  'sleep',
                  'diaper',
                  'growth',
                  'vaccinations',
                  'milestones',
                  'cry',
                ]
                .map(
                  (kind) =>
                      '$kind: ${rows(kind).where((r) => r['record_type'] != 'reminder').length}',
                )
                .join(' · ')
          : 'Tracker records have not loaded on this device yet.';
      return "$name — saved profile\nBirth date: ${recorded('birth_date', '')}\nGender: ${recorded('gender', '')}\nBlood group: ${recorded('blood_group', '')}\nRegistration weight: ${recorded('birth_weight_kg', ' kg')}\nSaved records: $counts\nAsk about feeding, sleep, growth or vaccinations for more details.";
    }
    return "I can summarize $name's saved feeding, sleep, diaper, growth, vaccination, milestone and cry records, or profile details. I'm a records helper, not a medical-advice chatbot. For health concerns, contact your pediatrician.";
  }
}
