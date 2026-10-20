/// Government of India UIP, infant/toddler portion (birth–24 months).
/// Source: MoHFW annual report 2025–26, National Immunization Schedule.
/// Vitamin A is not a vaccine and is intentionally not listed here.
const vaccinationSource =
    'https://notto.mohfw.gov.in/WriteReadData/Portal/News/951_1_Annual_Report_of_the_MoH_FW__2025_-_2026.pdf';
const vaccinationScheduleVersion = 'india-uip-infant-2026-10';

DateTime addCalendarMonths(DateTime date, int months) {
  final first = DateTime(date.year, date.month + months);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, date.day > last ? last : date.day);
}

List<Map<String, dynamic>> suggestedVaccinations(DateTime birth) {
  final dob = DateTime(birth.year, birth.month, birth.day);
  final result = <Map<String, dynamic>>[];
  void add(
    String id,
    String name,
    String age,
    DateTime due, {
    DateTime? end,
    bool conditional = false,
    String note = '',
  }) {
    result.add({
      'id': id,
      'name': name,
      'age': age,
      'due_date': due.toIso8601String(),
      'window_end': end?.toIso8601String(),
      'custom': false,
      'done': false,
      'excluded': conditional,
      'conditional': conditional,
      'notes': note,
      'doctor': '',
      'received_date': null,
      'reminder_at': null,
      'due_override': false,
      'schedule_version': vaccinationScheduleVersion,
    });
  }

  add(
    'bcg',
    'BCG',
    'At birth',
    dob,
    note: 'At birth or as early as possible. Ask the paediatrician if missed.',
  );
  add(
    'hepb_birth',
    'Hepatitis B — birth dose',
    'At birth',
    dob,
    note:
        'Birth dose is time-sensitive (within 24 hours). Consult the paediatrician if missed.',
  );
  add(
    'opv_0',
    'OPV — zero dose',
    'At birth',
    dob,
    note:
        'Birth dose is time-sensitive (first 15 days). Consult the paediatrician if missed.',
  );
  for (final week in [6, 10, 14]) {
    final dose = week == 6
        ? 1
        : week == 10
        ? 2
        : 3;
    final due = DateTime(dob.year, dob.month, dob.day + week * 7);
    for (final pair in [
      ['opv', 'OPV'],
      ['penta', 'Pentavalent'],
      ['rvv', 'Rotavirus'],
    ]) {
      add('${pair[0]}_$dose', '${pair[1]} — dose $dose', '$week weeks', due);
    }
    if (week != 10) {
      final n = week == 6 ? 1 : 2;
      add('fipv_$n', 'Fractional IPV — dose $n', '$week weeks', due);
      add('pcv_$n', 'PCV — dose $n', '$week weeks', due);
    }
  }
  final nine = addCalendarMonths(dob, 9), twelve = addCalendarMonths(dob, 12);
  add('mr_1', 'Measles–Rubella — dose 1', '9–12 months', nine, end: twelve);
  add('pcv_booster', 'PCV — booster', '9–12 months', nine, end: twelve);
  add('fipv_3', 'Fractional IPV — dose 3', '9–12 months', nine, end: twelve);
  add(
    'je_1',
    'Japanese Encephalitis — dose 1',
    '9–12 months',
    nine,
    end: twelve,
    conditional: true,
    note:
        'For endemic districts only. Include only after local/paediatrician confirmation.',
  );
  final sixteen = addCalendarMonths(dob, 16),
      twentyFour = addCalendarMonths(dob, 24);
  for (final pair in [
    ['mr_2', 'Measles–Rubella — dose 2'],
    ['dpt_booster', 'DPT — booster 1'],
    ['opv_booster', 'OPV — booster'],
  ]) {
    add(pair[0], pair[1], '16–24 months', sixteen, end: twentyFour);
  }
  add(
    'je_2',
    'Japanese Encephalitis — dose 2',
    '16–24 months',
    sixteen,
    end: twentyFour,
    conditional: true,
    note:
        'For endemic districts only. Include only after local/paediatrician confirmation.',
  );
  return result;
}

List<Map<String, dynamic>> mergeVaccinations(
  DateTime? birth,
  List<Map<String, dynamic>> saved,
) {
  final overrides = {for (final entry in saved) entry['id']: entry};
  final generated = birth == null
      ? <Map<String, dynamic>>[]
      : suggestedVaccinations(birth);
  final ids = generated.map((e) => e['id']).toSet();
  final result = generated.map((entry) {
    final saved = overrides[entry['id']];
    return <String, dynamic>{
      ...entry,
      ...?saved,
      if (saved?['due_override'] != true) 'due_date': entry['due_date'],
      'age': entry['age'],
      'window_end': entry['window_end'],
    };
  }).toList();
  result.addAll(
    saved.where((e) => e['custom'] == true && !ids.contains(e['id'])),
  );
  result.sort(
    (a, b) => (a['due_date'] as String).compareTo(b['due_date'] as String),
  );
  return result;
}
