import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/care_overview.dart';
import '../../growth/domain/growth_records.dart';

class CarePdf {
  static String date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String filename(CareOverview report) =>
      'LullaByte_${report.name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}_${date(report.start)}_${date(report.through)}.pdf';
  static Future<Uint8List> build(
    CareOverview report, {
    DateTime? exported,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/report/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/report/Roboto-Bold.ttf'),
    );
    final doc = pw.Document(
      title: '${report.name} - care summary',
      author: 'LullaByte',
    );
    pw.Widget heading(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF98577C),
        ),
      ),
    );
    pw.Widget text(String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 300,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        footer: (c) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'LullaByte care record | ${c.pageNumber} / ${c.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        build: (c) => [
          pw.Text(
            'LullaByte - Baby care summary',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          text(
            'Baby: ${report.name} | DOB: ${report.baby['birth_date'] ?? 'Not recorded'}',
          ),
          text(
            'Reporting period (inclusive): ${date(report.start)} to ${date(report.through)}',
          ),
          text(
            'Exported: ${(exported ?? DateTime.now()).toLocal().toIso8601String().split('.').first.replaceFirst('T', ' ')} (device local time)',
          ),
          text(
            'Caregiver-entered records, not a health assessment. Missing records are not confirmed zero activity. Active sleep is excluded from completed totals. No audio or photos are included.',
          ),
          for (final kind in [
            'feeding',
            'sleep',
            'diaper',
            'growth',
            'cry',
          ]) ...[
            heading(
              {
                'feeding': 'Feeding',
                'sleep': 'Sleep',
                'diaper': 'Diaper',
                'growth': 'Growth',
                'cry': 'Cry recordings',
              }[kind]!,
            ),
            text(report.summary(kind)),
            if (report.undated(kind) > 0)
              text(
                '${report.undated(kind)} date-missing older records excluded from this period.',
              ),
            if (kind == 'sleep' && report.activeSleep > 0)
              text(
                'A sleep timer is currently active; its elapsed time is not a completed sleep record.',
              ),
            if (kind == 'growth') ...[
              for (final metric in GrowthMetric.values)
                _growthPlot(report, metric),
            ] else ...[
              _barPlot(report.series(kind)),
              if (kind == 'feeding') _barPlot(report.series('bottle')),
            ],
            if (kind == 'cry')
              text(
                'Cry labels/scores are unvalidated sound-pattern model outputs, not confirmed causes or probabilities of baby needs. They must not replace clinical assessment.',
              ),
            for (final line in report.details(kind)) text(line),
          ],
          heading('Vaccinations'),
          text(
            'Received during period: ${report.received.length}; planned/suggested during period: ${report.planned.length}. Suggested dates need paediatrician confirmation; this is not catch-up advice.',
          ),
          for (final r in report.received)
            text('RECEIVED | ${r['name']} | ${r['received_date']}${_notes(r)}'),
          for (final r in report.planned)
            text(
              'PLANNED/SUGGESTED | ${r['name']} | ${r['due_date']}${_notes(r)}',
            ),
          text('Next suggested/planned doses after reporting period:'),
          for (final r in report.upcoming)
            text('${r['name']} | ${r['due_date']}'),
          heading('Milestones'),
          text(report.milestoneScope),
          if (report.milestones.isEmpty) text('No saved achievements.'),
          for (final r in report.milestones)
            text('${r['name']} | ${r['group'] ?? ''}'),
          heading('Registration measurements (separate from growth records)'),
          text(
            'Weight: ${report.baby['birth_weight_kg'] ?? 'Not recorded'} kg | Length: ${report.baby['birth_length_cm'] ?? 'Not recorded'} cm | Head: ${report.baby['head_circumference_cm'] ?? 'Not recorded'} cm. Registration measurement dates may not have been recorded.',
          ),
        ],
      ),
    );
    return doc.save();
  }

  static String _notes(Map r) =>
      (r['notes'] as String? ?? '').isEmpty ? '' : ' | Notes: ${r['notes']}';
  static pw.Widget _barPlot(CareSeries series) {
    if (series.empty) return pw.SizedBox();
    final max = series.buckets.fold(
      1.0,
      (m, b) => math.max(m, b.values.values.fold(0.0, (a, b) => a + b)),
    );
    const colors = ['#d882a8', '#87b9d4', '#95cbb5'];
    final w = 460.0 / series.buckets.length;
    final svg = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="130"><line x1="30" y1="106" x2="495" y2="106" stroke="#ccc"/>',
    );
    for (var i = 0; i < series.buckets.length; i++) {
      final b = series.buckets[i];
      final x = 32 + i * w;
      var y = 106.0;
      if (!b.recorded) {
        svg.write(
          '<line x1="$x" y1="100" x2="${x + math.max(1, w * .6)}" y2="100" stroke="#aaa"/>',
        );
        continue;
      }
      for (var k = 0; k < series.keys.length; k++) {
        final h = (b.values[series.keys[k]] ?? 0) / max * 90;
        y -= h;
        svg.write(
          '<rect x="$x" y="$y" width="${math.max(1, w * .6)}" height="$h" fill="${colors[k % 3]}"/>',
        );
      }
    }
    svg.write('</svg>');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${series.title} - ${series.granularity} (${series.unit}), 0 to ${max.toStringAsFixed(1)}',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SvgImage(svg: svg.toString(), height: 110),
        pw.Text(
          '${CarePdf.date(series.buckets.first.start)} to ${CarePdf.date(series.buckets.last.end.subtract(const Duration(days: 1)))} | ${series.keys.join(' / ')} | Grey dash: no records',
          style: const pw.TextStyle(fontSize: 8),
        ),
        for (final b in series.buckets)
          pw.Text(
            '${date(b.start)}: ${!b.recorded ? 'No records' : b.values.entries.map((e) => '${e.key} ${e.value.toStringAsFixed(1)}').join(', ')}',
            style: const pw.TextStyle(fontSize: 8),
          ),
      ],
    );
  }

  static pw.Widget _growthPlot(CareOverview report, GrowthMetric metric) {
    final points = GrowthRecords.points(report.growth, metric);
    if (points.isEmpty)
      return pw.Text(
        '${metric.label}: No measurements in this period.',
        style: const pw.TextStyle(fontSize: 9),
      );
    final values = points.map((r) => GrowthRecords.value(r, metric)!).toList();
    final low = values.reduce(math.min),
        high = values.reduce(math.max),
        span = values.reduce(math.max) - values.reduce(math.min);
    final first = GrowthRecords.date(points.first)!.millisecondsSinceEpoch,
        last = GrowthRecords.date(points.last)!.millisecondsSinceEpoch;
    final coords = <String>[];
    for (var i = 0; i < points.length; i++) {
      final x = first == last
          ? 250.0
          : 30 +
                460 *
                    (GrowthRecords.date(points[i])!.millisecondsSinceEpoch -
                        first) /
                    (last - first);
      final y = span == 0 ? 55.0 : 95 - 80 * (values[i] - low) / span;
      coords.add('$x,$y');
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${metric.label} (${metric.unit}) | ${low.toStringAsFixed(2)} to ${high.toStringAsFixed(2)}',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SvgImage(
          svg:
              '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="110">${points.length > 1 ? '<polyline points="${coords.join(' ')}" fill="none" stroke="#b56391" stroke-width="2"/>' : ''}${coords.map((p) => '<circle cx="${p.split(',')[0]}" cy="${p.split(',')[1]}" r="3" fill="#b56391"/>').join()}</svg>',
          height: 90,
        ),
        pw.Text(
          '${date(GrowthRecords.date(points.first)!)} to ${date(GrowthRecords.date(points.last)!)}; recorded points only.',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }
}
