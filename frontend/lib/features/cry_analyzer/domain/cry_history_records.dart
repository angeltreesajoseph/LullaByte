import 'dart:convert';
import 'dart:typed_data';

class CryHistoryRecords {
  static String key(Map<String, dynamic> row) =>
      '${row['time']}/${row['audio_sha256'] ?? row['id'] ?? ''}';
  static DateTime? date(Map<String, dynamic> row) =>
      DateTime.tryParse(row['time'] as String? ?? '')?.toLocal();
  static List<Map<String, dynamic>> sorted(List<Map<String, dynamic>> rows) =>
      [...rows]..sort(
        (a, b) =>
            (date(b) ?? DateTime(1970)).compareTo(date(a) ?? DateTime(1970)),
      );
  static List<Map<String, dynamic>> onDay(
    List<Map<String, dynamic>> rows,
    DateTime day,
  ) => sorted(rows).where((r) {
    final at = date(r);
    return at != null &&
        at.year == day.year &&
        at.month == day.month &&
        at.day == day.day;
  }).toList();
  static String clock(Duration duration) =>
      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  /// Read WAV header metadata only; never invent a duration for compressed formats.
  static Duration? duration(Map<String, dynamic> row) {
    final seconds = row['duration_seconds'];
    if (seconds is num && seconds.isFinite && seconds > 0)
      return Duration(milliseconds: (seconds * 1000).round());
    if (row['format'] != 'wav') return null;
    try {
      final audio = row['audio_data'] as String;
      final prefix = audio.substring(
        0,
        audio.length < 4096 ? audio.length : 4096,
      );
      final bytes = base64Decode(prefix);
      if (bytes.length < 12 ||
          ascii.decode(bytes.sublist(0, 4)) != 'RIFF' ||
          ascii.decode(bytes.sublist(8, 12)) != 'WAVE')
        return null;
      final data = ByteData.sublistView(bytes);
      int? rate;
      var at = 12;
      while (at + 8 <= bytes.length) {
        final tag = ascii.decode(bytes.sublist(at, at + 4));
        final size = data.getUint32(at + 4, Endian.little);
        if (tag == 'fmt ' && size >= 16 && at + 24 <= bytes.length)
          rate = data.getUint32(at + 16, Endian.little);
        if (tag == 'data' && rate != null && rate > 0)
          return Duration(milliseconds: (size / rate * 1000).round());
        at += 8 + size + (size % 2);
      }
    } catch (_) {}
    return null;
  }
}
