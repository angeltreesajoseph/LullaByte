import '../../../../core/network/care_dio.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/auth/firebase_auth_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../application/baby_profile_store.dart';
import '../widgets/baby_avatar.dart';
import '../../../family_sharing/presentation/widgets/join_care_team_card.dart';

/// Baby Profile screen (SRS Section 10.13).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, Dashboard, and Cry
/// Analyzer — the gradient backdrop, palette, and rounded 28px card
/// language come directly from `features/authentication/presentation/
/// widgets/` (read-only reuse; those files are not modified).
///
/// Displays the selected baby's saved details. The owner can edit that
/// profile; charts, reports and memories remain in their dedicated sections.
class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key, this.api, this.showAccountActions = true});
  final Dio? api;
  final bool showAccountActions;

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign in again anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoggingOut = true);
    await FirebaseAuthService().signOut();
    if (!mounted) return;
    context.go(RoutePaths.login);
  }

  late final Animation<Offset> _contentSlide;
  late final Animation<double> _avatarFade;
  late final Animation<double> _avatarScale;

  // Values follow the selected baby, including when switching twins.
  String get _babyName => BabyProfileStore.name;
  String get _ageLabel {
    final date = _dateOfBirth;
    if (date == null) return 'Age not recorded';
    final now = DateTime.now();
    var months = (now.year - date.year) * 12 + now.month - date.month;
    if (now.day < date.day) months--;
    if (months < 1)
      return '${now.difference(date).inDays.clamp(0, 30)} days old';
    return '$months month${months == 1 ? '' : 's'} old';
  }

  String get _bornLabel {
    final date = _dateOfBirth;
    return date == null
        ? 'Birth date not recorded'
        : 'Born ${date.day} ${_month(date.month)} ${date.year}';
  }

  DateTime? get _dateOfBirth =>
      DateTime.tryParse(BabyProfileStore.data['birth_date'] as String? ?? '');
  String _month(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
  static const _healthStatus = 'Profile';
  String get _weight => _valueWithUnit('birth_weight_kg', 'kg');
  String get _height => _valueWithUnit('birth_length_cm', 'cm');
  String get _headCircumference =>
      _valueWithUnit('head_circumference_cm', 'cm');
  String get _gender =>
      (BabyProfileStore.data['gender'] as String?) ?? 'Not recorded';
  String get _bloodGroup =>
      (BabyProfileStore.data['blood_group'] as String?) ?? 'Not recorded';
  String get _allergies =>
      (BabyProfileStore.data['allergies'] as String?) ?? 'Not recorded';
  String get _pediatrician =>
      (BabyProfileStore.data['pediatrician'] as String?) ?? 'Not recorded';
  String get _hospital =>
      (BabyProfileStore.data['hospital'] as String?) ?? 'Not recorded';

  String _valueWithUnit(String key, String unit) {
    final value = BabyProfileStore.data[key];
    return value == null ? 'Not recorded' : '$value $unit';
  }

  @override
  void initState() {
    super.initState();
    BabyProfileStore.changes.addListener(_refreshProfile);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _avatarFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );
    _avatarScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    BabyProfileStore.changes.removeListener(_refreshProfile);
    _entranceController.dispose();
    super.dispose();
  }

  void _refreshProfile() {
    if (mounted) setState(() {});
  }

  bool get _canEdit =>
      BabyProfileStore.id != null &&
      !{'viewer', 'caregiver'}.contains(BabyProfileStore.data['access_role']);

  String _contact(String key) {
    final text = BabyProfileStore.data[key]?.toString().trim() ?? '';
    return text.isEmpty ? 'Not recorded' : text;
  }

  void _editProfile() {
    if (!_canEdit) return;
    final baby = Map<String, dynamic>.from(BabyProfileStore.data);
    final screen = _EditBabyProfileScreen(
      api: widget.api,
      baby: baby,
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
    );
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => screen));
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                              BackButton(
                                onPressed: () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    context.go(RoutePaths.dashboard);
                                  }
                                },
                              ),
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
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (BabyProfileStore.id == null)
                            const AuthCard(
                              child: Text(
                                'Choose a baby from Home to view their profile.',
                              ),
                            )
                          else ...[
                            FadeTransition(
                              opacity: _avatarFade,
                              child: ScaleTransition(
                                scale: _avatarScale,
                                child: _ProfileHeroCard(
                                  babyName: _babyName,
                                  ageLabel: _ageLabel,
                                  bornLabel: _bornLabel,
                                  healthStatus: _healthStatus,
                                  weight: _weight,
                                  height: _height,
                                  headCircumference: _headCircumference,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.go(RoutePaths.growth),
                              icon: const Icon(Icons.show_chart_rounded),
                              label: const Text('View growth tracker'),
                            ),
                            const SizedBox(height: 10),
                            _SectionHeading(title: 'Baby details'),
                            const SizedBox(height: 10),
                            AuthCard(
                              child: Column(
                                children: [
                                  _InfoRow(
                                    icon: Icons.wc_rounded,
                                    label: 'Gender',
                                    value: _gender,
                                  ),
                                  _InfoDivider(),
                                  _InfoRow(
                                    icon: Icons.bloodtype_outlined,
                                    label: 'Blood group',
                                    value: _bloodGroup,
                                  ),
                                  _InfoDivider(),
                                  _InfoRow(
                                    icon: Icons.health_and_safety_outlined,
                                    label: 'Allergies',
                                    value: _allergies,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            _SectionHeading(title: 'Care contacts'),
                            const SizedBox(height: 10),
                            AuthCard(
                              child: Column(
                                children: [
                                  _InfoRow(
                                    icon: Icons.phone_outlined,
                                    label: 'Parent contact',
                                    value: _contact('parent_phone'),
                                  ),
                                  _InfoDivider(),
                                  _InfoRow(
                                    icon: Icons.medical_services_outlined,
                                    label: 'Pediatrician',
                                    value: _pediatrician,
                                  ),
                                  _InfoDivider(),
                                  _InfoRow(
                                    icon: Icons.phone_outlined,
                                    label: 'Pediatrician contact',
                                    value: _contact('pediatrician_phone'),
                                  ),
                                  _InfoDivider(),
                                  _InfoRow(
                                    icon: Icons.local_hospital_outlined,
                                    label: 'Hospital',
                                    value: _hospital,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            if (_canEdit)
                              AuthPrimaryButton(
                                label: 'Edit Profile',
                                isLoading: false,
                                onPressed: _editProfile,
                              )
                            else
                              const AuthCard(
                                child: Text(
                                  'Shared profile. Only the parent can edit baby details.',
                                ),
                              ),
                            const SizedBox(height: 22),
                          ],
                          if (widget.showAccountActions) ...[
                          _FamilySharingCard(
                            onTap: () => context.go(RoutePaths.familySharing),
                          ),
                          const SizedBox(height: 12),
                          const JoinCareTeamCard(),
                          const SizedBox(height: 22),
                          AuthOutlineButton(
                            label: 'Log Out',
                            icon: Icons.logout_rounded,
                            accent: Colors.redAccent,
                            isLoading: _isLoggingOut,
                            onPressed: _isLoggingOut ? null : _logout,
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

/// Baby Profile-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation (matching the pattern already used by
/// Dashboard and Cry Analyzer) so no shared or sibling screen file needs
/// to change.
class _ProfileFloatingDecor extends StatefulWidget {
  const _ProfileFloatingDecor();

  @override
  State<_ProfileFloatingDecor> createState() => _ProfileFloatingDecorState();
}

class _ProfileFloatingDecorState extends State<_ProfileFloatingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.03,
      left: 0.88,
      size: 12,
      color: AuthPalette.softCoral,
      phase: 0.0,
    ),
    _DecorSpec(
      icon: Icons.cloud_rounded,
      top: 0.07,
      left: 0.08,
      size: 20,
      color: AuthPalette.powderBlue,
      phase: 0.45,
    ),
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.18,
      left: 0.05,
      size: 10,
      color: AuthPalette.mint,
      phase: 0.2,
    ),
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.30,
      left: 0.93,
      size: 11,
      color: AuthPalette.lavenderMist,
      phase: 0.65,
    ),
    _DecorSpec(
      icon: Icons.cloud_rounded,
      top: 0.50,
      left: 0.90,
      size: 16,
      color: AuthPalette.blushPink,
      phase: 0.1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
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
                      final t =
                          (math.sin(
                                (_controller.value + spec.phase) * math.pi * 2,
                              ) +
                              1) /
                          2;
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
        style: GoogleFonts.quicksand(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AuthPalette.textDark,
        ),
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
    required this.weight,
    required this.height,
    required this.headCircumference,
  });

  final String babyName;
  final String ageLabel;
  final String bornLabel;
  final String healthStatus;
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
        border: Border.all(
          color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
        ),
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
                child: const BabyAvatar(size: 84),
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
                      style: GoogleFonts.nunito(
                        fontSize: 13.5,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                    Text(
                      bornLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AuthPalette.mint.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 13,
                            color: AuthPalette.textDark,
                          ),
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
          const SizedBox(height: 12),
          Text(
            'Registration measurements',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AuthPalette.textMuted,
            ),
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
                  child: _StatBlock(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight',
                    value: weight,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _StatBlock(
                    icon: Icons.straighten_outlined,
                    label: 'Height',
                    value: height,
                  ),
                ),
                _statDivider(),
                Expanded(
                  child: _StatBlock(
                    icon: Icons.circle_outlined,
                    label: 'Head',
                    value: headCircumference,
                  ),
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
  const _StatBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

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
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AuthPalette.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10.5,
            color: AuthPalette.textMuted,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              color: AuthPalette.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textDark,
              ),
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
    return Divider(
      color: AuthPalette.lavenderMist.withValues(alpha: 0.4),
      height: 1,
    );
  }
}

class _FamilySharingCard extends StatelessWidget {
  const _FamilySharingCard({required this.onTap});

  final VoidCallback onTap;

  static const _avatarColors = [
    AuthPalette.softCoral,
    AuthPalette.powderBlue,
    AuthPalette.mint,
  ];

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
                  child: const Icon(
                    Icons.family_restroom_rounded,
                    size: 21,
                    color: AuthPalette.textDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Sharing',
                        style: GoogleFonts.quicksand(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: AuthPalette.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Invite caregivers and manage access',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AuthPalette.textMuted,
                        ),
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
                            child: const Icon(
                              Icons.person_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AuthPalette.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _formatEditDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// Full-screen Edit Baby Profile page, reached from the Baby Profile
/// screen's Edit Profile button via `Navigator.push`. Reuses the same pastel design
/// language and shared background components already established on this
/// screen (including the private [_ProfileFloatingDecor] defined above).
///
/// The original baby ID is frozen when opened. Save persists through the
/// authenticated backend without changing another active baby's details.
class _EditBabyProfileScreen extends StatefulWidget {
  const _EditBabyProfileScreen({
    this.api,
    required this.baby,
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
  final Map<String, dynamic> baby;
  final Dio? api;
  final DateTime? initialDateOfBirth;
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
  String? _photoData;
  bool _saving = false;

  Future<void> _pickProfilePhoto() async {
    if (_saving) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 65,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return;
      final data = base64Encode(await picked.readAsBytes());
      if (data.length > 500000) throw StateError('Photo too large');
      if (mounted) setState(() => _photoData = data);
    } catch (_) {
      if (mounted)
        _showToast('Could not select this photo. Try a smaller image.');
    }
  }

  static const _genderOptions = <String>['Girl', 'Boy', 'Other'];
  static const _bloodGroupOptions = <String>[
    'Not recorded',
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _headCircumferenceController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _pediatricianController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _parentPhoneController;
  late final TextEditingController _doctorPhoneController;

  late DateTime? _dateOfBirth;
  late String _gender;
  late String _bloodGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    String recorded(String value) => value == 'Not recorded' ? '' : value;
    _weightController = TextEditingController(
      text: recorded(widget.initialWeight).split(' ').first,
    );
    _heightController = TextEditingController(
      text: recorded(widget.initialHeight).split(' ').first,
    );
    _headCircumferenceController = TextEditingController(
      text: recorded(widget.initialHeadCircumference).split(' ').first,
    );
    _allergiesController = TextEditingController(
      text: recorded(widget.initialAllergies),
    );
    _pediatricianController = TextEditingController(
      text: recorded(widget.initialPediatrician),
    );
    _hospitalController = TextEditingController(
      text: recorded(widget.initialHospital),
    );
    _parentPhoneController = TextEditingController(
      text: widget.baby['parent_phone'] as String? ?? '',
    );
    _doctorPhoneController = TextEditingController(
      text: widget.baby['pediatrician_phone'] as String? ?? '',
    );
    _dateOfBirth = widget.initialDateOfBirth;
    _gender = switch (widget.initialGender.toLowerCase()) {
      'girl' || 'female' => 'Girl',
      'boy' || 'male' => 'Boy',
      _ => 'Other',
    };
    _bloodGroup = _bloodGroupOptions.contains(widget.initialBloodGroup)
        ? widget.initialBloodGroup
        : _bloodGroupOptions.first;
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
    _parentPhoneController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AuthPalette.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            message,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth == null || _dateOfBirth!.isAfter(now)
          ? now
          : _dateOfBirth!,
      firstDate: _dateOfBirth != null && _dateOfBirth!.year < now.year - 10
          ? _dateOfBirth!
          : DateTime(now.year - 10),
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
              style: TextButton.styleFrom(
                foregroundColor: AuthPalette.softCoral,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _dateOfBirth = picked);
  }

  Future<void> _handleSave() async {
    if (_saving) return;
    final id = widget.baby['id'] as String?;
    if (id == null) return;
    if (_nameController.text.trim().isEmpty) {
      _showToast('Enter the baby\'s name.');
      return;
    }
    final phonePattern = RegExp(r'^[+0-9() .-]{0,32}$');
    if (!phonePattern.hasMatch(_parentPhoneController.text.trim()) ||
        !phonePattern.hasMatch(_doctorPhoneController.text.trim())) {
      _showToast('Enter a valid contact number (up to 32 characters).');
      return;
    }
    setState(() => _saving = true);
    double? measurement(TextEditingController controller) =>
        double.tryParse(controller.text.trim().split(' ').first);
    try {
      final dio =
          widget.api ?? careDio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      if (widget.api == null) {
        final user = FirebaseAuthService().currentUser;
        if (user == null) throw StateError('Please sign in again.');
        dio.options.headers['Authorization'] =
            'Bearer ${await user.getIdToken()}';
      }
      final response = await dio.patch<Map<String, dynamic>>(
        '/babies/$id',
        data: {
          if (_photoData != null) 'photo_data': _photoData,
          'name': _nameController.text.trim(),
          'birth_date': _dateOfBirth?.toIso8601String().split('T').first,
          'gender': _gender == 'Girl'
              ? 'female'
              : _gender == 'Boy'
              ? 'male'
              : 'unspecified',
          'parent_phone': _parentPhoneController.text.trim(),
          'pediatrician_phone': _doctorPhoneController.text.trim(),
          'blood_group': _bloodGroup == 'Not recorded' ? null : _bloodGroup,
          'birth_weight_kg': measurement(_weightController),
          'birth_length_cm': measurement(_heightController),
          'head_circumference_cm': measurement(_headCircumferenceController),
          'allergies': _allergiesController.text.trim(),
          'pediatrician': _pediatricianController.text.trim(),
          'hospital': _hospitalController.text.trim(),
        },
      );
      if (!mounted) return;
      final data = {
        ...Map<String, dynamic>.from(response.data!['data'] as Map),
        'access_role': widget.baby['access_role'] ?? 'owner',
      };
      BabyProfileStore.babies = BabyProfileStore.babies
          .map((baby) => baby['id'] == id ? data : baby)
          .toList();
      if (BabyProfileStore.id == id) BabyProfileStore.select(data);
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) _showToast('Could not save changes. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                          AuthBackButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
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
                        child: GestureDetector(
                          onTap: _pickProfilePhoto,
                          child: Column(
                            children: [
                              BabyAvatar(
                                size: 84,
                                profile: {
                                  ...widget.baby,
                                  if (_photoData != null)
                                    'photo_data': _photoData,
                                },
                              ),
                              const Text('Change photo'),
                            ],
                          ),
                        ),
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
                              value: _dateOfBirth == null
                                  ? 'Not recorded'
                                  : _formatEditDate(_dateOfBirth!),
                              onTap: _pickDateOfBirth,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gender',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AuthPalette.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _EditGenderSelector(
                              options: _genderOptions,
                              selected: _gender,
                              onChanged: (value) =>
                                  setState(() => _gender = value),
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
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AuthPalette.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _bloodGroup,
                              icon: const Icon(
                                Icons.expand_more_rounded,
                                color: AuthPalette.textMuted,
                              ),
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                color: AuthPalette.textDark,
                              ),
                              decoration: authPastelDecoration(
                                label: '',
                                hint: 'Select blood group',
                                prefixIcon: Icons.bloodtype_outlined,
                              ),
                              items: [
                                for (final group in _bloodGroupOptions)
                                  DropdownMenuItem(
                                    value: group,
                                    child: Text(group),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value != null)
                                  setState(() => _bloodGroup = value);
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _allergiesController,
                              maxLines: 2,
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                color: AuthPalette.textDark,
                              ),
                              cursorColor: AuthPalette.softCoral,
                              decoration: authPastelDecoration(
                                label: 'Allergies',
                                hint: 'e.g. None known',
                                prefixIcon: Icons.health_and_safety_outlined,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: _parentPhoneController,
                              label: 'Parent contact (optional)',
                              hintText: '+91 phone number',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (_) => null,
                              enabled: !_saving,
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
                              controller: _doctorPhoneController,
                              label: 'Pediatrician contact (optional)',
                              hintText: 'Clinic phone number',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (_) => null,
                              enabled: !_saving,
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
                              onPressed: _saving ? null : _handleSave,
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

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

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
          labelStyle: GoogleFonts.nunito(
            color: AuthPalette.textMuted,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.cake_outlined,
            color: AuthPalette.textMuted,
          ),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AuthPalette.textMuted,
            size: 18,
          ),
          filled: true,
          fillColor: AuthPalette.blushPink.withValues(alpha: 0.28),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AuthPalette.lavenderMist.withValues(alpha: 0.7),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AuthPalette.softCoral,
              width: 2,
            ),
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
  const _EditGenderSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

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
  const _EditGenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
        color: selected
            ? AuthPalette.softCoral
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : AuthPalette.lavenderMist.withValues(alpha: 0.6),
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
