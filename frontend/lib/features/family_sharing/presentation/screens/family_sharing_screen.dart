import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../domain/entities/live_care_session.dart';
import '../../domain/entities/permission_level.dart';
import '../../domain/entities/shared_member.dart';
import '../../domain/entities/shared_notification.dart';

/// Family Sharing screen (SRS Section 10.20) — a collaborative caregiver
/// and accessibility hub for working parents and deaf parents.
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established across the app — the gradient backdrop, palette, and
/// rounded 28px card language come directly from
/// `features/authentication/presentation/widgets/` (read-only reuse;
/// those files are not modified).
///
/// All family/caregiver data, live session data, and notifications are
/// realistic local mock state — there is no backend, Firebase, real
/// sharing API, or push notification integration yet. Invite, permission
/// changes, and alerts all surface a friendly local snackbar only.
class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({super.key});

  @override
  State<FamilySharingScreen> createState() => _FamilySharingScreenState();
}

class _FamilySharingScreenState extends State<FamilySharingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _headerFade;
  late final Animation<double> _headerScale;

  final _contactController = TextEditingController();
  String _relationship = _relationshipOptions.first;
  PermissionLevel _invitePermission = PermissionLevel.viewOnly;

  bool _strongVibration = true;
  bool _largeTextMode = false;
  bool _visualCryAlerts = true;
  bool _colorCodedUrgency = true;
  bool _caregiverTextSummary = true;

  static const _relationshipOptions = <String>[
    'Grandparent',
    'Aunt / Uncle',
    'Sibling',
    'Nanny / Caregiver',
    'Doctor',
    'Other',
  ];

  static const _liveCareSession = LiveCareSession(
    currentCaregiver: 'Priya',
    lastFeedingTime: '11:16 AM',
    sleepStatus: 'Awake',
    lastCryLabel: 'Hungry',
    lastCryConfidence: 86,
    updatedLabel: 'Updated 2 min ago',
  );

  static const _notifications = <SharedNotification>[
    SharedNotification(type: SharedNotificationType.feeding, message: 'Lily may be hungry', timeLabel: '5 min ago'),
    SharedNotification(type: SharedNotificationType.cry, message: 'Cry detected by caregiver', timeLabel: '12 min ago'),
    SharedNotification(type: SharedNotificationType.sleep, message: 'Sleep started', timeLabel: '1 hour ago'),
    SharedNotification(type: SharedNotificationType.milestone, message: 'New milestone completed', timeLabel: '3 hours ago'),
  ];

  late final List<SharedMember> _members = [
    SharedMember(
      id: '1',
      name: 'Angel Joseph',
      relationship: 'Parent',
      avatarIcon: Icons.person_rounded,
      avatarColor: AuthPalette.softCoral,
      permission: PermissionLevel.fullAccess,
    ),
    SharedMember(
      id: '2',
      name: 'Priya Sharma',
      relationship: 'Grandmother',
      avatarIcon: Icons.elderly_woman_rounded,
      avatarColor: AuthPalette.mint,
      permission: PermissionLevel.caregiver,
    ),
    SharedMember(
      id: '3',
      name: 'Rahul Nair',
      relationship: 'Uncle',
      avatarIcon: Icons.man_rounded,
      avatarColor: AuthPalette.powderBlue,
      permission: PermissionLevel.viewOnly,
    ),
    SharedMember(
      id: '4',
      name: 'Dr. Meera Nair',
      relationship: 'Pediatrician',
      avatarIcon: Icons.medical_services_rounded,
      avatarColor: AuthPalette.lavenderMist,
      permission: PermissionLevel.alertOnly,
    ),
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
    _contactController.dispose();
    super.dispose();
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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

  /// Distinct green success confirmation — used specifically for the email
  /// invitation flow, kept visually separate from [_showToast]'s neutral
  /// dark snackbar used everywhere else.
  void _showSuccessBanner(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AuthPalette.mint,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AuthPalette.textDark, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.nunito(color: AuthPalette.textDark, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _handleSendInvite() {
    final contact = _contactController.text.trim();
    if (contact.isEmpty) {
      _showToast('Add an email or phone number to send an invite');
      return;
    }
    final looksLikeEmail = contact.contains('@');
    if (looksLikeEmail && !_emailPattern.hasMatch(contact)) {
      _showToast('Enter a valid email address');
      return;
    }
    if (looksLikeEmail) {
      _openInvitationPreview(contact);
    } else {
      _addPendingMember(contact);
      _showToast('Invite sent to $contact 🌙');
    }
  }

  void _addPendingMember(String contact) {
    setState(() {
      _members.add(
        SharedMember(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: contact,
          relationship: _relationship,
          avatarIcon: Icons.person_add_alt_1_rounded,
          avatarColor: AuthPalette.blushPink,
          permission: _invitePermission,
          isPending: true,
        ),
      );
      _contactController.clear();
      _relationship = _relationshipOptions.first;
      _invitePermission = PermissionLevel.viewOnly;
    });
  }

  void _openInvitationPreview(String email) {
    final permission = _invitePermission;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _InvitationPreviewSheet(
        email: email,
        permission: permission,
        onCancel: () => Navigator.of(context).pop(),
        onSend: () {
          Navigator.of(context).pop();
          _addPendingMember(email);
          _showSuccessBanner('Invitation sent to $email');
        },
      ),
    );
  }

  void _handleChangePermission(SharedMember member, PermissionLevel newPermission) {
    setState(() => member.permission = newPermission);
    _showToast("${member.name}'s permission updated to ${newPermission.label} 🌙");
  }

  Future<void> _confirmRemoveAccess(SharedMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _RemoveAccessDialog(memberName: member.name),
    );
    if (confirmed == true) {
      setState(() => _members.remove(member));
      _showToast('${member.name} no longer has access 🌙');
    }
  }

  void _handleResend(SharedMember member) {
    _showSuccessBanner('Invitation resent to ${member.name}');
  }

  void _handleCancelInvite(SharedMember member) {
    setState(() => _members.remove(member));
    _showToast('Invitation to ${member.name} canceled');
  }

  void _handleSendAlert() {
    _showToast('Alert sent to family 🌙');
  }

  void _openMemberDetails(SharedMember member) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PermissionDetailSheet(
        member: member,
        onChangePermission: (level) {
          _handleChangePermission(member, level);
          Navigator.of(context).pop();
        },
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
          const Positioned.fill(child: _FamilySharingFloatingDecor()),
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
                            child: ScaleTransition(scale: _headerScale, child: const _SharingHeaderCard()),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Family & Caregivers'),
                          const SizedBox(height: 10),
                          for (final member in _members) ...[
                            _MemberCard(
                              member: member,
                              onTap: () => _openMemberDetails(member),
                              onRemoveAccess: () => _confirmRemoveAccess(member),
                              onResend: () => _handleResend(member),
                              onCancelInvite: () => _handleCancelInvite(member),
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 12),
                          const _SectionHeading(title: 'Invite a Caregiver'),
                          const SizedBox(height: 10),
                          _InviteCaregiverCard(
                            contactController: _contactController,
                            relationship: _relationship,
                            relationshipOptions: _relationshipOptions,
                            onRelationshipChanged: (value) => setState(() => _relationship = value),
                            permission: _invitePermission,
                            onPermissionChanged: (value) => setState(() => _invitePermission = value),
                            onSendInvite: _handleSendInvite,
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Collaborative Cry Analysis'),
                          const SizedBox(height: 10),
                          const _CryWorkflowCard(),
                          const SizedBox(height: 14),
                          const _InfoBanner(
                            message: 'Cry analysis provides a likely reason and is not a medical diagnosis.',
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Live Care Session'),
                          const SizedBox(height: 10),
                          _LiveCareSessionCard(session: _liveCareSession, onSendAlert: _handleSendAlert),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Shared Notifications'),
                          const SizedBox(height: 10),
                          AuthCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < _notifications.length; i++) ...[
                                  if (i > 0) const _InfoDivider(),
                                  _NotificationRow(notification: _notifications[i]),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _SectionHeading(title: 'Deaf Parent Support'),
                          const SizedBox(height: 10),
                          _DeafParentSupportCard(
                            strongVibration: _strongVibration,
                            largeTextMode: _largeTextMode,
                            visualCryAlerts: _visualCryAlerts,
                            colorCodedUrgency: _colorCodedUrgency,
                            caregiverTextSummary: _caregiverTextSummary,
                            onStrongVibrationChanged: (value) {
                              setState(() => _strongVibration = value);
                              _showToast(value ? 'Strong Vibration Alert turned on 🌙' : 'Strong Vibration Alert turned off');
                            },
                            onLargeTextModeChanged: (value) {
                              setState(() => _largeTextMode = value);
                              _showToast(value ? 'Large Text Mode turned on 🌙' : 'Large Text Mode turned off');
                            },
                            onVisualCryAlertsChanged: (value) {
                              setState(() => _visualCryAlerts = value);
                              _showToast(value ? 'Visual Cry Alerts turned on 🌙' : 'Visual Cry Alerts turned off');
                            },
                            onColorCodedUrgencyChanged: (value) {
                              setState(() => _colorCodedUrgency = value);
                              _showToast(value ? 'Color-Coded Urgency turned on 🌙' : 'Color-Coded Urgency turned off');
                            },
                            onCaregiverTextSummaryChanged: (value) {
                              setState(() => _caregiverTextSummary = value);
                              _showToast(value ? 'Caregiver-to-Parent Text Summary turned on 🌙' : 'Caregiver-to-Parent Text Summary turned off');
                            },
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

/// Family Sharing-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used across
/// the app, so no shared or sibling screen file needs to change.
class _FamilySharingFloatingDecor extends StatefulWidget {
  const _FamilySharingFloatingDecor();

  @override
  State<_FamilySharingFloatingDecor> createState() => _FamilySharingFloatingDecorState();
}

class _FamilySharingFloatingDecorState extends State<_FamilySharingFloatingDecor>
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
    return Divider(color: AuthPalette.lavenderMist.withValues(alpha: 0.4), height: 1);
  }
}

class _SharingHeaderCard extends StatelessWidget {
  const _SharingHeaderCard();

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
            child: const Icon(Icons.diversity_3_rounded, color: AuthPalette.softCoral, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sharing & Access',
                  style: GoogleFonts.quicksand(fontSize: 22, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  "Collaborate with family and caregivers in Lily's care",
                  style: GoogleFonts.nunito(fontSize: 13, color: AuthPalette.textMuted, height: 1.4),
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
  const _StatusChip({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AuthPalette.textDark),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
          ),
        ],
      ),
    );
  }
}

enum _MemberAction { changePermission, removeAccess }

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.onTap,
    required this.onRemoveAccess,
    required this.onResend,
    required this.onCancelInvite,
  });

  final SharedMember member;
  final VoidCallback onTap;
  final VoidCallback onRemoveAccess;
  final VoidCallback onResend;
  final VoidCallback onCancelInvite;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${member.name}, ${member.relationship}, ${member.permission.label}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AuthPalette.softCoral.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (member.isPending ? AuthPalette.blushPink : member.avatarColor).withValues(alpha: 0.32),
                      ),
                      child: Icon(
                        member.isPending ? Icons.schedule_rounded : member.avatarIcon,
                        color: AuthPalette.textDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.relationship,
                            style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _StatusChip(label: member.permission.label, icon: member.permission.icon, color: member.permission.color),
                              if (member.isPending)
                                const _StatusChip(label: 'Pending', icon: Icons.hourglass_top_rounded, color: AuthPalette.blushPink),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (!member.isPending)
                      PopupMenuButton<_MemberAction>(
                        icon: const Icon(Icons.more_vert_rounded, color: AuthPalette.textMuted, size: 20),
                        tooltip: 'More options',
                        color: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (action) {
                          switch (action) {
                            case _MemberAction.changePermission:
                              onTap();
                            case _MemberAction.removeAccess:
                              onRemoveAccess();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: _MemberAction.changePermission,
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined, size: 18, color: AuthPalette.textDark),
                                const SizedBox(width: 10),
                                Text(
                                  'Change Permission',
                                  style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w600, color: AuthPalette.textDark),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: _MemberAction.removeAccess,
                            child: Row(
                              children: [
                                const Icon(Icons.person_remove_outlined, size: 18, color: AuthPalette.error),
                                const SizedBox(width: 10),
                                Text(
                                  'Remove Access',
                                  style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w600, color: AuthPalette.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (member.isPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallActionButton(
                          label: 'Resend',
                          icon: Icons.refresh_rounded,
                          color: AuthPalette.powderBlue,
                          onTap: onResend,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SmallActionButton(
                          label: 'Cancel Invite',
                          icon: Icons.close_rounded,
                          color: AuthPalette.error,
                          onTap: onCancelInvite,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.55)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteCaregiverCard extends StatelessWidget {
  const _InviteCaregiverCard({
    required this.contactController,
    required this.relationship,
    required this.relationshipOptions,
    required this.onRelationshipChanged,
    required this.permission,
    required this.onPermissionChanged,
    required this.onSendInvite,
  });

  final TextEditingController contactController;
  final String relationship;
  final List<String> relationshipOptions;
  final ValueChanged<String> onRelationshipChanged;
  final PermissionLevel permission;
  final ValueChanged<PermissionLevel> onPermissionChanged;
  final VoidCallback onSendInvite;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: contactController,
            label: 'Email or Phone',
            hintText: 'e.g. priya@email.com',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (_) => null,
            enabled: true,
          ),
          const SizedBox(height: 14),
          Text(
            'Relationship',
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: relationship,
            icon: const Icon(Icons.expand_more_rounded, color: AuthPalette.textMuted),
            style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(20),
            decoration: authPastelDecoration(label: '', hint: 'Select relationship', prefixIcon: Icons.diversity_3_outlined),
            items: [
              for (final option in relationshipOptions) DropdownMenuItem(value: option, child: Text(option)),
            ],
            onChanged: (value) {
              if (value != null) onRelationshipChanged(value);
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Permission',
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PermissionLevel>(
            initialValue: permission,
            icon: const Icon(Icons.expand_more_rounded, color: AuthPalette.textMuted),
            style: GoogleFonts.nunito(fontSize: 15, color: AuthPalette.textDark),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(20),
            decoration: authPastelDecoration(label: '', hint: 'Select permission', prefixIcon: Icons.shield_outlined),
            items: [
              for (final level in PermissionLevel.values)
                DropdownMenuItem(value: level, child: Text(level.label)),
            ],
            onChanged: (value) {
              if (value != null) onPermissionChanged(value);
            },
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(label: 'Send Invite', isLoading: false, onPressed: onSendInvite),
        ],
      ),
    );
  }
}

class _CryWorkflowCard extends StatelessWidget {
  const _CryWorkflowCard();

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How collaborative cry analysis works',
            style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WorkflowStep(
                  icon: Icons.mic_rounded,
                  color: AuthPalette.powderBlue,
                  label: 'Caregiver\nrecords cry',
                ),
              ),
              _WorkflowConnector(),
              Expanded(
                child: _WorkflowStep(
                  icon: Icons.graphic_eq_rounded,
                  color: AuthPalette.lavenderMist,
                  label: 'AI\nanalyzes',
                ),
              ),
              _WorkflowConnector(),
              Expanded(
                child: _WorkflowStep(
                  icon: Icons.notifications_active_rounded,
                  color: AuthPalette.softCoral,
                  label: 'Family\nreceives alert',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.32)),
          child: Icon(icon, color: AuthPalette.textDark, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 10.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark, height: 1.3),
        ),
      ],
    );
  }
}

class _WorkflowConnector extends StatelessWidget {
  const _WorkflowConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Icon(Icons.arrow_forward_rounded, size: 16, color: AuthPalette.lavenderMist.withValues(alpha: 0.8)),
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

class _LiveCareSessionCard extends StatelessWidget {
  const _LiveCareSessionCard({required this.session, required this.onSendAlert});

  final LiveCareSession session;
  final VoidCallback onSendAlert;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: AuthPalette.mint, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'Live now · ${session.currentCaregiver} is caring for Lily',
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LiveStat(icon: Icons.local_drink_outlined, label: 'Last Feeding', value: session.lastFeedingTime),
              ),
              _liveDivider(),
              Expanded(
                child: _LiveStat(icon: Icons.bedtime_outlined, label: 'Sleep', value: session.sleepStatus),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AuthPalette.blushPink.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, size: 16, color: AuthPalette.softCoral),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Last cry: ${session.lastCryLabel} · ${session.lastCryConfidence}%',
                    style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            session.updatedLabel,
            style: GoogleFonts.nunito(fontSize: 11, color: AuthPalette.textMuted),
          ),
          const SizedBox(height: 14),
          AuthOutlineButton(
            label: 'Send Alert to Family',
            icon: Icons.campaign_outlined,
            accent: AuthPalette.softCoral,
            isLoading: false,
            onPressed: onSendAlert,
          ),
        ],
      ),
    );
  }

  Widget _liveDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
    );
  }
}

