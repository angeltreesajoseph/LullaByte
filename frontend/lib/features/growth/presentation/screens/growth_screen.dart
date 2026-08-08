import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

class _Measurement {
  const _Measurement({
    required this.label,
    required this.date,
    required this.weightKg,
    required this.heightCm,
    required this.headCm,
  });

  final String label;
  final DateTime date;
  final double weightKg;
  final double heightCm;
  final double headCm;
}

const _monthNames = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatGrowthDate(DateTime date) => '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// Growth Tracker screen (SRS Section 10.14).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, Cry
/// Analyzer, Baby Profile, Vaccination, Milestones, Gallery, Feeding,
/// Sleep, and Diaper — the gradient backdrop, palette, and rounded 28px
/// card language come directly from `features/authentication/presentation/
/// widgets/` (read-only reuse; those files are not modified).
///
/// All growth data shown is realistic sample data for Lily, kept only in
/// local widget state for this session. There is no backend, Firebase, or
/// database integration. Percentiles are explicitly labeled as demo data,
/// not medical guidance.
class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  DateTime? _selectedDate;

  static const _babyName = 'Lily';
  static const _ageLabel = '4 months';
  static const _weightPercentile = 55;
  static const _heightPercentile = 60;
  static const _headPercentile = 52;
  static const _weeklyGainLabel = '+180 g this week';
  static const _monthlyGainLabel = '+0.5 kg this month';
  static const _consistencyLabel = 'Steady & on track';
  static const _pediatricianCheckLabel = 'Recommended in 2 weeks';

  late final List<_Measurement> _history = [
    _Measurement(label: '4 months', date: DateTime(2026, 7, 15), weightKg: 6.2, heightCm: 62, headCm: 40),
    _Measurement(label: '3 months', date: DateTime(2026, 6, 15), weightKg: 5.7, heightCm: 60, headCm: 39),
    _Measurement(label: '2 months', date: DateTime(2026, 5, 15), weightKg: 5.1, heightCm: 57, headCm: 38),
    _Measurement(label: '1 month', date: DateTime(2026, 4, 15), weightKg: 4.3, heightCm: 54, headCm: 36.5),
    _Measurement(label: '2 weeks', date: DateTime(2026, 3, 29), weightKg: 3.6, heightCm: 51, headCm: 35),
    _Measurement(label: 'Birth', date: DateTime(2026, 3, 15), weightKg: 3.2, heightCm: 49, headCm: 34),
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
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
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
    setState(() => _selectedDate = picked);
  }

  void _handleSaveMeasurement() {
    final latest = _history.isNotEmpty ? _history.first : null;
    final weight = double.tryParse(_weightController.text.trim()) ?? latest?.weightKg ?? 0.0;
    final height = double.tryParse(_heightController.text.trim()) ?? latest?.heightCm ?? 0.0;
    final head = double.tryParse(_headController.text.trim()) ?? latest?.headCm ?? 0.0;
    final date = _selectedDate ?? DateTime.now();

    setState(() {
      _history.insert(
        0,
        _Measurement(
          label: _formatGrowthDate(date),
          date: date,
          weightKg: weight,
          heightCm: height,
          headCm: head,
        ),
      );
      _weightController.clear();
      _heightController.clear();
      _headController.clear();
      _selectedDate = null;
    });
    _showToast('Measurement saved 🌙');
  }

  @override
  Widget build(BuildContext context) {
    final latest = _history.isNotEmpty ? _history.first : null;
    final chronological = _history.reversed.toList();
    final chartWindow = chronological.length > 6 ? chronological.sublist(chronological.length - 6) : chronological;

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _GrowthFloatingDecor()),
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
                              child: const _GrowthHeaderCard(babyName: _babyName, ageLabel: _ageLabel),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_history.isEmpty)
                            _EmptyGrowthState(onLogFirst: () {})
                          else ...[
                            const _SectionHeading(title: 'Current Measurements'),
                            const SizedBox(height: 10),
                            _CurrentMeasurementsCard(
                              weightLabel: '${latest!.weightKg.toStringAsFixed(1)} kg',
                              heightLabel: '${latest.heightCm.toStringAsFixed(0)} cm',
                              headLabel: '${latest.headCm.toStringAsFixed(1)} cm',
                              lastUpdatedLabel: 'Last updated ${_formatGrowthDate(latest.date)}',
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeading(title: 'Add Measurement'),
                            const SizedBox(height: 10),
                            _AddMeasurementCard(
                              weightController: _weightController,
                              heightController: _heightController,
                              headController: _headController,
                              selectedDate: _selectedDate,
                              onPickDate: _pickDate,
                              onSave: _handleSaveMeasurement,
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeading(title: 'Weight Growth Chart'),
                            const SizedBox(height: 10),
                            _LineChartCard(
                              title: 'Weight over time (kg)',
                              values: chartWindow.map((m) => m.weightKg).toList(),
                              labels: chartWindow.map((m) => m.label).toList(),
                              color: AuthPalette.softCoral,
                              height: 140,
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeading(title: 'Height Trend'),
                            const SizedBox(height: 10),
                            _BarChartCard(
                              values: chartWindow.map((m) => m.heightCm).toList(),
                              labels: chartWindow.map((m) => m.label).toList(),
                              colors: const [AuthPalette.powderBlue, AuthPalette.mint],
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeading(title: 'Head Circumference'),
                            const SizedBox(height: 10),
                            _LineChartCard(
                              title: 'Head circumference over time (cm)',
                              values: chartWindow.map((m) => m.headCm).toList(),
                              labels: chartWindow.map((m) => m.label).toList(),
                              color: AuthPalette.lavenderMist,
                              height: 80,
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeading(title: 'Growth Percentiles'),
                            const SizedBox(height: 10),
                            const _PercentileCard(
                              weightPercentile: _weightPercentile,
                              heightPercentile: _heightPercentile,
                              headPercentile: _headPercentile,
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeading(title: 'Measurement History'),
                            const SizedBox(height: 10),
                            AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < math.min(5, _history.length); i++) ...[
                                    if (i > 0) const _InfoDivider(),
                                    _MeasurementHistoryRow(measurement: _history[i]),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeading(title: 'Insights'),
                            const SizedBox(height: 10),
                            AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: const [
                                  _InsightRow(
                                    icon: Icons.trending_up_rounded,
                                    color: AuthPalette.softCoral,
                                    title: 'Weekly Gain',
                                    detail: _weeklyGainLabel,
                                  ),
                                  _InsightRow(
                                    icon: Icons.calendar_month_rounded,
                                    color: AuthPalette.powderBlue,
                                    title: 'Monthly Gain',
                                    detail: _monthlyGainLabel,
                                  ),
                                  _InsightRow(
                                    icon: Icons.timeline_rounded,
                                    color: AuthPalette.mint,
                                    title: 'Growth Consistency',
                                    detail: _consistencyLabel,
                                  ),
                                  _InsightRow(
                                    icon: Icons.medical_services_outlined,
                                    color: AuthPalette.lavenderMist,
                                    title: 'Pediatrician Check',
                                    detail: _pediatricianCheckLabel,
                                    isLast: true,
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
          ),
        ],
      ),
    );
  }
}

/// Growth-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used by
/// Dashboard, Cry Analyzer, Baby Profile, Vaccination, Milestones,
/// Gallery, Feeding, Sleep, and Diaper, so no shared or sibling screen
/// file needs to change.
class _GrowthFloatingDecor extends StatefulWidget {
  const _GrowthFloatingDecor();

  @override
  State<_GrowthFloatingDecor> createState() => _GrowthFloatingDecorState();
}

class _GrowthFloatingDecorState extends State<_GrowthFloatingDecor> with SingleTickerProviderStateMixin {
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

class _GrowthHeaderCard extends StatelessWidget {
  const _GrowthHeaderCard({required this.babyName, required this.ageLabel});

  final String babyName;
  final String ageLabel;

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
      child: Row(
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
            child: const Icon(Icons.show_chart_rounded, color: AuthPalette.softCoral, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth Tracker',
                  style: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  "$babyName's healthy growth journey",
                  style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cake_outlined, size: 13, color: AuthPalette.textDark),
                      const SizedBox(width: 5),
                      Text(
                        'Age: $ageLabel',
                        style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
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

class _CurrentMeasurementsCard extends StatelessWidget {
  const _CurrentMeasurementsCard({
    required this.weightLabel,
    required this.heightLabel,
    required this.headLabel,
    required this.lastUpdatedLabel,
  });

  final String weightLabel;
  final String heightLabel;
  final String headLabel;
  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _StatBlock(icon: Icons.monitor_weight_outlined, label: 'Weight', value: weightLabel)),
              _statDivider(),
              Expanded(child: _StatBlock(icon: Icons.straighten_outlined, label: 'Height', value: heightLabel)),
              _statDivider(),
              Expanded(child: _StatBlock(icon: Icons.circle_outlined, label: 'Head', value: headLabel)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.event_available_outlined, size: 15, color: AuthPalette.textMuted),
              const SizedBox(width: 6),
              Text(
                lastUpdatedLabel,
                style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AuthPalette.softCoral),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 10.5, color: AuthPalette.textMuted),
        ),
      ],
    );
  }
}

class _AddMeasurementCard extends StatelessWidget {
  const _AddMeasurementCard({
    required this.weightController,
    required this.heightController,
    required this.headController,
    required this.selectedDate,
    required this.onPickDate,
    required this.onSave,
  });

  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController headController;
  final DateTime? selectedDate;
  final VoidCallback onPickDate;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  controller: weightController,
                  label: 'Weight (kg)',
                  hintText: 'e.g. 6.5',
                  prefixIcon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (_) => null,
                  enabled: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AuthTextField(
                  controller: heightController,
                  label: 'Height (cm)',
                  hintText: 'e.g. 63',
                  prefixIcon: Icons.straighten_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (_) => null,
                  enabled: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: headController,
            label: 'Head Circumference (cm)',
            hintText: 'e.g. 41',
            prefixIcon: Icons.circle_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (_) => null,
            enabled: true,
          ),
          const SizedBox(height: 14),
          _DatePickerField(
            label: 'Date',
            value: selectedDate == null ? null : _formatGrowthDate(selectedDate!),
            onTap: onPickDate,
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(
            label: 'Save Measurement',
            isLoading: false,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.label, required this.value, required this.onTap});

  final String label;
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
          labelText: label,
          hintText: 'Defaults to today',
          labelStyle: GoogleFonts.nunito(color: AuthPalette.textMuted, fontSize: 14),
          hintStyle: GoogleFonts.nunito(color: AuthPalette.textMuted.withValues(alpha: 0.6), fontSize: 13),
          prefixIcon: const Icon(Icons.calendar_today_outlined, color: AuthPalette.textMuted),
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

/// Animated pastel line chart used for the Weight and Head Circumference
/// cards. Points animate upward from the baseline on first build.
class _LineChartCard extends StatelessWidget {
  const _LineChartCard({
    required this.title,
    required this.values,
    required this.labels,
    required this.color,
    required this.height,
  });

  final String title;
  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: height,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) {
                return CustomPaint(
                  painter: _LineChartPainter(values: values, progress: t, color: color),
                  size: Size.infinite,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 9.5, color: AuthPalette.textMuted),
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

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.progress, required this.color});

  final List<double> values;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).clamp(0.1, double.infinity);

    const topPadding = 16.0;
    const bottomPadding = 4.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final baseline = topPadding + chartHeight;

    final gridPaint = Paint()
      ..color = AuthPalette.lavenderMist.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = topPadding + chartHeight * (i / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? size.width / 2 : size.width * (i / (values.length - 1));
      final normalized = (values[i] - minValue) / range;
      final finalY = topPadding + chartHeight * (1 - normalized);
      final animatedY = baseline + (finalY - baseline) * progress;
      points.add(Offset(x, animatedY));
    }

    if (points.length > 1) {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    final pointFillPaint = Paint()..color = Colors.white;
    final pointBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (final p in points) {
      canvas.drawCircle(p, 5, pointFillPaint);
      canvas.drawCircle(p, 5, pointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.values, required this.labels, required this.colors});

  final List<double> values;
  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).clamp(0.1, double.infinity);

    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: (values[i] - minValue) / range),
                      duration: Duration(milliseconds: 500 + (i * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) {
                        return FractionallySizedBox(
                          heightFactor: 0.16 + (t * 0.84),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: colors,
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
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 9.5, color: AuthPalette.textMuted),
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

class _PercentileCard extends StatelessWidget {
  const _PercentileCard({
    required this.weightPercentile,
    required this.heightPercentile,
    required this.headPercentile,
  });

  final int weightPercentile;
  final int heightPercentile;
  final int headPercentile;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PercentileRow(label: 'Weight-for-age', percentile: weightPercentile, color: AuthPalette.softCoral),
          const SizedBox(height: 16),
          _PercentileRow(label: 'Height-for-age', percentile: heightPercentile, color: AuthPalette.powderBlue),
          const SizedBox(height: 16),
          _PercentileRow(label: 'Head circumference', percentile: headPercentile, color: AuthPalette.mint),
          const SizedBox(height: 18),
          _InfoBanner(
            message: 'This is demo data only, not medical advice. Always check with your pediatrician for a '
                "personalized assessment of Lily's growth.",
          ),
        ],
      ),
    );
  }
}

