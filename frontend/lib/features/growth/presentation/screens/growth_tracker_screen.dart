import '../../../../core/network/care_dio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/history_date_range.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../domain/growth_records.dart';
import '../widgets/growth_chart.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({
    super.key,
    this.api,
    this.historyOnly = false,
    this.historyRange,
  });
  final bool historyOnly;
  final DateTimeRange? historyRange;
  final Dio? api;
  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  List<Map<String, dynamic>> _rows = [];
  String? _babyId;
  String _babyName = '';
  bool _loading = true, _saving = false;
  bool _loaded = false;
  bool _refreshing = false, _freshReady = false;
  int _loadVersion = 0;
  String? _error;
  DateTime? _birthDate;
  DateTime _day = DateUtils.dateOnly(DateTime.now());
  bool _allDates = true;
  DateTimeRange? _reportRange;

  @override
  void initState() {
    super.initState();
    _reportRange = widget.historyRange;
    BabyProfileStore.changes.addListener(_profileChanged);
    _load();
  }

  @override
  void dispose() {
    BabyProfileStore.changes.removeListener(_profileChanged);
    super.dispose();
  }

  void _profileChanged() {
    if (_babyId != BabyProfileStore.id) _load();
  }

  Future<Dio> _client() async {
    if (widget.api != null) return widget.api!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    return careDio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
      ),
    );
  }

  Future<void> _load({bool keepForm = false}) async {
    final version = ++_loadVersion;
    final id = BabyProfileStore.id;
    final snapshot = BabyProfileStore.snapshotFor(id);
    setState(() {
      _babyId = id;
      _babyName = BabyProfileStore.name;
      _birthDate = DateTime.tryParse(snapshot?['birth_date'] as String? ?? '');
      if (!keepForm)
        _rows = ((snapshot?['tracker_data'] as Map?)?['growth'] as List? ?? [])
            .map((r) => Map<String, dynamic>.from(r as Map))
            .toList();
      _loading = !keepForm && snapshot == null;
      _loaded = snapshot != null || keepForm && _loaded;
      _refreshing = id != null;
      _freshReady = false;
      _error = null;
      _day = DateUtils.dateOnly(DateTime.now());
      _allDates = true;
    });
    if (id == null) {
      setState(() {
        _loading = false;
        _error = 'Select a baby profile first.';
      });
      return;
    }
    try {
      final api = await _client();
      final result = await api.get('/babies/$id');
      if (!mounted || id != _babyId || version != _loadVersion) return;
      final data = Map<String, dynamic>.from(result.data['data'] as Map);
      BabyProfileStore.rememberSnapshot(data);
      final rows = ((data['tracker_data'] as Map?)?['growth'] as List? ?? [])
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      setState(() {
        _rows = rows;
        _birthDate = DateTime.tryParse(
          data['birth_date'] as String? ??
              BabyProfileStore.data['birth_date'] as String? ??
              '',
        );
        _loading = false;
        _loaded = true;
        _refreshing = false;
        _freshReady = true;
      });
    } catch (error) {
      if (mounted && id == _babyId && version == _loadVersion)
        setState(() {
          _loading = false;
          _refreshing = false;
          if (error is DioException &&
              {401, 403, 404}.contains(error.response?.statusCode)) {
            _rows = [];
            _loaded = false;
          }
          _error = 'Could not load growth records. Tap retry.';
        });
    }
  }

  Future<bool> _persist(
    List<Map<String, dynamic>> rows,
    String baby,
    String name,
  ) async {
    if (_refreshing || !_freshReady) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Wait for the latest records to refresh, or retry loading before saving.',
            ),
          ),
        );
      return false;
    }
    if (_saving || baby != _babyId || baby != BabyProfileStore.id) return false;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final api = await _client();
      await api.put('/babies/$baby/trackers/growth', data: rows);
      if (!mounted || baby != _babyId) return true;
      setState(() => _rows = rows);
      if (BabyProfileStore.id == baby) {
        BabyProfileStore.data = {
          ...BabyProfileStore.data,
          'tracker_data': {
            ...Map<String, dynamic>.from(
              BabyProfileStore.data['tracker_data'] as Map? ?? {},
            ),
            'growth': rows,
          },
        };
        BabyProfileStore.babies = BabyProfileStore.babies
            .map(
              (b) => b['id'] == baby
                  ? {
                      ...b,
                      'tracker_data': {
                        ...Map<String, dynamic>.from(
                          b['tracker_data'] as Map? ?? {},
                        ),
                        'growth': rows,
                      },
                    }
                  : b,
            )
            .toList();
        BabyProfileStore.changes.value++;
      }
      return true;
    } catch (_) {
      if (mounted && baby == _babyId)
        setState(
          () => _error =
              'Could not save. Your existing records have not changed. Please retry.',
        );
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit([Map<String, dynamic>? row, int? index]) async {
    final baby = _babyId;
    final name = _babyName;
    if (baby == null || _loading || _saving || _refreshing) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => Theme(
          data: Theme.of(routeContext).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFC34F7C),
              primary: const Color(0xFFC34F7C),
            ),
          ),
          child: _GrowthForm(
            babyName: name,
            initial: row,
            birthDate: _birthDate,
            onSave: (entry) async {
              if (baby != _babyId || baby != BabyProfileStore.id) return false;
              final next = _rows
                  .map((r) => Map<String, dynamic>.from(r))
                  .toList();
              if (index == null) {
                next.insert(0, entry);
              } else {
                next[index] = entry;
              }
              return _persist(next, baby, name);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _delete(int index) async {
    if (_refreshing || !_freshReady) return;
    final baby = _babyId!, name = _babyName;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete measurement?'),
        content: Text('Remove this record for $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true && mounted && baby == _babyId) {
      final next = [..._rows]..removeAt(index);
      await _persist(next, baby, name);
    }
  }

  Future<void> _history() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GrowthScreen(api: widget.api, historyOnly: true),
      ),
    );
    if (mounted) await _load(keepForm: true);
  }

  String _when(DateTime at) =>
      MaterialLocalizations.of(context).formatMediumDate(at);
  Widget _heading(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final sorted = _rows.asMap().entries.toList()
      ..sort(
        (a, b) => (GrowthRecords.date(b.value) ?? DateTime(1970)).compareTo(
          GrowthRecords.date(a.value) ?? DateTime(1970),
        ),
      );
    final visible = sorted
        .where(
          (e) =>
              !widget.historyOnly ||
              (_allDates &&
                  historyIncludes(_reportRange, GrowthRecords.date(e.value))) ||
              (!_allDates &&
                  GrowthRecords.date(e.value) != null &&
                  GrowthRecords.sameDay(GrowthRecords.date(e.value)!, _day)),
        )
        .toList();
    final baby = _babyId;
    return Theme(
      data: _theme(context),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _GrowthBackground()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 580,
                      minHeight:
                          MediaQuery.sizeOf(context).height -
                          MediaQuery.paddingOf(context).vertical -
                          38,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AuthBackButton(
                              onPressed: () => widget.historyOnly
                                  ? Navigator.pop(context)
                                  : context.go(RoutePaths.dashboard),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                widget.historyOnly
                                    ? 'Growth history'
                                    : 'Growth tracker',
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.straighten_rounded,
                              color: Color(0xFFBF7B9C),
                              size: 26,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Records for $_babyName',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                        ),
                        if (_refreshing && _loaded)
                          const LinearProgressIndicator(),
                        if (_error != null && _loaded)
                          TextButton(
                            onPressed: () => _load(keepForm: true),
                            child: const Text('Retry refresh'),
                          ),
                        if (_loading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Color(0xFFAD355F),
                                ),
                              ),
                            ),
                          if (!_loaded)
                            TextButton(
                              onPressed: () => _load(),
                              child: const Text('Retry loading'),
                            ),
                          if (_loaded) ...[
                            if (!widget.historyOnly) ...[
                              _LatestMeasurements(rows: _rows, when: _when),
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Registration measurements stay in Profile; they are not copied into new entries.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AuthPalette.textMuted,
                                  ),
                                ),
                              ),
                              _heading('Add measurement'),
                              _GrowthForm(
                                key: ValueKey('growth_form_$baby'),
                                embedded: true,
                                babyName: _babyName,
                                birthDate: _birthDate,
                                onSave: (entry) => baby != _babyId
                                    ? Future.value(false)
                                    : _persist(
                                        [entry, ..._rows],
                                        baby!,
                                        _babyName,
                                      ),
                              ),
                              _heading('Measurement trend'),
                              GrowthChart(
                                key: ValueKey('growth_chart_$baby'),
                                rows: _rows,
                              ),
                              _heading('Recent measurements'),
                            ] else ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        _allDates
                                            ? (_reportRange == null
                                                  ? 'All dates'
                                                  : historyRangeLabel(
                                                      context,
                                                      _reportRange!,
                                                    ))
                                            : MaterialLocalizations.of(
                                                context,
                                              ).formatMediumDate(_day),
                                      ),
                                      onPressed: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _day,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );
                                        if (date != null && mounted)
                                          setState(() {
                                            _day = date;
                                            _allDates = false;
                                          });
                                      },
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _day = DateUtils.dateOnly(DateTime.now());
                                      _allDates = false;
                                    }),
                                    child: const Text('Today'),
                                  ),
                                  if (!_allDates || _reportRange != null)
                                    IconButton(
                                      tooltip: 'Show all dates',
                                      onPressed: () => setState(() {
                                        _reportRange = null;
                                        _allDates = true;
                                      }),
                                      icon: const Icon(
                                        Icons.filter_alt_off_outlined,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (visible.isEmpty)
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: widget.historyOnly
                                      ? MediaQuery.sizeOf(context).height * .5
                                      : 130,
                                ),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .85),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: const Color(0xFFEBD9E7),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.straighten_rounded,
                                      color: Color(0xFFAE89BC),
                                      size: 38,
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'No measurements for this selection',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Saved measurements appear here for this baby.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AuthPalette.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            for (final item
                                in widget.historyOnly
                                    ? visible
                                    : visible.take(3))
                              _MeasurementCard(
                                row: item.value,
                                when: _when,
                                onEdit: _saving
                                    ? null
                                    : () => _edit(item.value, item.key),
                                onDelete: _saving
                                    ? null
                                    : () => _delete(item.key),
                              ),
                            if (!widget.historyOnly)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: OutlinedButton.icon(
                                  onPressed: _saving ? null : _history,
                                  icon: const Icon(Icons.history_rounded),
                                  label: const Text('View all history'),
                                ),
                              ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ThemeData _theme(BuildContext context) => Theme.of(context).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFC34F7C),
    primary: const Color(0xFFC34F7C),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFAC456D),
      backgroundColor: Colors.white.withValues(alpha: .8),
      side: const BorderSide(color: Color(0xFFECCDDD)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
);

