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
import '../../domain/diaper_records.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({
    super.key,
    this.api,
    this.historyOnly = false,
    this.historyRange,
  });
  final bool historyOnly;
  final DateTimeRange? historyRange;
  final Dio? api;
  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
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
        _rows = ((snapshot?['tracker_data'] as Map?)?['diaper'] as List? ?? [])
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
      final rows = ((data['tracker_data'] as Map?)?['diaper'] as List? ?? [])
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
          _error = 'Could not load diaper records. Tap retry.';
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
      await api.put('/babies/$baby/trackers/diaper', data: rows);
      if (!mounted || baby != _babyId) return true;
      setState(() => _rows = rows);
      if (BabyProfileStore.id == baby) {
        BabyProfileStore.data = {
          ...BabyProfileStore.data,
          'tracker_data': {
            ...Map<String, dynamic>.from(
              BabyProfileStore.data['tracker_data'] as Map? ?? {},
            ),
            'diaper': rows,
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
                        'diaper': rows,
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
          child: _DiaperForm(
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
        title: const Text('Delete diaper change?'),
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
        builder: (_) => DiaperScreen(api: widget.api, historyOnly: true),
      ),
    );
    if (mounted) await _load(keepForm: true);
  }

  String _when(DateTime at) =>
      '${MaterialLocalizations.of(context).formatMediumDate(at)} · ${TimeOfDay.fromDateTime(at).format(context)}';
  Widget _heading(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final today = DiaperRecords.onDay(_rows, DateTime.now());
    final sorted = _rows.asMap().entries.toList()
      ..sort(
        (a, b) => (DiaperRecords.date(b.value) ?? DateTime(1970)).compareTo(
          DiaperRecords.date(a.value) ?? DateTime(1970),
        ),
      );
    final visible = sorted
        .where(
          (e) =>
              !widget.historyOnly ||
              (_allDates &&
                  historyIncludes(_reportRange, DiaperRecords.date(e.value))) ||
              (!_allDates &&
                  DiaperRecords.date(e.value) != null &&
                  DiaperRecords.sameDay(DiaperRecords.date(e.value)!, _day)),
        )
        .toList();
    return Theme(
      data: _theme(context),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: _DiaperBackground()),
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
                                    ? 'Diaper history'
                                    : 'Diaper care',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.child_friendly_outlined,
                              color: Color(0xFFBF7B9C),
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
                              _DiaperSummary(
                                rows: today,
                                last:
                                    sorted.isEmpty ||
                                        DiaperRecords.date(
                                              sorted.first.value,
                                            ) ==
                                            null
                                    ? 'No changes recorded yet'
                                    : 'Last change: ${_when(DiaperRecords.date(sorted.first.value)!)}',
                              ),
                              _heading('Add diaper change'),
                              _DiaperForm(
                                key: ValueKey('diaper_form_$_babyId'),
                                embedded: true,
                                babyName: _babyName,
                                birthDate: _birthDate,
                                onSave: (entry) => _persist(
                                  [entry, ..._rows],
                                  _babyId!,
                                  _babyName,
                                ),
                              ),
                              _heading('Recent changes'),
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
                                      : 150,
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
                                    Container(
                                      padding: const EdgeInsets.all(22),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFBE1EC),
                                            Color(0xFFE7E1F7),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.child_friendly_outlined,
                                        color: Color(0xFFAE7899),
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.historyOnly
                                          ? 'No changes for this selection'
                                          : 'No diaper changes logged yet',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your baby’s saved changes will appear here.',
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
                              _DiaperRecordCard(
                                row: item.value,
                                time: DiaperRecords.date(item.value) == null
                                    ? 'Date not recorded'
                                    : _when(DiaperRecords.date(item.value)!),
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
Color _color(String type) => switch (type) {
  'wet' => const Color(0xFFBCD9ED),
  'dirty' => const Color(0xFFF4B4CB),
  _ => const Color(0xFFD4C4ED),
};
IconData _icon(String type) => switch (type) {
  'wet' => Icons.water_drop_outlined,
  'dirty' => Icons.eco_outlined,
  _ => Icons.change_circle_outlined,
};

class _DiaperForm extends StatefulWidget {
  const _DiaperForm({
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
  State<_DiaperForm> createState() => _DiaperFormState();
}

class _DiaperFormState extends State<_DiaperForm> {
  final _notes = TextEditingController();
  late String _type;
  String? _stoolColor;
  DateTime? _at;
  bool _automaticTime = true, _saving = false;
  String? _error;
  static const _colors = ['Yellow', 'Brown', 'Green', 'Other'];
  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _type = ['wet', 'dirty', 'mixed'].contains(r?['type'])
        ? r!['type'] as String
        : 'wet';
    _stoolColor = _colors.contains(r?['color']) ? r!['color'] as String : null;
    _notes.text = r?['notes'] as String? ?? '';
    _at = r == null ? DateTime.now() : DiaperRecords.date(r);
    _automaticTime = r == null;
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _date() async {
    final now = DateTime.now();
    final first = widget.birthDate != null && widget.birthDate!.isBefore(now)
        ? DateUtils.dateOnly(widget.birthDate!)
        : DateTime(2000);
    var initial = _at ?? now;
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
      initialTime: TimeOfDay.fromDateTime(_at ?? now),
    );
    if (time != null && mounted)
      setState(() {
        _at = DateTime(day.year, day.month, day.day, time.hour, time.minute);
        _automaticTime = false;
      });
  }

  Future<void> _save() async {
    if (_saving) return;
    final at = _automaticTime ? DateTime.now() : _at;
    if (at == null ||
        at.isAfter(DateTime.now()) ||
        (widget.birthDate != null &&
            at.isBefore(DateUtils.dateOnly(widget.birthDate!)))) {
      setState(() => _error = 'Choose a date from birth through now.');
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
    final entry = <String, dynamic>{
      ...?widget.initial,
      'id':
          widget.initial?['id'] ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      'type': _type,
      'time': at.toUtc().toIso8601String(),
      'color': _type == 'wet' ? null : _stoolColor,
      'notes': _notes.text.trim(),
    }..remove('occurred_at');
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
          _at = DateTime.now();
          _automaticTime = true;
          _stoolColor = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Diaper change saved')));
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6FC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEADFED)),
          ),
          child: Row(
            children: [
              for (final type in ['wet', 'dirty', 'mixed'])
                Expanded(
                  child: Semantics(
                    selected: type == _type,
                    button: true,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: type == _type
                            ? _color(type)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: ValueKey('diaper_type_$type'),
                          borderRadius: BorderRadius.circular(16),
                          onTap: _saving
                              ? null
                              : () => setState(() => _type = type),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                Icon(
                                  _icon(type),
                                  color: const Color(0xFF805D75),
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DiaperRecords.label(type),
                                  style: TextStyle(
                                    fontWeight: type == _type
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 13,
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
        ),
        const SizedBox(height: 20),
        if (_type != 'wet') ...[
          const Text(
            'Stool colour (optional)',
            style: TextStyle(color: AuthPalette.textMuted),
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final value in _colors)
                ChoiceChip(
                  label: Text(value),
                  selected: _stoolColor == value,
                  onSelected: _saving
                      ? null
                      : (selected) => setState(
                          () => _stoolColor = selected ? value : null,
                        ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: _saving ? null : _date,
          icon: const Icon(Icons.calendar_today_outlined, size: 20),
          label: Text(
            _automaticTime
                ? 'Now · change date/time'
                : _at == null
                ? 'Choose date and time'
                : '${MaterialLocalizations.of(context).formatMediumDate(_at!)} · ${TimeOfDay.fromDateTime(_at!).format(context)}',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notes,
          enabled: !_saving,
          maxLength: 500,
          maxLines: 3,
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
          label: widget.embedded ? 'Save change' : 'Save changes',
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
              const Positioned.fill(child: _DiaperBackground()),
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
                                  'Edit diaper change',
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

class _DiaperSummary extends StatelessWidget {
  const _DiaperSummary({required this.rows, required this.last});
  final List<Map<String, dynamic>> rows;
  final String last;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('diaper_summary'),
    padding: const EdgeInsets.all(16),
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
        const SizedBox(height: 10),
        Row(
          children: [
            _metric('${rows.length}', 'Total'),
            for (final type in ['wet', 'dirty', 'mixed'])
              _metric(
                '${DiaperRecords.count(rows, type)}',
                DiaperRecords.label(type),
              ),
          ],
        ),
        const SizedBox(height: 10),
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
            fontSize: 20,
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

class _DiaperRecordCard extends StatelessWidget {
  const _DiaperRecordCard({
    required this.row,
    required this.time,
    this.onEdit,
    this.onDelete,
  });
  final Map<String, dynamic> row;
  final String time;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final type = row['type'] as String? ?? 'wet';
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
                  color: _color(type).withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _icon(type),
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
                      DiaperRecords.label(type),
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
                tooltip: 'Edit diaper change',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: Color(0xFFAA7894),
                ),
              ),
              IconButton(
                tooltip: 'Delete diaper change',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                  color: Color(0xFFAA7894),
                ),
              ),
            ],
          ),
          if (type != 'wet' &&
              row['color'] != null &&
              row['color'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Stool colour: ${row['color']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AuthPalette.textMuted,
                ),
              ),
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

class _DiaperBackground extends StatelessWidget {
  const _DiaperBackground();
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
