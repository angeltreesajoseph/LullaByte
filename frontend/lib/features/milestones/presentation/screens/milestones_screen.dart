import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../domain/entities/milestone_mock_data.dart';
import '../../domain/entities/milestone_models.dart';
import 'milestone_detail_screen.dart';

/// Level 1 of the Milestones feature: "All Milestones" — a scrollable list
/// of age-group cards. Tapping a card opens [MilestoneDetailScreen] (Level
/// 2) via `Navigator.push`.
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Dashboard and Baby Profile — the gradient backdrop,
/// palette, and rounded 28px card language come directly from
/// `features/authentication/presentation/widgets/` (read-only reuse;
/// those files are not modified).
///
/// All milestone data is realistic sample data for Lily, held in the
/// single shared, in-memory `mockMilestoneAgeGroups` list (see
/// `milestone_mock_data.dart`) — there is no backend, Firebase, or
/// database integration.
class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

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

  Future<void> _openAgeGroup(int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MilestoneDetailScreen(ageGroups: mockMilestoneAgeGroups, initialIndex: index),
      ),
    );
    // The detail screen mutates the same shared list in place, so a
    // refresh here is enough to reflect any checklist changes made there.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _MilestonesFloatingDecor()),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All Milestones',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AuthPalette.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Every baby grows at their own pace. Explore Lily's milestones by age group "
                                  'below — tap a card to see the full checklist and celebrate each little win.',
                                  style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          for (var i = 0; i < mockMilestoneAgeGroups.length; i++) ...[
                            _AgeGroupCard(
                              group: mockMilestoneAgeGroups[i],
                              onTap: () => _openAgeGroup(i),
                            ),
                            if (i != mockMilestoneAgeGroups.length - 1) const SizedBox(height: 14),
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

/// Milestones-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used across
/// the app, so no shared or sibling screen file needs to change.
class _MilestonesFloatingDecor extends StatefulWidget {
  const _MilestonesFloatingDecor();

  @override
  State<_MilestonesFloatingDecor> createState() => _MilestonesFloatingDecorState();
}

class _MilestonesFloatingDecorState extends State<_MilestonesFloatingDecor>
    with SingleTickerProviderStateMixin {
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

class _AgeGroupCard extends StatelessWidget {
  const _AgeGroupCard({required this.group, required this.onTap});

  final AgeGroupMilestones group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = group.totalCount == 0 ? 0.0 : group.completedCount / group.totalCount;

    return Semantics(
      button: true,
      label: '${group.fullLabel}, ${group.completedCount} of ${group.totalCount} milestones completed',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AuthPalette.softCoral.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: AuthPalette.lavenderMist.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: group.color.withValues(alpha: 0.32),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: group.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(group.icon, color: AuthPalette.softCoral, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.fullLabel,
                              style: GoogleFonts.quicksand(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AuthPalette.textDark,
                              ),
                            ),
                          ),
                          Text(
                            '${group.completedCount}/${group.totalCount}',
                            style: GoogleFonts.nunito(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 8,
                              backgroundColor: AuthPalette.lavenderMist.withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation(AuthPalette.mint),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AuthPalette.textMuted, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
