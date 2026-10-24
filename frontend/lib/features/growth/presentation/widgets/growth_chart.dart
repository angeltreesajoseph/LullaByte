import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/growth_records.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

class GrowthChart extends StatefulWidget {
  const GrowthChart({super.key, required this.rows});
  final List<Map<String, dynamic>> rows;
  @override
  State<GrowthChart> createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> {
  GrowthMetric _metric = GrowthMetric.weight;
  int? _selected;
  @override
  void didUpdateWidget(covariant GrowthChart old) {
    super.didUpdateWidget(old);
    _selected = null;
  }

  String _date(BuildContext context, DateTime at) =>
      MaterialLocalizations.of(context).formatMediumDate(at);
  @override
  Widget build(BuildContext context) {
    final points = GrowthRecords.points(widget.rows, _metric);
    final selected = points.isEmpty
        ? null
        : points[(_selected ?? points.length - 1).clamp(0, points.length - 1)];
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final m in GrowthMetric.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      key: ValueKey('growth_chart_${m.field}'),
                      label: Text(m == GrowthMetric.height ? 'Height' : m.label),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      selected: _metric == m,
                      onSelected: (_) => setState(() {
                        _metric = m;
                        _selected = null;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${_metric.label} (${_metric.unit})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (points.isEmpty)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: Text(
                'Add a ${_metric.label.toLowerCase()} measurement to start.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AuthPalette.textMuted),
              ),
            ),
          if (points.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final values = points
                    .map((r) => GrowthRecords.value(r, _metric)!)
                    .toList();
                final low = values.reduce(math.min),
                    high = values.reduce(math.max);
                final pad = high == low
                    ? math.max(high * .05, .1)
                    : (high - low) * .15;
                final min = math.max(0.0, low - pad), max = high + pad;
                final first = GrowthRecords.date(
                  points.first,
                )!.millisecondsSinceEpoch;
                final last = GrowthRecords.date(
                  points.last,
                )!.millisecondsSinceEpoch;
                final offsets = <Offset>[];
                for (var i = 0; i < points.length; i++) {
                  final t = GrowthRecords.date(
                    points[i],
                  )!.millisecondsSinceEpoch;
                  final x = last == first
                      ? width / 2
                      : 48 + (width - 62) * (t - first) / (last - first);
                  final y = 12 + 150 * (max - values[i]) / (max - min);
                  offsets.add(Offset(x, y));
                }
                return SizedBox(
                  height: 205,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GrowthPainter(
                            offsets: offsets,
                            min: min,
                            max: max,
                            selected: _selected ?? points.length - 1,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 48,
                        bottom: 0,
                        child: Text(
                          _date(context, GrowthRecords.date(points.first)!),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AuthPalette.textMuted,
                          ),
                        ),
                      ),
                      if (first != last)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Text(
                            _date(context, GrowthRecords.date(points.last)!),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                        ),
                      for (var i = 0; i < points.length; i++)
                        Positioned(
                          left: offsets[i].dx - 15,
                          top: offsets[i].dy - 15,
                          child: Semantics(
                            button: true,
                            label:
                                '${_date(context, GrowthRecords.date(points[i])!)}: ${GrowthRecords.number(values[i])} ${_metric.unit}',
                            child: GestureDetector(
                              key: ValueKey(
                                'growth_point_${points[i]['id'] ?? i}',
                              ),
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _selected = i),
                              child: const SizedBox(width: 30, height: 30),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEDF4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_date(context, GrowthRecords.date(selected)!)} · ${GrowthRecords.number(GrowthRecords.value(selected, _metric)!)} ${_metric.unit}',
                  key: const ValueKey('growth_chart_selection'),
                  style: const TextStyle(
                    color: Color(0xFF98577C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            points.length == 1
                ? 'One measurement recorded. Add another to see a trend.'
                : 'Tap a point for its exact date and value.',
            style: const TextStyle(fontSize: 11, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 4),
          const Text(
            'Recorded measurements only—not a clinical growth assessment.',
            style: TextStyle(fontSize: 11, color: AuthPalette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _GrowthPainter extends CustomPainter {
  const _GrowthPainter({
    required this.offsets,
    required this.min,
    required this.max,
    required this.selected,
  });
  final List<Offset> offsets;
  final double min, max;
  final int selected;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFEADFEB)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = 12.0 + 75 * i;
      canvas.drawLine(Offset(46, y), Offset(size.width, y), grid);
      final text = TextPainter(
        text: TextSpan(
          text: (max - (max - min) * i / 2).toStringAsFixed(1),
          style: const TextStyle(fontSize: 10, color: AuthPalette.textMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 43);
      text.paint(canvas, Offset(0, y - 6));
    }
    canvas.drawLine(const Offset(46, 12), const Offset(46, 174), grid);
    if (offsets.length > 1) {
      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final p in offsets.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFD881A9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
    for (var i = 0; i < offsets.length; i++) {
      if (i == selected)
        canvas.drawCircle(
          offsets[i],
          9,
          Paint()..color = const Color(0x44D881A9),
        );
      canvas.drawCircle(
        offsets[i],
        4.5,
        Paint()..color = const Color(0xFFB56391),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthPainter old) => true;
}
