import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

enum _FeedingType { breastfeed, bottle, solids }

extension _FeedingTypeX on _FeedingType {
  String get label => switch (this) {
        _FeedingType.breastfeed => 'Breastfeed',
        _FeedingType.bottle => 'Bottle',
        _FeedingType.solids => 'Solids',
      };

  IconData get icon => switch (this) {
        _FeedingType.breastfeed => Icons.favorite_rounded,
        _FeedingType.bottle => Icons.local_drink_rounded,
        _FeedingType.solids => Icons.restaurant_rounded,
      };

  Color get color => switch (this) {
        _FeedingType.breastfeed => AuthPalette.softCoral,
        _FeedingType.bottle => AuthPalette.powderBlue,
        _FeedingType.solids => AuthPalette.mint,
      };
}

class _FeedingEntry {
  const _FeedingEntry({
    required this.type,
    required this.amountLabel,
    required this.durationLabel,
    required this.timeLabel,
  });

  final _FeedingType type;
  final String amountLabel;
  final String durationLabel;
  final String timeLabel;
}

/// Feeding Tracker screen (SRS Section 10.7).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, Cry
/// Analyzer, Baby Profile, Vaccination, Milestones, and Gallery — the
/// gradient backdrop, palette, and rounded 28px card language come
/// directly from `features/authentication/presentation/widgets/`
/// (read-only reuse; those files are not modified).
///
/// All feeding data shown is realistic sample data for Lily, kept only in
/// local widget state for this session. There is no backend, Firebase, or
/// database integration — Save Feeding and the reminder toggle surface
/// friendly local feedback only.
class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;

  final _amountController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  _FeedingType _selectedType = _FeedingType.bottle;
  TimeOfDay? _selectedTime;
  bool _reminderEnabled = true;

  static const _babyName = 'Lily';
  static const _todaysTotalMilkMl = 640;
  static const _nextFeedLabel = '4:30 PM • in 1h 45m';
  static const _lastFeedLabel = '2:30 PM • 1h 15m ago';
  static const _avgIntervalLabel = '2h 40m';
  static const _longestFeedLabel = '28 min • Breastfeed';
  static const _nightFeedsLabel = '2 feeds after 10 PM';

  static const _intakeChart = <_IntakePoint>[
    _IntakePoint(label: '6a', ml: 90),
    _IntakePoint(label: '9a', ml: 120),
    _IntakePoint(label: '12p', ml: 60),
    _IntakePoint(label: '3p', ml: 150),
    _IntakePoint(label: '6p', ml: 100),
    _IntakePoint(label: '9p', ml: 120),
  ];

  final List<_FeedingEntry> _history = [
    const _FeedingEntry(type: _FeedingType.bottle, amountLabel: '120 ml', durationLabel: '10 min', timeLabel: '2:30 PM'),
    const _FeedingEntry(type: _FeedingType.breastfeed, amountLabel: '—', durationLabel: '18 min', timeLabel: '11:45 AM'),
    const _FeedingEntry(type: _FeedingType.solids, amountLabel: '3 tbsp mashed banana', durationLabel: '12 min', timeLabel: '9:30 AM'),
    const _FeedingEntry(type: _FeedingType.bottle, amountLabel: '90 ml', durationLabel: '8 min', timeLabel: '6:15 AM'),
    const _FeedingEntry(type: _FeedingType.breastfeed, amountLabel: '—', durationLabel: '22 min', timeLabel: '2:10 AM'),
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
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _amountController.dispose();
    _durationController.dispose();
    _notesController.dispose();
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AuthPalette.softCoral,
              onPrimary: Colors.white,
              surface: AuthPalette.warmCream,
              onSurface: AuthPalette.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AuthPalette.softCoral),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedTime = picked);
  }

  void _handleSaveFeeding() {
    final amount = _amountController.text.trim();
    final duration = _durationController.text.trim();

    if (amount.isEmpty && duration.isEmpty) {
      _showToast('Add an amount or duration to save this feeding');
      return;
    }

    final timeLabel = _selectedTime?.format(context) ?? 'Just now';
    setState(() {
      _history.insert(
        0,
        _FeedingEntry(
          type: _selectedType,
          amountLabel: amount.isEmpty ? '—' : amount,
          durationLabel: duration.isEmpty ? '—' : (RegExp(r'^\d+$').hasMatch(duration) ? '$duration min' : duration),
          timeLabel: timeLabel,
        ),
      );
      _amountController.clear();
      _durationController.clear();
      _notesController.clear();
      _selectedTime = null;
    });
    _showToast('Feeding saved 🌙');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _FeedingFloatingDecor()),
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
                              child: const _FeedingHeaderCard(
                                babyName: _babyName,
                                totalMilkMl: _todaysTotalMilkMl,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _FeedingTypeSegmentedControl(
                            selected: _selectedType,
                            onChanged: (type) => setState(() => _selectedType = type),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Add Feeding'),
                          const SizedBox(height: 10),
                          _AddFeedingCard(
                            amountController: _amountController,
                            durationController: _durationController,
                            notesController: _notesController,
                            selectedTime: _selectedTime,
                            onPickTime: _pickTime,
                            onSave: _handleSaveFeeding,
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: "Today's Schedule"),
                          const SizedBox(height: 10),
                          _TodaysScheduleCard(
                            nextFeedLabel: _nextFeedLabel,
                            lastFeedLabel: _lastFeedLabel,
                            reminderEnabled: _reminderEnabled,
                            onReminderChanged: (value) {
                              setState(() => _reminderEnabled = value);
                              _showToast(value ? 'Feeding reminders turned on 🌙' : 'Feeding reminders turned off');
                            },
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Feeding History'),
                          const SizedBox(height: 10),
                          if (_history.isEmpty)
                            _EmptyFeedingState(
                              onLogFirstFeeding: () => _showToast('Log a feeding using the form above 🌙'),
                            )
                          else
                            AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < math.min(5, _history.length); i++) ...[
                                    if (i > 0) const _InfoDivider(),
                                    _FeedingHistoryRow(entry: _history[i]),
                                  ],
                                ],
                              ),
                            ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Daily Intake'),
                          const SizedBox(height: 10),
                          const _DailyIntakeCard(points: _intakeChart),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Insights'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                _InsightRow(
                                  icon: Icons.timelapse_rounded,
                                  color: AuthPalette.powderBlue,
                                  title: 'Average Interval',
                                  detail: _avgIntervalLabel,
                                ),
                                _InsightRow(
                                  icon: Icons.hourglass_bottom_rounded,
                                  color: AuthPalette.mint,
                                  title: 'Longest Feed',
                                  detail: _longestFeedLabel,
                                ),
                                _InsightRow(
                                  icon: Icons.nightlight_round,
                                  color: AuthPalette.lavenderMist,
                                  title: 'Night Feeds',
                                  detail: _nightFeedsLabel,
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

/// Feeding-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used by
/// Dashboard, Cry Analyzer, Baby Profile, Vaccination, Milestones, and
/// Gallery, so no shared or sibling screen file needs to change.
class _FeedingFloatingDecor extends StatefulWidget {
  const _FeedingFloatingDecor();

  @override
  State<_FeedingFloatingDecor> createState() => _FeedingFloatingDecorState();
}

class _FeedingFloatingDecorState extends State<_FeedingFloatingDecor> with SingleTickerProviderStateMixin {
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

class _FeedingHeaderCard extends StatelessWidget {
  const _FeedingHeaderCard({required this.babyName, required this.totalMilkMl});

  final String babyName;
  final int totalMilkMl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AuthPalette.blushPink.withValues(alpha: 0.55),
            AuthPalette.lavenderMist.withValues(alpha: 0.45),
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
                child: const Icon(Icons.local_drink_rounded, color: AuthPalette.softCoral, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feeding Tracker',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$babyName's feeding routine",
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
                const Icon(Icons.water_drop_rounded, size: 18, color: AuthPalette.softCoral),
                const SizedBox(width: 10),
                Text(
                  "Today's total milk",
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const Spacer(),
                Text(
                  '$totalMilkMl ml',
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

class _FeedingTypeSegmentedControl extends StatelessWidget {
  const _FeedingTypeSegmentedControl({required this.selected, required this.onChanged});

  final _FeedingType selected;
  final ValueChanged<_FeedingType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          for (final type in _FeedingType.values)
            Expanded(
              child: _SegmentButton(
                type: type,
                selected: type == selected,
                onTap: () => onChanged(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.type, required this.selected, required this.onTap});

  final _FeedingType type;
  final bool selected;
  final VoidCallback onTap;

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

class _AddFeedingCard extends StatelessWidget {
  const _AddFeedingCard({
    required this.amountController,
    required this.durationController,
    required this.notesController,
    required this.selectedTime,
    required this.onPickTime,
    required this.onSave,
  });

  final TextEditingController amountController;
  final TextEditingController durationController;
  final TextEditingController notesController;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickTime;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: amountController,
            label: 'Amount',
            hintText: 'e.g. 120 ml or 3 tbsp',
            prefixIcon: Icons.local_drink_outlined,
            validator: (_) => null,
            enabled: true,
          ),
          const SizedBox(height: 14),
          _TimePickerField(
            value: selectedTime?.format(context),
            onTap: onPickTime,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: durationController,
            label: 'Duration',
            hintText: 'e.g. 15 min',
            prefixIcon: Icons.timer_outlined,
            keyboardType: TextInputType.number,
            validator: (_) => null,
            enabled: true,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: notesController,
            maxLines: 3,
            style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
            cursorColor: AuthPalette.softCoral,
            decoration: authPastelDecoration(
              label: 'Notes',
              hint: 'Anything worth remembering? (optional)',
              prefixIcon: Icons.edit_note_rounded,
            ),
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(
            label: 'Save Feeding',
            isLoading: false,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({required this.value, required this.onTap});

  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: 'Time',
          hintText: 'Select a time',
          labelStyle: GoogleFonts.nunito(color: AuthPalette.textMuted, fontSize: 14),
          hintStyle: GoogleFonts.nunito(color: AuthPalette.textMuted.withValues(alpha: 0.6), fontSize: 14),
          prefixIcon: const Icon(Icons.access_time_rounded, color: AuthPalette.textMuted),
          suffixIcon: const Icon(Icons.expand_more_rounded, color: AuthPalette.textMuted),
          filled: true,
          fillColor: AuthPalette.blushPink.withValues(alpha: 0.28),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: AuthPalette.lavenderMist.withValues(alpha: 0.7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AuthPalette.softCoral, width: 2),
          ),
        ),
        child: Text(
          value ?? '',
          style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
        ),
      ),
    );
  }
}

class _TodaysScheduleCard extends StatelessWidget {
  const _TodaysScheduleCard({
    required this.nextFeedLabel,
    required this.lastFeedLabel,
    required this.reminderEnabled,
    required this.onReminderChanged,
  });

  final String nextFeedLabel;
  final String lastFeedLabel;
  final bool reminderEnabled;
  final ValueChanged<bool> onReminderChanged;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ScheduleRow(icon: Icons.schedule_rounded, color: AuthPalette.softCoral, title: 'Next Feed', detail: nextFeedLabel),
          const SizedBox(height: 14),
          _ScheduleRow(icon: Icons.history_rounded, color: AuthPalette.powderBlue, title: 'Last Feed', detail: lastFeedLabel),
          const SizedBox(height: 6),
          const _InfoDivider(),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AuthPalette.mint.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_active_outlined, size: 18, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Feeding Reminders',
                  style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ),
              Switch(
                value: reminderEnabled,
                onChanged: onReminderChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AuthPalette.softCoral,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AuthPalette.textMuted.withValues(alpha: 0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.icon, required this.color, required this.title, required this.detail});

  final IconData icon;
  final Color color;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: AuthPalette.textDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
              ),
              Text(
                detail,
                style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedingHistoryRow extends StatelessWidget {
  const _FeedingHistoryRow({required this.entry});

  final _FeedingEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: entry.type.color.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(entry.type.icon, size: 18, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type.label,
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.amountLabel} · ${entry.durationLabel}',
                  style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            entry.timeLabel,
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _IntakePoint {
  const _IntakePoint({required this.label, required this.ml});

  final String label;
  final double ml;
}

class _DailyIntakeCard extends StatelessWidget {
  const _DailyIntakeCard({required this.points});

  final List<_IntakePoint> points;

  @override
  Widget build(BuildContext context) {
    final maxMl = points.map((p) => p.ml).reduce(math.max);

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
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: points[i].ml / maxMl),
                      duration: Duration(milliseconds: 500 + (i * 120)),
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
                                colors: [AuthPalette.powderBlue, AuthPalette.mint],
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
                if (i > 0) const SizedBox(width: 10),
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

class _EmptyFeedingState extends StatelessWidget {
  const _EmptyFeedingState({required this.onLogFirstFeeding});

  final VoidCallback onLogFirstFeeding;

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
                    color: AuthPalette.powderBlue.withValues(alpha: 0.35),
                  ),
                ),
                const Icon(Icons.local_drink_rounded, color: AuthPalette.softCoral, size: 38),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No feedings logged yet',
            style: GoogleFonts.quicksand(fontSize: 16.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            "Log Lily's first feeding to start building her daily routine.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: 'Log First Feeding',
            isLoading: false,
            onPressed: onLogFirstFeeding,
          ),
        ],
      ),
    );
  }
}
