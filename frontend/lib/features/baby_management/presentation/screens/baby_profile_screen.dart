import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

/// Baby Profile screen (SRS Section 10.13).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, and Cry
/// Analyzer — the gradient backdrop, palette, and rounded 28px card
/// language come directly from `features/authentication/presentation/
/// widgets/` (read-only reuse; those files are not modified).
///
/// Every value shown is realistic sample data. There is no backend or
/// state-management integration yet — Edit Profile opens a real (local
/// state only) edit form; Share Profile, Export PDF, and Open Memories
/// all surface a friendly "coming soon" toast.
class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _avatarFade;
  late final Animation<double> _avatarScale;

  // Realistic sample data — no backend/state-management wiring yet.
  static const _babyName = 'Lily Johnson';
  static const _ageLabel = '4 months old';
  static const _bornLabel = 'Born 15 March 2026';
  static final _dateOfBirth = DateTime(2026, 3, 15);
  static const _healthStatus = 'Healthy';
  static const _parentName = 'Angel Joseph';
  static const _weight = '6.2 kg';
  static const _height = '62 cm';
  static const _headCircumference = '40 cm';
  static const _gender = 'Girl';
  static const _bloodGroup = 'O+';
  static const _allergies = 'None known';
  static const _pediatrician = 'Dr. Meera Nair';
  static const _hospital = "Sunrise Children's Hospital";
  static const _weightTrend = [5.4, 5.7, 5.9, 6.0, 6.2];
  static const _heightTrend = [54.0, 56.5, 58.0, 60.0, 62.0];
  static const _lastUpdatedLabel = 'Last updated 5 days ago';
  static const _avgSleep = '13h 20m';
  static const _feedingsToday = '7';
  static const _diapersToday = '5';
  static const _criesAnalyzed = '3';
  static const _upcomingVaccine = 'DTaP • in 12 days';
  static const _lastCheckup = '2 weeks ago • Dr. Meera Nair';
  static const _medications = 'Vitamin D drops • Daily';

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
    _avatarFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
    _avatarScale = Tween<double>(begin: 0.8, end: 1.0).animate(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _ProfileFloatingDecor()),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Baby Profile',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: AuthPalette.textDark,
                                    ),
                                  ),
                                ),
                                _CircleIconButton(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit profile',
                                  // rootNavigator: true escapes this tab's branch
                                  // Navigator so Edit Profile renders full-screen,
                                  // outside MainNavigationShell's persistent bottom bar.
                                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                      builder: (context) => _EditBabyProfileScreen(
                                        initialName: _babyName,
                                        initialDateOfBirth: _dateOfBirth,
                                        initialGender: _gender,
                                        initialWeight: _weight,
                                        initialHeight: _height,
                                        initialHeadCircumference: _headCircumference,
                                        initialBloodGroup: _bloodGroup,
                                        initialAllergies: _allergies,
                                        initialPediatrician: _pediatrician,
                                        initialHospital: _hospital,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          FadeTransition(
                            opacity: _avatarFade,
                            child: ScaleTransition(
                              scale: _avatarScale,
                              child: _ProfileHeroCard(
                                babyName: _babyName,
                                ageLabel: _ageLabel,
                                bornLabel: _bornLabel,
                                healthStatus: _healthStatus,
                                parentName: _parentName,
                                weight: _weight,
                                height: _height,
                                headCircumference: _headCircumference,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _SectionHeading(title: 'About'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                _InfoRow(icon: Icons.wc_rounded, label: 'Gender', value: _gender),
                                _InfoDivider(),
                                _InfoRow(icon: Icons.bloodtype_outlined, label: 'Blood Group', value: _bloodGroup),
                                _InfoDivider(),
                                _InfoRow(icon: Icons.health_and_safety_outlined, label: 'Allergies', value: _allergies),
                                _InfoDivider(),
                                _InfoRow(icon: Icons.medical_services_outlined, label: 'Pediatrician', value: _pediatrician),
                                _InfoDivider(),
                                _InfoRow(icon: Icons.local_hospital_outlined, label: 'Hospital', value: _hospital),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _SectionHeading(title: 'Growth Overview'),
                          const SizedBox(height: 10),
                          const _GrowthOverviewCard(
                            weightTrend: _weightTrend,
                            heightTrend: _heightTrend,
                            lastUpdatedLabel: _lastUpdatedLabel,
                          ),
                          const SizedBox(height: 22),
                          _SectionHeading(title: 'Care Summary'),
                          const SizedBox(height: 10),
                          const _CareSummaryGrid(
                            avgSleep: _avgSleep,
                            feedingsToday: _feedingsToday,
                            diapersToday: _diapersToday,
                            criesAnalyzed: _criesAnalyzed,
                          ),
                          const SizedBox(height: 22),
                          _SectionHeading(title: 'Medical'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                _MedicalRow(
                                  icon: Icons.vaccines_rounded,
                                  color: AuthPalette.softCoral,
                                  title: 'Upcoming Vaccine',
                                  detail: _upcomingVaccine,
                                ),
                                _MedicalRow(
                                  icon: Icons.fact_check_outlined,
                                  color: AuthPalette.powderBlue,
                                  title: 'Last Checkup',
                                  detail: _lastCheckup,
                                ),
                                _MedicalRow(
                                  icon: Icons.medication_rounded,
                                  color: AuthPalette.mint,
                                  title: 'Medications',
                                  detail: _medications,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _FamilySharingCard(onTap: () => context.go(RoutePaths.familySharing)),
                          const SizedBox(height: 22),
                          _SectionHeading(title: 'Memories'),
                          const SizedBox(height: 10),
                          _MemoriesCard(onOpenGallery: () => _showToast('Memories is coming soon 🌙')),
                          const SizedBox(height: 22),
                          _SectionHeading(title: 'Twin Mode'),
                          const SizedBox(height: 10),
                          _TwinModeCard(onEnable: () => _showToast('Twin Mode setup is coming soon 🌙')),
                          const SizedBox(height: 26),
                          AuthPrimaryButton(
                            label: 'Edit Profile',
                            isLoading: false,
                            onPressed: () => _showToast('Edit Profile is coming soon 🌙'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AuthOutlineButton(
                                  label: 'Share Profile',
                                  icon: Icons.ios_share_rounded,
                                  accent: AuthPalette.powderBlue,
                                  isLoading: false,
                                  onPressed: () => _showToast('Share Profile is coming soon 🌙'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthOutlineButton(
                                  label: 'Export PDF',
                                  icon: Icons.picture_as_pdf_outlined,
                                  accent: AuthPalette.mint,
                                  isLoading: false,
                                  onPressed: () => _showToast('Export PDF is coming soon 🌙'),
                                ),
                              ),
                            ],
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

/// Baby Profile-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation (matching the pattern already used by
/// Dashboard and Cry Analyzer) so no shared or sibling screen file needs
/// to change.
class _ProfileFloatingDecor extends StatefulWidget {
  const _ProfileFloatingDecor();

  @override
  State<_ProfileFloatingDecor> createState() => _ProfileFloatingDecorState();
}

class _ProfileFloatingDecorState extends State<_ProfileFloatingDecor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.03, left: 0.88, size: 12, color: AuthPalette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.07, left: 0.08, size: 20, color: AuthPalette.powderBlue, phase: 0.45),
    _DecorSpec(icon: Icons.star_rounded, top: 0.18, left: 0.05, size: 10, color: AuthPalette.mint, phase: 0.2),
    _DecorSpec(icon: Icons.star_rounded, top: 0.30, left: 0.93, size: 11, color: AuthPalette.lavenderMist, phase: 0.65),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.50, left: 0.90, size: 16, color: AuthPalette.blushPink, phase: 0.1),
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.75),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AuthPalette.textDark, size: 20),
          ),
        ),
      ),
    );
  }
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

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.babyName,
    required this.ageLabel,
    required this.bornLabel,
    required this.healthStatus,
    required this.parentName,
    required this.weight,
    required this.height,
    required this.headCircumference,
  });

  final String babyName;
  final String ageLabel;
  final String bornLabel;
  final String healthStatus;
  final String parentName;
  final String weight;
  final String height;
  final String headCircumference;

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
                width: 84,
                height: 84,
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
                child: const Icon(Icons.child_friendly_rounded, color: AuthPalette.softCoral, size: 42),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babyName,
                      style: GoogleFonts.quicksand(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    Text(
                      ageLabel,
                      style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
                    ),
                    Text(
                      bornLabel,
                      style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AuthPalette.mint.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_rounded, size: 13, color: AuthPalette.textDark),
                          const SizedBox(width: 5),
                          Text(
                            healthStatus,
                            style: GoogleFonts.nunito(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AuthPalette.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 15, color: AuthPalette.textMuted),
              const SizedBox(width: 6),
              Text(
                'Parent: $parentName',
                style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatBlock(icon: Icons.monitor_weight_outlined, label: 'Weight', value: weight),
                ),
                _statDivider(),
                Expanded(
                  child: _StatBlock(icon: Icons.straighten_outlined, label: 'Height', value: height),
                ),
                _statDivider(),
                Expanded(
                  child: _StatBlock(icon: Icons.circle_outlined, label: 'Head', value: headCircumference),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40,
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
        Icon(icon, size: 18, color: AuthPalette.textDark),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AuthPalette.powderBlue.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
            ),
          ),
        ],
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

