import 'package:flutter_test/flutter_test.dart';
import 'package:lullabyte/features/trackers/application/care_pdf.dart';
import 'package:lullabyte/features/trackers/domain/care_overview.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'creates real PDF bytes with selected baby and charts, even for empty periods',
    () async {
      final report = CareOverview(
        {'name': 'Zoë', 'birth_date': '2026-01-01'},
        DateTime(2026, 10, 20),
        DateTime(2026, 10, 20),
      );
      final bytes = await CarePdf.build(
        report,
        exported: DateTime(2026, 10, 20, 12),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
      expect(CarePdf.filename(report), contains('2026-10-20'));
    },
  );
  test(
    'monthly charts and many detailed notes paginate without overflow',
    () async {
      final report = CareOverview(
        {
          'name': 'Anna',
          'tracker_data': {
            'feeding': List.generate(
              70,
              (i) => {
                'type': 'bottle',
                'occurred_at': DateTime(
                  2026,
                  10,
                  1 + i % 20,
                  8,
                ).toIso8601String(),
                'amount_ml': 40,
                'notes': List.filled(40, 'Care note').join(' '),
              },
            ),
            'growth': [
              {'date': '2026-10-01', 'weight': 4, 'height': 50},
              {'date': '2026-10-20', 'weight': 5, 'head': 34},
            ],
          },
        },
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 20),
      );
      final bytes = await CarePdf.build(report);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    },
  );
}
