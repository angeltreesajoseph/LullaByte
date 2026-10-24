class DiaperRecords {
  static DateTime? date(Map<String, dynamic> row) => DateTime.tryParse(
    (row['occurred_at'] ?? row['time']) as String? ?? '',
  )?.toLocal();
  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static List<Map<String, dynamic>> onDay(
    List<Map<String, dynamic>> rows,
    DateTime day,
  ) => rows.where((r) => date(r) != null && sameDay(date(r)!, day)).toList();
  static int count(List<Map<String, dynamic>> rows, String type) =>
      rows.where((r) => r['type'] == type).length;
  static String label(String? type) => switch (type) {
    'wet' => 'Wet',
    'dirty' => 'Dirty',
    'mixed' => 'Mixed',
    _ => 'Diaper change',
  };
}
