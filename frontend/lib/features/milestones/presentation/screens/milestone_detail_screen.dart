import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../domain/entities/milestone_models.dart';

/// Level 2 of the Milestones feature: full-screen detail view for a single
/// age group, reached from [MilestonesScreen] via `Navigator.push`.
///
/// Reuses the same pastel design language already established across the
/// app (gradient backdrop, rounded 28px cards, Quicksand/Nunito) via the
/// shared, read-only `features/authentication/presentation/widgets/`.
/// [ageGroups] is the single shared, mutable, in-memory milestone list
/// (see `milestone_mock_data.dart`) — toggling a checklist item here
/// mutates that same list, so the "All Milestones" list screen reflects
/// the change immediately on return. Previous/Next swap to an adjacent
/// age group via `Navigator.pushReplacement`, keeping the navigation
/// stack at a single detail screen with the list screen underneath.
class MilestoneDetailScreen extends StatefulWidget {
  const MilestoneDetailScreen({required this.ageGroups, required this.initialIndex, super.key});

  final List<AgeGroupMilestones> ageGroups;
  final int initialIndex;

  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  AgeGroupMilestones get _group => widget.ageGroups[widget.initialIndex];
  bool get _hasPrevious => widget.initialIndex > 0;
  bool get _hasNext => widget.initialIndex < widget.ageGroups.length - 1;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _contentFade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _toggleItem(MilestoneItem item) {
    setState(() => item.achieved = !item.achieved);
  }

  void _goToIndex(int index) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MilestoneDetailScreen(ageGroups: widget.ageGroups, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _DetailFloatingDecor()),
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
                              AuthBackButton(onPressed: () => Navigator.of(context).pop()),
                              const Spacer(),
                            ],
                          ),
                          _HeroCard(group: group),
                          const SizedBox(height: 22),
                          for (final category in group.categories) ...[
                            _CategoryCard(category: category, onToggle: _toggleItem),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: AuthOutlineButton(
                                  label: 'Previous',
                                  icon: Icons.arrow_back_rounded,
                                  accent: AuthPalette.lavenderMist,
                                  isLoading: false,
                                  onPressed: _hasPrevious ? () => _goToIndex(widget.initialIndex - 1) : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthOutlineButton(
                                  label: 'Next',
                                  icon: Icons.arrow_forward_rounded,
                                  accent: AuthPalette.softCoral,
                                  isLoading: false,
                                  onPressed: _hasNext ? () => _goToIndex(widget.initialIndex + 1) : null,
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

/// Detail-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used across
/// the app, so no shared or sibling screen file needs to change.
class _DetailFloatingDecor extends StatefulWidget {
  const _DetailFloatingDecor();

  @override
  State<_DetailFloatingDecor> createState() => _DetailFloatingDecorState();
}

class _DetailFloatingDecorState extends State<_DetailFloatingDecor> with SingleTickerProviderStateMixin {
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.group});

  final AgeGroupMilestones group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  group.color.withValues(alpha: 0.55),
                  AuthPalette.lavenderMist.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AuthPalette.softCoral.withValues(alpha: 0.16),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 96,
                height: 96,
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
                child: Icon(group.icon, color: AuthPalette.softCoral, size: 46),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.fullLabel,
                  style: GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AuthPalette.mint.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${group.completedCount} out of ${group.totalCount} completed',
                  style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onToggle});

  final MilestoneCategory category;
  final ValueChanged<MilestoneItem> onToggle;

  @override
  Widget build(BuildContext context) {
    final progress = category.totalCount == 0 ? 0.0 : category.completedCount / category.totalCount;

    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: category.type.color.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.type.icon, size: 18, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.type.label,
                  style: GoogleFonts.quicksand(fontSize: 15.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ),
              Text(
                '${category.completedCount}/${category.totalCount}',
                style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted),
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
                  minHeight: 8,
                  backgroundColor: AuthPalette.lavenderMist.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation(AuthPalette.mint),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < category.items.length; i++)
            _ChecklistTile(
              item: category.items[i],
              isLast: i == category.items.length - 1,
              onTap: () => onToggle(category.items[i]),
            ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item, required this.isLast, required this.onTap});

  final MilestoneItem item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: item.achieved,
      label: item.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.achieved ? AuthPalette.mint : Colors.white,
                      border: Border.all(
                        color: item.achieved ? AuthPalette.mint : AuthPalette.lavenderMist.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                    ),
                    child: item.achieved
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : null,
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
                  padding: const EdgeInsets.only(bottom: 16, top: 4),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: item.achieved ? 1.0 : 0.55,
                    child: Text(
                      item.name,
                      style: GoogleFonts.nunito(
                        fontSize: 13.5,
                        fontWeight: item.achieved ? FontWeight.w700 : FontWeight.w600,
                        color: AuthPalette.textDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