class _GrowthOverviewCard extends StatelessWidget {
  const _GrowthOverviewCard({
    required this.weightTrend,
    required this.heightTrend,
    required this.lastUpdatedLabel,
  });

  final List<double> weightTrend;
  final List<double> heightTrend;
  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weight trend',
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 10),
          _MiniTrendChart(values: weightTrend, colors: const [AuthPalette.powderBlue, AuthPalette.mint]),
          const SizedBox(height: 18),
          Text(
            'Height trend',
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 10),
          _MiniTrendChart(values: heightTrend, colors: const [AuthPalette.softCoral, AuthPalette.lavenderMist]),
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
}

class _MiniTrendChart extends StatelessWidget {
  const _MiniTrendChart({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).clamp(0.1, double.infinity);

    return SizedBox(
      height: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (values[i] - minValue) / range),
                duration: Duration(milliseconds: 500 + (i * 120)),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) {
                  return FractionallySizedBox(
                    heightFactor: 0.2 + (t * 0.8),
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
    );
  }
}

class _CareSummaryGrid extends StatelessWidget {
  const _CareSummaryGrid({
    required this.avgSleep,
    required this.feedingsToday,
    required this.diapersToday,
    required this.criesAnalyzed,
  });

  final String avgSleep;
  final String feedingsToday;
  final String diapersToday;
  final String criesAnalyzed;

