import '../../../../core/network/care_dio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../domain/sleep_records.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({
    super.key,
    this.api,
    this.historyOnly = false,
    this.now,
    this.historyRange,
  });
  final DateTime Function()? now;
  final bool historyOnly;
  final DateTimeRange? historyRange;
  final Dio? api;
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
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
  bool _showManual = false;
  String _type = 'nap';
  Timer? _tick;
  final Map<String, DateTime> _pendingStops = {};
  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _reportRange = widget.historyRange;
    BabyProfileStore.changes.addListener(_profileChanged);
    _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _rows.any(SleepRecords.active)) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
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
        _rows = ((snapshot?['tracker_data'] as Map?)?['sleep'] as List? ?? [])
            .map((r) => Map<String, dynamic>.from(r as Map))
            .toList();
      _loading = !keepForm && snapshot == null;
      _loaded = snapshot != null || keepForm && _loaded;
      _refreshing = id != null;
      _freshReady = false;
      _error = null;
      _day = DateUtils.dateOnly(DateTime.now());
      _allDates = true;
      if (!keepForm) _showManual = false;
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
      final rows = ((data['tracker_data'] as Map?)?['sleep'] as List? ?? [])
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      final prefs = await SharedPreferences.getInstance();
      final draft = prefs.getString(await _draftKey(id));
      if (!mounted || id != _babyId || version != _loadVersion) return;
      final activeRows = rows.where(SleepRecords.active);
      DateTime? savedEnd;
      if (draft != null && activeRows.isNotEmpty) {
        try {
          final saved = jsonDecode(draft) as Map;
          if (saved['id'] == activeRows.first['id']) {
            savedEnd = DateTime.tryParse(saved['end_at'] as String? ?? '');
          }
        } catch (_) {}
      }
      if (savedEnd != null && activeRows.isNotEmpty) {
        _pendingStops[id] = savedEnd;
      } else {
        _pendingStops.remove(id);
      }
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
          _error = 'Could not load sleep records. Tap retry.';
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
      await api.put('/babies/$baby/trackers/sleep', data: rows);
      if (!mounted || baby != _babyId) return true;
      setState(() => _rows = rows);
      if (BabyProfileStore.id == baby) {
        BabyProfileStore.data = {
          ...BabyProfileStore.data,
          'tracker_data': {
            ...Map<String, dynamic>.from(
              BabyProfileStore.data['tracker_data'] as Map? ?? {},
            ),
            'sleep': rows,
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
                        'sleep': rows,
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
          child: _SleepForm(
            babyName: name,
            initial: row,
            birthDate: _birthDate,
            rows: _rows,
            onSave: (entry) async {
              if (baby != _babyId || baby != BabyProfileStore.id) return false;
              final problem = SleepRecords.validate(
                entry,
                _rows
                    .asMap()
                    .entries
                    .where((e) => e.key != index)
                    .map((e) => e.value)
                    .toList(),
                _now,
                birth: _birthDate,
              );
              if (problem != null) {
                setState(() => _error = problem);
                return false;
              }
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
        title: const Text('Delete sleep session?'),
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

  Future<String> _draftKey(String baby) async {
    final uid = widget.api != null
        ? 'test-owner'
        : FirebaseAuth.instance.currentUser?.uid ?? 'signed-out';
    return 'sleep_stop/$uid/$baby';
  }

  Future<void> _start() async {
    if (_saving || _refreshing || _rows.any(SleepRecords.active)) return;
    final now = _now;
    if (_birthDate != null && now.isBefore(DateUtils.dateOnly(_birthDate!))) {
      setState(
        () =>
            _error = 'Correct the baby’s date of birth before starting sleep.',
      );
      return;
    }
    if (_rows.any(
      (r) =>
          SleepRecords.start(r) != null &&
          SleepRecords.end(r) != null &&
          !now.isBefore(SleepRecords.start(r)!) &&
          now.isBefore(SleepRecords.end(r)!),
    )) {
      setState(
        () => _error = 'This start time overlaps an existing sleep session.',
      );
      return;
    }
    await _persist(
      [
        {
          'id': now.microsecondsSinceEpoch.toString(),
          'record_type': 'active',
          'type': _type,
          'start_at': now.toUtc().toIso8601String(),
        },
        ..._rows,
      ],
      _babyId!,
      _babyName,
    );
  }

  Future<void> _stop() async {
    if (_saving || _refreshing) return;
    final baby = _babyId!, name = _babyName;
    final index = _rows.indexWhere(SleepRecords.active);
    if (index < 0) return;
    final row = _rows[index];
    final at = _pendingStops[baby] ?? _now;
    final completed = {
      ...row,
      'record_type': 'session',
      'end_at': at.toUtc().toIso8601String(),
    };
    final problem = SleepRecords.validate(
      completed,
      _rows,
      _now,
      birth: _birthDate,
    );
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final key = await _draftKey(baby);
    try {
      await prefs.setString(
        key,
        jsonEncode({'id': row['id'], 'end_at': at.toIso8601String()}),
      );
    } catch (_) {}
    if (!mounted || baby != _babyId || _saving) return;
    setState(() => _pendingStops[baby] = at);
    final next = [..._rows];
    next[index] = completed;
    if (await _persist(next, baby, name)) {
      _pendingStops.remove(baby);
      try {
        await prefs.remove(key);
      } catch (_) {}
    }
  }

  Future<void> _history() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SleepScreen(api: widget.api, historyOnly: true, now: widget.now),
      ),
    );
    if (mounted) await _load(keepForm: true);
  }

  String _when(DateTime at) =>
      '${MaterialLocalizations.of(context).formatMediumDate(at)} · ${TimeOfDay.fromDateTime(at).format(context)}';
  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final active = _rows.where(SleepRecords.active);
    final current = active.isEmpty ? null : active.first;
    final sorted =
        _rows
            .asMap()
            .entries
            .where((e) => !SleepRecords.active(e.value))
            .toList()
          ..sort(
            (a, b) => (SleepRecords.start(b.value) ?? DateTime(1970)).compareTo(
              SleepRecords.start(a.value) ?? DateTime(1970),
            ),
          );
    final visible = sorted
        .where(
          (e) =>
              !widget.historyOnly ||
              (_allDates &&
                  historyIntersects(
                    _reportRange,
                    SleepRecords.start(e.value),
                    SleepRecords.end(e.value),
                  )) ||
              (!_allDates && SleepRecords.touchesDay(e.value, _day)),
        )
        .toList();
    final baby = _babyId;
    return Theme(
      data: _theme(context),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _SleepBackground()),
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
                                widget.historyOnly ? 'Sleep history' : 'Sleep',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.bedtime_outlined,
                              color: Color(0xFFAA82BB),
                              size: 28,
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
                              _SleepSummary(rows: _rows, day: _now),
                              const SizedBox(height: 18),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _SleepTabs(
                                      value:
                                          current?['type'] as String? ?? _type,
                                      enabled: !_saving && current == null,
                                      onChanged: (v) =>
                                          setState(() => _type = v),
                                    ),
                                    const SizedBox(height: 20),
                                    Icon(
                                      current == null
                                          ? Icons.nights_stay_outlined
                                          : Icons.bedtime_rounded,
                                      size: 48,
                                      color: const Color(0xFFAA82BB),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      current == null
                                          ? 'Ready for a little rest'
                                          : _pendingStops.containsKey(baby)
                                          ? 'Stopped · waiting to save'
                                          : 'Sleep in progress',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (current != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        SleepRecords.duration(
                                          SleepRecords.elapsed(
                                            current,
                                            _pendingStops[baby] ?? _now,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF936EAA),
                                        ),
                                      ),
                                      Text(
                                        'Started ${_when(SleepRecords.start(current)!)}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AuthPalette.textMuted,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 18),
                                    AuthPrimaryButton(
                                      label: current == null
                                          ? 'Start sleep'
                                          : _pendingStops.containsKey(baby)
                                          ? 'Retry saving sleep'
                                          : 'Stop and save',
                                      isLoading: _saving,
                                      onPressed: _saving
                                          ? null
                                          : current == null
                                          ? _start
                                          : _stop,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'The start time is saved for this baby, even when you leave this page.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AuthPalette.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _saving
                                    ? null
                                    : () => setState(
                                        () => _showManual = !_showManual,
                                      ),
                                icon: Icon(
                                  _showManual
                                      ? Icons.expand_less
                                      : Icons.add_rounded,
                                ),
                                label: Text(
                                  _showManual
                                      ? 'Hide past sleep form'
                                      : 'Add past sleep',
                                ),
                              ),
                              if (_showManual) ...[
                                const SizedBox(height: 12),
                                _SleepForm(
                                  key: ValueKey('sleep_form_$baby'),
                                  embedded: true,
                                  babyName: _babyName,
                                  birthDate: _birthDate,
                                  rows: _rows,
                                  onSave: (entry) async {
                                    if (baby != _babyId) return false;
                                    final problem = SleepRecords.validate(
                                      entry,
                                      _rows,
                                      _now,
                                      birth: _birthDate,
                                    );
                                    if (problem != null) {
                                      setState(() => _error = problem);
                                      return false;
                                    }
                                    return _persist(
                                      [entry, ..._rows],
                                      baby!,
                                      _babyName,
                                    );
                                  },
                                ),
                              ],
                              _heading('Recent sleep'),
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
                                        final day = await showDatePicker(
                                          context: context,
                                          initialDate: _day,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );
                                        if (day != null && mounted)
                                          setState(() {
                                            _day = day;
                                            _allDates = false;
                                          });
                                      },
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _day = DateUtils.dateOnly(_now);
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
                              if (current != null)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'A sleep timer is running. Stop it on the main sleep page to add it to history.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AuthPalette.textMuted,
                                    ),
                                  ),
                                ),
                            ],
                            if (visible.isEmpty)
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: widget.historyOnly
                                      ? MediaQuery.sizeOf(context).height * .5
                                      : 140,
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
                                      Icons.nights_stay_outlined,
                                      color: Color(0xFFAE89BC),
                                      size: 42,
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'No completed sleep sessions',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Saved sessions appear here for this baby.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AuthPalette.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            for (final item
                                in widget.historyOnly
                                    ? visible
                                    : visible.take(3))
                              _SleepRecordCard(
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
    seedColor: const Color(0xFFAA78B2),
    primary: const Color(0xFFAA628C),
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

class _SleepForm extends StatefulWidget {
  const _SleepForm({
    super.key,
    required this.babyName,
    required this.onSave,
    required this.rows,
    this.initial,
    this.birthDate,
    this.embedded = false,
  });
  final String babyName;
  final Map<String, dynamic>? initial;
  final DateTime? birthDate;
  final bool embedded;
  final List<Map<String, dynamic>> rows;
  final Future<bool> Function(Map<String, dynamic>) onSave;
  @override
  State<_SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<_SleepForm> {
  final _notes = TextEditingController();
  late String _type;
  DateTime? _start, _end;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _type = widget.initial?['type'] == 'night' ? 'night' : 'nap';
    _start = widget.initial == null
        ? DateTime.now().subtract(const Duration(hours: 1))
        : SleepRecords.start(widget.initial!);
    _end = widget.initial == null
        ? DateTime.now()
        : SleepRecords.end(widget.initial!);
    _notes.text = widget.initial?['notes'] as String? ?? '';
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final now = DateTime.now();
    final first = widget.birthDate != null && widget.birthDate!.isBefore(now)
        ? DateUtils.dateOnly(widget.birthDate!)
        : DateTime(2000);
    var initial = (start ? _start : _end) ?? now;
    if (initial.isBefore(first) || initial.isAfter(now)) initial = now;
    final day = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now,
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time != null && mounted)
      setState(() {
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        );
        if (start) {
          _start = at;
        } else {
          _end = at;
        }
      });
  }

  Future<void> _save() async {
    if (_saving) return;
    final entry = <String, dynamic>{
      'id':
          widget.initial?['id'] ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      'record_type': 'session',
      'type': _type,
      'start_at': _start?.toUtc().toIso8601String(),
      'end_at': _end?.toUtc().toIso8601String(),
      'notes': _notes.text.trim(),
      if (widget.initial != null && SleepRecords.start(widget.initial!) == null)
        'legacy_details':
            '${widget.initial!['time'] ?? ''} · ${widget.initial!['duration'] ?? ''}',
    };
    final problem = SleepRecords.validate(
      entry,
      widget.rows,
      DateTime.now(),
      birth: widget.birthDate,
    );
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    if (_notes.text.trim().length > 500) {
      setState(() => _error = 'Keep notes within 500 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    bool success;
    try {
      success = await widget.onSave(entry);
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    if (success) {
      if (widget.embedded) {
        setState(() {
          _saving = false;
          _notes.clear();
          _start = DateTime.now().subtract(const Duration(hours: 1));
          _end = DateTime.now();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sleep session saved')));
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

  String _when(DateTime? at) => at == null
      ? 'Choose date and time'
      : '${MaterialLocalizations.of(context).formatMediumDate(at)} · ${TimeOfDay.fromDateTime(at).format(context)}';
  Widget _body(BuildContext context) => AuthCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SleepTabs(
          value: _type,
          enabled: !_saving,
          onChanged: (v) => setState(() => _type = v),
        ),
        const SizedBox(height: 18),
        if (widget.initial != null &&
            SleepRecords.start(widget.initial!) == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Previous record: ${widget.initial!['time']} · ${widget.initial!['duration']}. Please add its actual start and end dates.',
            ),
          ),
        const Text('Start', style: TextStyle(color: AuthPalette.textMuted)),
        OutlinedButton.icon(
          onPressed: _saving ? null : () => _pick(true),
          icon: const Icon(Icons.bedtime_outlined, size: 20),
          label: Text(_when(_start)),
        ),
        const SizedBox(height: 12),
        const Text('End', style: TextStyle(color: AuthPalette.textMuted)),
        OutlinedButton.icon(
          onPressed: _saving ? null : () => _pick(false),
          icon: const Icon(Icons.wb_sunny_outlined, size: 20),
          label: Text(_when(_end)),
        ),
        if (_start != null && _end != null && _end!.isAfter(_start!))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Duration: ${SleepRecords.duration(_end!.difference(_start!))}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF936EAA),
              ),
            ),
          ),
        const SizedBox(height: 12),
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
          label: widget.embedded ? 'Save past sleep' : 'Save changes',
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
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
              const Positioned.fill(child: _SleepBackground()),
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
                                  'Edit sleep session',
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

class _SleepTabs extends StatelessWidget {
  const _SleepTabs({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF6FC),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEADFED)),
    ),
    child: Row(
      children: [
        for (final type in ['nap', 'night'])
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: type == value
                    ? (type == 'nap'
                          ? const Color(0xFFD5E7F4)
                          : const Color(0xFFE2D6F2))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('sleep_type_$type'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: enabled ? () => onChanged(type) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == 'nap'
                              ? Icons.wb_twilight_rounded
                              : Icons.bedtime_outlined,
                          color: const Color(0xFF805D75),
                          size: 23,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type == 'nap' ? 'Nap' : 'Night',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _SleepSummary extends StatelessWidget {
  const _SleepSummary({required this.rows, required this.day});
  final List<Map<String, dynamic>> rows;
  final DateTime day;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('sleep_summary'),
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
          'TODAY · COMPLETED SLEEP',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.w800,
            color: Color(0xFF975F7B),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _metric(
              SleepRecords.duration(SleepRecords.onDay(rows, day)),
              'Total',
            ),
            _metric(
              SleepRecords.duration(SleepRecords.onDay(rows, day, type: 'nap')),
              'Naps',
            ),
            _metric(
              SleepRecords.duration(
                SleepRecords.onDay(rows, day, type: 'night'),
              ),
              'Night',
            ),
          ],
        ),
      ],
    ),
  );
  Widget _metric(String value, String label) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF784E68),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8C7487)),
        ),
      ],
    ),
  );
}

