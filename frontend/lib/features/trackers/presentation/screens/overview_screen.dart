import '../../../../core/network/care_dio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../../baby_management/data/baby_api.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../feeding/presentation/screens/feeding_screen.dart';
import '../../../sleep/presentation/screens/sleep_screen.dart';
import '../../../diaper/presentation/screens/diaper_screen.dart';
import '../../../growth/presentation/screens/growth_screen.dart';
import '../../../growth/presentation/widgets/growth_chart.dart';
import '../../../cry_analyzer/presentation/screens/cry_history_screen.dart';
import '../../../vaccination/presentation/screens/vaccination_screen.dart';
import '../../../milestones/presentation/screens/milestones_screen.dart';
import '../../domain/care_overview.dart';
import '../widgets/care_bar_chart.dart';
import 'care_pdf_preview.dart';

class TrackersScreen extends StatefulWidget {
  const TrackersScreen({super.key, this.api, this.onExport, this.onHistory});
  final Dio? api;
  final Future<void> Function(CareOverview)? onExport;
  final Future<void> Function(String, DateTimeRange)? onHistory;
  @override
  State<TrackersScreen> createState() => _OverviewState();
}

class _OverviewState extends State<TrackersScreen> {
  List<Map<String, dynamic>> _babies = [];
  Map<String, dynamic>? _baby;
  bool _loading = true, _updatingStore = false, _exporting = false;
  int _generation = 0;
  String? _error;
  String _period = 'Today';
  bool _showBottleVolume = false;
  late DateTimeRange _range;
  @override
  void initState() {
    super.initState();
    _range = _preset('Today');
    BabyProfileStore.changes.addListener(_changed);
    _load();
  }

  @override
  void dispose() {
    BabyProfileStore.changes.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (_updatingStore || !mounted) return;
    if (BabyProfileStore.id != _baby?['id']) {
      _load();
      return;
    }
    setState(() {
      _baby = Map<String, dynamic>.from(BabyProfileStore.data);
      _babies = BabyProfileStore.babies;
    });
  }

  DateTimeRange _preset(String value) {
    final now = DateUtils.dateOnly(DateTime.now());
    return DateTimeRange(
      start: value == 'Weekly'
          ? DateTime(now.year, now.month, now.day - 6)
          : value == 'Monthly'
          ? DateTime(now.year, now.month, 1)
          : now,
      end: now,
    );
  }

