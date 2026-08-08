import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

enum _VaccineStatus { done, upcoming, pending }

extension _VaccineStatusX on _VaccineStatus {
  String get label => switch (this) {
        _VaccineStatus.done => 'Done',
        _VaccineStatus.upcoming => 'Upcoming',
        _VaccineStatus.pending => 'Pending',
      };

  Color get color => switch (this) {
        _VaccineStatus.done => AuthPalette.mint,
        _VaccineStatus.upcoming => AuthPalette.powderBlue,
        _VaccineStatus.pending => AuthPalette.blushPink,
      };

  IconData get icon => switch (this) {
        _VaccineStatus.done => Icons.check_circle_rounded,
        _VaccineStatus.upcoming => Icons.schedule_rounded,
        _VaccineStatus.pending => Icons.hourglass_empty_rounded,
      };
}

class _VaccineRecord {
  const _VaccineRecord({
    required this.name,
    required this.recommendedAge,
    required this.dateLabel,
    required this.status,
    required this.description,
    required this.protectsAgainst,
    required this.sideEffects,
    required this.doseNumber,
  });

  final String name;
  final String recommendedAge;
  final String dateLabel;
  final _VaccineStatus status;
  final String description;
  final String protectsAgainst;
  final String sideEffects;
  final String doseNumber;
}

