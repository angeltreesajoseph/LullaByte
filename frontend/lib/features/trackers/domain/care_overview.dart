import 'dart:convert';
import '../../feeding/domain/feeding_records.dart';
import '../../sleep/domain/sleep_records.dart';
import '../../diaper/domain/diaper_records.dart';
import '../../growth/domain/growth_records.dart';
import '../../cry_analyzer/domain/cry_history_records.dart';
import '../../vaccination/domain/vaccination_schedule.dart';

class CareBucket {
  CareBucket(this.start, this.end);
  final DateTime start, end; // end exclusive, local calendar boundaries
  final values = <String, double>{};
  bool recorded = false;
}

class CareSeries {
  CareSeries(this.title, this.unit, this.keys, this.buckets, this.granularity);
  final String title, unit, granularity;
  final List<String> keys;
  final List<CareBucket> buckets;
  bool get empty => !buckets.any((b) => b.recorded);
}

/// Immutable reporting snapshot; all sections use the same inclusive local date range.
class CareOverview {
  CareOverview(Map<String, dynamic> profile, DateTime from, DateTime through)
    : baby = Map<String, dynamic>.from(
        jsonDecode(
              jsonEncode({
                'id': profile['id'],
                'name': profile['name'],
                'birth_date': profile['birth_date'],
                'birth_weight_kg': profile['birth_weight_kg'],
                'birth_length_cm': profile['birth_length_cm'],
                'head_circumference_cm': profile['head_circumference_cm'],
                'tracker_data': {
                  for (final kind in [
                    'feeding',
                    'sleep',
                    'diaper',
                    'growth',
                    'cry',
                    'vaccinations',
                    'milestones',
                  ])
                    kind:
                        ((profile['tracker_data'] as Map?)?[kind] as List? ??
                                [])
                            .map(
                              (r) => {
                                for (final e in (r as Map).entries)
                                  if (e.key != 'audio_data') e.key: e.value,
                                if (kind == 'cry' &&
                                    CryHistoryRecords.duration(
                                          Map<String, dynamic>.from(r),
                                        ) !=
                                        null)
                                  'duration_seconds':
                                      CryHistoryRecords.duration(
                                        Map<String, dynamic>.from(r),
                                      )!.inMilliseconds /
                                      1000,
                              },
                            )
                            .toList(),
                },
              }),
            )
            as Map,
      ),
      start = DateTime(from.year, from.month, from.day),
      end = DateTime(through.year, through.month, through.day + 1) {
    if (!end.isAfter(start)) throw ArgumentError('Invalid report date range');
  }
  final Map<String, dynamic> baby;
  final DateTime start, end;
  DateTime get through => DateTime(end.year, end.month, end.day - 1);
  String get name => baby['name'] as String? ?? 'Baby';
  List<Map<String, dynamic>> rows(String kind) =>
      ((baby['tracker_data'] as Map?)?[kind] as List? ?? [])
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
  bool contains(DateTime? at) =>
      at != null && !at.isBefore(start) && at.isBefore(end);
  List<Map<String, dynamic>> get feeding => FeedingRecords.feeds(
    rows('feeding'),
  ).where((r) => contains(FeedingRecords.date(r))).toList();
  List<Map<String, dynamic>> get diaper =>
      rows('diaper').where((r) => contains(DiaperRecords.date(r))).toList();
  List<Map<String, dynamic>> get growth =>
      rows('growth').where((r) => contains(GrowthRecords.date(r))).toList();
  List<Map<String, dynamic>> get cry =>
      rows('cry').where((r) => contains(CryHistoryRecords.date(r))).toList();
  List<Map<String, dynamic>> get sleep => rows('sleep').where((r) {
    final a = SleepRecords.start(r), b = SleepRecords.end(r);
    return a != null &&
        b != null &&
        b.isAfter(a) &&
        a.isBefore(end) &&
        b.isAfter(start);
  }).toList();
  int get activeSleep => rows('sleep').where(SleepRecords.active).length;
  int undated(String kind) => rows(kind)
      .where(
        (r) => switch (kind) {
          'feeding' =>
            r['record_type'] != 'reminder' && FeedingRecords.date(r) == null,
          'sleep' =>
            !SleepRecords.active(r) &&
                (SleepRecords.start(r) == null || SleepRecords.end(r) == null),
          'diaper' => DiaperRecords.date(r) == null,
          'growth' => GrowthRecords.date(r) == null,
          'cry' => CryHistoryRecords.date(r) == null,
          _ => false,
        },
      )
      .length;
  Duration sleepDuration({String? type}) {
    var total = Duration.zero;
    for (final r in sleep) {
      if (type != null && r['type'] != type) continue;
      final a = SleepRecords.start(r)!, b = SleepRecords.end(r)!;
      total += (b.isBefore(end) ? b : end).difference(
        a.isAfter(start) ? a : start,
      );
    }
    return total;
  }

