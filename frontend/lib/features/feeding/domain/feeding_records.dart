/// Structured records keep dates, quantities and notes separate from UI labels.
class FeedingRecords {
  static DateTime? date(Map<String, dynamic> row) =>
      DateTime.tryParse(row['occurred_at'] as String? ?? '')?.toLocal();

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<Map<String, dynamic>> feeds(List<Map<String, dynamic>> rows) =>
      rows.where((r) => r['record_type'] != 'reminder').toList();

  static List<Map<String, dynamic>> onDay(
    List<Map<String, dynamic>> rows,
    DateTime day,
  ) => feeds(rows).where((r) {
    final at = date(r);
    return at != null && sameDay(at, day);
  }).toList();

  static double bottleMl(List<Map<String, dynamic>> rows) => rows
      .where((r) => r['type'] == 'bottle')
      .fold(0.0, (sum, r) => sum + ((r['amount_ml'] as num?)?.toDouble() ?? 0));

  static double breastMinutes(List<Map<String, dynamic>> rows) => rows
      .where((r) => r['type'] == 'breastfeed')
      .fold(
        0.0,
        (sum, r) => sum + ((r['duration_min'] as num?)?.toDouble() ?? 0),
      );

  static String number(num value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);

  static String detail(Map<String, dynamic> r) {
    if (r['occurred_at'] == null) {
      return [
        r['amount'],
        r['duration'],
        r['time'],
      ].where((v) => v != null && v.toString().isNotEmpty).join(' · ');
    }
    return switch (r['type']) {
      'breastfeed' =>
        '${r['side'] ?? 'Both'} · ${number((r['duration_min'] as num?) ?? 0)} min',
      'bottle' =>
        '${r['milk_type'] ?? 'Milk'} · ${number((r['amount_ml'] as num?) ?? 0)} ml',
      _ => [
        r['food'],
        r['quantity'],
      ].where((v) => v != null && v.toString().isNotEmpty).join(' · '),
    };
  }

  static String dashboard(Map<String, dynamic> baby, DateTime now) {
    final raw = (baby['tracker_data'] as Map?)?['feeding'] as List? ?? [];
    final today = onDay(
      raw.map((r) => Map<String, dynamic>.from(r as Map)).toList(),
      now,
    );
    return today.isEmpty
        ? 'No feeds logged today'
        : '${today.length} feeds today';
  }
}