/// Vaccination screen (SRS Section 10.10).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, Cry
/// Analyzer, and Baby Profile — the gradient backdrop, palette, and rounded
/// 28px card language come directly from `features/authentication/
/// presentation/widgets/` (read-only reuse; those files are not modified).
///
/// All immunisation data shown is realistic sample data for Lily (4 months
/// old). There is no backend, Firebase, or notifications integration yet —
/// Set Reminder and Add Vaccination surface a friendly "coming soon" toast.
class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;

  static const _babyName = 'Lily';

  static const _vaccines = <_VaccineRecord>[
    _VaccineRecord(
      name: 'BCG',
      recommendedAge: 'At birth',
      dateLabel: 'Given 15 Mar 2026',
      status: _VaccineStatus.done,
      description: 'A single shot given shortly after birth to build early protection against tuberculosis.',
      protectsAgainst: 'Tuberculosis (TB)',
      sideEffects: 'Small red bump at the injection site; a mild scar forms as it heals.',
      doseNumber: 'Dose 1 of 1',
    ),
    _VaccineRecord(
      name: 'Hepatitis B',
      recommendedAge: 'At birth',
      dateLabel: 'Given 15 Mar 2026',
      status: _VaccineStatus.done,
      description: 'Protects the liver from hepatitis B infection. This is the first of three doses.',
      protectsAgainst: 'Hepatitis B',
      sideEffects: 'Mild soreness at the injection site; rarely, a low-grade fever.',
      doseNumber: 'Dose 1 of 3',
    ),
    _VaccineRecord(
      name: 'DTP 1',
      recommendedAge: '6 weeks',
      dateLabel: 'Given 26 Apr 2026',
      status: _VaccineStatus.done,
      description: 'First dose of the combined vaccine protecting against three serious bacterial infections.',
      protectsAgainst: 'Diphtheria, Tetanus, Pertussis (Whooping Cough)',
      sideEffects: 'Mild fever, fussiness, or swelling at the injection site for a day or two.',
      doseNumber: 'Dose 1 of 3',
    ),
    _VaccineRecord(
      name: 'DTP 2',
      recommendedAge: '10 weeks',
      dateLabel: 'Due 5 Aug 2026',
      status: _VaccineStatus.upcoming,
      description: 'Second dose, boosting the immunity built by the first shot.',
      protectsAgainst: 'Diphtheria, Tetanus, Pertussis (Whooping Cough)',
      sideEffects: 'Similar to Dose 1 — mild fever and irritability are common.',
      doseNumber: 'Dose 2 of 3',
    ),
    _VaccineRecord(
      name: 'PCV 1',
      recommendedAge: '6 weeks',
      dateLabel: 'Due 12 Aug 2026',
      status: _VaccineStatus.pending,
      description: 'Pneumococcal conjugate vaccine protecting against serious bacterial infections.',
      protectsAgainst: 'Pneumonia, Meningitis, Ear infections',
      sideEffects: 'Redness or tenderness at the injection site; mild fussiness.',
      doseNumber: 'Dose 1 of 3',
    ),
    _VaccineRecord(
      name: 'Rotavirus 2',
      recommendedAge: '10 weeks',
      dateLabel: 'Due 19 Aug 2026',
      status: _VaccineStatus.pending,
      description: 'Oral drops that protect against severe rotavirus diarrhoea, a common cause of dehydration in infants.',
      protectsAgainst: 'Rotavirus (severe diarrhoea & vomiting)',
      sideEffects: 'Mild fussiness; rarely, mild diarrhoea for a day.',
      doseNumber: 'Dose 2 of 3',
    ),
    _VaccineRecord(
      name: 'MMR',
      recommendedAge: '9 months',
      dateLabel: 'Due 15 Dec 2026',
      status: _VaccineStatus.pending,
      description: 'Combined vaccine protecting against three common childhood viral infections.',
      protectsAgainst: 'Measles, Mumps, Rubella',
      sideEffects: 'Mild rash or low fever 1–2 weeks after the shot in some babies.',
      doseNumber: 'Dose 1 of 2',
    ),
  ];

  static const _nextAppointmentVaccine = 'DTP — Dose 2';
  static const _nextAppointmentDate = '5 August 2026';
  static const _nextAppointmentTime = '10:30 AM';
  static const _nextAppointmentPediatrician = 'Dr. Meera Nair';

  int get _doneCount => _vaccines.where((v) => v.status == _VaccineStatus.done).length;
  int get _totalCount => _vaccines.length;

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

  void _openVaccineDetails(_VaccineRecord vaccine) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VaccineDetailSheet(vaccine: vaccine),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _VaccinationFloatingDecor()),
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
                              child: _VaccinationHeaderCard(
                                babyName: _babyName,
                                doneCount: _doneCount,
                                totalCount: _totalCount,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Immunisation Timeline'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < _vaccines.length; i++) ...[
                                  if (i > 0) const _InfoDivider(),
                                  _VaccineTimelineItem(
                                    vaccine: _vaccines[i],
                                    onTap: () => _openVaccineDetails(_vaccines[i]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Next Appointment'),
                          const SizedBox(height: 10),
                          _NextAppointmentCard(
                            vaccineName: _nextAppointmentVaccine,
                            dateLabel: _nextAppointmentDate,
                            timeLabel: _nextAppointmentTime,
                            pediatrician: _nextAppointmentPediatrician,
                            onSetReminder: () => _showToast('Reminders are coming soon 🌙'),
                          ),
                          const SizedBox(height: 26),
                          AuthPrimaryButton(
                            label: 'Add Vaccination',
                            isLoading: false,
                            onPressed: () => _showToast('Add Vaccination is coming soon 🌙'),
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

/// Vaccination-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used by
/// Dashboard, Cry Analyzer, and Baby Profile, so no shared or sibling
/// screen file needs to change.
class _VaccinationFloatingDecor extends StatefulWidget {
  const _VaccinationFloatingDecor();

  @override
  State<_VaccinationFloatingDecor> createState() => _VaccinationFloatingDecorState();
}

class _VaccinationFloatingDecorState extends State<_VaccinationFloatingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.04, left: 0.10, size: 12, color: AuthPalette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.06, left: 0.86, size: 20, color: AuthPalette.powderBlue, phase: 0.4),
    _DecorSpec(icon: Icons.star_rounded, top: 0.20, left: 0.92, size: 10, color: AuthPalette.mint, phase: 0.25),
    _DecorSpec(icon: Icons.star_rounded, top: 0.28, left: 0.05, size: 11, color: AuthPalette.lavenderMist, phase: 0.6),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.55, left: 0.06, size: 16, color: AuthPalette.blushPink, phase: 0.15),
    _DecorSpec(icon: Icons.star_rounded, top: 0.72, left: 0.90, size: 12, color: AuthPalette.softCoral, phase: 0.5),
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

class _VaccinationHeaderCard extends StatelessWidget {
  const _VaccinationHeaderCard({required this.babyName, required this.doneCount, required this.totalCount});

  final String babyName;
  final int doneCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final remaining = totalCount - doneCount;
    final progress = totalCount == 0 ? 0.0 : doneCount / totalCount;

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
                child: const Icon(Icons.vaccines_rounded, color: AuthPalette.softCoral, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vaccinations',
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$babyName's immunisation record",
                      style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      '$doneCount of $totalCount completed',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$remaining remaining',
                      style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: AuthPalette.lavenderMist.withValues(alpha: 0.35),
                        valueColor: const AlwaysStoppedAnimation(AuthPalette.mint),
                      );
                    },
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _VaccineStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: AuthPalette.textDark),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
          ),
        ],
      ),
    );
  }
}

