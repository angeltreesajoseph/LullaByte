class SleepRecords {
  static DateTime? start(Map<String, dynamic> r) =>
      DateTime.tryParse(r['start_at'] as String? ?? '')?.toLocal();
  static DateTime? end(Map<String, dynamic> r) =>
      DateTime.tryParse(r['end_at'] as String? ?? '')?.toLocal();
  static bool active(Map<String, dynamic> r) =>
      r['record_type'] == 'active' && start(r) != null;
  static String label(dynamic type) => type == 'night' ? 'Night sleep' : 'Nap';
  static String duration(Duration d) {
    final seconds = d.inSeconds < 0 ? 0 : d.inSeconds;
    final minutes = seconds ~/ 60;
    if (minutes == 0) return seconds == 0 ? '0 min' : '<1 min';
    return minutes < 60 ? '$minutes min' : '${minutes ~/ 60}h ${minutes % 60}m';
  }

  static Duration elapsed(Map<String, dynamic> r, DateTime now) {
    final s = start(r), e = end(r) ?? (active(r) ? now : null);
    return s == null || e == null || !e.isAfter(s)
        ? Duration.zero
        : e.difference(s);
  }

  /// Clip each session to calendar-day boundaries; legacy labels never imply dates.
  static Duration onDay(
    List<Map<String, dynamic>> rows,
    DateTime day, {
    String? type,
  }) {
    final from = DateTime(day.year, day.month, day.day),
        to = DateTime(day.year, day.month, day.day + 1);
    var microseconds = 0;
    for (final r in rows) {
      if (type != null && r['type'] != type) continue;
      final s = start(r), e = end(r);
      if (s == null || e == null || !e.isAfter(s)) continue;
      final a = s.isAfter(from) ? s : from, b = e.isBefore(to) ? e : to;
      if (b.isAfter(a)) microseconds += b.difference(a).inMicroseconds;
    }
    return Duration(microseconds: microseconds);
  }

  static bool touchesDay(Map<String, dynamic> r, DateTime day) {
    final s = start(r), e = end(r);
    if (s == null || e == null) return false;
    return s.isBefore(DateTime(day.year, day.month, day.day + 1)) &&
        e.isAfter(DateTime(day.year, day.month, day.day));
  }

  static String? validate(
    Map<String, dynamic> candidate,
    List<Map<String, dynamic>> rows,
    DateTime now, {
    DateTime? birth,
  }) {
    final s = start(candidate), e = end(candidate);
    if (s == null || e == null)
      return 'Choose both start and end dates and times.';
    if (!e.isAfter(s)) return 'End time must be after start time.';
    if (e.isAfter(now) || s.isAfter(now))
      return 'Sleep times cannot be in the future.';
    if (birth != null &&
        s.isBefore(DateTime(birth.year, birth.month, birth.day)))
      return 'Sleep cannot start before birth.';
    for (final r in rows) {
      if (candidate['id'] != null && candidate['id'] == r['id']) continue;
      final a = start(r), b = end(r) ?? (active(r) ? now : null);
      if (a != null && b != null && s.isBefore(b) && e.isAfter(a))
        return 'This overlaps another sleep session. Check the times.';
    }
    return null;
  }

  static String dashboard(Map<String, dynamic> baby, DateTime now) {
    final rows = ((baby['tracker_data'] as Map?)?['sleep'] as List? ?? [])
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
    if (rows.any(active)) return 'Sleep timer running';
    final total = onDay(rows, now);
    return total == Duration.zero
        ? 'No sleep logged today'
        : '${duration(total)} today';
  }
}
