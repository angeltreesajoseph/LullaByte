import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

enum _CryMood { hungry, tired, discomfort }

extension _CryMoodX on _CryMood {
  String get label => switch (this) {
        _CryMood.hungry => 'Hungry',
        _CryMood.tired => 'Tired',
        _CryMood.discomfort => 'Discomfort',
      };

  IconData get icon => switch (this) {
        _CryMood.hungry => Icons.local_drink_rounded,
        _CryMood.tired => Icons.bedtime_rounded,
        _CryMood.discomfort => Icons.sentiment_dissatisfied_rounded,
      };

  Color get color => switch (this) {
        _CryMood.hungry => AuthPalette.softCoral,
        _CryMood.tired => AuthPalette.lavenderMist,
        _CryMood.discomfort => AuthPalette.powderBlue,
      };

  String get detectedPattern => switch (this) {
        _CryMood.hungry => 'A rhythmic, rising cry pattern typically associated with hunger cues.',
        _CryMood.tired => 'A low, whiny, repetitive pattern often linked to overtiredness.',
        _CryMood.discomfort => 'A sudden, sharp cry pattern often linked to discomfort (wet diaper, gas, or temperature).',
      };

  String get suggestedAction => switch (this) {
        _CryMood.hungry => 'Offer a feeding and see if Lily settles within the next few minutes.',
        _CryMood.tired => 'Dim the lights and start a calming wind-down routine for a nap.',
        _CryMood.discomfort => 'Check her diaper and clothing, and make sure the room temperature feels right.',
      };
}

class _ReminderItem {
  const _ReminderItem({required this.icon, required this.title, required this.timeLabel, required this.color});

  final IconData icon;
  final String title;
  final String timeLabel;
  final Color color;
}

class _CryAlert {
  const _CryAlert({required this.mood, required this.confidence, required this.timeLabel, required this.caregiverName});

  final _CryMood mood;
  final int confidence;
  final String timeLabel;
  final String caregiverName;
}

class _MilestoneCelebration {
  const _MilestoneCelebration({required this.title, required this.icon, required this.color});

  final String title;
  final IconData icon;
  final Color color;
}

class _HistoryEntry {
  const _HistoryEntry({required this.icon, required this.title, required this.color, required this.timeLabel});

  final IconData icon;
  final String title;
  final Color color;
  final String timeLabel;
}