  @override
  Widget build(BuildContext context) {
    final items = <(_CareSummaryItem, String)>[
      (const _CareSummaryItem(icon: Icons.bedtime_rounded, label: 'Avg Sleep', color: AuthPalette.lavenderMist), avgSleep),
      (const _CareSummaryItem(icon: Icons.local_drink_rounded, label: 'Feedings Today', color: AuthPalette.powderBlue), feedingsToday),
      (const _CareSummaryItem(icon: Icons.child_care_rounded, label: 'Diapers Today', color: AuthPalette.mint), diapersToday),
      (const _CareSummaryItem(icon: Icons.graphic_eq_rounded, label: 'Cries Analyzed', color: AuthPalette.softCoral), criesAnalyzed),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        final (item, value) = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: item.color.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: Icon(item.icon, size: 18, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                    ),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(fontSize: 10.5, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CareSummaryItem {
  const _CareSummaryItem({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;
}

class _MedicalRow extends StatelessWidget {
  const _MedicalRow({
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
      ),
    );
  }
}

/// Entry point into the Family Sharing feature (SRS Section 10.20),
/// reusing [AuthCard]'s exact radius/shadow/spacing via composition so it
/// matches every other card on this screen, with a [Material]+[InkWell]
/// wrapper added purely for the tap ripple.
class _FamilySharingCard extends StatelessWidget {
  const _FamilySharingCard({required this.onTap});

  final VoidCallback onTap;

  static const _avatarColors = [AuthPalette.softCoral, AuthPalette.powderBlue, AuthPalette.mint];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Family Sharing, invite caregivers and manage access',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: AuthCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AuthPalette.lavenderMist.withValues(alpha: 0.32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.family_restroom_rounded, size: 21, color: AuthPalette.textDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Sharing',
                        style: GoogleFonts.quicksand(fontSize: 15.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Invite caregivers and manage access',
                        style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 26 + (_avatarColors.length - 1) * 14.0,
                  height: 28,
                  child: Stack(
                    children: [
                      for (var i = 0; i < _avatarColors.length; i++)
                        Positioned(
                          left: i * 14.0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _avatarColors[i].withValues(alpha: 0.85),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.person_rounded, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AuthPalette.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoriesCard extends StatelessWidget {
  const _MemoriesCard({required this.onOpenGallery});

  final VoidCallback onOpenGallery;

  static const _accents = [AuthPalette.blushPink, AuthPalette.powderBlue, AuthPalette.mint];

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < _accents.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _accents[i].withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.photo_rounded, color: AuthPalette.textDark, size: 26),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          AuthOutlineButton(
            label: 'Open Memories',
            icon: Icons.photo_library_outlined,
            accent: AuthPalette.lavenderMist,
            isLoading: false,
            onPressed: onOpenGallery,
          ),
        ],
      ),
    );
  }
}

class _TwinModeCard extends StatelessWidget {
  const _TwinModeCard({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AuthPalette.softCoral.withValues(alpha: 0.32),
                    ),
                    child: const Icon(Icons.child_friendly_rounded, color: AuthPalette.softCoral, size: 28),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AuthPalette.lavenderMist.withValues(alpha: 0.18),
                      border: Border.all(
                        color: AuthPalette.lavenderMist.withValues(alpha: 0.6),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Icons.child_friendly_rounded,
                      color: AuthPalette.lavenderMist.withValues(alpha: 0.7),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Twin mode not enabled',
            style: GoogleFonts.quicksand(fontSize: 15.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Caring for twins? Turn on Twin Mode to track a sibling alongside Lily.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted, height: 1.4),
          ),
          const SizedBox(height: 14),
          AuthOutlineButton(
            label: 'Enable Twin Mode',
            icon: Icons.diversity_3_outlined,
            accent: AuthPalette.softCoral,
            isLoading: false,
            onPressed: onEnable,
          ),
        ],
      ),
    );
  }
}

const _monthNames = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatEditDate(DateTime date) => '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// Full-screen Edit Baby Profile page, reached from the Baby Profile
/// screen's pen icon via `Navigator.push`. Reuses the same pastel design
/// language and shared background components already established on this
/// screen (including the private [_ProfileFloatingDecor] defined above).
///
/// Fields are pre-filled with the profile's current sample values but kept
/// only in local, temporary widget state — there is no backend, Firebase,
/// or database wiring. Save Changes shows a demo confirmation snackbar and
/// pops back to the profile screen without persisting anything.
class _EditBabyProfileScreen extends StatefulWidget {
  const _EditBabyProfileScreen({
    required this.initialName,
    required this.initialDateOfBirth,
    required this.initialGender,
    required this.initialWeight,
    required this.initialHeight,
    required this.initialHeadCircumference,
    required this.initialBloodGroup,
    required this.initialAllergies,
    required this.initialPediatrician,
    required this.initialHospital,
  });

  final String initialName;
  final DateTime initialDateOfBirth;
  final String initialGender;
  final String initialWeight;
  final String initialHeight;
  final String initialHeadCircumference;
  final String initialBloodGroup;
  final String initialAllergies;
  final String initialPediatrician;
  final String initialHospital;

  @override
  State<_EditBabyProfileScreen> createState() => _EditBabyProfileScreenState();
}

class _EditBabyProfileScreenState extends State<_EditBabyProfileScreen> {
  static const _genderOptions = <String>['Girl', 'Boy', 'Other'];
  static const _bloodGroupOptions = <String>['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _headCircumferenceController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _pediatricianController;
  late final TextEditingController _hospitalController;

  late DateTime _dateOfBirth;
  late String _gender;
  late String _bloodGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _weightController = TextEditingController(text: widget.initialWeight);
    _heightController = TextEditingController(text: widget.initialHeight);
    _headCircumferenceController = TextEditingController(text: widget.initialHeadCircumference);
    _allergiesController = TextEditingController(text: widget.initialAllergies);
    _pediatricianController = TextEditingController(text: widget.initialPediatrician);
    _hospitalController = TextEditingController(text: widget.initialHospital);
    _dateOfBirth = widget.initialDateOfBirth;
    _gender = widget.initialGender;
    _bloodGroup = _bloodGroupOptions.contains(widget.initialBloodGroup) ? widget.initialBloodGroup : _bloodGroupOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _headCircumferenceController.dispose();
    _allergiesController.dispose();
    _pediatricianController.dispose();
    _hospitalController.dispose();
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

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(now.year - 10),
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
    setState(() => _dateOfBirth = picked);
  }

  void _handleSave() {
    _showToast('Profile updated (demo)');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _ProfileFloatingDecor()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          AuthBackButton(onPressed: () => Navigator.of(context).pop()),
                          const Spacer(),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Edit Baby Profile',
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AuthPalette.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: _AvatarPicker(onTap: () => _showToast('Photo picker is coming soon 🌙')),
                      ),
                      const SizedBox(height: 22),
                      AuthCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              controller: _nameController,
                              label: 'Name',
                              hintText: "Baby's full name",
                              prefixIcon: Icons.badge_outlined,
                              validator: (_) => null,
                              enabled: true,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 14),
                            _DatePickerField(
                              label: 'Date of Birth',
                              value: _formatEditDate(_dateOfBirth),
                              onTap: _pickDateOfBirth,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gender',
                              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
                            ),
                            const SizedBox(height: 8),
                            _EditGenderSelector(
                              options: _genderOptions,
                              selected: _gender,
                              onChanged: (value) => setState(() => _gender = value),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: AuthTextField(
                                    controller: _weightController,
                                    label: 'Weight',
                                    hintText: 'e.g. 6.2 kg',
                                    prefixIcon: Icons.monitor_weight_outlined,
                                    keyboardType: TextInputType.text,
                                    validator: (_) => null,
                                    enabled: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AuthTextField(
                                    controller: _heightController,
                                    label: 'Height',
                                    hintText: 'e.g. 62 cm',
                                    prefixIcon: Icons.straighten_outlined,
                                    keyboardType: TextInputType.text,
                                    validator: (_) => null,
                                    enabled: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: _headCircumferenceController,
                              label: 'Head Circumference',
                              hintText: 'e.g. 40 cm',
                              prefixIcon: Icons.circle_outlined,
                              keyboardType: TextInputType.text,
                              validator: (_) => null,
                              enabled: true,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Blood Group',
                              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _bloodGroup,
                              icon: const Icon(Icons.expand_more_rounded, color: AuthPalette.textMuted),
                              style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
                              decoration: authPastelDecoration(
                                label: '',
                                hint: 'Select blood group',
                                prefixIcon: Icons.bloodtype_outlined,
                              ),
                              items: [
                                for (final group in _bloodGroupOptions)
                                  DropdownMenuItem(value: group, child: Text(group)),
                              ],
                              onChanged: (value) {
                                if (value != null) setState(() => _bloodGroup = value);
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _allergiesController,
                              maxLines: 2,
                              style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
                              cursorColor: AuthPalette.softCoral,
                              decoration: authPastelDecoration(
                                label: 'Allergies',
                                hint: 'e.g. None known',
                                prefixIcon: Icons.health_and_safety_outlined,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: _pediatricianController,
                              label: 'Pediatrician',
                              hintText: "e.g. Dr. Meera Nair",
                              prefixIcon: Icons.medical_services_outlined,
                              validator: (_) => null,
                              enabled: true,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: _hospitalController,
                              label: 'Hospital',
                              hintText: 'e.g. Sunrise Children\'s Hospital',
                              prefixIcon: Icons.local_hospital_outlined,
                              validator: (_) => null,
                              enabled: true,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: AuthOutlineButton(
                              label: 'Cancel',
                              icon: Icons.close_rounded,
                              accent: AuthPalette.lavenderMist,
                              isLoading: false,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AuthPrimaryButton(
                              label: 'Save Changes',
                              isLoading: false,
                              onPressed: _handleSave,
                            ),
                          ),
                        ],
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

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Change baby's photo",
      child: InkWell(
        borderRadius: BorderRadius.circular(56),
        onTap: onTap,
        child: SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            children: [
              Container(
                width: 104,
                height: 104,
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
                child: const Icon(Icons.child_friendly_rounded, color: AuthPalette.softCoral, size: 50),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AuthPalette.softCoral,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(color: AuthPalette.textMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.cake_outlined, color: AuthPalette.textMuted),
          suffixIcon: const Icon(Icons.calendar_today_outlined, color: AuthPalette.textMuted, size: 18),
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
          value,
          style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
        ),
      ),
    );
  }
}

class _EditGenderSelector extends StatelessWidget {
  const _EditGenderSelector({required this.options, required this.selected, required this.onChanged});

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _EditGenderChip(
              label: options[i],
              selected: options[i] == selected,
              onTap: () => onChanged(options[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _EditGenderChip extends StatelessWidget {
  const _EditGenderChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? AuthPalette.softCoral : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.transparent : AuthPalette.lavenderMist.withValues(alpha: 0.6),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AuthPalette.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
