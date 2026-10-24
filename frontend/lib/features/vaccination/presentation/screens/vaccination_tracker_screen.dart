import '../../../../core/network/care_dio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/router/route_paths.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../application/vaccination_reminders.dart';
import '../../domain/vaccination_schedule.dart';
import '../widgets/vaccination_cards.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key, this.api, this.syncReminders});
  final Dio? api;
  final Future<void> Function(List<Map<String, dynamic>> entries)?
  syncReminders;
  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  List<Map<String, dynamic>> _entries = [];
  Map<String, dynamic> _profile = {};
  bool _loading = true, _busy = false;
  bool _refreshing = false, _freshReady = false;
  String? _error;
  String? _saveError;
  String? _reminderError;
  int _generation = 0;
  DateTime? get _birth =>
      DateTime.tryParse(_profile['birth_date'] as String? ?? '');
  String get _name => _profile['name'] as String? ?? BabyProfileStore.name;
  Future<Dio> _client() async {
    if (widget.api != null) return widget.api!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in required');
    return careDio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BabyProfileStore.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    BabyProfileStore.changes.removeListener(_load);
    super.dispose();
  }

  void _message(String text) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final id = BabyProfileStore.id;
    final snapshot = BabyProfileStore.snapshotFor(id);
    setState(() {
      _loading = snapshot == null;
      _refreshing = id != null;
      _freshReady = false;
      _error = null;
      _profile = snapshot ?? {};
      _entries = snapshot == null
          ? []
          : mergeVaccinations(
              DateTime.tryParse(snapshot['birth_date'] as String? ?? ''),
              ((snapshot['tracker_data'] as Map?)?['vaccinations'] as List? ??
                      [])
                  .map((r) => Map<String, dynamic>.from(r as Map))
                  .toList(),
            );
      _saveError = null;
      _reminderError = null;
    });
    if (id == null) {
      setState(() {
        _loading = false;
        _error = 'Create or select a baby profile first.';
      });
      return;
    }
    try {
      final client = await _client();
      final response = await client.get('/babies/$id');
      if (!mounted || generation != _generation || id != BabyProfileStore.id)
        return;
      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      BabyProfileStore.rememberSnapshot(data);
      final birth = DateTime.tryParse(data['birth_date'] as String? ?? '');
      if (birth != null && birth.isAfter(DateTime.now())) {
        setState(() {
          _loading = false;
          _refreshing = false;
          _error =
              'The birth date is in the future. Correct it in Profile before calculating vaccinations.';
        });
        return;
      }
      final saved =
          ((data['tracker_data'] as Map?)?['vaccinations'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
      setState(() {
        _profile = data;
        _entries = mergeVaccinations(
          DateTime.tryParse(data['birth_date'] as String? ?? ''),
          saved,
        );
        _loading = false;
      });
      setState(() {
        _refreshing = false;
        _freshReady = true;
      });
      await _sync(id);
    } catch (error) {
      if (mounted && generation == _generation)
        setState(() {
          _loading = false;
          _refreshing = false;
          if (error is DioException &&
              {401, 403, 404}.contains(error.response?.statusCode)) {
            _entries = [];
            _profile = {};
          }
          _error =
              'Could not load vaccinations. Check the connection and retry.';
        });
    }
  }

  Future<void> _sync(String babyId) async {
    if (widget.syncReminders != null) {
      await widget.syncReminders!(_entries);
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || babyId != BabyProfileStore.id) return;
    try {
      await VaccinationReminders.sync(
        user.uid,
        babyId,
        _name,
        _profile['access_role'] == 'viewer' ? [] : _entries,
      );
      if (mounted) setState(() => _reminderError = null);
    } catch (_) {
      if (mounted)
        setState(
          () => _reminderError =
              'Your record is saved, but this phone could not schedule the reminder. Check notification permissions and retry.',
        );
      _message(
        'Records are available, but reminders could not be scheduled on this device.',
      );
    }
  }

  Future<bool> _persist(List<Map<String, dynamic>> entries) async {
    if (_refreshing || !_freshReady) {
      _message('Wait for the latest records to refresh before saving.');
      return false;
    }
    final id = BabyProfileStore.id;
    final generation = _generation;
    if (_busy || id == null) return false;
    final previous = _entries;
    setState(() {
      _busy = true;
      _saveError = null;
      _entries = entries;
    });
    try {
      final client = await _client();
      final response = await client.put(
        '/babies/$id/trackers/vaccinations',
        data: entries,
      );
      if (!mounted || generation != _generation || id != BabyProfileStore.id)
        return false;
      final saved = (response.data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() => _entries = saved);
      BabyProfileStore.data = {
        ...BabyProfileStore.data,
        'tracker_data': {
          ...Map<String, dynamic>.from(
            BabyProfileStore.data['tracker_data'] as Map? ?? {},
          ),
          'vaccinations': saved,
        },
      };
      await _sync(id);
      return true;
    } catch (error) {
      var message = 'Could not save. Your change was not stored. Please retry.';
      if (error is DioException) {
        final data = error.response?.data;
        final envelope = data is Map ? data['error'] : null;
        if (envelope is Map && envelope['message'] is String)
          message = envelope['message'] as String;
        if (error.response?.statusCode == 400)
          message =
              'Vaccination saving is not enabled on this server yet. Wait for the latest Render deployment.';
      }
      if (mounted && generation == _generation)
        setState(() {
          _entries = previous;
          _saveError = message;
        });
      _message(message);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _replace(Map<String, dynamic> entry) => _persist([
    for (final old in _entries)
      if (old['id'] == entry['id']) entry else old,
  ]);
  Future<void> _toggle(Map<String, dynamic> entry) async {
    final done = entry['done'] != true;
    final saved = await _replace({
      ...entry,
      'done': done,
      'received_date': done
          ? DateUtils.dateOnly(DateTime.now()).toIso8601String()
          : null,
      'reminder_at': null,
    });
    if (saved)
      _message(
        done
            ? 'Marked received today. Use Edit details to change the date.'
            : 'Completion removed.',
      );
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> _edit([Map<String, dynamic>? entry]) async {
    final generation = _generation;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _VaccinationForm(
          entry: entry,
          birth: _birth,
          onSave: (result) async {
            if (!mounted || generation != _generation) return false;
            if (entry == null)
              return _persist(
                [..._entries, result]..sort(
                  (a, b) => (a['due_date'] as String).compareTo(
                    b['due_date'] as String,
                  ),
                ),
              );
            return _replace(result);
          },
        ),
      ),
    );
  }

  Future<void> _remind(Map<String, dynamic> entry) async {
    final generation = _generation;
    final existing = DateTime.tryParse(entry['reminder_at'] as String? ?? '');
    final nowIst = DateTime.now().toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );
    final initial =
        existing?.toUtc().add(const Duration(hours: 5, minutes: 30)) ??
        DateTime.parse(entry['due_date'] as String);
    var selectedDate = DateUtils.dateOnly(
      initial.isBefore(nowIst) ? nowIst : initial,
    );
    var selectedTime = existing == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay.fromDateTime(initial);
    String? sheetError;
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AuthPalette.warmCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 34,
                color: Color(0xFFB76C8D),
              ),
              const SizedBox(height: 12),
              const Text(
                'A gentle reminder',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AuthPalette.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AuthPalette.textMuted),
              ),
              const SizedBox(height: 20),
              VaccineAction(
                label: MaterialLocalizations.of(
                  context,
                ).formatMediumDate(selectedDate),
                icon: Icons.calendar_today_outlined,
                onTap: () async {
                  final value = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateUtils.dateOnly(nowIst),
                    lastDate: DateTime(nowIst.year + 5),
                  );
                  if (value != null && context.mounted)
                    update(() => selectedDate = value);
                },
              ),
              const SizedBox(height: 10),
              VaccineAction(
                label: selectedTime.format(context) + ' IST',
                icon: Icons.schedule_outlined,
                onTap: () async {
                  final value = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (value != null && context.mounted)
                    update(() => selectedTime = value);
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'India time (IST). Delivery may be delayed by phone battery settings.',
                style: TextStyle(fontSize: 12, color: AuthPalette.textMuted),
              ),
              if (sheetError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    sheetError!,
                    style: const TextStyle(color: AuthPalette.error),
                  ),
                ),
              const SizedBox(height: 20),
              VaccineAction(
                label: 'Save reminder',
                icon: Icons.check_rounded,
                primary: true,
                onTap: () {
                  final instant = DateTime.utc(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  ).subtract(const Duration(hours: 5, minutes: 30));
                  if (!instant.isAfter(DateTime.now().toUtc())) {
                    update(() => sheetError = 'Choose a future date or time.');
                    return;
                  }
                  Navigator.pop(sheetContext, instant.toIso8601String());
                },
              ),
              if (existing != null)
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext, 'remove'),
                  child: const Text(
                    'Remove reminder',
                    style: TextStyle(color: AuthPalette.error),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == null || !mounted || generation != _generation) return;
    if (action == 'remove') {
      await _replace({...entry, 'reminder_at': null});
      return;
    }
    try {
      if (!await VaccinationReminders.requestPermission()) {
        _message(
          'Allow notifications in your phone settings, then set the reminder again.',
        );
        return;
      }
      if (!mounted || generation != _generation) return;
      if (await _replace({...entry, 'reminder_at': action}))
        _message('Reminder saved. Check the scheduled time on the card.');
    } catch (_) {
      _message(
        'This phone could not enable reminders. Check notification permissions.',
      );
    }
  }

  String _date(Object? value) {
    final date = DateTime.tryParse(value as String? ?? '');
    return date == null
        ? 'Not set'
        : MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Widget _card(Map<String, dynamic> entry) {
    final excluded = entry['excluded'] == true, done = entry['done'] == true;
    final past = DateTime.parse(
      entry['due_date'] as String,
    ).isBefore(DateUtils.dateOnly(DateTime.now()));
    final reminder = DateTime.tryParse(entry['reminder_at'] as String? ?? '');
    final reminderIst = reminder?.toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );
    return VaccinationDoseCard(
      key: ValueKey(entry['id']),
      entry: entry,
      date: done
          ? 'Received ' + _date(entry['received_date'])
          : 'Suggested / planned ' + _date(entry['due_date']),
      status: excluded
          ? 'Confirm with your paediatrician before including.'
          : done
          ? 'Recorded as received'
          : past
          ? 'Date passed — review past records with your paediatrician.'
          : 'Upcoming dose',
      reminderEnabled: reminder != null && reminder.isAfter(DateTime.now()),
      reminderLabel: reminder == null ? 'Set reminder' : 'Change reminder',
      reminderInfo: reminderIst == null
          ? null
          : 'Reminder: ' +
                _date(reminderIst.toIso8601String()) +
                ' ' +
                reminderIst.hour.toString().padLeft(2, '0') +
                ':' +
                reminderIst.minute.toString().padLeft(2, '0') +
                ' IST',
      onToggle: _busy || _refreshing || excluded ? null : () => _toggle(entry),
      onEdit: _busy || _refreshing ? null : () => _edit(entry),
      onReminder: _busy || _refreshing ? null : () => _remind(entry),
      menu: PopupMenuButton<String>(
        enabled: !_busy && !_refreshing,
        icon: const Icon(Icons.more_horiz, color: AuthPalette.textMuted),
        onSelected: (action) async {
          final generation = _generation;
          if (action == 'delete') {
            if (await _confirm(
                  'Delete vaccination?',
                  'Remove this custom vaccination and its reminder?',
                ) &&
                generation == _generation) {
              await _persist(
                _entries.where((e) => e['id'] != entry['id']).toList(),
              );
            }
          } else if (action == 'exclude') {
            final yes = await _confirm(
              excluded ? 'Include this dose?' : 'Mark not applicable?',
              'Confirm this decision with your paediatrician. JE is only for endemic areas.',
            );
            if (yes && generation == _generation)
              await _replace({
                ...entry,
                'excluded': !excluded,
                'reminder_at': null,
              });
          }
        },
        itemBuilder: (_) => [
          if (entry['custom'] == true)
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete vaccination'),
            ),
          if (!done)
            PopupMenuItem(
              value: 'exclude',
              child: Text(
                excluded
                    ? 'Include after doctor confirmation'
                    : 'Mark not applicable',
              ),
            ),
          if (done && entry['custom'] != true)
            const PopupMenuItem(
              enabled: false,
              child: Text('Uncheck to correct completion'),
            ),
        ],
      ),
    );
  }

  void _showScope() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm with your paediatrician'),
      content: const SingleChildScrollView(
        child: SelectableText(
          'India government UIP suggestions for birth–24 months. Dates are calculated from DOB, not medical eligibility or catch-up instructions. JE applies only to endemic areas. Later childhood doses and Vitamin A are outside this list.\n\nReminders use India time and depend on phone permissions and battery settings.\n\nSource: ' +
              vaccinationSource,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final active = _entries.where((e) => e['excluded'] != true).toList();
    final done = active.where((e) => e['done'] == true).length;
    final future =
        active
            .where(
              (e) =>
                  e['done'] != true &&
                  !DateTime.parse(
                    e['due_date'] as String,
                  ).isBefore(DateUtils.dateOnly(DateTime.now())),
            )
            .toList()
          ..sort(
            (a, b) =>
                (a['due_date'] as String).compareTo(b['due_date'] as String),
          );
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC3628E))
          .copyWith(
            primary: const Color(0xFFAF527B),
            surface: AuthPalette.warmCream,
          ),
      scaffoldBackgroundColor: AuthPalette.warmCream,
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: AuthPalette.textDark,
        displayColor: AuthPalette.textDark,
      ),
    );
    return Theme(
      data: theme,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AuthPalette.warmCream,
                AuthPalette.blushPink,
                AuthPalette.lavenderMist,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                  children: [
                    Row(
                      children: [
                        AuthBackButton(
                          onPressed: () => Navigator.of(context).canPop()
                              ? Navigator.pop(context)
                              : context.go(RoutePaths.dashboard),
                        ),
                        const Spacer(),
                        const Text(
                          'HEALTH & CARE',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                            color: AuthPalette.textMuted,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Schedule information',
                          onPressed: _showScope,
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            color: AuthPalette.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    VaccinationHero(
                      name: _name,
                      done: done,
                      total: active.length,
                      next: future.isEmpty
                          ? null
                          : (future.first['name'] as String) +
                                ' · ' +
                                _date(future.first['due_date']),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _showScope,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.health_and_safety_outlined,
                              size: 18,
                              color: Color(0xFFAF527B),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'India UIP · Birth–24 months\nConfirm suggested dates with your paediatrician.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: AuthPalette.textDark,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AuthPalette.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_refreshing && !_loading)
                      const LinearProgressIndicator(),
                    if (_loading)
                      const LinearProgressIndicator()
                    else if (_error != null) ...[
                      AuthCard(child: Text(_error!)),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Retry loading'),
                      ),
                    ] else ...[
                      if (_birth == null)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Add DOB in Profile to get schedule suggestions. You can still add custom vaccinations.',
                          ),
                        ),
                      VaccineAction(
                        label: 'Add vaccination',
                        icon: Icons.add_rounded,
                        primary: true,
                        onTap: _busy ? null : () => _edit(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Vaccination checklist',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap the box to mark received today. Use Edit details for an earlier date.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AuthPalette.textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_busy)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(),
                        ),
                      if (_saveError != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDEE),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            _saveError!,
                            style: const TextStyle(color: Color(0xFF9D3F4A)),
                          ),
                        ),
                      if (_reminderError != null)
                        AuthCard(
                          child: Column(
                            children: [
                              Text(_reminderError!),
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => _sync(BabyProfileStore.id!),
                                child: const Text('Retry reminders'),
                              ),
                            ],
                          ),
                        ),
                      for (final entry in active) _card(entry),
                      if (_entries.any((e) => e['excluded'] == true))
                        Material(
                          type: MaterialType.transparency,
                          child: ExpansionTile(
                            title: const Text(
                              'Conditional / not applicable doses',
                            ),
                            subtitle: const Text(
                              'Include only after paediatrician confirmation',
                              style: TextStyle(fontSize: 11),
                            ),
                            children: [
                              for (final entry in _entries.where(
                                (e) => e['excluded'] == true,
                              ))
                                _card(entry),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VaccinationForm extends StatefulWidget {
  const _VaccinationForm({this.entry, this.birth, required this.onSave});
  final Map<String, dynamic>? entry;
  final DateTime? birth;
  final Future<bool> Function(Map<String, dynamic>) onSave;
  @override
  State<_VaccinationForm> createState() => _VaccinationFormState();
}

class _VaccinationFormState extends State<_VaccinationForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _doctor, _notes;
  late DateTime _due;
  DateTime? _received;
  bool _done = false;
  bool _saving = false;
  String? _saveError;
  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _name = TextEditingController(text: e?['name'] as String? ?? '');
    _doctor = TextEditingController(text: e?['doctor'] as String? ?? '');
    _notes = TextEditingController(text: e?['notes'] as String? ?? '');
    _due = DateTime.tryParse(e?['due_date'] as String? ?? '') ?? DateTime.now();
    _received = DateTime.tryParse(e?['received_date'] as String? ?? '');
    _done = e?['done'] == true;
  }

  @override
  void dispose() {
    _name.dispose();
    _doctor.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _label(DateTime? date) => date == null
      ? 'Choose date'
      : MaterialLocalizations.of(context).formatMediumDate(date);
  Future<void> _pick(bool received) async {
    final first = widget.birth ?? DateTime(1900);
    final last = received ? DateTime.now() : DateTime(DateTime.now().year + 5);
    var initial = received ? _received ?? DateTime.now() : _due;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (date != null && mounted)
      setState(() {
        if (received) {
          _received = date;
        } else {
          _due = date;
        }
      });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_done && _received == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose the actual received date.')),
      );
      return;
    }
    final dueChanged =
        widget.entry != null &&
        _due != DateTime.tryParse(widget.entry!['due_date'] as String);
    final data = <String, dynamic>{
      ...?(widget.entry),
      'id':
          widget.entry?['id'] ??
          'custom_${DateTime.now().microsecondsSinceEpoch}',
      'custom': widget.entry?['custom'] ?? true,
      'name': _name.text.trim(),
      'due_date': (_done && widget.entry == null ? _received! : _due)
          .toIso8601String(),
      'due_override':
          widget.entry?['due_override'] == true ||
          dueChanged ||
          widget.entry == null,
      'done': _done,
      'received_date': _done ? _received!.toIso8601String() : null,
      'reminder_at': _done || dueChanged ? null : widget.entry?['reminder_at'],
      'excluded': _done ? false : widget.entry?['excluded'] ?? false,
      'doctor': _doctor.text.trim(),
      'notes': _notes.text.trim(),
    };
    setState(() {
      _saving = true;
      _saveError = null;
    });
    final saved = await widget.onSave(data);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _saveError =
            'Could not save. Your details are still here—please retry.';
      });
    }
  }

  InputDecoration _field(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AuthPalette.textMuted),
    filled: true,
    fillColor: const Color(0xFFFDF2F7),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE4D8EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFE4D8EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFC3628E), width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB9658C))
          .copyWith(
            primary: const Color(0xFFAF527B),
            surface: AuthPalette.warmCream,
          ),
    ),
    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AuthPalette.warmCream,
              AuthPalette.blushPink,
              AuthPalette.lavenderMist,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Form(
                key: _form,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AuthBackButton(
                        onPressed: _saving
                            ? () {}
                            : () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.entry == null
                          ? 'Add vaccination'
                          : 'Edit vaccination',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep the little details in one safe place.',
                      style: TextStyle(color: AuthPalette.textMuted),
                    ),
                    const SizedBox(height: 22),
                    AuthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _name,
                            enabled:
                                !_saving &&
                                (widget.entry == null ||
                                    widget.entry?['custom'] == true),
                            maxLength: 160,
                            decoration: _field(
                              'Vaccine and dose',
                              Icons.vaccines_outlined,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter vaccine and dose'
                                : null,
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Already received',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: const Text(
                                'Switch off to keep this dose planned.',
                              ),
                              value: _done,
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(() => _done = value),
                            ),
                          ),
                          const SizedBox(height: 12),
                          VaccineAction(
                            label:
                                (_done ? 'Received: ' : 'Planned: ') +
                                _label(_done ? _received : _due),
                            icon: Icons.calendar_today_outlined,
                            onTap: _saving ? null : () => _pick(_done),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _doctor,
                            enabled: !_saving,
                            maxLength: 160,
                            decoration: _field(
                              'Doctor / clinic (optional)',
                              Icons.medical_services_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notes,
                            enabled: !_saving,
                            maxLength: 500,
                            maxLines: 3,
                            decoration: _field(
                              'Notes (optional)',
                              Icons.notes_rounded,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Confirm dates with your paediatrician. Set a reminder from the saved card. Changing a planned date clears its old reminder.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                          if (_saveError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text(
                                _saveError!,
                                style: const TextStyle(
                                  color: AuthPalette.error,
                                ),
                              ),
                            ),
                          const SizedBox(height: 22),
                          if (_saving)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: LinearProgressIndicator(),
                            ),
                          VaccineAction(
                            label: _saving ? 'Saving…' : 'Save vaccination',
                            icon: Icons.check_rounded,
                            primary: true,
                            onTap: _saving ? null : _save,
                          ),
                        ],
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
  );
}