  Future<Dio> _client() async {
    if (widget.api != null) return widget.api!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in required');
    return careDio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
      ),
    );
  }

  Future<void> _load() async {
    final generation = ++_generation, id = BabyProfileStore.id;
    setState(() {
      _baby =
          BabyProfileStore.snapshotFor(id) ??
          (id == _baby?['id'] ? _baby : null);
      _babies = BabyProfileStore.babies;
      _loading = _baby == null;
      _error = null;
      if (_period != 'Custom') _range = _preset(_period);
    });
    try {
      final babies = await BabyApi(await _client()).list();
      if (!mounted || generation != _generation || BabyProfileStore.id != id)
        return;
      if (babies.isEmpty) {
        setState(() {
          _baby = null;
          _babies = [];
          _loading = false;
        });
        return;
      }
      final selected = babies.firstWhere(
        (r) => r['id'] == id,
        orElse: () => babies.first,
      );
      _updatingStore = true;
      BabyProfileStore.babies = babies;
      BabyProfileStore.select(selected);
      _updatingStore = false;
      setState(() {
        _babies = babies;
        _baby = Map<String, dynamic>.from(selected);
        _loading = false;
      });
    } catch (_) {
      if (mounted && generation == _generation)
        setState(() {
          _loading = false;
          _error = 'Could not refresh the care overview. Please retry.';
        });
    }
  }

  Future<void> _select(String period) async {
    if (period == 'Custom') {
      final selected = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDateRange: _range,
      );
      if (selected != null && mounted)
        setState(() {
          _range = selected;
          _period = period;
        });
    } else {
      setState(() {
        _period = period;
        _range = _preset(period);
      });
    }
  }

  Future<void> _history(String kind) async {
    if (_loading || _baby == null) return;
    if (widget.onHistory != null) {
      await widget.onHistory!(kind, _range);
      return;
    }
    final page = switch (kind) {
      'feeding' => FeedingScreen(
        historyOnly: true,
        api: widget.api,
        historyRange: _range,
      ),
      'sleep' => SleepScreen(
        historyOnly: true,
        api: widget.api,
        historyRange: _range,
      ),
      'diaper' => DiaperScreen(
        historyOnly: true,
        api: widget.api,
        historyRange: _range,
      ),
      'growth' => GrowthScreen(
        historyOnly: true,
        api: widget.api,
        historyRange: _range,
      ),
      'cry' => CryHistoryScreen(api: widget.api, historyRange: _range),
      'vaccinations' => VaccinationScreen(api: widget.api),
      _ => const MilestonesScreen(),
    };
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) await _load();
  }

  Future<void> _export(CareOverview report) async {
    setState(() => _exporting = true);
    try {
      // Freeze the current view; later profile/range changes do not change this PDF.
      if (widget.onExport != null) {
        await widget.onExport!(report);
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CarePdfPreview(report: report),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _date(DateTime at) =>
      MaterialLocalizations.of(context).formatMediumDate(at);
  Widget _section(
    String kind,
    String title,
    IconData icon,
    Color color,
    Widget content, {
    String? summary,
    int undated = 0,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .93),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: const Color(0xFFE9D9E7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF976987), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _history(kind),
              child: const Text('View history'),
            ),
          ],
        ),
        if (summary != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              summary,
              style: const TextStyle(fontSize: 13, color: Color(0xFF7C6375)),
            ),
          ),
        content,
        if (undated > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$undated date-missing older records excluded. View history to review.',
              style: const TextStyle(
                fontSize: 10,
                color: AuthPalette.textMuted,
              ),
            ),
          ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final report = _baby == null
        ? null
        : CareOverview(_baby!, _range.start, _range.end);
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
              child: RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Overview',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Refresh overview',
                                onPressed: _loading ? null : _load,
                                icon: const Icon(Icons.refresh_rounded),
                              ),
                            ],
                          ),
                          const Text(
                            'Your baby’s care, together in one place',
                            style: TextStyle(
                              fontSize: 13,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_babies.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                for (final baby in _babies)
                                  ChoiceChip(
                                    avatar: const Icon(
                                      Icons.child_care_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      baby['name'] as String? ?? 'Baby',
                                    ),
                                    selected: baby['id'] == _baby?['id'],
                                    onSelected: _loading || _exporting
                                        ? null
                                        : (_) {
                                            BabyProfileStore.select(baby);
                                          },
                                  ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final period in [
                                  'Today',
                                  'Weekly',
                                  'Monthly',
                                  'Custom',
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(period),
                                      showCheckmark: false,
                                      visualDensity: VisualDensity.compact,
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      selected: period == _period,
                                      onSelected: (_) => _select(period),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${_date(_range.start)} – ${_date(_range.end)} · inclusive',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: LinearProgressIndicator(),
                            ),
                          if (_error != null) ...[
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Retry'),
                            ),
                          ],
                          if (!_loading && report == null)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Create or select a baby profile to view care records.',
                              ),
                            ),
                          if (report != null) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed:
                                  _loading || _error != null || _exporting
                                  ? null
                                  : () => _export(report),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: Text(
                                _exporting
                                    ? 'Preparing PDF…'
                                    : 'Preview / export care PDF',
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Records help you review care—not diagnose growth or health. Export only what you choose to share.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AuthPalette.textMuted,
                                ),
                              ),
                            ),
                            _section(
                              'feeding',
                              'Feeding',
                              Icons.local_drink_outlined,
                              const Color(0xFFA9CEE8),
                              Column(
                                children: [
                                  SegmentedButton<bool>(
                                    segments: const [
                                      ButtonSegment(
                                        value: false,
                                        label: Text('Feed count'),
                                      ),
                                      ButtonSegment(
                                        value: true,
                                        label: Text('Bottle volume'),
                                      ),
                                    ],
                                    selected: {_showBottleVolume},
                                    showSelectedIcon: false,
                                    onSelectionChanged: (selection) =>
                                        setState(() {
                                          _showBottleVolume = selection.single;
                                        }),
                                  ),
                                  const SizedBox(height: 14),
                                  CareBarChart(
                                    series: report.series(
                                      _showBottleVolume ? 'bottle' : 'feeding',
                                    ),
                                  ),
                                ],
                              ),
                              summary: report.summary('feeding'),
                              undated: report.undated('feeding'),
                            ),
                            _section(
                              'sleep',
                              'Sleep',
                              Icons.bedtime_outlined,
                              const Color(0xFFD4C4ED),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CareBarChart(series: report.series('sleep')),
                                  if (report.activeSleep > 0)
                                    const Text(
                                      'A timer is running; only completed sleep is included.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AuthPalette.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                              summary: report.summary('sleep'),
                              undated: report.undated('sleep'),
                            ),
                            _section(
                              'diaper',
                              'Diaper',
                              Icons.child_friendly_outlined,
                              const Color(0xFFB1DCCB),
                              CareBarChart(series: report.series('diaper')),
                              summary: report.summary('diaper'),
                              undated: report.undated('diaper'),
                            ),
                            _section(
                              'growth',
                              'Growth',
                              Icons.straighten_rounded,
                              const Color(0xFFF4A1BE),
                              GrowthChart(
                                key: ValueKey(
                                  'overview_growth_${_baby!['id']}_${_range.start}_${_range.end}',
                                ),
                                rows: report.growth,
                              ),
                              summary: report.summary('growth'),
                              undated: report.undated('growth'),
                            ),
                            _section(
                              'cry',
                              'Cry recordings',
                              Icons.graphic_eq_rounded,
                              const Color(0xFFF4A1BE),
                              CareBarChart(series: report.series('cry')),
                              summary: report.summary('cry'),
                              undated: report.undated('cry'),
                            ),
                            _section(
                              'vaccinations',
                              'Vaccinations',
                              Icons.vaccines_outlined,
                              const Color(0xFFA9CEE8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${report.received.length} received · ${report.planned.length} suggested/planned in period',
                                  ),
                                  for (final r in report.received.take(3))
                                    ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.check_circle_outline,
                                        size: 20,
                                      ),
                                      title: Text(r['name'] as String),
                                      subtitle: Text(
                                        'Received: ${r['received_date']}',
                                      ),
                                    ),
                                  for (final r in report.planned.take(3))
                                    ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.event_outlined,
                                        size: 20,
                                      ),
                                      title: Text(r['name'] as String),
                                      subtitle: Text(
                                        'Suggested/planned: ${_date(DateTime.parse(r['due_date'] as String))}',
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Next dates after this period',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (report.upcoming.isEmpty)
                                    const Text(
                                      'No later suggested/planned doses in the saved schedule.',
                                    ),
                                  for (final r in report.upcoming)
                                    Text(
                                      '${r['name']} · ${_date(DateTime.parse(r['due_date'] as String))}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Confirm vaccination timing with your paediatrician. No automatic catch-up advice.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AuthPalette.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _section(
                              'milestones',
                              'Milestones',
                              Icons.workspace_premium_outlined,
                              const Color(0xFFB1DCCB),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${report.milestones.length} saved achievements',
                                  ),
                                  Text(
                                    report.milestoneScope,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AuthPalette.textMuted,
                                    ),
                                  ),
                                  const Text(
                                    'No invented stage-completion percentage.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AuthPalette.textMuted,
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }
}
