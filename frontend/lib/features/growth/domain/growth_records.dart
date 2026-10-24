enum GrowthMetric {
  weight('weight', 'Weight', 'kg'),
  height('height', 'Length/Height', 'cm'),
  head('head', 'Head', 'cm');

  const GrowthMetric(this.field, this.label, this.unit);
  final String field, label, unit;
}

class GrowthRecords {
  static DateTime? date(Map<String, dynamic> row) =>
      DateTime.tryParse(row['date'] as String? ?? '')?.toLocal();
  static double? value(Map<String, dynamic> row, GrowthMetric metric) {
    final raw = row[metric.field];
    final v = raw is num
        ? raw.toDouble()
        : double.tryParse(raw?.toString() ?? '');
    return v != null && v.isFinite && v > 0 ? v : null;
  }

  static String number(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  static List<Map<String, dynamic>> points(
    List<Map<String, dynamic>> rows,
    GrowthMetric metric,
  ) =>
      rows.where((r) => date(r) != null && value(r, metric) != null).toList()
        ..sort((a, b) => date(a)!.compareTo(date(b)!));
  static Map<String, dynamic>? latest(
    List<Map<String, dynamic>> rows,
    GrowthMetric metric,
  ) {
    final sorted = points(rows, metric);
    return sorted.isEmpty ? null : sorted.last;
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static String dashboardWeight(Map<String, dynamic> baby) {
    final rows = ((baby['tracker_data'] as Map?)?['growth'] as List? ?? [])
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
    final row = latest(rows, GrowthMetric.weight);
    if (row != null)
      return '${number(value(row, GrowthMetric.weight)!)} kg (growth)';
    final registration = baby['birth_weight_kg'];
    return registration == null
        ? 'Not recorded'
        : '$registration kg (registration)';
  }
}