class _SleepRecordCard extends StatelessWidget {
  const _SleepRecordCard({
    required this.row,
    required this.when,
    this.onEdit,
    this.onDelete,
  });
  final Map<String, dynamic> row;
  final String Function(DateTime) when;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final start = SleepRecords.start(row), end = SleepRecords.end(row);
    return Container(
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
                  color: const Color(0xFFE2D6F2).withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  row['type'] == 'night'
                      ? Icons.bedtime_outlined
                      : Icons.wb_twilight_rounded,
                  color: const Color(0xFF8D627B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SleepRecords.label(row['type']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      start == null || end == null
                          ? row['duration'] as String? ??
                                'Duration not recorded'
                          : SleepRecords.duration(end.difference(start)),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF936EAA),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit sleep session',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: Color(0xFFAA7894),
                ),
              ),
              IconButton(
                tooltip: 'Delete sleep session',
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
          Text(
            start == null || end == null
                ? 'Previous time: ${row['time'] ?? 'Not recorded'}. Edit to add dates.'
                : '${when(start)} → ${when(end)}',
            style: const TextStyle(fontSize: 12, color: AuthPalette.textMuted),
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
}

class _SleepBackground extends StatelessWidget {
  const _SleepBackground();
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
            Icons.nights_stay_outlined,
            size: 28,
            color: Color(0x33A578A4),
          ),
        ),
      ),
    ],
  );
}
