import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

enum _SleepType { nap, night }

extension _SleepTypeX on _SleepType {
  String get label => switch (this) {
        _SleepType.nap => 'Nap',
        _SleepType.night => 'Night',
      };

  IconData get icon => switch (this) {
        _SleepType.nap => Icons.wb_twilight_rounded,
        _SleepType.night => Icons.bedtime_rounded,
      };

  Color get color => switch (this) {
        _SleepType.nap => AuthPalette.powderBlue,
        _SleepType.night => AuthPalette.lavenderMist,
      };
}

class _SleepSession {
  const _SleepSession({
    required this.type,
    required this.durationLabel,
    required this.timeLabel,
  });

  final _SleepType type;
  final String durationLabel;
  final String timeLabel;
}

class _TimelineBlock {
  const _TimelineBlock({required this.start, required this.end, required this.type});

  final double start;
  final double end;
  final _SleepType type;
}

class _WeekPoint {
  const _WeekPoint({required this.label, required this.hours});

  final String label;
  final double hours;
}

/// Sleep Tracker screen (SRS Section 10.8).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, Cry
/// Analyzer, Baby Profile, Vaccination, Milestones, Gallery, and Feeding —
/// the gradient backdrop, palette, and rounded 28px card language come
/// directly from `features/authentication/presentation/widgets/`
/// (read-only reuse; those files are not modified).
///
/// All sleep data shown is realistic sample data for Lily, kept only in
/// local widget state for this session (including the live elapsed
/// timer). There is no backend, Firebase, or database integration.
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;
  late final AnimationController _pulseController;

  Timer? _tickTimer;
  bool _isSleeping = false;
  DateTime? _sleepStart;
  Duration _elapsed = Duration.zero;
  _SleepType _selectedType = _SleepType.nap;
  int _todaysTotalSleepMinutes = (13 * 60) + 20;

  static const _babyName = 'Lily';
  static const _avgBedtimeLabel = '8:05 PM';
  static const _longestNapLabel = '1h 30m • Afternoon nap';
  static const _nightAwakeningsLabel = '2 times last night';

  static const _timelineBlocks = <_TimelineBlock>[
    _TimelineBlock(start: 0.0, end: 0.25, type: _SleepType.night),
    _TimelineBlock(start: 0.375, end: 0.4375, type: _SleepType.nap),
    _TimelineBlock(start: 0.5208, end: 0.5833, type: _SleepType.nap),
    _TimelineBlock(start: 0.6875, end: 0.7188, type: _SleepType.nap),
    _TimelineBlock(start: 0.8333, end: 1.0, type: _SleepType.night),
  ];

  static const _weekTrend = <_WeekPoint>[
    _WeekPoint(label: 'Mon', hours: 12.5),
    _WeekPoint(label: 'Tue', hours: 13.0),
    _WeekPoint(label: 'Wed', hours: 11.8),
    _WeekPoint(label: 'Thu', hours: 13.5),
    _WeekPoint(label: 'Fri', hours: 12.0),
    _WeekPoint(label: 'Sat', hours: 13.8),
    _WeekPoint(label: 'Sun', hours: 13.2),
  ];

  final List<_SleepSession> _history = [
    _SleepSession(type: _SleepType.nap, durationLabel: '45m', timeLabel: '4:30 PM – 5:15 PM'),
    _SleepSession(type: _SleepType.nap, durationLabel: '1h 30m', timeLabel: '12:30 PM – 2:00 PM'),
    _SleepSession(type: _SleepType.nap, durationLabel: '1h 30m', timeLabel: '9:00 AM – 10:30 AM'),
    _SleepSession(type: _SleepType.night, durationLabel: '10h 0m', timeLabel: '8:00 PM – 6:00 AM'),
    _SleepSession(type: _SleepType.nap, durationLabel: '50m', timeLabel: '5:15 PM – 6:05 PM'),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
    _headerScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack)),
    );
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _tickTimer?.cancel();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AuthPalette.textDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            message,
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours <= 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  String _formatTimeOfDay(DateTime dt) => TimeOfDay.fromDateTime(dt).format(context);

  void _startSleep() {
    final now = DateTime.now();
    setState(() {
      _isSleeping = true;
      _sleepStart = now;
      _elapsed = Duration.zero;
    });
    _pulseController.repeat(reverse: true);
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _sleepStart == null) return;
      setState(() => _elapsed = DateTime.now().difference(_sleepStart!));
    });
    _showToast('${_selectedType.label} sleep started 🌙');
  }

  void _endSleep() {
    final start = _sleepStart;
    final duration = _elapsed;
    _tickTimer?.cancel();
    _pulseController
      ..stop()
      ..reset();
    setState(() {
      _isSleeping = false;
      if (start != null) {
        _history.insert(
          0,
          _SleepSession(
            type: _selectedType,
            durationLabel: _formatDuration(duration),
            timeLabel: '${_formatTimeOfDay(start)} – ${_formatTimeOfDay(DateTime.now())}',
          ),
        );
        _todaysTotalSleepMinutes += duration.inMinutes;
      }
      _sleepStart = null;
      _elapsed = Duration.zero;
    });
    _showToast('Sleep session saved 🌙');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _SleepFloatingDecor()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              AuthBackButton(onPressed: () => context.go(RoutePaths.dashboard)),
                              const Spacer(),
                            ],
                          ),
                          FadeTransition(
                            opacity: _headerFade,
                            child: ScaleTransition(
                              scale: _headerScale,
                              child: _SleepHeaderCard(
                                babyName: _babyName,
                                totalSleepLabel: _formatDuration(Duration(minutes: _todaysTotalSleepMinutes)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _NapNightSegmentedControl(
                            selected: _selectedType,
                            enabled: !_isSleeping,
                            onChanged: (type) => setState(() => _selectedType = type),
                          ),
                          const SizedBox(height: 16),
                          _SleepToggleButton(
                            isSleeping: _isSleeping,
                            pulseAnimation: _pulseController,
                            sleepType: _selectedType,
                            onPressed: _isSleeping ? _endSleep : _startSleep,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                            child: _isSleeping
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _CurrentSleepCard(
                                      startedAtLabel: _sleepStart == null ? '' : _formatTimeOfDay(_sleepStart!),
                                      elapsedLabel: _formatDuration(_elapsed),
                                      type: _selectedType,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: "Today's Sleep Timeline"),
                          const SizedBox(height: 10),
                          const _SleepTimelineCard(blocks: _timelineBlocks),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Sleep History'),
                          const SizedBox(height: 10),
                          if (_history.isEmpty)
                            _EmptySleepState(onStartFirstSession: _startSleep)
                          else
                            AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < math.min(5, _history.length); i++) ...[
                                    if (i > 0) const _InfoDivider(),
                                    _SleepHistoryRow(session: _history[i]),
                                  ],
                                ],
                              ),
                            ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Weekly Sleep Trend'),
                          const SizedBox(height: 10),
                          const _WeeklyTrendCard(points: _weekTrend),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Insights'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                _InsightRow(
                                  icon: Icons.wb_twilight_rounded,
                                  color: AuthPalette.softCoral,
                                  title: 'Average Bedtime',
                                  detail: _avgBedtimeLabel,
                                ),
                                _InsightRow(
                                  icon: Icons.hourglass_bottom_rounded,
                                  color: AuthPalette.mint,
                                  title: 'Longest Nap',
                                  detail: _longestNapLabel,
                                ),
                                _InsightRow(
                                  icon: Icons.visibility_rounded,
                                  color: AuthPalette.lavenderMist,
                                  title: 'Night Awakenings',
                                  detail: _nightAwakeningsLabel,
                                  isLast: true,
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
        ],
      ),
    );
  }
}

