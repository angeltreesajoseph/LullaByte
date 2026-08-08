import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

enum _DiaperType { wet, dirty, mixed }

extension _DiaperTypeX on _DiaperType {
  String get label => switch (this) {
        _DiaperType.wet => 'Wet',
        _DiaperType.dirty => 'Dirty',
        _DiaperType.mixed => 'Mixed',
      };

  IconData get icon => switch (this) {
        _DiaperType.wet => Icons.water_drop_rounded,
        _DiaperType.dirty => Icons.eco_rounded,
        _DiaperType.mixed => Icons.change_circle_rounded,
      };

  Color get color => switch (this) {
        _DiaperType.wet => AuthPalette.powderBlue,
        _DiaperType.dirty => AuthPalette.softCoral,
        _DiaperType.mixed => AuthPalette.lavenderMist,
      };
}

class _DiaperEntry {
  _DiaperEntry({
    required this.type,
    required this.color,
    required this.timestamp,
    this.notes = '',
  });

  final _DiaperType type;
  final String color;
  final DateTime timestamp;
  final String notes;
}

class _WeekDiaperPoint {
  const _WeekDiaperPoint({required this.label, required this.wetCount, required this.dirtyCount});

  final String label;
  final int wetCount;
  final int dirtyCount;
}

/// Diaper Tracker screen (SRS Section 10.9).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, Cry
/// Analyzer, Baby Profile, Vaccination, Milestones, Gallery, Feeding, and
/// Sleep — the gradient backdrop, palette, and rounded 28px card language
/// come directly from `features/authentication/presentation/widgets/`
/// (read-only reuse; those files are not modified).
///
/// All diaper data shown is realistic sample data for Lily, kept only in
/// local widget state for this session. There is no backend, Firebase, or
/// database integration.
class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;

  final _notesController = TextEditingController();

  _DiaperType _formType = _DiaperType.wet;
  String _formColor = 'Yellow';
  TimeOfDay? _formTime;

  static const _babyName = 'Lily';
  static const _colorOptions = <String>['Yellow', 'Brown', 'Green', 'Other'];
  static const _avgChangesPerDayLabel = '6 per day';
  static const _longestDryIntervalLabel = '5h 30m • Overnight';
  static const _mostCommonTypeLabel = 'Wet (60%)';

  static const _weekPattern = <_WeekDiaperPoint>[
    _WeekDiaperPoint(label: 'Mon', wetCount: 5, dirtyCount: 2),
    _WeekDiaperPoint(label: 'Tue', wetCount: 6, dirtyCount: 3),
    _WeekDiaperPoint(label: 'Wed', wetCount: 4, dirtyCount: 2),
    _WeekDiaperPoint(label: 'Thu', wetCount: 5, dirtyCount: 3),
    _WeekDiaperPoint(label: 'Fri', wetCount: 6, dirtyCount: 2),
    _WeekDiaperPoint(label: 'Sat', wetCount: 5, dirtyCount: 4),
    _WeekDiaperPoint(label: 'Sun', wetCount: 4, dirtyCount: 2),
  ];

  late final List<_DiaperEntry> _history = [
    _DiaperEntry(type: _DiaperType.wet, color: 'Yellow', timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
    _DiaperEntry(
      type: _DiaperType.dirty,
      color: 'Brown',
      timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
      notes: 'Slightly loose',
    ),
    _DiaperEntry(type: _DiaperType.wet, color: 'Yellow', timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 55))),
    _DiaperEntry(
      type: _DiaperType.mixed,
      color: 'Brown',
      timestamp: DateTime.now().subtract(const Duration(hours: 8, minutes: 30)),
      notes: 'After feeding',
    ),
    _DiaperEntry(type: _DiaperType.wet, color: 'Yellow', timestamp: DateTime.now().subtract(const Duration(hours: 11, minutes: 10))),
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

  String _formatElapsed(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours <= 0) return '${minutes}m ago';
    return '${hours}h ${minutes}m ago';
  }

  void _quickAdd(_DiaperType type) {
    setState(() {
      _history.insert(
        0,
        _DiaperEntry(
          type: type,
          color: type == _DiaperType.dirty || type == _DiaperType.mixed ? 'Brown' : 'Yellow',
          timestamp: DateTime.now(),
        ),
      );
    });
    _showToast('${type.label} diaper logged 🌙');
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _formTime ?? TimeOfDay.now(),
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
    setState(() => _formTime = picked);
  }

  void _handleSaveChange() {
    final now = DateTime.now();
    final timestamp = _formTime == null
        ? now
        : DateTime(now.year, now.month, now.day, _formTime!.hour, _formTime!.minute);
    setState(() {
      _history.insert(
        0,
        _DiaperEntry(
          type: _formType,
          color: _formColor,
          timestamp: timestamp,
          notes: _notesController.text.trim(),
        ),
      );
      _notesController.clear();
      _formTime = null;
    });
    _showToast('Diaper change saved 🌙');
  }

  @override
  Widget build(BuildContext context) {
    final lastChange = _history.isEmpty ? null : _history.first;
    final suggestedNext = lastChange?.timestamp.add(const Duration(hours: 2));

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _DiaperFloatingDecor()),
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
                              child: _DiaperHeaderCard(
                                babyName: _babyName,
                                totalChanges: _history.length,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _QuickAddRow(onQuickAdd: _quickAdd),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Add Diaper'),
                          const SizedBox(height: 10),
                          _AddDiaperCard(
                            selectedType: _formType,
                            onTypeChanged: (type) => setState(() => _formType = type),
                            selectedColor: _formColor,
                            colorOptions: _colorOptions,
                            onColorChanged: (color) => setState(() => _formColor = color),
                            selectedTime: _formTime,
                            onPickTime: _pickTime,
                            notesController: _notesController,
                            onSave: _handleSaveChange,
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Current Status'),
                          const SizedBox(height: 10),
                          _CurrentStatusCard(
                            lastChangeLabel: lastChange == null ? '—' : TimeOfDay.fromDateTime(lastChange.timestamp).format(context),
                            timeSinceLabel: lastChange == null ? '—' : _formatElapsed(DateTime.now().difference(lastChange.timestamp)),
                            suggestedNextLabel: suggestedNext == null ? '—' : TimeOfDay.fromDateTime(suggestedNext).format(context),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: "Today's Timeline"),
                          const SizedBox(height: 10),
                          if (_history.isEmpty)
                            _EmptyDiaperState(onLogFirstChange: () => _quickAdd(_DiaperType.wet))
                          else
                            AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < _history.length; i++)
                                    _DiaperTimelineTile(
                                      entry: _history[i],
                                      isLast: i == _history.length - 1,
                                    ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Diaper History'),
                          const SizedBox(height: 10),
                          if (_history.isNotEmpty)
                            AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < math.min(5, _history.length); i++) ...[
                                    if (i > 0) const _InfoDivider(),
                                    _DiaperHistoryRow(entry: _history[i]),
                                  ],
                                ],
                              ),
                            ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Weekly Pattern'),
                          const SizedBox(height: 10),
                          const _WeeklyPatternCard(points: _weekPattern),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Insights'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                _InsightRow(
                                  icon: Icons.calendar_today_rounded,
                                  color: AuthPalette.powderBlue,
                                  title: 'Average Changes',
                                  detail: _avgChangesPerDayLabel,
                                ),
                                _InsightRow(
                                  icon: Icons.nightlight_round,
                                  color: AuthPalette.lavenderMist,
                                  title: 'Longest Dry Interval',
                                  detail: _longestDryIntervalLabel,
                                ),
                                _InsightRow(
                                  icon: Icons.pie_chart_rounded,
                                  color: AuthPalette.mint,
                                  title: 'Most Common Type',
                                  detail: _mostCommonTypeLabel,
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

/// Diaper-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used by
/// Dashboard, Cry Analyzer, Baby Profile, Vaccination, Milestones,
/// Gallery, Feeding, and Sleep, so no shared or sibling screen file needs
/// to change.
class _DiaperFloatingDecor extends StatefulWidget {
  const _DiaperFloatingDecor();

  @override
  State<_DiaperFloatingDecor> createState() => _DiaperFloatingDecorState();
}

class _DiaperFloatingDecorState extends State<_DiaperFloatingDecor> with SingleTickerProviderStateMixin {
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

class _DiaperHeaderCard extends StatelessWidget {
  const _DiaperHeaderCard({required this.babyName, required this.totalChanges});

  final String babyName;
  final int totalChanges;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AuthPalette.mint.withValues(alpha: 0.5),
            AuthPalette.powderBlue.withValues(alpha: 0.45),
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
                child: const Icon(Icons.child_care_rounded, color: AuthPalette.softCoral, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diaper Tracker',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$babyName's diaper routine",
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
                const Icon(Icons.check_circle_rounded, size: 18, color: AuthPalette.softCoral),
                const SizedBox(width: 10),
                Text(
                  "Today's total changes",
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const Spacer(),
                Text(
                  '$totalChanges changes',
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

class _QuickAddRow extends StatelessWidget {
  const _QuickAddRow({required this.onQuickAdd});

  final ValueChanged<_DiaperType> onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final type in _DiaperType.values) ...[
          if (type != _DiaperType.values.first) const SizedBox(width: 10),
          Expanded(child: _QuickAddButton(type: type, onTap: () => onQuickAdd(type))),
        ],
      ],
    );
  }
}

class _QuickAddButton extends StatefulWidget {
  const _QuickAddButton({required this.type, required this.onTap});

  final _DiaperType type;
  final VoidCallback onTap;

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Quick add ${widget.type.label} diaper',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: widget.type.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.type.color.withValues(alpha: 0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.type.icon, size: 20, color: AuthPalette.textDark),
                const SizedBox(height: 4),
                Text(
                  widget.type.label,
                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddDiaperCard extends StatelessWidget {
  const _AddDiaperCard({
    required this.selectedType,
    required this.onTypeChanged,
    required this.selectedColor,
    required this.colorOptions,
    required this.onColorChanged,
    required this.selectedTime,
    required this.onPickTime,
    required this.notesController,
    required this.onSave,
  });

  final _DiaperType selectedType;
  final ValueChanged<_DiaperType> onTypeChanged;
  final String selectedColor;
  final List<String> colorOptions;
  final ValueChanged<String> onColorChanged;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickTime;
  final TextEditingController notesController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Type',
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 8),
          _TypeSegmentedControl(selected: selectedType, onChanged: onTypeChanged),
          const SizedBox(height: 16),
          _TimePickerField(value: selectedTime?.format(context), onTap: onPickTime),
          const SizedBox(height: 16),
          Text(
            'Color',
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedColor,
            icon: const Icon(Icons.expand_more_rounded, color: AuthPalette.textMuted),
            style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
            decoration: authPastelDecoration(
              label: '',
              hint: 'Select a color',
              prefixIcon: Icons.palette_outlined,
            ),
            items: [
              for (final color in colorOptions) DropdownMenuItem(value: color, child: Text(color)),
            ],
            onChanged: (value) {
              if (value != null) onColorChanged(value);
            },
          ),
          const SizedBox(height: 16),
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
            label: 'Save Change',
            isLoading: false,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _TypeSegmentedControl extends StatelessWidget {
  const _TypeSegmentedControl({required this.selected, required this.onChanged});

  final _DiaperType selected;
  final ValueChanged<_DiaperType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AuthPalette.blushPink.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          for (final type in _DiaperType.values)
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

  final _DiaperType type;
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
          hintText: 'Select a time (defaults to now)',
          labelStyle: GoogleFonts.nunito(color: AuthPalette.textMuted, fontSize: 14),
          hintStyle: GoogleFonts.nunito(color: AuthPalette.textMuted.withValues(alpha: 0.6), fontSize: 13),
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

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({
    required this.lastChangeLabel,
    required this.timeSinceLabel,
    required this.suggestedNextLabel,
  });

  final String lastChangeLabel;
  final String timeSinceLabel;
  final String suggestedNextLabel;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Row(
        children: [
          Expanded(
            child: _StatusStat(icon: Icons.history_rounded, label: 'Last Change', value: lastChangeLabel),
          ),
          _statDivider(),
          Expanded(
            child: _StatusStat(icon: Icons.timelapse_rounded, label: 'Time Since', value: timeSinceLabel),
          ),
          _statDivider(),
          Expanded(
            child: _StatusStat(icon: Icons.event_available_rounded, label: 'Next Check', value: suggestedNextLabel),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
    );
  }
}

class _StatusStat extends StatelessWidget {
  const _StatusStat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AuthPalette.softCoral),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(fontSize: 13.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 10.5, color: AuthPalette.textMuted),
        ),
      ],
    );
  }
}

