import '../../../../core/network/care_dio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/history_date_range.dart';
import '../../../../core/config/app_config.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../domain/cry_history_records.dart';
import '../../application/cry_history_playback.dart';
import '../widgets/cry_recording_card.dart';

class CryHistoryScreen extends StatefulWidget {
  const CryHistoryScreen({
    super.key,
    this.api,
    this.playback,
    this.historyRange,
  });
  final CryHistoryPlayback? playback;
  final DateTimeRange? historyRange;
  final Dio? api;
  @override
  State<CryHistoryScreen> createState() => _CryHistoryScreenState();
}

class _CryHistoryScreenState extends State<CryHistoryScreen> {
  List<Map<String, dynamic>> _rows = [];
  String? _babyId;
  String _babyName = '';
  bool _loading = true, _saving = false;
  bool _loaded = false;
  int _loadVersion = 0;
  String? _error;
  late final CryHistoryPlayback _playback;
  bool _playingBusy = false;
  DateTime _day = DateUtils.dateOnly(DateTime.now());
  bool _allDates = true;
  DateTimeRange? _reportRange;

  @override
  void initState() {
    super.initState();
    _reportRange = widget.historyRange;
    BabyProfileStore.changes.addListener(_profileChanged);
    _playback = widget.playback ?? DeviceCryHistoryPlayback();
    _playback.addListener(_audioChanged);
    _load();
  }

  @override
  void dispose() {
    _playback.removeListener(_audioChanged);
    _playback.dispose();
    BabyProfileStore.changes.removeListener(_profileChanged);
    super.dispose();
  }

  void _audioChanged() {
    if (mounted) setState(() {});
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
    setState(() {
      _babyId = id;
      _babyName = BabyProfileStore.name;
      if (!keepForm) _rows = [];
      _loading = !keepForm;
      _loaded = keepForm && _loaded;
      _error = null;
      _day = DateUtils.dateOnly(DateTime.now());
      _allDates = true;
    });
    if (id == null) {
      try {
        await _playback.stop();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Select a baby profile first.';
      });
      return;
    }
    try {
      await _playback.stop();
      final api = await _client();
      final result = await api.get('/babies/$id');
      if (!mounted || id != _babyId || version != _loadVersion) return;
      final data = Map<String, dynamic>.from(result.data['data'] as Map);
      final rows = ((data['tracker_data'] as Map?)?['cry'] as List? ?? [])
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      setState(() {
        _rows = rows;
        _loading = false;
        _loaded = true;
      });
    } catch (_) {
      if (mounted && id == _babyId && version == _loadVersion)
        setState(() {
          _loading = false;
          _error = 'Could not load recordings. Tap retry.';
        });
    }
  }

  Future<bool> _persist(
    List<Map<String, dynamic>> rows,
    String baby,
    String name,
  ) async {
    if (_saving || baby != _babyId || baby != BabyProfileStore.id) return false;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final api = await _client();
      await _playback.stop();
      final response = await api.put('/babies/$baby/trackers/cry', data: rows);
      final saved =
          (response.data?['data'] as List?)
              ?.map((r) => Map<String, dynamic>.from(r as Map))
              .toList() ??
          rows;
      rows = saved;
      if (!mounted || baby != _babyId) return true;
      setState(() => _rows = rows);
      if (BabyProfileStore.id == baby) {
        BabyProfileStore.data = {
          ...BabyProfileStore.data,
          'tracker_data': {
            ...?BabyProfileStore.data['tracker_data'] as Map<String, dynamic>?,
            'cry': rows,
          },
        };
        BabyProfileStore.babies = BabyProfileStore.babies
            .map(
              (b) => b['id'] == baby
                  ? {
                      ...b,
                      'tracker_data': {
                        ...?b['tracker_data'] as Map<String, dynamic>?,
                        'cry': rows,
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

  Future<void> _play(Map<String, dynamic> row) async {
    if (_playingBusy || _saving || _loading) return;
    final baby = _babyId;
    setState(() => _playingBusy = true);
    try {
      await _playback.toggle(row);
    } catch (_) {
      if (mounted && baby == _babyId)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not play this recording. Please retry.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _playingBusy = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    if (_saving || _playingBusy) return;
    final baby = _babyId!, name = _babyName;
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete recording?'),
        content: Text('Remove this saved audio and analysis for $name?'),
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
      await _persist(
        _rows
            .where(
              (r) => CryHistoryRecords.key(r) != CryHistoryRecords.key(row),
            )
            .toList(),
        baby,
        name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _allDates
        ? CryHistoryRecords.sorted(_rows)
              .where(
                (r) => historyIncludes(_reportRange, CryHistoryRecords.date(r)),
              )
              .toList()
        : CryHistoryRecords.onDay(_rows, _day);
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC34F7C),
          primary: const Color(0xFFC34F7C),
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: AuthBackgroundGradient()),
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
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Cry history',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.graphic_eq_rounded,
                              color: Color(0xFFBF7B9C),
                              size: 28,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Recordings for $_babyName',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                        ),
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
                        const SizedBox(height: 12),
                        if (_loading) const LinearProgressIndicator(),
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: const TextStyle(color: Color(0xFFAD355F)),
                          ),
                          TextButton(
                            onPressed: () => _load(),
                            child: const Text('Retry loading'),
                          ),
                        ],
                        if (_saving) const LinearProgressIndicator(),
                        if (_loaded) ...[
                          Text(
                            '${visible.length} saved recording${visible.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                          if (visible.isEmpty)
                            Container(
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.sizeOf(context).height * .5,
                              ),
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .85),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: const Color(0xFFEAD6E4),
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.graphic_eq_rounded,
                                    color: Color(0xFFBF7B9C),
                                    size: 48,
                                  ),
                                  SizedBox(height: 18),
                                  Text(
                                    'No recordings for this selection',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Record or upload audio on the Cry Analyzer page. Saved recordings will appear here for this baby.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AuthPalette.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          for (final row in visible)
                            CryRecordingCard(
                              key: ValueKey(CryHistoryRecords.key(row)),
                              entry: row,
                              active:
                                  _playback.currentKey ==
                                  CryHistoryRecords.key(row),
                              playing:
                                  _playback.currentKey ==
                                      CryHistoryRecords.key(row) &&
                                  _playback.playing,
                              position: _playback.position,
                              playbackDuration: _playback.duration,
                              onPlay: _saving || _playingBusy
                                  ? null
                                  : () => _play(row),
                              onDelete: _saving || _playingBusy
                                  ? null
                                  : () => _delete(row),
                            ),
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