/// Sleep-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used by
/// Dashboard, Cry Analyzer, Baby Profile, Vaccination, Milestones,
/// Gallery, and Feeding, so no shared or sibling screen file needs to
/// change.
class _SleepFloatingDecor extends StatefulWidget {
  const _SleepFloatingDecor();

  @override
  State<_SleepFloatingDecor> createState() => _SleepFloatingDecorState();
}

class _SleepFloatingDecorState extends State<_SleepFloatingDecor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.03, left: 0.09, size: 12, color: AuthPalette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.05, left: 0.85, size: 20, color: AuthPalette.powderBlue, phase: 0.4),
    _DecorSpec(icon: Icons.star_rounded, top: 0.19, left: 0.91, size: 10, color: AuthPalette.mint, phase: 0.25),
    _DecorSpec(icon: Icons.star_rounded, top: 0.28, left: 0.05, size: 11, color: AuthPalette.lavenderMist, phase: 0.6),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.53, left: 0.07, size: 16, color: AuthPalette.blushPink, phase: 0.15),
    _DecorSpec(icon: Icons.star_rounded, top: 0.70, left: 0.91, size: 12, color: AuthPalette.softCoral, phase: 0.5),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final spec in _specs)
                Positioned(
                  top: constraints.maxHeight * spec.top,
                  left: constraints.maxWidth * spec.left,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final t = (math.sin((_controller.value + spec.phase) * math.pi * 2) + 1) / 2;
                      return Opacity(opacity: 0.07 + (t * 0.09), child: child);
                    },
                    child: Icon(spec.icon, size: spec.size, color: spec.color),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DecorSpec {
  const _DecorSpec({
    required this.icon,
    required this.top,
    required this.left,
    required this.size,
    required this.color,
    required this.phase,
  });

  final IconData icon;
  final double top;
  final double left;
  final double size;
  final Color color;
  final double phase;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: AuthPalette.lavenderMist.withValues(alpha: 0.4), height: 1);
  }
}

class _SleepHeaderCard extends StatelessWidget {
  const _SleepHeaderCard({required this.babyName, required this.totalSleepLabel});

