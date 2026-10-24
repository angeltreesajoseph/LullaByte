import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/cry_analyzer/domain/cry_history_records.dart';

void main() {
  test('history sorts by date, supports latest three and local day filter', () {
    final day = DateTime(2026, 10, 20);
    final rows = <Map<String, dynamic>>[
      for (var i = 0; i < 5; i++)
        {'time': day.subtract(Duration(days: i)).toIso8601String()},
    ];
    final reversed = rows.reversed.toList();
    expect(
      CryHistoryRecords.sorted(reversed).take(3).map((r) => r['time']),
      rows.take(3).map((r) => r['time']),
    );
    expect(CryHistoryRecords.onDay(rows, day), hasLength(1));
  });
  test(
    'WAV header gives real duration; invalid and compressed files stay unknown',
    () {
      final bytes = Uint8List(44);
      final data = ByteData.sublistView(bytes);
      bytes.setRange(0, 4, ascii.encode('RIFF'));
      bytes.setRange(8, 12, ascii.encode('WAVE'));
      bytes.setRange(12, 16, ascii.encode('fmt '));
      data.setUint32(16, 16, Endian.little);
      data.setUint32(28, 32000, Endian.little);
      bytes.setRange(36, 40, ascii.encode('data'));
      data.setUint32(40, 64000, Endian.little);
      expect(
        CryHistoryRecords.duration({
          'format': 'wav',
          'audio_data': base64Encode(bytes),
        }),
        const Duration(seconds: 2),
      );
      expect(
        CryHistoryRecords.duration({'format': 'mp3', 'audio_data': 'AA=='}),
        isNull,
      );
      expect(
        CryHistoryRecords.duration({'format': 'wav', 'audio_data': 'bad'}),
        isNull,
      );
      expect(
        CryHistoryRecords.duration({'duration_seconds': 2.5}),
        const Duration(milliseconds: 2500),
      );
    },
  );
}