class _PercentileRow extends StatelessWidget {
  const _PercentileRow({required this.label, required this.percentile, required this.color});

  final String label;
  final int percentile;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
              ),
            ),
            Text(
              '${percentile}th percentile',
              style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentile / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AuthPalette.lavenderMist.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(color),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AuthPalette.powderBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuthPalette.powderBlue.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AuthPalette.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementHistoryRow extends StatelessWidget {
  const _MeasurementHistoryRow({required this.measurement});

  final _Measurement measurement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AuthPalette.mint.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: const Icon(Icons.event_note_rounded, size: 18, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatGrowthDate(measurement.date),
                  style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  'Weight ${measurement.weightKg.toStringAsFixed(1)} kg · '
                  'Height ${measurement.heightCm.toStringAsFixed(0)} cm · '
                  'Head ${measurement.headCm.toStringAsFixed(1)} cm',
                  style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted),
                ),
              ],
            ),
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

class _EmptyGrowthState extends StatelessWidget {
  const _EmptyGrowthState({required this.onLogFirst});

  final VoidCallback onLogFirst;

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
                const Icon(Icons.show_chart_rounded, color: AuthPalette.softCoral, size: 38),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No measurements logged yet',
            style: GoogleFonts.quicksand(fontSize: 16.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            "Log Lily's first measurement to start tracking her growth journey.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: 'Log First Measurement',
            isLoading: false,
            onPressed: onLogFirst,
          ),
        ],
      ),
    );
  }
}