class _LiveStat extends StatelessWidget {
  const _LiveStat({required this.icon, required this.label, required this.value});

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
          style: GoogleFonts.quicksand(fontSize: 14, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
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

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final SharedNotification notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: notification.type.color.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(notification.type.icon, size: 18, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notification.message,
              style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
            ),
          ),
          Text(
            notification.timeLabel,
            style: GoogleFonts.nunito(fontSize: 11.5, color: AuthPalette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DeafParentSupportCard extends StatelessWidget {
  const _DeafParentSupportCard({
    required this.strongVibration,
    required this.largeTextMode,
    required this.visualCryAlerts,
    required this.colorCodedUrgency,
    required this.caregiverTextSummary,
    required this.onStrongVibrationChanged,
    required this.onLargeTextModeChanged,
    required this.onVisualCryAlertsChanged,
    required this.onColorCodedUrgencyChanged,
    required this.onCaregiverTextSummaryChanged,
  });

  final bool strongVibration;
  final bool largeTextMode;
  final bool visualCryAlerts;
  final bool colorCodedUrgency;
  final bool caregiverTextSummary;
  final ValueChanged<bool> onStrongVibrationChanged;
  final ValueChanged<bool> onLargeTextModeChanged;
  final ValueChanged<bool> onVisualCryAlertsChanged;
  final ValueChanged<bool> onColorCodedUrgencyChanged;
  final ValueChanged<bool> onCaregiverTextSummaryChanged;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AuthPalette.lavenderMist.withValues(alpha: 0.32), shape: BoxShape.circle),
                child: const Icon(Icons.accessibility_new_rounded, size: 18, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Built for deaf and hard-of-hearing parents',
                  style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const _InfoDivider(),
          _AccessibilityToggleRow(
            icon: Icons.vibration_rounded,
            title: 'Strong Vibration Alert',
            subtitle: "Intense vibration pattern when Lily cries",
            value: strongVibration,
            onChanged: onStrongVibrationChanged,
          ),
          const _InfoDivider(),
          _AccessibilityToggleRow(
            icon: Icons.format_size_rounded,
            title: 'Large Text Mode',
            subtitle: 'Bigger, bolder text throughout the app',
            value: largeTextMode,
            onChanged: onLargeTextModeChanged,
          ),
          const _InfoDivider(),
          _AccessibilityToggleRow(
            icon: Icons.visibility_rounded,
            title: 'Visual Cry Alerts',
            subtitle: 'Full-screen flash and banner instead of sound',
            value: visualCryAlerts,
            onChanged: onVisualCryAlertsChanged,
          ),
          const _InfoDivider(),
          _AccessibilityToggleRow(
            icon: Icons.palette_rounded,
            title: 'Color-Coded Urgency',
            subtitle: 'Red, amber, and green cues for how urgent an alert is',
            value: colorCodedUrgency,
            onChanged: onColorCodedUrgencyChanged,
          ),
          const _InfoDivider(),
          _AccessibilityToggleRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Caregiver-to-Parent Text Summary',
            subtitle: 'Caregivers can send short written updates instead of calling',
            value: caregiverTextSummary,
            onChanged: onCaregiverTextSummaryChanged,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _AccessibilityToggleRow extends StatelessWidget {
  const _AccessibilityToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLast ? 12 : 10).copyWith(bottom: isLast ? 2 : 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: AuthPalette.powderBlue.withValues(alpha: 0.28), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(fontSize: 11, color: AuthPalette.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AuthPalette.softCoral,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AuthPalette.textMuted.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// Pastel bottom sheet shown when a family/caregiver card is tapped.
class _PermissionDetailSheet extends StatelessWidget {
  const _PermissionDetailSheet({required this.member, required this.onChangePermission});

  final SharedMember member;
  final ValueChanged<PermissionLevel> onChangePermission;

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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: member.avatarColor.withValues(alpha: 0.32)),
                    child: Icon(member.avatarIcon, color: AuthPalette.textDark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: GoogleFonts.quicksand(fontSize: 18, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.relationship,
                          style: GoogleFonts.nunito(fontSize: 12.5, color: AuthPalette.textMuted),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(label: member.permission.label, icon: member.permission.icon, color: member.permission.color),
                ],
              ),
              const SizedBox(height: 18),
              const _InfoDivider(),
              const SizedBox(height: 14),
              _PermissionDetailBlock(label: 'What they can view', items: member.permission.canView, icon: Icons.check_circle_rounded, color: AuthPalette.mint),
              const SizedBox(height: 14),
              _PermissionDetailBlock(label: 'What they can add', items: member.permission.canAdd, icon: Icons.add_circle_rounded, color: AuthPalette.powderBlue),
              const SizedBox(height: 14),
              _PermissionDetailBlock(label: 'What they cannot modify', items: member.permission.cannotModify, icon: Icons.block_rounded, color: AuthPalette.error),
              const SizedBox(height: 20),
              Text(
                'Change Permission',
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textMuted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final level in PermissionLevel.values)
                    _PermissionOptionChip(
                      level: level,
                      selected: level == member.permission,
                      onTap: () => onChangePermission(level),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionDetailBlock extends StatelessWidget {
  const _PermissionDetailBlock({required this.label, required this.items, required this.icon, required this.color});

  final String label;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted, letterSpacing: 0.3),
        ),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.nunito(fontSize: 13, color: AuthPalette.textDark, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PermissionOptionChip extends StatelessWidget {
  const _PermissionOptionChip({required this.level, required this.selected, required this.onTap});

  final PermissionLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? level.color.withValues(alpha: 0.45) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? Colors.transparent : AuthPalette.lavenderMist.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(level.icon, size: 14, color: AuthPalette.textDark),
              const SizedBox(width: 6),
              Text(
                level.label,
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirmation dialog shown before a member's access is removed.
class _RemoveAccessDialog extends StatelessWidget {
  const _RemoveAccessDialog({required this.memberName});

  final String memberName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        decoration: BoxDecoration(
          color: AuthPalette.warmCream,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AuthPalette.softCoral.withValues(alpha: 0.22),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AuthPalette.error.withValues(alpha: 0.16)),
              child: const Icon(Icons.person_remove_rounded, color: AuthPalette.error, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Remove access?',
              style: GoogleFonts.quicksand(fontSize: 19, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              '$memberName will no longer be able to view or receive cry alerts for Lily.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 13, color: AuthPalette.textMuted, height: 1.45),
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
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DangerButton(
                    label: 'Remove',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Material(
        color: AuthPalette.error,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Invitation Preview" pastel bottom sheet — a UI-only simulation of an
/// outgoing email invite. No real email is sent; the mock body below is
/// static, hand-written copy shown purely for preview purposes.
class _InvitationPreviewSheet extends StatelessWidget {
  const _InvitationPreviewSheet({
    required this.email,
    required this.permission,
    required this.onSend,
    required this.onCancel,
  });

  final String email;
  final PermissionLevel permission;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  String get _mockEmailBody =>
      "Hi there,\n\nYou've been invited to help care for Lily on LullaByte as a ${permission.label}. "
      'Accept the invite to view updates, log care activities, and stay connected with the family.\n\n'
      'With love,\nThe LullaByte Family';

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
              Text(
                'Invitation Preview',
                style: GoogleFonts.quicksand(fontSize: 19, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                "Here's what will be sent — no real email is sent yet.",
                style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PreviewFieldRow(label: 'To', value: email),
                    const SizedBox(height: 8),
                    const _PreviewFieldRow(label: 'Baby', value: 'Lily'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Permission',
                          style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted),
                        ),
                        const Spacer(),
                        _StatusChip(label: permission.label, icon: permission.icon, color: permission.color),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _InfoDivider(),
                    const SizedBox(height: 14),
                    Text(
                      _mockEmailBody,
                      style: GoogleFonts.nunito(fontSize: 13, color: AuthPalette.textDark, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AuthOutlineButton(
                      label: 'Cancel',
                      icon: Icons.close_rounded,
                      accent: AuthPalette.lavenderMist,
                      isLoading: false,
                      onPressed: onCancel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthPrimaryButton(label: 'Send', isLoading: false, onPressed: onSend),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewFieldRow extends StatelessWidget {
  const _PreviewFieldRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 11.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
          ),
        ),
      ],
    );
  }
}