class _GrowthForm extends StatefulWidget {
  const _GrowthForm({
    super.key,
    required this.babyName,
    required this.onSave,
    this.initial,
    this.birthDate,
    this.embedded = false,
  });
  final String babyName;
  final Map<String, dynamic>? initial;
  final DateTime? birthDate;
  final bool embedded;
  final Future<bool> Function(Map<String, dynamic>) onSave;
  @override
  State<_GrowthForm> createState() => _GrowthFormState();
}

class _GrowthFormState extends State<_GrowthForm> {
  final _key = GlobalKey<FormState>();
  final _fields = {
    for (final m in GrowthMetric.values) m: TextEditingController(),
  };
  final _notes = TextEditingController();
  late DateTime _date;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _date = widget.initial == null
        ? DateUtils.dateOnly(DateTime.now())
        : GrowthRecords.date(widget.initial!) ??
              DateUtils.dateOnly(DateTime.now());
    for (final m in GrowthMetric.values) {
      final value = widget.initial == null
          ? null
          : GrowthRecords.value(widget.initial!, m);
      _fields[m]!.text = value == null ? '' : GrowthRecords.number(value);
    }
    _notes.text = widget.initial?['notes'] as String? ?? '';
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final first = widget.birthDate != null && widget.birthDate!.isBefore(now)
        ? DateUtils.dateOnly(widget.birthDate!)
        : DateTime(2000);
    final initial = _date.isBefore(first) || _date.isAfter(now) ? now : _date;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now,
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    if (_fields.values.every((c) => c.text.trim().isEmpty)) {
      setState(() => _error = 'Enter at least one measurement.');
      return;
    }
    final day = DateUtils.dateOnly(_date);
    if (day.isAfter(DateUtils.dateOnly(DateTime.now())) ||
        (widget.birthDate != null &&
            day.isBefore(DateUtils.dateOnly(widget.birthDate!)))) {
      setState(
        () => _error = 'Choose a measurement date from birth through today.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final row = <String, dynamic>{
      ...?widget.initial,
      'id':
          widget.initial?['id'] ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      'date': day.toIso8601String(),
      'notes': _notes.text.trim(),
      for (final m in GrowthMetric.values)
        m.field: _fields[m]!.text.trim().isEmpty
            ? null
            : double.parse(_fields[m]!.text.trim()),
    }..remove('label');
    bool saved;
    try {
      saved = await widget.onSave(row);
    } catch (_) {
      saved = false;
    }
    if (!mounted) return;
    if (saved) {
      if (widget.embedded) {
        setState(() {
          _saving = false;
          for (final c in _fields.values) {
            c.clear();
          }
          _notes.clear();
          _date = DateUtils.dateOnly(DateTime.now());
          _key.currentState?.reset();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Measurement saved')));
      } else {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _saving = false;
        _error = 'Could not save. Your details are still here. Please retry.';
      });
    }
  }

  Widget _body(BuildContext context) => AuthCard(
    child: Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _saving ? null : _pick,
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            label: Text(
              MaterialLocalizations.of(context).formatMediumDate(_date),
            ),
            key: const ValueKey('measurement_date'),
          ),
          const SizedBox(height: 18),
          for (final m in GrowthMetric.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                key: ValueKey('measurement_${m.field}'),
                controller: _fields[m],
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                maxLength: 10,
                decoration: authPastelDecoration(
                  label:
                      '${m == GrowthMetric.head ? 'Head circumference' : m.label} (${m.unit})',
                  hint: 'Optional',
                  prefixIcon: m == GrowthMetric.weight
                      ? Icons.monitor_weight_outlined
                      : m == GrowthMetric.head
                      ? Icons.circle_outlined
                      : Icons.straighten_rounded,
                ).copyWith(counterText: ''),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final value = double.tryParse(v.trim());
                  return value == null || !value.isFinite || value <= 0
                      ? 'Enter a number greater than zero'
                      : null;
                },
              ),
            ),
          TextField(
            controller: _notes,
            enabled: !_saving,
            maxLength: 500,
            maxLines: 2,
            decoration: authPastelDecoration(
              label: 'Notes (optional)',
              hint: 'Anything worth remembering?',
              prefixIcon: Icons.edit_note_rounded,
            ).copyWith(counterText: ''),
          ),
          const SizedBox(height: 18),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFAD355F)),
              ),
            ),
          AuthPrimaryButton(
            label: widget.embedded ? 'Save measurement' : 'Save changes',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _body(context);
    return Theme(
      data: _theme(context),
      child: PopScope(
        canPop: !_saving,
        child: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: _GrowthBackground()),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 580,
                        minHeight:
                            MediaQuery.sizeOf(context).height -
                            MediaQuery.paddingOf(context).vertical -
                            40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              AuthBackButton(
                                onPressed: _saving
                                    ? () {}
                                    : () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Edit measurement',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('For ${widget.babyName}'),
                          ),
                          _body(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestMeasurements extends StatelessWidget {
  const _LatestMeasurements({required this.rows, required this.when});
  final List<Map<String, dynamic>> rows;
  final String Function(DateTime) when;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('growth_summary'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFBE1EC), Color(0xFFECE3F7)],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFEED2E4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LATEST RECORDED',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.w800,
            color: Color(0xFF975F7B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final m in GrowthMetric.values) Expanded(child: _metric(m)),
          ],
        ),
      ],
    ),
  );
  Widget _metric(GrowthMetric m) {
    final row = GrowthRecords.latest(rows, m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row == null
              ? '—'
              : '${GrowthRecords.number(GrowthRecords.value(row, m)!)} ${m.unit}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF784E68),
          ),
        ),
        Text(
          m.label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8C7487)),
        ),
        const SizedBox(height: 4),
        Text(
          row == null ? 'Not recorded' : when(GrowthRecords.date(row)!),
          style: const TextStyle(fontSize: 10, color: Color(0xFF8C7487)),
        ),
      ],
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.row,
    required this.when,
    this.onEdit,
    this.onDelete,
  });
  final Map<String, dynamic> row;
  final String Function(DateTime) when;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFECDDE9)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF8E0EB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.straighten_rounded,
                color: Color(0xFF8D627B),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                GrowthRecords.date(row) == null
                    ? 'Date not recorded'
                    : when(GrowthRecords.date(row)!),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Edit measurement',
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
                size: 19,
                color: Color(0xFFAA7894),
              ),
            ),
            IconButton(
              tooltip: 'Delete measurement',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 19,
                color: Color(0xFFAA7894),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final m in GrowthMetric.values)
              if (GrowthRecords.value(row, m) != null)
                Text(
                  '${m.label}: ${GrowthRecords.number(GrowthRecords.value(row, m)!)} ${m.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF77596E),
                  ),
                ),
          ],
        ),
        if ((row['notes'] as String? ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              row['notes'] as String,
              style: const TextStyle(
                fontSize: 13,
                color: AuthPalette.textMuted,
              ),
            ),
          ),
      ],
    ),
  );
}

class _GrowthBackground extends StatelessWidget {
  const _GrowthBackground();
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: AuthBackgroundGradient()),
      Positioned(
        right: -70,
        bottom: 50,
        child: IgnorePointer(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .24),
                width: 30,
              ),
            ),
          ),
        ),
      ),
      const Positioned(
        right: 28,
        bottom: 28,
        child: IgnorePointer(
          child: Icon(
            Icons.favorite_outline_rounded,
            size: 28,
            color: Color(0x33A578A4),
          ),
        ),
      ),
    ],
  );
}
