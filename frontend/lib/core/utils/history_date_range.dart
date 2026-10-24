import 'package:flutter/material.dart';

bool historyIncludes(DateTimeRange? range, DateTime? date) {
  if (range == null) return true;
  if (date == null) return false;
  final until = DateTime(range.end.year, range.end.month, range.end.day + 1);
  return !date.isBefore(DateUtils.dateOnly(range.start)) &&
      date.isBefore(until);
}

bool historyIntersects(DateTimeRange? range, DateTime? start, DateTime? end) {
  if (range == null) return true;
  if (start == null || end == null) return false;
  return start.isBefore(
        DateTime(range.end.year, range.end.month, range.end.day + 1),
      ) &&
      end.isAfter(DateUtils.dateOnly(range.start));
}

String historyRangeLabel(BuildContext context, DateTimeRange range) {
  final strings = MaterialLocalizations.of(context);
  return '${strings.formatShortDate(range.start)} – ${strings.formatShortDate(range.end)}';
}