  List<Map<String, dynamic>> get vaccines => mergeVaccinations(
    DateTime.tryParse(baby['birth_date'] as String? ?? ''),
    rows('vaccinations'),
  ).where((r) => r['excluded'] != true).toList();
  List<Map<String, dynamic>> get received => vaccines
      .where(
        (r) =>
            r['done'] == true &&
            contains(
              DateTime.tryParse(r['received_date'] as String? ?? '')?.toLocal(),
            ),
      )
      .toList();
  List<Map<String, dynamic>> get planned => vaccines
      .where(
        (r) =>
            r['done'] != true &&
            contains(
              DateTime.tryParse(r['due_date'] as String? ?? '')?.toLocal(),
            ),
      )
      .toList();
  List<Map<String, dynamic>> get upcoming => vaccines
      .where(
        (r) =>
            r['done'] != true &&
            (DateTime.tryParse(
                  r['due_date'] as String? ?? '',
                )?.isAfter(end.subtract(const Duration(microseconds: 1))) ??
                false),
      )
      .take(3)
      .toList();
  List<Map<String, dynamic>> get milestones =>
      rows('milestones').where((r) => r['achieved'] == true).toList();
  String get milestoneScope =>
      'Saved achievements (all time; achievement dates were not recorded)';
  String get _bottleSummary =>
      feeding.any((r) => r['type'] == 'bottle' && r['amount_ml'] is num)
      ? '${FeedingRecords.number(FeedingRecords.bottleMl(feeding))} ml bottle'
      : 'Bottle volume not recorded';
  String get _breastSummary =>
      feeding.any((r) => r['type'] == 'breastfeed' && r['duration_min'] is num)
      ? '${FeedingRecords.number(FeedingRecords.breastMinutes(feeding))} min breastfeed'
      : 'Breastfeeding duration not recorded';
  String summary(String kind) => switch (kind) {
    'feeding' =>
      feeding.isEmpty
          ? 'No records'
          : '${feeding.length} feeds · $_bottleSummary · $_breastSummary',
    'sleep' =>
      sleep.isEmpty
          ? 'No completed sleep records'
          : SleepRecords.duration(sleepDuration()),
    'diaper' =>
      diaper.isEmpty
          ? 'No records'
          : '${diaper.length} changes · Wet ${DiaperRecords.count(diaper, 'wet')} / Dirty ${DiaperRecords.count(diaper, 'dirty')} / Mixed ${DiaperRecords.count(diaper, 'mixed')}',
    'cry' =>
      cry.isEmpty
          ? 'No saved recordings'
          : '${cry.length} saved recordings (not confirmed cry causes)',
    'growth' =>
      growth.isEmpty
          ? 'No measurements in this period'
          : '${growth.length} measurement records',
    _ => '',
  };
  List<CareBucket> _buckets() {
    final days = end.difference(start).inDays;
    final result = <CareBucket>[];
    var at = start;
    while (at.isBefore(end)) {
      final next = days <= 31
          ? DateTime(at.year, at.month, at.day + 1)
          : days <= 90
          ? DateTime(at.year, at.month, at.day + 7)
          : DateTime(at.year, at.month + 1, 1);
      final until = next.isBefore(end) ? next : end;
      result.add(CareBucket(at, until));
      at = until;
    }
    return result;
  }

