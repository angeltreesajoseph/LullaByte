import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

/// Parent Dashboard screen (SRS Section 10.5) — the "Home" tab of the
/// persistent shell navigation (see `core/router/main_navigation_shell.dart`).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, and Baby Registration — the gradient
/// backdrop, palette, and rounded 28px card language come directly from
/// `features/authentication/presentation/widgets/` (read-only reuse; those
/// files are not modified). Every value shown is realistic sample data;
/// there is no backend or state-management integration yet.
///
/// The bottom navigation bar and the Luma AI button now live in the
/// shared [MainNavigationShell] wrapping all four main tabs, not on this
/// screen directly. Section order: baby summary, Quick Actions (six small
/// cards in a 2-column grid) with a full-width Milestones card beneath,
/// Growth, Today's Care, then Recent Activity.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroFade;

  // Realistic sample data — no backend/state-management wiring yet.
  static const _parentName = 'Meera';
  static const _babyName = 'Lily';
  static const _babyAgeLabel = '4 months';
  static const _unreadNotifications = 3;
  static const _babyStatus = _BabyStatus.sleeping;
  static const _lastCryTime = '2 hours ago';
  static const _sleepSummary = '6h 45m today';
  static const _feedingSummary = '5 feeds • last at 2:30 PM';
  static const _weightSummary = '6.2 kg (+0.3 kg)';
  static const _weightTrend = [5.4, 5.7, 5.9, 6.0, 6.2];
  static const _heightPercentile = 0.62;
  static const _lastMeasuredLabel = 'Last measured 5 days ago';

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );
    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
    );
    _heroScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.85, curve: Curves.easeOutBack)),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AuthPalette.textDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            '$feature is coming soon 🌙',
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  /// Quick Actions dispatcher: routes each of the six small cards to its
  /// real, already-implemented screen via the existing GoRouter
  /// [RoutePaths].
  void _handleQuickAction(String label) {
    switch (label) {
      case 'Analyze Cry':
        context.go(RoutePaths.cryAnalyzer);
      case 'Feeding':
        context.go(RoutePaths.feeding);
      case 'Sleep':
        context.go(RoutePaths.sleep);
      case 'Diaper':
        context.go(RoutePaths.diaper);
      case 'Growth':
        context.go(RoutePaths.growth);
      case 'Vaccinations':
        context.go(RoutePaths.vaccination);
      default:
        _showComingSoon(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _DashboardFloatingDecor()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _DashboardHeader(
                                parentName: _parentName,
                                babyName: _babyName,
                                babyAge: _babyAgeLabel,
                                greeting: _greeting,
                                unreadCount: _unreadNotifications,
                                onBellTap: () => context.go(RoutePaths.notifications),
                              ),
                              const SizedBox(height: 18),
                              FadeTransition(
                                opacity: _heroFade,
                                child: ScaleTransition(
                                  scale: _heroScale,
                                  alignment: Alignment.topCenter,
                                  child: const _BabyHeroCard(
                                    babyName: _babyName,
                                    babyAge: _babyAgeLabel,
                                    status: _babyStatus,
                                    lastCryTime: _lastCryTime,
                                    sleepSummary: _sleepSummary,
                                    feedingSummary: _feedingSummary,
                                    weightSummary: _weightSummary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              _SectionHeading(title: 'Quick Actions'),
                              const SizedBox(height: 10),
                              _QuickActionsGrid(onTap: _handleQuickAction),
                              const SizedBox(height: 14),
                              _MilestonesQuickActionCard(onTap: () => context.go(RoutePaths.milestones)),
                              const SizedBox(height: 22),
                              if (isWide)
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: _GrowthSection(
                                          weightTrend: _weightTrend,
                                          heightPercentile: _heightPercentile,
                                          lastMeasuredLabel: _lastMeasuredLabel,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(child: _TodaysCareSection()),
                                    ],
                                  ),
                                )
                              else ...[
                                const _GrowthSection(
                                  weightTrend: _weightTrend,
                                  heightPercentile: _heightPercentile,
                                  lastMeasuredLabel: _lastMeasuredLabel,
                                ),
                                const SizedBox(height: 22),
                                const _TodaysCareSection(),
                              ],
                              const SizedBox(height: 22),
                              _SectionHeading(title: 'Recent Activity'),
                              const SizedBox(height: 10),
                              const _ActivityTimeline(),
                              const SizedBox(height: 12),
                            ],
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

enum _BabyStatus { sleeping, awake, feeding }

extension on _BabyStatus {
  String get label => switch (this) {
        _BabyStatus.sleeping => 'Sleeping',
        _BabyStatus.awake => 'Awake',
        _BabyStatus.feeding => 'Feeding',
      };

  IconData get icon => switch (this) {
        _BabyStatus.sleeping => Icons.bedtime_rounded,
        _BabyStatus.awake => Icons.wb_sunny_rounded,
        _BabyStatus.feeding => Icons.local_drink_rounded,
      };

  Color get color => switch (this) {
        _BabyStatus.sleeping => AuthPalette.lavenderMist,
        _BabyStatus.awake => AuthPalette.mint,
        _BabyStatus.feeding => AuthPalette.powderBlue,
      };
}

/// Dashboard-local "stars and clouds" ambient decoration, deliberately
/// separate from the auth feature's `AuthFloatingDecor` (which uses stars
/// and hearts) so this screen's exact spec — floating stars/clouds — is
/// met without touching any shared file used by Login/Register.
class _DashboardFloatingDecor extends StatefulWidget {
  const _DashboardFloatingDecor();

  @override
  State<_DashboardFloatingDecor> createState() => _DashboardFloatingDecorState();
}

class _DashboardFloatingDecorState extends State<_DashboardFloatingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.03, left: 0.08, size: 14, color: AuthPalette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.06, left: 0.80, size: 26, color: AuthPalette.powderBlue, phase: 0.4),
    _DecorSpec(icon: Icons.star_rounded, top: 0.12, left: 0.92, size: 10, color: AuthPalette.mint, phase: 0.2),
    _DecorSpec(icon: Icons.star_rounded, top: 0.02, left: 0.45, size: 11, color: AuthPalette.lavenderMist, phase: 0.6),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.20, left: 0.04, size: 20, color: AuthPalette.blushPink, phase: 0.1),
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
                      return Opacity(opacity: 0.08 + (t * 0.10), child: child);
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

/// Header row: parent avatar, time-of-day greeting, baby name/age, and a
/// notification bell with an unread-count badge.
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.parentName,
    required this.babyName,
    required this.babyAge,
    required this.greeting,
    required this.unreadCount,
    required this.onBellTap,
  });

  final String parentName;
  final String babyName;
  final String babyAge;
  final String greeting;
  final int unreadCount;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AuthPalette.softCoral, AuthPalette.lavenderMist],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            parentName.isEmpty ? '?' : parentName[0],
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $parentName 👋',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AuthPalette.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$babyName • $babyAge',
                style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
              ),
            ],
          ),
        ),
        _NotificationBell(unreadCount: unreadCount, onTap: onBellTap),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unreadCount, required this.onTap});

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: unreadCount > 0 ? '$unreadCount unread notifications' : 'Notifications',
      child: Material(
        color: Colors.white.withValues(alpha: 0.75),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_rounded, color: AuthPalette.textDark, size: 24),
                if (unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: const BoxDecoration(
                        color: AuthPalette.softCoral,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$unreadCount',
                        style: GoogleFonts.nunito(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared card shell matching `AuthCard`'s exact radius/shadow language,
/// but allowing a custom (non-white) background — used by the Baby Hero
/// Card, which is deliberately visually distinct from the regular section
/// cards beneath it.
BoxDecoration _pastelCardDecoration({Gradient? gradient, Color? color}) {
  return BoxDecoration(
    color: gradient == null ? (color ?? Colors.white.withValues(alpha: 0.92)) : null,
    gradient: gradient,
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
  );
}

class _BabyHeroCard extends StatelessWidget {
  const _BabyHeroCard({
    required this.babyName,
    required this.babyAge,
    required this.status,
    required this.lastCryTime,
    required this.sleepSummary,
    required this.feedingSummary,
    required this.weightSummary,
  });

  final String babyName;
  final String babyAge;
  final _BabyStatus status;
  final String lastCryTime;
  final String sleepSummary;
  final String feedingSummary;
  final String weightSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _pastelCardDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AuthPalette.blushPink.withValues(alpha: 0.55),
            AuthPalette.lavenderMist.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.85),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AuthPalette.softCoral.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.child_friendly_rounded, color: AuthPalette.softCoral, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      babyName,
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    Text(
                      babyAge,
                      style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textMuted),
                    ),
                    const SizedBox(height: 8),
                    _StatusChip(status: status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.graphic_eq_rounded, size: 16, color: AuthPalette.textMuted),
              const SizedBox(width: 6),
              Text(
                'Last cry $lastCryTime',
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
                  child: _HeroStat(
                    icon: Icons.bedtime_outlined,
                    label: 'Sleep',
                    value: sleepSummary,
                    color: AuthPalette.lavenderMist,
                  ),
                ),
                _heroDivider(),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.local_drink_outlined,
                    label: 'Feeding',
                    value: feedingSummary,
                    color: AuthPalette.powderBlue,
                  ),
                ),
                _heroDivider(),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight',
                    value: weightSummary,
                    color: AuthPalette.mint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _BabyStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: AuthPalette.textDark),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: GoogleFonts.nunito(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AuthPalette.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AuthPalette.textDark),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
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

