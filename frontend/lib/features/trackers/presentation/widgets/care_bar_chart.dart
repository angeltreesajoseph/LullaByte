import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/care_overview.dart';

const careChartColors = [
  Color(0xFFD882A8),
  Color(0xFF87B9D4),
  Color(0xFF95CBB5),
];

class CareBarChart extends StatelessWidget {
  const CareBarChart({super.key, required this.series});
  final CareSeries series;
  @override
  Widget build(BuildContext context) {
    if (series.empty)
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No records in this period.', textAlign: TextAlign.center),
      );
    final max = series.buckets.fold(
      1.0,
      (max, b) => math.max(max, b.values.values.fold(0.0, (a, b) => a + b)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${series.granularity} · ${series.unit}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF887184)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    max.toStringAsFixed(max < 10 ? 1 : 0),
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 90),
                  const Text('0', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(240, series.buckets.length * 42.0),
                  height: 190,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final bucket in series.buckets)
                        Expanded(
                          child: Tooltip(
                            message: !bucket.recorded
                                ? 'No records'
                                : bucket.values.entries
                                      .map(
                                        (e) =>
                                            '${e.key}: ${e.value.toStringAsFixed(1)} ${series.unit}',
                                      )
                                      .join('\n'),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 112,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: !bucket.recorded
                                        ? const Text(
                                            '—',
                                            style: TextStyle(
                                              color: Color(0xFFBBAFBA),
                                            ),
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for (
                                                var i = series.keys.length - 1;
                                                i >= 0;
                                                i--
                                              )
                                                Container(
                                                  width: 20,
                                                  height:
                                                      112 *
                                                      (bucket.values[series
                                                              .keys[i]] ??
                                                          0) /
                                                      max,
                                                  color:
                                                      careChartColors[i %
                                                          careChartColors
                                                              .length],
                                                ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${bucket.start.day}/${bucket.start.month}',
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 9),
                                ),
                                Text(
                                  !bucket.recorded
                                      ? 'No data'
                                      : bucket.values.values
                                            .fold(0.0, (a, b) => a + b)
                                            .toStringAsFixed(
                                              series.unit == 'count' ? 0 : 1,
                                            ),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF998A98),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (var i = 0; i < series.keys.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    color: careChartColors[i % careChartColors.length],
                  ),
                  const SizedBox(width: 4),
                  Text(series.keys[i], style: const TextStyle(fontSize: 10)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'No data means no saved record—not a confirmed zero.',
          style: TextStyle(fontSize: 10, color: Color(0xFF887184)),
        ),
      ],
    );
  }
}