  final String babyName;
  final String totalSleepLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AuthPalette.lavenderMist.withValues(alpha: 0.55),
            AuthPalette.blushPink.withValues(alpha: 0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.softCoral.withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AuthPalette.lavenderMist.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.85),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AuthPalette.softCoral.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.bedtime_rounded, color: AuthPalette.softCoral, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Tracker',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$babyName's sleep routine",
                      style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.nightlight_round, size: 18, color: AuthPalette.softCoral),
                const SizedBox(width: 10),
                Text(
                  "Today's total sleep",
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const Spacer(),
                Text(
                  totalSleepLabel,
                  style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NapNightSegmentedControl extends StatelessWidget {
  const _NapNightSegmentedControl({required this.selected, required this.enabled, required this.onChanged});

  final _SleepType selected;
  final bool enabled;
  final ValueChanged<_SleepType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            for (final type in _SleepType.values)
              Expanded(
                child: _SegmentButton(
                  type: type,
                  selected: type == selected,
                  onTap: enabled ? () => onChanged(type) : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.type, required this.selected, required this.onTap});

  final _SleepType type;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: type.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? type.color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.icon, size: 18, color: selected ? Colors.white : AuthPalette.textMuted),
                  const SizedBox(height: 3),
                  Text(
                    type.label,
                    style: GoogleFonts.nunito(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AuthPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepToggleButton extends StatelessWidget {
  const _SleepToggleButton({
    required this.isSleeping,
    required this.pulseAnimation,
    required this.sleepType,
    required this.onPressed,
  });

  final bool isSleeping;
  final Animation<double> pulseAnimation;
  final _SleepType sleepType;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = isSleeping
        ? const [AuthPalette.lavenderMist, Color(0xFF9E8FD6)]
        : [AuthPalette.softCoral, const Color(0xFFEF6FA0)];

    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSleeping)
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                final scale = 1.0 + (pulseAnimation.value * 0.06);
                final opacity = 0.35 * (1 - pulseAnimation.value);
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AuthPalette.lavenderMist,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
            ),
          Material(
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onPressed,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSleeping ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isSleeping ? 'End Sleep' : 'Start Sleep',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentSleepCard extends StatelessWidget {
  const _CurrentSleepCard({
    required this.startedAtLabel,
    required this.elapsedLabel,
    required this.type,
  });

  final String startedAtLabel;
  final String elapsedLabel;
  final _SleepType type;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Started at',
                  style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  startedAtLabel,
                  style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Elapsed',
                  style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  elapsedLabel,
                  style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.w800, color: AuthPalette.softCoral),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Type',
                  style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 12, color: AuthPalette.textDark),
                      const SizedBox(width: 4),
                      Text(
                        type.label,
                        style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepTimelineCard extends StatelessWidget {
  const _SleepTimelineCard({required this.blocks});

  final List<_TimelineBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowFraction = (now.hour * 60 + now.minute) / (24 * 60);

    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 32,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    children: [
                      Container(color: AuthPalette.blushPink.withValues(alpha: 0.25)),
                      for (final block in blocks)
                        Positioned(
                          left: width * block.start,
                          width: width * (block.end - block.start),
                          top: 0,
                          bottom: 0,
                          child: Container(color: block.type.color.withValues(alpha: 0.65)),
                        ),
                      Positioned(
                        left: (width * nowFraction).clamp(0, math.max(0.0, width - 2)),
                        top: 0,
                        bottom: 0,
                        child: Container(width: 2, color: AuthPalette.softCoral),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _timelineLabel('12a'),
              _timelineLabel('6a'),
              _timelineLabel('12p'),
              _timelineLabel('6p'),
              _timelineLabel('12a'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _LegendDot(color: _SleepType.nap.color, label: 'Nap'),
              const SizedBox(width: 18),
              _LegendDot(color: _SleepType.night.color, label: 'Night'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timelineLabel(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(fontSize: 10.5, color: AuthPalette.textMuted),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted)),
      ],
    );
  }
}

class _SleepHistoryRow extends StatelessWidget {
  const _SleepHistoryRow({required this.session});

  final _SleepSession session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: session.type.color.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(session.type.icon, size: 18, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.type.label,
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  session.timeLabel,
                  style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            session.durationLabel,
            style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.points});

  final List<_WeekPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxHours = points.map((p) => p.hours).reduce(math.max);

    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < points.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: points[i].hours / maxHours),
                      duration: Duration(milliseconds: 500 + (i * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) {
                        return FractionallySizedBox(
                          heightFactor: 0.14 + (t * 0.86),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [AuthPalette.lavenderMist, AuthPalette.powderBlue],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    points[i].label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 10.5, color: AuthPalette.textMuted),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    this.isLast = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14, top: 2),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
            ),
          ),
          Text(
            detail,
            style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EmptySleepState extends StatelessWidget {
  const _EmptySleepState({required this.onStartFirstSession});

  final VoidCallback onStartFirstSession;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        children: [
          SizedBox(
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AuthPalette.lavenderMist.withValues(alpha: 0.4),
                  ),
                ),
                const Icon(Icons.bedtime_rounded, color: AuthPalette.softCoral, size: 38),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No sleep sessions logged yet',
            style: GoogleFonts.quicksand(fontSize: 16.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            "Start tracking Lily's sleep to see her daily rhythm here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: 'Start First Sleep Session',
            isLoading: false,
            onPressed: onStartFirstSession,
          ),
        ],
      ),
    );
  }
}