/// Notifications & Reminders screen (SRS Section 10.17) — a reminder and
/// alert center built for working parents, caregivers, and deaf parents.
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established across the app — the gradient backdrop, palette, and
/// rounded 28px card language come directly from
/// `features/authentication/presentation/widgets/` (read-only reuse;
/// those files are not modified).
///
/// All data shown is realistic local mock state — there is no backend,
/// Firebase, or real push notification integration. Mark All as Read and
/// Clear History update local state only and surface a snackbar.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  bool _pushEnabled = true;
  bool _vibrationEnabled = true;
  bool _largeTextEnabled = false;
  bool _caregiverAlertsEnabled = true;
  int _unreadCount = 3;

  static const _reminders = <_ReminderItem>[
    _ReminderItem(icon: Icons.local_drink_rounded, title: 'Feeding', timeLabel: '2:30 PM', color: AuthPalette.powderBlue),
    _ReminderItem(icon: Icons.bedtime_rounded, title: 'Nap time', timeLabel: '3:15 PM', color: AuthPalette.lavenderMist),
    _ReminderItem(icon: Icons.vaccines_rounded, title: 'Vaccine due', timeLabel: 'Tomorrow', color: AuthPalette.softCoral),
    _ReminderItem(icon: Icons.show_chart_rounded, title: 'Growth check', timeLabel: 'Sunday', color: AuthPalette.mint),
  ];

  static const _cryAlerts = <_CryAlert>[
    _CryAlert(mood: _CryMood.hungry, confidence: 86, timeLabel: '2:10 PM', caregiverName: 'Priya'),
    _CryAlert(mood: _CryMood.tired, confidence: 74, timeLabel: '11:40 AM', caregiverName: 'Priya'),
    _CryAlert(mood: _CryMood.discomfort, confidence: 61, timeLabel: '9:05 AM', caregiverName: 'Angel'),
  ];

  static const _celebrations = <_MilestoneCelebration>[
    _MilestoneCelebration(title: 'Rolled over', icon: Icons.emoji_events_rounded, color: AuthPalette.mint),
    _MilestoneCelebration(title: 'Smiled socially', icon: Icons.emoji_events_rounded, color: AuthPalette.blushPink),
    _MilestoneCelebration(title: 'Held head steady', icon: Icons.emoji_events_rounded, color: AuthPalette.powderBlue),
  ];

  late List<_HistoryEntry> _historyToday = [
    const _HistoryEntry(icon: Icons.local_drink_rounded, title: 'Feeding reminder', color: AuthPalette.powderBlue, timeLabel: '10 min ago'),
    const _HistoryEntry(icon: Icons.graphic_eq_rounded, title: 'Cry alert', color: AuthPalette.softCoral, timeLabel: '25 min ago'),
    const _HistoryEntry(icon: Icons.bedtime_rounded, title: 'Sleep started', color: AuthPalette.lavenderMist, timeLabel: '1 hour ago'),
  ];

  late List<_HistoryEntry> _historyYesterday = [
    const _HistoryEntry(icon: Icons.vaccines_rounded, title: 'Vaccine reminder', color: AuthPalette.softCoral, timeLabel: 'Yesterday'),
    const _HistoryEntry(icon: Icons.workspace_premium_rounded, title: 'Milestone completed', color: AuthPalette.mint, timeLabel: 'Yesterday'),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
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

  void _handleMarkAllRead() {
    setState(() => _unreadCount = 0);
    _showToast('All notifications marked as read 🌙');
  }

  void _handleClearHistory() {
    setState(() {
      _historyToday = [];
      _historyYesterday = [];
    });
    _showToast('Notification history cleared');
  }

  void _openCryAlertDetails(_CryAlert alert) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CryAlertDetailSheet(alert: alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyEmpty = _historyToday.isEmpty && _historyYesterday.isEmpty;

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _NotificationsFloatingDecor()),
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
                          _NotificationsHeaderCard(unreadCount: _unreadCount),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Quick Settings'),
                          const SizedBox(height: 10),
                          _QuickSettingsCard(
                            pushEnabled: _pushEnabled,
                            vibrationEnabled: _vibrationEnabled,
                            largeTextEnabled: _largeTextEnabled,
                            caregiverAlertsEnabled: _caregiverAlertsEnabled,
                            onPushChanged: (value) {
                              setState(() => _pushEnabled = value);
                              _showToast(value ? 'Push notifications turned on 🌙' : 'Push notifications turned off');
                            },
                            onVibrationChanged: (value) {
                              setState(() => _vibrationEnabled = value);
                              _showToast(value ? 'Vibration alerts turned on 🌙' : 'Vibration alerts turned off');
                            },
                            onLargeTextChanged: (value) {
                              setState(() => _largeTextEnabled = value);
                              _showToast(value ? 'Large-text alerts turned on 🌙' : 'Large-text alerts turned off');
                            },
                            onCaregiverAlertsChanged: (value) {
                              setState(() => _caregiverAlertsEnabled = value);
                              _showToast(value ? 'Caregiver alerts turned on 🌙' : 'Caregiver alerts turned off');
                            },
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Upcoming Reminders'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < _reminders.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 10),
                                  _ReminderTile(
                                    item: _reminders[i],
                                    onTap: () => _showToast('Edit ${_reminders[i].title} is coming soon 🌙'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Cry Alerts'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < _cryAlerts.length; i++) ...[
                                  if (i > 0) const _InfoDivider(),
                                  _CryAlertRow(alert: _cryAlerts[i], onTap: () => _openCryAlertDetails(_cryAlerts[i])),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Milestone Celebrations'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < _celebrations.length; i++) ...[
                                  if (i > 0) const _InfoDivider(),
                                  _CelebrationRow(celebration: _celebrations[i]),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Notification History'),
                          const SizedBox(height: 10),
                          if (historyEmpty)
                            const _EmptyHistoryState()
                          else
                            AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_historyToday.isNotEmpty) ...[
                                    _HistoryGroupLabel(label: 'Today'),
                                    for (var i = 0; i < _historyToday.length; i++)
                                      _HistoryTile(entry: _historyToday[i], isLast: i == _historyToday.length - 1 && _historyYesterday.isEmpty),
                                  ],
                                  if (_historyYesterday.isNotEmpty) ...[
                                    if (_historyToday.isNotEmpty) const SizedBox(height: 14),
                                    _HistoryGroupLabel(label: 'Yesterday'),
                                    for (var i = 0; i < _historyYesterday.length; i++)
                                      _HistoryTile(entry: _historyYesterday[i], isLast: i == _historyYesterday.length - 1),
                                  ],
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: AuthOutlineButton(
                                  label: 'Mark all as read',
                                  icon: Icons.done_all_rounded,
                                  accent: AuthPalette.mint,
                                  isLoading: false,
                                  onPressed: _handleMarkAllRead,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthOutlineButton(
                                  label: 'Clear history',
                                  icon: Icons.delete_outline_rounded,
                                  accent: AuthPalette.error,
                                  isLoading: false,
                                  onPressed: _handleClearHistory,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const _AccessibilityInfoCard(),
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

/// Notifications-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used across
/// the app, so no shared or sibling screen file needs to change.
class _NotificationsFloatingDecor extends StatefulWidget {
  const _NotificationsFloatingDecor();

  @override
  State<_NotificationsFloatingDecor> createState() => _NotificationsFloatingDecorState();
}

class _NotificationsFloatingDecorState extends State<_NotificationsFloatingDecor>
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
    return Divider(color: AuthPalette.lavenderMist.withValues(alpha: 0.4), height: 22);
  }
}

class _NotificationsHeaderCard extends StatelessWidget {
  const _NotificationsHeaderCard({required this.unreadCount});

  final int unreadCount;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              clipBehavior: Clip.none,
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
                  child: const Icon(Icons.notifications_rounded, color: AuthPalette.softCoral, size: 30),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                      decoration: const BoxDecoration(color: AuthPalette.softCoral, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        '$unreadCount',
                        style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications & Reminders',
                  style: GoogleFonts.quicksand(fontSize: 21, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  "Stay updated about Lily's care",
                  style: GoogleFonts.nunito(fontSize: 13, color: AuthPalette.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickSettingsCard extends StatelessWidget {
  const _QuickSettingsCard({
    required this.pushEnabled,
    required this.vibrationEnabled,
    required this.largeTextEnabled,
    required this.caregiverAlertsEnabled,
    required this.onPushChanged,
    required this.onVibrationChanged,
    required this.onLargeTextChanged,
    required this.onCaregiverAlertsChanged,
  });

  final bool pushEnabled;
  final bool vibrationEnabled;
  final bool largeTextEnabled;
  final bool caregiverAlertsEnabled;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onVibrationChanged;
  final ValueChanged<bool> onLargeTextChanged;
  final ValueChanged<bool> onCaregiverAlertsChanged;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingsToggleRow(
            icon: Icons.notifications_active_outlined,
            title: 'Push Notifications',
            value: pushEnabled,
            onChanged: onPushChanged,
          ),
          const _InfoDivider(),
          _SettingsToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Vibration Alerts',
            value: vibrationEnabled,
            onChanged: onVibrationChanged,
          ),
          const _InfoDivider(),
          _SettingsToggleRow(
            icon: Icons.format_size_rounded,
            title: 'Large-Text Alerts',
            value: largeTextEnabled,
            onChanged: onLargeTextChanged,
          ),
          const _InfoDivider(),
          _SettingsToggleRow(
            icon: Icons.diversity_3_rounded,
            title: 'Caregiver Alerts',
            value: caregiverAlertsEnabled,
            onChanged: onCaregiverAlertsChanged,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AuthPalette.powderBlue.withValues(alpha: 0.28), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: AuthPalette.textDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AuthPalette.softCoral,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AuthPalette.textMuted.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.item, required this.onTap});

  final _ReminderItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.title}, ${item.timeLabel}',
      child: Material(
        color: item.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: item.color.withValues(alpha: 0.4), shape: BoxShape.circle),
                  child: Icon(item.icon, size: 19, color: AuthPalette.textDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                  ),
                ),
                Text(
                  item.timeLabel,
                  style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: AuthPalette.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pastel pill showing the AI's confidence percentage for a cry alert,
/// colored by mood — the "Confidence chip" required on each alert row.
class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({required this.mood, required this.confidence});

  final _CryMood mood;
  final int confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: mood.color.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$confidence%',
        style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
      ),
    );
  }
}

class _CryAlertRow extends StatelessWidget {
  const _CryAlertRow({required this.alert, required this.onTap});

  final _CryAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${alert.mood.label}, ${alert.confidence} percent, detected by ${alert.caregiverName}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: alert.mood.color.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: Icon(alert.mood.icon, size: 19, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.mood.label,
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${alert.timeLabel} · Detected by ${alert.caregiverName}',
                      style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ConfidenceChip(mood: alert.mood, confidence: alert.confidence),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AuthPalette.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebrationRow extends StatelessWidget {
  const _CelebrationRow({required this.celebration});

  final _MilestoneCelebration celebration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: celebration.color.withValues(alpha: 0.32), shape: BoxShape.circle),
                child: Icon(celebration.icon, size: 21, color: AuthPalette.textDark),
              ),
              const Positioned(top: -4, left: -4, child: Icon(Icons.star_rounded, size: 12, color: AuthPalette.softCoral)),
              const Positioned(bottom: -3, right: -5, child: Icon(Icons.star_rounded, size: 9, color: AuthPalette.lavenderMist)),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            celebration.title,
            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
        ),
        Text(
          '🎉',
          style: GoogleFonts.nunito(fontSize: 16),
        ),
      ],
    );
  }
}

