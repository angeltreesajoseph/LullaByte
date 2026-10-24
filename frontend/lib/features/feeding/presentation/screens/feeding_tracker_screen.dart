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
import '../../application/feeding_reminders.dart';
import '../../domain/feeding_records.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({
    super.key,
    this.api,
    this.syncReminders,
    this.requestPermission,
    this.historyOnly = false,
    this.historyRange,
  });
  final bool historyOnly;
  final DateTimeRange? historyRange;
  final Dio? api;
  final Future<void> Function(
    String baby,
    String name,
    List<Map<String, dynamic>> rows,
  )?
  syncReminders;
  final Future<bool> Function()? requestPermission;
  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  List<Map<String, dynamic>> _rows = [];
  String? _babyId;
  String _babyName = '';
  bool _loading = true, _saving = false;
  bool _loaded = false;
  bool _refreshing = false, _freshReady = false;
  int _loadVersion = 0;
  String? _error, _notificationError;
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

  Future<void> _sync(
    String baby,
    String name,
    List<Map<String, dynamic>> rows,
  ) async {
    try {
      if (widget.syncReminders != null) {
        await widget.syncReminders!(baby, name, rows);
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null)
          await FeedingReminders.sync(
            user.uid,
            baby,
            name,
            BabyProfileStore.data['access_role'] == 'viewer' ? [] : rows,
          );
      }
      if (mounted && baby == _babyId) setState(() => _notificationError = null);
    } catch (_) {
      if (mounted && baby == _babyId)
        setState(
          () => _notificationError =
              'Records are saved, but phone reminders could not be updated. Retry below.',
        );
    }
  }

  Future<void> _load({bool keepForm = false}) async {
    final version = ++_loadVersion;
    final id = BabyProfileStore.id;
    final snapshot = BabyProfileStore.snapshotFor(id);
    setState(() {
      _babyId = id;
      _babyName = BabyProfileStore.name;
      if (!keepForm)
        _rows = ((snapshot?['tracker_data'] as Map?)?['feeding'] as List? ?? [])
            .map((r) => Map<String, dynamic>.from(r as Map))
            .toList();
      _loading = !keepForm && snapshot == null;
      _loaded = snapshot != null || keepForm && _loaded;
      _refreshing = id != null;
      _freshReady = false;
      _error = null;
      _notificationError = null;
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
      final rows = ((data['tracker_data'] as Map?)?['feeding'] as List? ?? [])
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      setState(() {
        _rows = rows;
        _loading = false;
        _loaded = true;
        _refreshing = false;
        _freshReady = true;
      });
      await _sync(id, _babyName, rows);
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
          _error = 'Could not load feeding records. Tap retry.';
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
      await api.put('/babies/$baby/trackers/feeding', data: rows);
      if (!mounted || baby != _babyId) return true;
      setState(() => _rows = rows);
      if (BabyProfileStore.id == baby) {
        BabyProfileStore.data = {
          ...BabyProfileStore.data,
          'tracker_data': {
            ...Map<String, dynamic>.from(
              BabyProfileStore.data['tracker_data'] as Map? ?? {},
            ),
            'feeding': rows,
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
                        'feeding': rows,
                      },
                    }
                  : b,
            )
            .toList();
        BabyProfileStore.changes.value++;
      }
      await _sync(baby, name, rows);
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
          child: _FeedForm(
            babyName: name,
            initial: row,
            birthDate: DateTime.tryParse(
              BabyProfileStore.data['birth_date'] as String? ?? '',
            ),
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
        title: const Text('Delete feeding?'),
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

  Future<void> _remind([int? index]) async {
    final baby = _babyId!, name = _babyName;
    final existing = index == null ? null : _rows[index];
    final previous = DateTime.tryParse(
      existing?['reminder_at'] as String? ?? '',
    )?.toLocal();
    final initial =
        previous != null &&
            previous.isAfter(DateTime.now()) &&
            previous.isBefore(DateTime.now().add(const Duration(days: 365)))
        ? previous
        : DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateUtils.dateOnly(DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted || baby != _babyId) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted || baby != _babyId) return;
    final at = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!at.isAfter(DateTime.now())) {
      _toast('Choose a future reminder time.');
      return;
    }
    try {
      final allowed =
          await (widget.requestPermission?.call() ??
              FeedingReminders.permission());
      if (!mounted || baby != _babyId) return;
      if (!allowed) {
        _toast('Enable notifications in phone settings to set a reminder.');
        return;
      }
      final next = [..._rows];
      final entry = <String, dynamic>{
        'id':
            existing?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        'record_type': 'reminder',
        'reminder_at': at.toUtc().toIso8601String(),
      };
      if (index == null) {
        next.add(entry);
      } else {
        next[index] = entry;
      }
      await _persist(next, baby, name);
    } catch (_) {
      if (mounted)
        _toast('Could not access phone notifications. Please retry.');
    }
  }

  Future<void> _removeReminder(int index) async {
    final baby = _babyId!, name = _babyName;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('Remove this feeding reminder for $name?'),
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

  void _toast(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  String _when(DateTime at) =>
      '${MaterialLocalizations.of(context).formatMediumDate(at)} · ${TimeOfDay.fromDateTime(at).format(context)}';
  Widget _heading(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Text(
      label,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
    ),
  );

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FeedingScreen(
          historyOnly: true,
          api: widget.api,
          syncReminders: widget.syncReminders,
          requestPermission: widget.requestPermission,
        ),
      ),
    );
    if (mounted) await _load(keepForm: true);
  }

  @override
  Widget build(BuildContext context) {
    final feeds = FeedingRecords.feeds(_rows);
    final today = FeedingRecords.onDay(_rows, DateTime.now());
    final dated = feeds.where((r) => FeedingRecords.date(r) != null).toList()
      ..sort(
        (a, b) => FeedingRecords.date(b)!.compareTo(FeedingRecords.date(a)!),
      );
    final breast = dated.where((r) => r['type'] == 'breastfeed');
    final visible =
        _rows
            .asMap()
            .entries
            .where(
              (e) =>
                  e.value['record_type'] != 'reminder' &&
                  (!widget.historyOnly ||
                      (_allDates &&
                          historyIncludes(
                            _reportRange,
                            FeedingRecords.date(e.value),
                          )) ||
                      (!_allDates &&
                          FeedingRecords.date(e.value) != null &&
                          FeedingRecords.sameDay(
                            FeedingRecords.date(e.value)!,
                            _day,
                          ))),
            )
            .toList()
          ..sort(
            (a, b) => (FeedingRecords.date(b.value) ?? DateTime(1970))
                .compareTo(FeedingRecords.date(a.value) ?? DateTime(1970)),
          );
    final reminders =
        _rows
            .asMap()
            .entries
            .where((e) => e.value['record_type'] == 'reminder')
            .toList()
          ..sort(
            (a, b) => (a.value['reminder_at'] as String? ?? '').compareTo(
              b.value['reminder_at'] as String? ?? '',
            ),
          );
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC34F7C),
          primary: const Color(0xFFC34F7C),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFAC456D),
            backgroundColor: Colors.white.withValues(alpha: .8),
            side: const BorderSide(color: Color(0xFFF0CADA)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _FeedingBackdrop()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                              onPressed: () => widget.historyOnly
                                  ? Navigator.pop(context)
                                  : context.go(RoutePaths.dashboard),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.historyOnly
                                    ? 'Feeding history'
                                    : 'Feeding',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.historyOnly
                                    ? Icons.history_rounded
                                    : Icons.local_drink_rounded,
                                color: const Color(0xFFD87097),
                              ),
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
                              onPressed: _load,
                              child: const Text('Retry loading'),
                            ),
                          if (_loaded) ...[
                            if (!widget.historyOnly) ...[
                              _CompactSummary(
                                count: today.length,
                                solids: today
                                    .where((r) => r['type'] == 'solids')
                                    .length,
                                ml: FeedingRecords.number(
                                  FeedingRecords.bottleMl(today),
                                ),
                                minutes: FeedingRecords.number(
                                  FeedingRecords.breastMinutes(today),
                                ),
                                last: dated.isEmpty
                                    ? 'No feeds recorded yet'
                                    : 'Last feed: ${_when(FeedingRecords.date(dated.first)!)}',
                              ),
                              _heading('Add feeding'),
                              _FeedForm(
                                key: ValueKey('feeding_form_$_babyId'),
                                embedded: true,
                                babyName: _babyName,
                                birthDate: DateTime.tryParse(
                                  BabyProfileStore.data['birth_date']
                                          as String? ??
                                      '',
                                ),
                                lastSide: breast.isEmpty
                                    ? null
                                    : breast.first['side'] as String?,
                                onSave: (entry) => _persist(
                                  [entry, ..._rows],
                                  _babyId!,
                                  _babyName,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Feeding reminders',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _saving ? null : () => _remind(),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Add reminder'),
                                  ),
                                ],
                              ),
                              for (final item in reminders)
                                _ReminderCard(
                                  at: DateTime.tryParse(
                                    item.value['reminder_at'] as String? ?? '',
                                  )?.toLocal(),
                                  label: _when,
                                  onEdit: _saving
                                      ? null
                                      : () => _remind(item.key),
                                  onDelete: _saving
                                      ? null
                                      : () => _removeReminder(item.key),
                                ),
                              if (_notificationError != null) ...[
                                Text(_notificationError!),
                                TextButton(
                                  onPressed: () =>
                                      _sync(_babyId!, _babyName, _rows),
                                  child: const Text('Retry phone reminder'),
                                ),
                              ],
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Optional, one-time reminders. Phone settings may delay notifications.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AuthPalette.textMuted,
                                  ),
                                ),
                              ),
                              _heading('Recent feedings'),
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
                                  const SizedBox(width: 8),
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
                              const SizedBox(height: 12),
                            ],
                            if (visible.isEmpty)
                              _FeedingEmptyState(
                                history: widget.historyOnly,
                                onLog: widget.historyOnly
                                    ? () => Navigator.pop(context)
                                    : null,
                              ),
                            for (final item
                                in widget.historyOnly
                                    ? visible
                                    : visible.take(3))
                              _FeedHistoryCard(
                                entry: item.value,
                                time: FeedingRecords.date(item.value) == null
                                    ? 'Date not recorded'
                                    : _when(FeedingRecords.date(item.value)!),
                                onEdit: _saving
                                    ? null
                                    : () => _edit(item.value, item.key),
                                onDelete: _saving
                                    ? null
                                    : () => _delete(item.key),
                              ),
                            if (!widget.historyOnly)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: OutlinedButton.icon(
                                  onPressed: _saving ? null : _openHistory,
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

String _label(dynamic type) => switch (type) {
  'breastfeed' => 'Breastfeed',
  'bottle' => 'Bottle',
  'solids' => 'Solids',
  _ => 'Feeding',
};

class _FeedForm extends StatefulWidget {
  const _FeedForm({
    super.key,
    this.embedded = false,
    this.lastSide,
    required this.babyName,
    required this.onSave,
    this.initial,
    this.birthDate,
  });
  final bool embedded;
  final String? lastSide;
  final String babyName;
  final Map<String, dynamic>? initial;
  final DateTime? birthDate;
  final Future<bool> Function(Map<String, dynamic>) onSave;
  @override
  State<_FeedForm> createState() => _FeedFormState();
}

class _FeedFormState extends State<_FeedForm> {
  final _key = GlobalKey<FormState>();
  final _amount = TextEditingController(),
      _duration = TextEditingController(),
      _food = TextEditingController(),
      _quantity = TextEditingController(),
      _notes = TextEditingController();
  late String _type, _side, _milk;
  DateTime? _at;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final r = widget.initial ?? {};
    _type = ['breastfeed', 'bottle', 'solids'].contains(r['type'])
        ? r['type'] as String
        : 'bottle';
    _side = r['side'] as String? ?? 'Both';
    _milk = r['milk_type'] as String? ?? 'Formula';
    _at = widget.initial == null ? DateTime.now() : FeedingRecords.date(r);
    _amount.text = '${r['amount_ml'] ?? ''}';
    _duration.text = '${r['duration_min'] ?? ''}';
    _food.text = r['food'] as String? ?? '';
    _quantity.text = r['quantity'] as String? ?? '';
    _notes.text = r['notes'] as String? ?? '';
  }

  @override
  void dispose() {
    for (final c in [_amount, _duration, _food, _quantity, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _positive(String? value) {
    final v = double.tryParse(value?.trim() ?? '');
    return v == null || !v.isFinite || v <= 0
        ? 'Enter a number greater than zero'
        : null;
  }

  Future<void> _date() async {
    final now = DateTime.now();
    final birth = widget.birthDate;
    final first = birth != null && birth.isBefore(now)
        ? DateUtils.dateOnly(birth)
        : DateTime(2000);
    var initial = _at ?? now;
    if (initial.isBefore(first) || initial.isAfter(now)) initial = now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_at ?? now),
    );
    if (time != null && mounted)
      setState(
        () => _at = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
  }

  Future<void> _save() async {
    if (_saving || !_key.currentState!.validate()) return;
    if (_at == null ||
        _at!.isAfter(DateTime.now()) ||
        (widget.birthDate != null &&
            _at!.isBefore(DateUtils.dateOnly(widget.birthDate!)))) {
      setState(() => _error = 'Choose a feeding date from birth through now.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final row = <String, dynamic>{
      'id':
          widget.initial?['id'] ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      'type': _type,
      'occurred_at': _at!.toUtc().toIso8601String(),
      'notes': _notes.text.trim(),
      if (_type == 'breastfeed') ...{
        'side': _side,
        'duration_min': double.parse(_duration.text.trim()),
      },
      if (_type == 'bottle') ...{
        'milk_type': _milk,
        'amount_ml': double.parse(_amount.text.trim()),
      },
      if (_type == 'solids') ...{
        'food': _food.text.trim(),
        'quantity': _quantity.text.trim(),
      },
      if (widget.initial != null && widget.initial!['occurred_at'] == null)
        'legacy_details': FeedingRecords.detail(widget.initial!),
    };
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
          for (final c in [_amount, _duration, _food, _quantity, _notes]) {
            c.clear();
          }
          _at = DateTime.now();
          _key.currentState?.reset();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Feeding saved')));
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

  Widget _field(
    TextEditingController c,
    String label, {
    bool numeric = false,
    bool required = false,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: c,
      enabled: !_saving,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLength: numeric ? 8 : 500,
      decoration: authPastelDecoration(
        label: label,
        hint: hint ?? label,
        prefixIcon: numeric ? Icons.straighten : Icons.edit_note,
      ).copyWith(counterText: ''),
      validator: numeric
          ? _positive
          : required
          ? (v) => v == null || v.trim().isEmpty ? 'Please enter $label' : null
          : null,
    ),
  );
  Widget _formBody(BuildContext context) => AuthCard(
    child: Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeedTabs(
            value: _type,
            enabled: !_saving,
            onChanged: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: 18),
          if (widget.initial != null && widget.initial!['occurred_at'] == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Previous details: ${FeedingRecords.detail(widget.initial!)}. Please confirm the date and values below.',
              ),
            ),
          if (_type == 'breastfeed') ...[
            if (widget.lastSide != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Last recorded side: ${widget.lastSide}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AuthPalette.textMuted,
                  ),
                ),
              ),
            const Text('Breast side'),
            Wrap(
              spacing: 8,
              children: [
                for (final side in ['Left', 'Right', 'Both'])
                  ChoiceChip(
                    label: Text(side),
                    selected: _side == side,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _side = side),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _field(_duration, 'Duration (minutes)', numeric: true),
          ],
          if (_type == 'bottle') ...[
            const Text('Milk type'),
            Wrap(
              spacing: 8,
              children: [
                for (final milk in ['Formula', 'Expressed breast milk'])
                  ChoiceChip(
                    label: Text(milk),
                    selected: _milk == milk,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _milk = milk),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _field(_amount, 'Amount consumed (ml)', numeric: true),
          ],
          if (_type == 'solids') ...[
            _field(_food, 'Food name', required: true),
            _field(_quantity, 'Quantity (optional)', hint: 'e.g. 2 teaspoons'),
          ],
          OutlinedButton.icon(
            onPressed: _saving ? null : _date,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _at == null
                  ? 'Choose date and time'
                  : '${MaterialLocalizations.of(context).formatMediumDate(_at!)} · ${TimeOfDay.fromDateTime(_at!).format(context)}',
            ),
          ),
          const SizedBox(height: 16),
          _field(
            _notes,
            'Notes (optional)',
            hint: _type == 'solids'
                ? 'Any observed reaction or other notes'
                : 'Anything worth remembering',
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          AuthPrimaryButton(
            label: 'Save feeding',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _formBody(context);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _FeedingBackdrop()),
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
                                'Edit feeding',
                                style: TextStyle(
                                  fontSize: 26,
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
                        _formBody(context),
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

Color _feedColor(String type) => switch (type) {
  'breastfeed' => const Color(0xFFF4A1BE),
  'bottle' => const Color(0xFFA9CEE8),
  _ => const Color(0xFFB1DCCB),
};
IconData _feedIcon(String type) => switch (type) {
  'breastfeed' => Icons.favorite_outline_rounded,
  'bottle' => Icons.local_drink_outlined,
  _ => Icons.restaurant_rounded,
};

class _FeedTabs extends StatelessWidget {
  const _FeedTabs({
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
      color: const Color(0xFFFCF8FC),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEADFED)),
    ),
    child: Row(
      children: [
        for (final type in ['breastfeed', 'bottle', 'solids'])
          Expanded(
            child: Semantics(
              selected: type == value,
              button: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: type == value
                      ? _feedColor(type).withValues(alpha: .5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: enabled ? () => onChanged(type) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Icon(
                            _feedIcon(type),
                            size: 23,
                            color: type == value
                                ? const Color(0xFF704B61)
                                : AuthPalette.textMuted,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _label(type),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: type == value
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: AuthPalette.textDark,
                            ),
                          ),
                        ],
                      ),
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

class _CompactSummary extends StatelessWidget {
  const _CompactSummary({
    required this.count,
    required this.solids,
    required this.ml,
    required this.minutes,
    required this.last,
  });
  final int count, solids;
  final String ml, minutes, last;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('feeding_summary'),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFBE1EC), Color(0xFFECE3F7)],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFEED2E4)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFCE8CAC).withValues(alpha: .12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TODAY',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF975F7B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _metric('$count', 'feeds'),
            _metric('$ml ml', 'bottle'),
            _metric('$minutes min', 'breastfeed'),
            _metric('$solids', 'solids'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          last,
          style: const TextStyle(fontSize: 11, color: Color(0xFF7D6578)),
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
            fontSize: 17,
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

class _FeedingBackdrop extends StatelessWidget {
  const _FeedingBackdrop();
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
      Positioned(
        left: -55,
        top: 140,
        child: IgnorePointer(
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .13),
            ),
          ),
        ),
      ),
      const Positioned(
        right: 30,
        bottom: 30,
        child: IgnorePointer(
          child: Icon(
            Icons.favorite_outline_rounded,
            size: 30,
            color: Color(0x33A578A4),
          ),
        ),
      ),
    ],
  );
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.at,
    required this.label,
    this.onEdit,
    this.onDelete,
  });
  final DateTime? at;
  final String Function(DateTime) label;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final upcoming = at != null && at!.isAfter(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: upcoming
              ? const [Color(0xFFFFE8EF), Color(0xFFF0E8FB)]
              : const [Color(0xFFF3EFF4), Color(0xFFFAF7FA)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8C9DA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBD7E9D).withValues(alpha: .1),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              upcoming
                  ? Icons.notifications_active_outlined
                  : Icons.alarm_on_rounded,
              color: const Color(0xFFB75D86),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upcoming ? 'UPCOMING REMINDER' : 'PAST REMINDER',
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: .7,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFAA6385),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  at == null ? 'Choose a valid time' : label(at!),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF70536B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit reminder',
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 19,
              color: Color(0xFFAA6385),
            ),
          ),
          IconButton(
            tooltip: 'Delete reminder',
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              size: 19,
              color: Color(0xFFAA6385),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedingEmptyState extends StatelessWidget {
  const _FeedingEmptyState({required this.history, this.onLog});
  final bool history;
  final VoidCallback? onLog;
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      minHeight: history ? MediaQuery.sizeOf(context).height * .55 : 160,
    ),
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .8),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFEAD9E7)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(26),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFBE0EC), Color(0xFFE9E1F7)],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            history ? Icons.history_rounded : Icons.local_drink_outlined,
            size: 44,
            color: const Color(0xFFC17E9F),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          history ? 'Your feeding story starts here' : 'No feedings logged yet',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF77596E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          history
              ? 'No records for this selection. Try another date or log a feeding for your baby.'
              : 'Saved feedings will appear here, just for this baby.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AuthPalette.textMuted,
          ),
        ),
        if (onLog != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: OutlinedButton.icon(
              onPressed: onLog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Log a feeding'),
            ),
          ),
      ],
    ),
  );
}

class _FeedHistoryCard extends StatelessWidget {
  const _FeedHistoryCard({
    required this.entry,
    required this.time,
    this.onEdit,
    this.onDelete,
  });
  final Map<String, dynamic> entry;
  final String time;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final type = entry['type'] as String? ?? 'bottle';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFECDDE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB79BC6).withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _feedColor(type).withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _feedIcon(type),
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
                      _label(type),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit feeding',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: Color(0xFFAA7894),
                ),
              ),
              IconButton(
                tooltip: 'Delete feeding',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                  color: Color(0xFFAA7894),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 2),
            child: Text(
              FeedingRecords.detail(entry),
              style: const TextStyle(fontSize: 14, color: Color(0xFF6E5366)),
            ),
          ),
          if ((entry['notes'] as String? ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 2, right: 8),
              child: Text(
                entry['notes'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AuthPalette.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