  CareSeries series(String kind) {
    final buckets = _buckets();
    final keys = switch (kind) {
      'feeding' => ['Breastfeed', 'Bottle', 'Solids'],
      'bottle' => ['Bottle ml'],
      'sleep' => ['Nap', 'Night'],
      'diaper' => ['Wet', 'Dirty', 'Mixed'],
      _ => ['Recordings'],
    };
    final source = switch (kind) {
      'feeding' || 'bottle' => feeding,
      'sleep' => sleep,
      'diaper' => diaper,
      _ => cry,
    };
    for (final bucket in buckets) {
      bool inside(DateTime? at) =>
          at != null && !at.isBefore(bucket.start) && at.isBefore(bucket.end);
      final records = source
          .where(
            (r) => switch (kind) {
              'feeding' || 'bottle' => inside(FeedingRecords.date(r)),
              'diaper' => inside(DiaperRecords.date(r)),
              'sleep' =>
                SleepRecords.start(r)!.isBefore(bucket.end) &&
                    SleepRecords.end(r)!.isAfter(bucket.start),
              _ => inside(CryHistoryRecords.date(r)),
            },
          )
          .toList();
      bucket.recorded = records.isNotEmpty;
      for (final key in keys) bucket.values[key] = 0;
      for (final r in records) {
        if (kind == 'sleep') {
          final a = SleepRecords.start(r)!, b = SleepRecords.end(r)!;
          final minutes =
              (b.isBefore(bucket.end) ? b : bucket.end)
                  .difference(a.isAfter(bucket.start) ? a : bucket.start)
                  .inSeconds /
              60;
          final key = r['type'] == 'night' ? 'Night' : 'Nap';
          bucket.values[key] = bucket.values[key]! + minutes;
        } else if (kind == 'bottle') {
          if (r['type'] == 'bottle' && r['amount_ml'] is num) {
            bucket.values['Bottle ml'] =
                bucket.values['Bottle ml']! + (r['amount_ml'] as num);
          }
        } else {
          final key = kind == 'feeding'
              ? switch (r['type']) {
                  'breastfeed' => 'Breastfeed',
                  'bottle' => 'Bottle',
                  _ => 'Solids',
                }
              : kind == 'diaper'
              ? switch (r['type']) {
                  'wet' => 'Wet',
                  'dirty' => 'Dirty',
                  _ => 'Mixed',
                }
              : 'Recordings';
          bucket.values[key] = bucket.values[key]! + 1;
        }
      }
      if (kind == 'bottle')
        bucket.recorded = records.any(
          (r) => r['type'] == 'bottle' && r['amount_ml'] is num,
        );
    }
    final days = end.difference(start).inDays;
    return CareSeries(
      switch (kind) {
        'feeding' => 'Feed counts',
        'bottle' => 'Bottle volume',
        'sleep' => 'Completed sleep',
        'diaper' => 'Diaper changes',
        _ => 'Saved cry recordings',
      },
      kind == 'bottle'
          ? 'ml'
          : kind == 'sleep'
          ? 'minutes'
          : 'count',
      keys,
      buckets,
      days <= 31
          ? 'Daily'
          : days <= 90
          ? 'Weekly'
          : 'Monthly',
    );
  }

  List<String> details(String kind) {
    String date(DateTime? at) => at == null
        ? 'Date unavailable'
        : at.toIso8601String().replaceFirst('T', ' ').split('.').first;
    String note(Map r) =>
        (r['notes'] as String? ?? '').isEmpty ? '' : ' | Notes: ${r['notes']}';
    return switch (kind) {
      'feeding' =>
        feeding
            .map(
              (r) =>
                  '${date(FeedingRecords.date(r))} | ${r['type']} | ${FeedingRecords.detail(r)}${note(r)}',
            )
            .toList(),
      'sleep' =>
        sleep
            .map(
              (r) =>
                  '${date(SleepRecords.start(r))} to ${date(SleepRecords.end(r))} | ${SleepRecords.label(r['type'])} | Full session: ${SleepRecords.duration(SleepRecords.elapsed(r, end))}${note(r)}',
            )
            .toList(),
      'diaper' =>
        diaper
            .map(
              (r) =>
                  '${date(DiaperRecords.date(r))} | ${DiaperRecords.label(r['type'])}${r['type'] != 'wet' && r['color'] != null ? ' | Stool colour: ${r['color']}' : ''}${note(r)}',
            )
            .toList(),
      'growth' =>
        growth
            .map(
              (r) =>
                  '${date(GrowthRecords.date(r)).split(' ').first} | ${[for (final m in GrowthMetric.values)
                    if (GrowthRecords.value(r, m) != null) '${m.label}: ${GrowthRecords.number(GrowthRecords.value(r, m)!)} ${m.unit}'].join(' | ')}${note(r)}',
            )
            .toList(),
      'cry' =>
        cry
            .map(
              (r) =>
                  '${date(CryHistoryRecords.date(r))} | ${r['result'] ?? r['label'] ?? 'Analysis unavailable'}${r['scores'] is Map ? ' | Unvalidated model scores: ${(r['scores'] as Map).entries.map((e) => '${e.key}: ${e.value}%').join(', ')}' : ''}',
            )
            .toList(),
      _ => [],
    };
  }
}