class _DiaperTimelineTile extends StatelessWidget {
  const _DiaperTimelineTile({required this.entry, required this.isLast});

  final _DiaperEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: entry.type.color.withValues(alpha: 0.32), shape: BoxShape.circle),
                child: Icon(entry.type.icon, size: 16, color: AuthPalette.textDark),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AuthPalette.lavenderMist.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.type.label,
                      style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                    ),
                  ),
                  Text(
                    TimeOfDay.fromDateTime(entry.timestamp).format(context),
                    style: GoogleFonts.nunito(fontSize: 11, color: AuthPalette.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaperHistoryRow extends StatelessWidget {
  const _DiaperHistoryRow({required this.entry});

  final _DiaperEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Text(
                      entry.type.label,
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AuthPalette.lavenderMist.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        entry.color,
                        style: GoogleFonts.nunito(fontSize: 10.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                      ),
                    ),
                  ],
                ),
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            TimeOfDay.fromDateTime(entry.timestamp).format(context),
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _WeeklyPatternCard extends StatelessWidget {
  const _WeeklyPatternCard({required this.points});

  final List<_WeekDiaperPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxTotal = points.map((p) => p.wetCount + p.dirtyCount).reduce(math.max);

    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < points.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: (points[i].wetCount + points[i].dirtyCount) / maxTotal),
                      duration: Duration(milliseconds: 500 + (i * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) {
                        final total = points[i].wetCount + points[i].dirtyCount;
                        final dirtyFraction = total == 0 ? 0.0 : points[i].dirtyCount / total;
                        return FractionallySizedBox(
                          heightFactor: 0.1 + (t * 0.9),
                          alignment: Alignment.bottomCenter,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: ((1 - dirtyFraction) * 100).round().clamp(1, 100),
                                  child: Container(color: AuthPalette.powderBlue),
                                ),
                                Expanded(
                                  flex: (dirtyFraction * 100).round().clamp(1, 100),
                                  child: Container(color: AuthPalette.softCoral),
                                ),
                              ],
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
          const SizedBox(height: 14),
          Row(
            children: [
              _LegendDot(color: AuthPalette.powderBlue, label: 'Wet'),
              const SizedBox(width: 18),
              _LegendDot(color: AuthPalette.softCoral, label: 'Dirty'),
            ],
          ),
        ],
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

class _EmptyDiaperState extends StatelessWidget {
  const _EmptyDiaperState({required this.onLogFirstChange});

  final VoidCallback onLogFirstChange;

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
                    color: AuthPalette.mint.withValues(alpha: 0.35),
                  ),
                ),
                const Icon(Icons.child_care_rounded, color: AuthPalette.softCoral, size: 38),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No diaper changes logged yet',
            style: GoogleFonts.quicksand(fontSize: 16.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            "Log Lily's first diaper change to start tracking her routine.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: 'Log First Change',
            isLoading: false,
            onPressed: onLogFirstChange,
          ),
        ],
      ),
    );
  }
}