class _HistoryGroupLabel extends StatelessWidget {
  const _HistoryGroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted, letterSpacing: 0.4),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.isLast});

  final _HistoryEntry entry;
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: entry.color.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: Icon(entry.icon, size: 15, color: AuthPalette.textDark),
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
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                    ),
                  ),
                  Text(
                    entry.timeLabel,
                    style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted),
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

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AuthPalette.lavenderMist.withValues(alpha: 0.35),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: AuthPalette.softCoral, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            'All caught up',
            style: GoogleFonts.quicksand(fontSize: 16.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'New reminders and alerts will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _AccessibilityInfoCard extends StatelessWidget {
  const _AccessibilityInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuthPalette.mint.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AuthPalette.mint.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.accessibility_new_rounded, color: AuthPalette.textDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'For deaf parents, vibration and large-text alerts can help ensure important cry and caregiver '
              'notifications are not missed.',
              style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textDark, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastel bottom sheet with the detected pattern, suggested action, and a
/// safety note for a caregiver-triggered cry alert.
class _CryAlertDetailSheet extends StatelessWidget {
  const _CryAlertDetailSheet({required this.alert});

  final _CryAlert alert;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
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
        child: SingleChildScrollView(
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
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: alert.mood.color.withValues(alpha: 0.32)),
                    child: Icon(alert.mood.icon, color: AuthPalette.textDark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.mood.label,
                          style: GoogleFonts.quicksand(fontSize: 19, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${alert.timeLabel} · Detected by ${alert.caregiverName}',
                          style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted),
                        ),
                      ],
                    ),
                  ),
                  _ConfidenceChip(mood: alert.mood, confidence: alert.confidence),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AuthPalette.lavenderMist, height: 1),
              const SizedBox(height: 16),
              _DetailBlock(label: 'Detected Pattern', value: alert.mood.detectedPattern),
              const SizedBox(height: 14),
              _DetailBlock(label: 'Suggested Action', value: alert.mood.suggestedAction),
              const SizedBox(height: 18),
              const _AccessibilityInfoCard(),
              const SizedBox(height: 12),
              Container(
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
                        'Cry analysis provides a likely reason and is not a medical diagnosis.',
                        style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AuthPrimaryButton(label: 'Got it', isLoading: false, onPressed: () => Navigator.of(context).pop()),
            ],
          ),
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
          style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted, letterSpacing: 0.3),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textDark, height: 1.45),
        ),
      ],
    );
  }
}