class _VaccineTimelineItem extends StatelessWidget {
  const _VaccineTimelineItem({required this.vaccine, required this.onTap});

  final _VaccineRecord vaccine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${vaccine.name}, ${vaccine.status.label}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: vaccine.status.color.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vaccines_outlined, size: 18, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccine.name,
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vaccine.recommendedAge} · ${vaccine.dateLabel}',
                      style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: vaccine.status),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AuthPalette.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({
    required this.vaccineName,
    required this.dateLabel,
    required this.timeLabel,
    required this.pediatrician,
    required this.onSetReminder,
  });

  final String vaccineName;
  final String dateLabel;
  final String timeLabel;
  final String pediatrician;
  final VoidCallback onSetReminder;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AuthPalette.powderBlue.withValues(alpha: 0.32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded, color: AuthPalette.textDark, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vaccineName,
                  style: GoogleFonts.quicksand(fontSize: 16.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AppointmentDetailRow(icon: Icons.calendar_today_outlined, label: dateLabel),
          const SizedBox(height: 8),
          _AppointmentDetailRow(icon: Icons.access_time_rounded, label: timeLabel),
          const SizedBox(height: 8),
          _AppointmentDetailRow(icon: Icons.medical_services_outlined, label: pediatrician),
          const SizedBox(height: 16),
          AuthOutlineButton(
            label: 'Set Reminder',
            icon: Icons.notifications_active_outlined,
            accent: AuthPalette.softCoral,
            isLoading: false,
            onPressed: onSetReminder,
          ),
        ],
      ),
    );
  }
}

class _AppointmentDetailRow extends StatelessWidget {
  const _AppointmentDetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AuthPalette.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 13, color: AuthPalette.textDark),
        ),
      ],
    );
  }
}

/// Pastel bottom sheet shown when a vaccine timeline item is tapped.
class _VaccineDetailSheet extends StatelessWidget {
  const _VaccineDetailSheet({required this.vaccine});

  final _VaccineRecord vaccine;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        decoration: BoxDecoration(
          color: AuthPalette.warmCream,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AuthPalette.softCoral.withValues(alpha: 0.18),
              blurRadius: 36,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AuthPalette.lavenderMist.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: vaccine.status.color.withValues(alpha: 0.32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.vaccines_rounded, color: AuthPalette.textDark, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccine.name,
                        style: GoogleFonts.quicksand(fontSize: 19, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${vaccine.recommendedAge} · ${vaccine.dateLabel}',
                        style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: vaccine.status),
              ],
            ),
            const SizedBox(height: 18),
            const _InfoDivider(),
            const SizedBox(height: 14),
            _DetailBlock(label: 'Description', value: vaccine.description),
            const SizedBox(height: 14),
            _DetailBlock(label: 'Protects Against', value: vaccine.protectsAgainst),
            const SizedBox(height: 14),
            _DetailBlock(label: 'Side Effects', value: vaccine.sideEffects),
            const SizedBox(height: 14),
            _DetailBlock(label: 'Dose', value: vaccine.doseNumber),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Got it',
              isLoading: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted, letterSpacing: 0.4),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(fontSize: 14, color: AuthPalette.textDark, height: 1.4),
        ),
      ],
    );
  }
}
