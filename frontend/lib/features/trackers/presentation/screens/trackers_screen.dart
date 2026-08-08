import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

enum _TrackersTab { track, summary, reports }

/// Trackers tab — one of the four persistent shell sections (Home,
/// Trackers, Memories, Profile). Reuses the same pastel design language
/// already established across the app; kept alive by the shell's
/// `StatefulShellRoute.indexedStack` so its scroll/tab state persists
/// when switching away and back.
///
/// All data shown is realistic local mock state — there is no backend,
/// Firebase, or database integration. Export PDF is a snackbar-only
/// simulation.
class TrackersScreen extends StatefulWidget {
  const TrackersScreen({super.key});

  @override
  State<TrackersScreen> createState() => _TrackersScreenState();
}

class _TrackersScreenState extends State<TrackersScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  _TrackersTab _selectedTab = _TrackersTab.track;

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
          const Positioned.fill(child: _TrackersFloatingDecor()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, viewportConstraints) {
                // A ConstrainedBox with the viewport's own minHeight makes the
                // scrollable content always fill at least the full screen —
                // without it, the Summary/Reports tabs (whose content is much
                // shorter than Track's) leave a chunk of open space below the
                // last card where nothing about the layout guarantees the
                // pastel background is the only thing visible while
                // scrolling/bouncing. This keeps the page reading as one
                // continuous surface regardless of which tab is active.
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
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
                                Text(
                                  'Trackers',
                                  style: GoogleFonts.quicksand(fontSize: 26, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Keep track of daily routines',
                                  style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
                                ),
                                const SizedBox(height: 18),
                                _TrackersTabSelector(
                                  selected: _selectedTab,
                                  onChanged: (tab) => setState(() => _selectedTab = tab),
                                ),
                                const SizedBox(height: 20),
                                switch (_selectedTab) {
                                  _TrackersTab.track => const _TrackTabContent(),
                                  _TrackersTab.summary => const _SummaryTabContent(),
                                  _TrackersTab.reports => _ReportsTabContent(onAction: _showToast),
                                },
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Trackers-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used across
/// the app, so no shared or sibling screen file needs to change.
class _TrackersFloatingDecor extends StatefulWidget {
  const _TrackersFloatingDecor();

  @override
  State<_TrackersFloatingDecor> createState() => _TrackersFloatingDecorState();
}

class _TrackersFloatingDecorState extends State<_TrackersFloatingDecor> with SingleTickerProviderStateMixin {
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

class _TrackersTabSelector extends StatelessWidget {
  const _TrackersTabSelector({required this.selected, required this.onChanged});

  final _TrackersTab selected;
  final ValueChanged<_TrackersTab> onChanged;

  static const _labels = <_TrackersTab, String>{
    _TrackersTab.track: 'Track',
    _TrackersTab.summary: 'Summary',
    _TrackersTab.reports: 'Reports',
  };

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
          for (final tab in _TrackersTab.values)
            Expanded(
              child: _SegmentButton(
                label: _labels[tab]!,
                selected: tab == selected,
                onTap: () => onChanged(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? AuthPalette.softCoral : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AuthPalette.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackerDestination {
  const _TrackerDestination({required this.label, required this.icon, required this.color, required this.path});

  final String label;
  final IconData icon;
  final Color color;
  final String path;
}

class _TrackTabContent extends StatelessWidget {
  const _TrackTabContent();

  static const _destinations = <_TrackerDestination>[
    _TrackerDestination(label: 'Cry Analyzer', icon: Icons.graphic_eq_rounded, color: AuthPalette.softCoral, path: RoutePaths.cryAnalyzer),
    _TrackerDestination(label: 'Feeding', icon: Icons.local_drink_rounded, color: AuthPalette.powderBlue, path: RoutePaths.feeding),
    _TrackerDestination(label: 'Sleep', icon: Icons.bedtime_rounded, color: AuthPalette.lavenderMist, path: RoutePaths.sleep),
    _TrackerDestination(label: 'Diaper', icon: Icons.child_care_rounded, color: AuthPalette.mint, path: RoutePaths.diaper),
    _TrackerDestination(label: 'Growth', icon: Icons.show_chart_rounded, color: AuthPalette.blushPink, path: RoutePaths.growth),
    _TrackerDestination(label: 'Vaccinations', icon: Icons.vaccines_rounded, color: Color(0xFFEF6FA0), path: RoutePaths.vaccination),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _destinations.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final destination = _destinations[index];
            return _TrackerCard(destination: destination, onTap: () => context.go(destination.path));
          },
        ),
        const SizedBox(height: 22),
        const _SectionHeading(title: 'Milestones'),
        const SizedBox(height: 10),
        _TrackersMilestonesCard(onTap: () => context.go(RoutePaths.milestones)),
      ],
    );
  }
}

class _TrackerCard extends StatelessWidget {
  const _TrackerCard({required this.destination, required this.onTap});

  final _TrackerDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: destination.label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: destination.color.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: destination.color.withValues(alpha: 0.32), shape: BoxShape.circle),
                  child: Icon(destination.icon, color: AuthPalette.textDark, size: 21),
                ),
                const SizedBox(height: 10),
                Text(
                  destination.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackersMilestonesCard extends StatelessWidget {
  const _TrackersMilestonesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Milestones, 8 of 10 for this stage',
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: AuthPalette.mint.withValues(alpha: 0.32), shape: BoxShape.circle),
                  child: const Icon(Icons.workspace_premium_rounded, color: AuthPalette.textDark, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Milestones',
                        style: GoogleFonts.quicksand(fontSize: 15.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.8,
                          minHeight: 7,
                          backgroundColor: AuthPalette.lavenderMist,
                          valueColor: AlwaysStoppedAnimation(AuthPalette.mint),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '8 of 10 milestones for this stage',
                        style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted),
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

class _SummaryStat {
  const _SummaryStat({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _SummaryTabContent extends StatelessWidget {
  const _SummaryTabContent();

  static const _stats = <_SummaryStat>[
    _SummaryStat(icon: Icons.bedtime_rounded, label: 'Sleep Today', value: '13h 20m', color: AuthPalette.lavenderMist),
    _SummaryStat(icon: Icons.local_drink_rounded, label: 'Feeds Today', value: '7', color: AuthPalette.powderBlue),
    _SummaryStat(icon: Icons.child_care_rounded, label: 'Diapers Today', value: '5', color: AuthPalette.mint),
    _SummaryStat(icon: Icons.graphic_eq_rounded, label: 'Cries Analyzed', value: '3', color: AuthPalette.softCoral),
    _SummaryStat(icon: Icons.monitor_weight_outlined, label: 'Weight Change', value: '+0.3 kg', color: AuthPalette.blushPink),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final stat = _stats[index];
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
                decoration: BoxDecoration(color: stat.color.withValues(alpha: 0.32), shape: BoxShape.circle),
                child: Icon(stat.icon, size: 18, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stat.value,
                      style: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                    ),
                    Text(
                      stat.label,
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

class _ReportsTabContent extends StatelessWidget {
  const _ReportsTabContent({required this.onAction});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportRow(
                icon: Icons.today_rounded,
                color: AuthPalette.powderBlue,
                title: 'Daily',
                subtitle: "Today's care summary",
                onTap: () => onAction('Daily report is coming soon 🌙'),
              ),
              const _InfoDivider(),
              _ReportRow(
                icon: Icons.view_week_rounded,
                color: AuthPalette.mint,
                title: 'Weekly',
                subtitle: 'Trends over the last 7 days',
                onTap: () => onAction('Weekly report is coming soon 🌙'),
              ),
              const _InfoDivider(),
              _ReportRow(
                icon: Icons.calendar_month_rounded,
                color: AuthPalette.lavenderMist,
                title: 'Monthly',
                subtitle: 'Full growth and care overview',
                onTap: () => onAction('Monthly report is coming soon 🌙'),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AuthPrimaryButton(
          label: 'Export PDF',
          isLoading: false,
          onPressed: () => onAction('Report exported (demo) 🌙'),
        ),
      ],
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

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isLast ? 12 : 10).copyWith(bottom: isLast ? 2 : 10),
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
                      subtitle,
                      style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AuthPalette.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