/// Quick Actions grid — a fixed 2-column layout that lays six small cards
/// out as three rows of two: Analyze Cry, Feeding, Sleep, Diaper, Growth,
/// Vaccinations.
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.onTap});

  final ValueChanged<String> onTap;

  static const _actions = <_QuickAction>[
    _QuickAction(label: 'Analyze Cry', icon: Icons.graphic_eq_rounded, color: AuthPalette.softCoral),
    _QuickAction(label: 'Feeding', icon: Icons.local_drink_rounded, color: AuthPalette.powderBlue),
    _QuickAction(label: 'Sleep', icon: Icons.bedtime_rounded, color: AuthPalette.lavenderMist),
    _QuickAction(label: 'Diaper', icon: Icons.child_care_rounded, color: AuthPalette.mint),
    _QuickAction(label: 'Growth', icon: Icons.show_chart_rounded, color: AuthPalette.blushPink),
    _QuickAction(label: 'Vaccinations', icon: Icons.vaccines_rounded, color: Color(0xFFEF6FA0)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];
        return _QuickActionCard(action: action, onTap: () => onTap(action.label));
      },
    );
  }
}

class _QuickAction {
  const _QuickAction({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.action.color == AuthPalette.blushPink
        ? AuthPalette.softCoral
        : AuthPalette.textDark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: widget.action.color.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.action.color.withValues(alpha: 0.32),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.action.icon, color: iconColor, size: 21),
              ),
              const SizedBox(height: 8),
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Third row of the Quick Actions section: a full-width, long-format card
/// for Milestones (88–100px tall), using the same rounded/shadow language
/// as the six small cards above but a horizontal icon–text–chevron layout,
/// and the same subtle press-scale tap animation.
class _MilestonesQuickActionCard extends StatefulWidget {
  const _MilestonesQuickActionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MilestonesQuickActionCard> createState() => _MilestonesQuickActionCardState();
}

class _MilestonesQuickActionCardState extends State<_MilestonesQuickActionCard> {
  static const _pastelGold = Color(0xFFFFD9A0);
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: "Milestones, track Lily's developmental progress",
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            height: 96,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: _pastelGold.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: _pastelGold.withValues(alpha: 0.35), shape: BoxShape.circle),
                  child: const Icon(Icons.workspace_premium_rounded, color: AuthPalette.textDark, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Milestones',
                        style: GoogleFonts.quicksand(fontSize: 15.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Track Lily's developmental progress",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
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

class _GrowthSection extends StatelessWidget {
  const _GrowthSection({
    required this.weightTrend,
    required this.heightPercentile,
    required this.lastMeasuredLabel,
  });

  final List<double> weightTrend;
  final double heightPercentile;
  final String lastMeasuredLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _pastelCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionHeading(title: 'Growth')),
              Icon(Icons.trending_up_rounded, color: AuthPalette.mint, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Weight trend',
            style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 10),
          _MiniWeightChart(values: weightTrend),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Height percentile',
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
              ),
              const Spacer(),
              Text(
                '${(heightPercentile * 100).round()}th',
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _HeightProgressBar(value: heightPercentile),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.event_available_outlined, size: 15, color: AuthPalette.textMuted),
              const SizedBox(width: 6),
              Text(
                lastMeasuredLabel,
                style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniWeightChart extends StatelessWidget {
  const _MiniWeightChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).clamp(0.1, double.infinity);

    return SizedBox(
      height: 64,
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
                    heightFactor: 0.18 + (t * 0.82),
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
    );
  }
}

class _HeightProgressBar extends StatelessWidget {
  const _HeightProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(height: 12, color: AuthPalette.lavenderMist.withValues(alpha: 0.3)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) {
              return FractionallySizedBox(
                widthFactor: t,
                child: Container(
                  height: 12,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AuthPalette.softCoral, AuthPalette.mint],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodaysCareSection extends StatelessWidget {
  const _TodaysCareSection();

  static const _items = <_CareReminder>[
    _CareReminder(
      icon: Icons.local_drink_rounded,
      color: AuthPalette.powderBlue,
      title: 'Next Feeding',
      detail: '1:30 PM • in 45 min',
    ),
    _CareReminder(
      icon: Icons.bedtime_rounded,
      color: AuthPalette.lavenderMist,
      title: 'Next Nap',
      detail: '3:00 PM',
    ),
    _CareReminder(
      icon: Icons.vaccines_rounded,
      color: AuthPalette.softCoral,
      title: 'Next Vaccination',
      detail: 'DTaP • in 12 days',
    ),
    _CareReminder(
      icon: Icons.medication_rounded,
      color: AuthPalette.mint,
      title: 'Medication Reminder',
      detail: 'Vitamin D drops • 6:00 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _pastelCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: "Today's Care"),
          const SizedBox(height: 10),
          for (final item in _items) _CareReminderTile(item: item),
        ],
      ),
    );
  }
}

class _CareReminder {
  const _CareReminder({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
}

class _CareReminderTile extends StatelessWidget {
  const _CareReminderTile({required this.item});

  final _CareReminder item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(item.icon, size: 18, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                Text(
                  item.detail,
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

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  static const _events = <_ActivityEvent>[
    _ActivityEvent(
      icon: Icons.graphic_eq_rounded,
      color: AuthPalette.softCoral,
      title: 'Cry Analyzed',
      detail: 'Hungry • 92% confidence',
      time: '10 min ago',
    ),
    _ActivityEvent(
      icon: Icons.local_drink_rounded,
      color: AuthPalette.powderBlue,
      title: 'Feeding Recorded',
      detail: '120 ml • Bottle',
      time: '2 hours ago',
    ),
    _ActivityEvent(
      icon: Icons.bedtime_rounded,
      color: AuthPalette.lavenderMist,
      title: 'Sleep Session Ended',
      detail: '1h 30m',
      time: '3 hours ago',
    ),
    _ActivityEvent(
      icon: Icons.child_care_rounded,
      color: AuthPalette.mint,
      title: 'Diaper Changed',
      detail: 'Wet',
      time: '4 hours ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      decoration: _pastelCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _events.length; i++)
            _ActivityTimelineTile(event: _events[i], isLast: i == _events.length - 1),
        ],
      ),
    );
  }
}

class _ActivityEvent {
  const _ActivityEvent({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String time;
}

class _ActivityTimelineTile extends StatelessWidget {
  const _ActivityTimelineTile({required this.event, required this.isLast});

  final _ActivityEvent event;
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
                decoration: BoxDecoration(color: event.color.withValues(alpha: 0.32), shape: BoxShape.circle),
                child: Icon(event.icon, size: 16, color: AuthPalette.textDark),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.nunito(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AuthPalette.textDark,
                          ),
                        ),
                        Text(
                          event.detail,
                          style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    event.time,
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

