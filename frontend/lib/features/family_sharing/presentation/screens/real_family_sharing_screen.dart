import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/care_dio.dart';
import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../application/shared_care_connection.dart';
import '../../application/shared_care_notifications.dart';
import '../../../baby_management/data/baby_api.dart';

bool needsInvitationVerification({
  required bool signedIn,
  required bool emailVerified,
  required bool reviewingInvitation,
}) => signedIn && !emailVerified && reviewingInvitation;

class FamilySharingScreen extends StatefulWidget {
  const FamilySharingScreen({
    super.key,
    this.api,
    this.invitationId,
    this.joinMode = false,
    this.notificationStatus,
    this.setNotifications,
  });
  final Dio? api;
  final String? invitationId;
  final bool joinMode;
  final Future<bool> Function()? notificationStatus;
  final Future<void> Function(bool)? setNotifications;
  @override
  State<FamilySharingScreen> createState() => _FamilySharingState();
}

class _FamilySharingState extends State<FamilySharingScreen>
    with WidgetsBindingObserver {
  final _invitation = TextEditingController();
  late final Dio _api =
      widget.api ?? careDio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  List<Map<String, dynamic>> _babies = [], _shares = [];
  String? _babyId, _error;
  String? _joinedBabyId;
  bool get _joinFlow => widget.joinMode || widget.invitationId != null;
  bool _busy = true, _notifications = false, _notificationBusy = false;
  bool _reviewingInvitation = false;
  bool get _signedIn =>
      widget.api != null || FirebaseAuth.instance.currentUser != null;
  bool get _needsVerification => needsInvitationVerification(
    signedIn: _signedIn,
    emailVerified:
        widget.api != null ||
        FirebaseAuth.instance.currentUser?.emailVerified == true,
    reviewingInvitation:
        widget.joinMode ||
        _reviewingInvitation ||
        _invitation.text.isNotEmpty ||
        _shares.any(
          (s) =>
              s['baby_id'] == _babyId &&
              s['is_owner'] != true &&
              s['status'] == 'pending',
        ),
  );

  List<Map<String, dynamic>> get _choices {
    final result = [..._babies];
    for (final share in _shares) {
      if (!result.any((b) => b['id'] == share['baby_id'])) {
        result.add({
          'id': share['baby_id'],
          'name': share['baby_name'],
          'access_role': 'pending',
        });
      }
    }
    return result;
  }

  bool get _owner =>
      _babies.any((b) => b['id'] == _babyId && b['access_role'] == 'owner');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.invitationId != null)
      PendingCareInvitation.id = widget.invitationId;
    _invitation.text = PendingCareInvitation.id ?? '';
    _load(refreshIdentity: false);
    _readNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _invitation.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _readNotifications();
  }

  Future<void> _readNotifications() async {
    try {
      final enabled =
          await (widget.notificationStatus?.call() ??
              (widget.api != null
                  ? Future.value(false)
                  : SharedCareNotifications.isEnabled()));
      if (mounted) setState(() => _notifications = enabled);
    } catch (_) {
      if (mounted) setState(() => _notifications = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationBusy = true);
    try {
      if (widget.setNotifications != null) {
        await widget.setNotifications!(value);
      } else if (value) {
        await SharedCareNotifications.enable();
      } else {
        await SharedCareNotifications.disable();
      }
      await _readNotifications();
    } catch (e) {
      if (mounted) _notice(_message(e));
      await _readNotifications();
    } finally {
      if (mounted) setState(() => _notificationBusy = false);
    }
  }

  Future<void> _auth({bool refreshIdentity = false}) async {
    if (widget.api != null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Please sign in again.');
    if (refreshIdentity) await user.reload();
    _api.options.headers['Authorization'] =
        'Bearer ${await FirebaseAuth.instance.currentUser!.getIdToken(refreshIdentity)}';
  }

  String _message(Object error) {
    if (error is StateError) return error.message.toString();
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map &&
          body['error'] is Map &&
          body['error']['message'] is String) {
        return body['error']['message'] as String;
      }
      if (body is Map && body['detail'] is String)
        return body['detail'] as String;
    }
    return 'Could not update Family Sharing. Check your connection and retry.';
  }

  void _notice(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _refresh({bool refreshIdentity = false}) async {
    await _auth(refreshIdentity: refreshIdentity);
    final responses = await Future.wait<dynamic>([
      BabyApi(_api).list(fresh: refreshIdentity),
      _api.get('/sharing'),
    ]);
    final babies = responses[0] as List<Map<String, dynamic>>;
    final response = responses[1] as Response;
    if (!mounted) return;
    setState(() {
      _babies = babies;
      _shares = (response.data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (!_choices.any((b) => b['id'] == _babyId)) {
        _babyId = _choices.any((b) => b['id'] == BabyProfileStore.id)
            ? BabyProfileStore.id
            : _choices.firstOrNull?['id'] as String?;
      }
      final invitation = _shares
          .where((s) => s['id'] == PendingCareInvitation.id)
          .firstOrNull;
      if (invitation != null) _babyId = invitation['baby_id'] as String;
    });
    BabyProfileStore.babies = babies;
    final selected = babies.where((b) => b['id'] == _babyId).firstOrNull;
    if (selected != null) BabyProfileStore.select(selected);
  }

  Future<void> _load({bool refreshIdentity = true}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _refresh(refreshIdentity: refreshIdentity);
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _action(Future<void> Function() action, String success) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth();
      await action();
      await _refresh();
      if (mounted) _notice(success);
      return true;
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(Map<String, dynamic> share) async {
    final link = share['invitation_url'] as String?;
    if (link == null) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted)
      _notice('Invitation link copied. Send it to the invited person.');
  }

  Future<void> _remove(Map<String, dynamic> share) async {
    final pending = share['status'] == 'pending';
    final label = share['is_owner'] == true
        ? (pending ? 'Cancel invitation' : 'Remove access')
        : (pending ? 'Decline invitation' : 'Leave care team');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('$label?'),
        content: Text(
          pending
              ? 'This invitation will no longer work.'
              : 'Future access will stop. Records already viewed or exported cannot be erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(label),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _action(() async {
        await _api.delete('/sharing/${share['id']}');
      }, '$label completed.');
    }
  }

  Future<void> _accept(Map<String, dynamic> share) async {
    final ok = await _action(() async {
      await _api.post('/sharing/${share['id']}/accept');
      PendingCareInvitation.id = null;
      _invitation.clear();
    }, 'Invitation accepted.');
    if (ok && mounted) {
      setState(() {
        _babyId = share['baby_id'] as String;
        _joinedBabyId = _babyId;
      });
    }
  }

  Future<void> _invite() async {
    // Bind the dialog to this baby even if the underlying list refreshes.
    final babyId = _babyId;
    if (!_owner || babyId == null) return;
    var email = '';
    final form = GlobalKey<FormState>();
    String role = 'viewer';
    final payload = await showDialog<Map<String, String>>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, update) => AlertDialog(
          backgroundColor: AuthPalette.warmCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text('Invite caregiver'),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    onChanged: (value) => email = value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: authPastelDecoration(
                      label: 'Their account email',
                      hint: 'name@example.com',
                      prefixIcon: Icons.mail_outline,
                    ),
                    validator: (value) =>
                        RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(value?.trim() ?? '')
                        ? null
                        : 'Enter a valid email address.',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Permission'),
                    items: const [
                      DropdownMenuItem(
                        value: 'viewer',
                        child: Text('View only'),
                      ),
                      DropdownMenuItem(
                        value: 'caregiver',
                        child: Text('Manage care'),
                      ),
                    ],
                    onChanged: (v) => update(() => role = v!),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'View only: read records and chat.\nManage care: also add, edit and delete care records.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AuthPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate())
                  Navigator.pop(c, {'email': email.trim(), 'role': role});
              },
              child: const Text('Create invitation'),
            ),
          ],
        ),
      ),
    );
    if (payload == null || !mounted) return;
    Map<String, dynamic>? created;
    final ok = await _action(() async {
      final response = await _api.post(
        '/sharing/babies/$babyId',
        data: payload,
      );
      created = Map<String, dynamic>.from(response.data['data'] as Map);
    }, 'Invitation created.');
    if (ok && mounted && created != null) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Invitation ready'),
          content: const Text(
            'Send this link to the invited person. They must sign in with the invited email. The link expires in 7 days.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Done'),
            ),
            FilledButton.icon(
              onPressed: () => _copy(created!),
              icon: const Icon(Icons.link),
              label: const Text('Copy invitation link'),
            ),
          ],
        ),
      );
    }
  }

  bool _expired(Map<String, dynamic> share) {
    final date = DateTime.tryParse(share['expires_at']?.toString() ?? '');
    return date != null && date.isBefore(DateTime.now());
  }

  String _expiry(Map<String, dynamic> share) {
    final date = DateTime.tryParse(
      share['expires_at']?.toString() ?? '',
    )?.toLocal();
    if (date == null) return 'Expiry unavailable';
    return '${_expired(share) ? 'Expired' : 'Expires'} ${MaterialLocalizations.of(context).formatShortDate(date)}';
  }

  Widget _card(Widget child) => Container(
    margin: EdgeInsets.only(bottom: _joinFlow ? 8 : 12),
    padding: EdgeInsets.all(_joinFlow ? 12 : 16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AuthPalette.lavenderMist.withValues(alpha: .65),
      ),
      boxShadow: [
        BoxShadow(
          color: AuthPalette.softCoral.withValues(alpha: .06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
  Widget _heading(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 14, 4, 12),
    child: Text(
      title,
      style: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AuthPalette.textDark,
      ),
    ),
  );
  Widget _entry(Map<String, dynamic> share) {
    final owner = share['is_owner'] == true;
    final pending = share['status'] == 'pending';
    final expired = pending && _expired(share);
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AuthPalette.blushPink,
                child: Icon(
                  pending
                      ? Icons.mail_outline_rounded
                      : Icons.person_outline_rounded,
                  color: AuthPalette.softCoral,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (share['name'] ?? share['email']).toString(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (share['name'] != null)
                      Text(
                        share['email'].toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      share['role'] == 'viewer' ? 'View only' : 'Manage care',
                      style: const TextStyle(
                        color: AuthPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    if (pending)
                      Text(
                        _expiry(share),
                        style: TextStyle(
                          fontSize: 12,
                          color: expired
                              ? Colors.red.shade700
                              : AuthPalette.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (owner && !pending)
                PopupMenuButton<String>(
                  key: ValueKey('member_menu_${share['id']}'),
                  enabled: !_busy,
                  tooltip: 'Manage member',
                  onSelected: (value) {
                    if (value == 'remove') {
                      _remove(share);
                    } else {
                      _action(() async {
                        await _api.patch(
                          '/sharing/${share['id']}',
                          data: {'role': value},
                        );
                      }, 'Permission updated.');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'caregiver',
                      child: Text('Manage care'),
                    ),
                    PopupMenuItem(value: 'viewer', child: Text('View only')),
                    PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove access'),
                    ),
                  ],
                ),
            ],
          ),
          if (pending)
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                if (owner && !expired && share['invitation_url'] != null)
                  TextButton.icon(
                    onPressed: _busy ? null : () => _copy(share),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Copy link'),
                  ),
                if (!owner && !expired)
                  TextButton(
                    onPressed: _busy ? null : () => _accept(share),
                    child: const Text('Accept'),
                  ),
                TextButton(
                  onPressed: _busy ? null : () => _remove(share),
                  child: Text(owner ? 'Cancel invitation' : 'Decline'),
                ),
              ],
            ),
          if (!owner && !pending)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _busy ? null : () => _remove(share),
                child: const Text('Leave care team'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _reviewLink() async {
    FocusScope.of(context).unfocus();
    if (_needsVerification) {
      _notice('Verify your signed-in email first, then tap Refresh.');
      return;
    }
    final id = PendingCareInvitation.parse(_invitation.text);
    final share = _shares
        .where((s) => s['id'] == id && s['is_owner'] != true)
        .firstOrNull;
    if (id == null || share == null) {
      _notice(
        'Check the invitation link, sign in with the invited email, verify it, then refresh.',
      );
      return;
    }
    setState(() => _babyId = share['baby_id'] as String);
    if (share['status'] == 'accepted') {
      PendingCareInvitation.id = null;
      final baby = _babies
          .where((b) => b['id'] == share['baby_id'])
          .firstOrNull;
      if (baby != null) BabyProfileStore.select(baby);
      setState(() => _joinedBabyId = share['baby_id'] as String);
      _notice('You already have access to this baby.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Join ${share['baby_name']}’s care team?'),
        content: Text(
          'Permission: ${share['role'] == 'viewer' ? 'View only' : 'Manage care'}. Only accept invitations from people you know.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _accept(share);
  }

  Widget _invitationEntry() => _card(
    ExpansionTile(
      key: const ValueKey('manual_invitation'),
      initiallyExpanded: widget.joinMode || _invitation.text.isNotEmpty,
      onExpansionChanged: (expanded) =>
          setState(() => _reviewingInvitation = expanded),
      tilePadding: EdgeInsets.zero,
      title: Text(
        widget.joinMode ? 'Join a baby’s care team' : 'Have an invitation?',
      ),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Paste the link sent by the parent. Use the email they invited and verify it before accepting.',
          ),
        ),
        TextField(
          controller: _invitation,
          decoration: authPastelDecoration(
            label: 'Invitation link or code',
            hint: 'Paste your invitation',
            prefixIcon: Icons.link_rounded,
          ),
        ),
        TextButton(
          onPressed: _busy ? null : _reviewLink,
          child: const Text('Review invitation'),
        ),
      ],
    ),
  );

  Widget _step(
    int number,
    String title,
    Widget child, {
    bool complete = false,
  }) => _card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AuthPalette.blushPink,
              child: complete
                  ? const Icon(
                      Icons.check,
                      size: 17,
                      color: AuthPalette.softCoral,
                    )
                  : Text(
                      '$number',
                      style: const TextStyle(
                        color: AuthPalette.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$number. $title',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );

  Widget _joinBody() {
    final email = widget.api == null
        ? FirebaseAuth.instance.currentUser?.email
        : null;
    final verified = _signedIn && !_needsVerification;
    final joined =
        _joinedBabyId != null && _babies.any((b) => b['id'] == _joinedBabyId);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        key: const ValueKey('join_steps_scroll'),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 24).clamp(0, double.infinity),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_busy) const LinearProgressIndicator(),
              _step(
                1,
                'Verify your email',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verified
                          ? 'Email verified. You’re ready to join.'
                          : 'Use the email the parent invited.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                    if (email != null)
                      Text(
                        email,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                      ),
                    if (!_signedIn)
                      TextButton(
                        onPressed: () => context.go(RoutePaths.login),
                        child: const Text('Sign in'),
                      ),
                    if (_signedIn && !verified)
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            onPressed: _busy
                                ? null
                                : () => _action(
                                    () async {
                                      await FirebaseAuth.instance.currentUser!
                                          .sendEmailVerification();
                                    },
                                    'Verification requested for ${email ?? 'your signed-in email'}. Check your inbox and spam.',
                                  ),
                            child: const Text('Send verification email'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            onPressed: _busy ? null : _load,
                            child: const Text('I’ve verified · Refresh'),
                          ),
                        ],
                      ),
                  ],
                ),
                complete: verified,
              ),
              _step(
                2,
                'Accept the invitation',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Paste the full link sent by the parent.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _invitation,
                      enabled: !joined && !_busy,
                      decoration: authPastelDecoration(
                        label: 'Invitation link or code',
                        hint: 'Paste invitation link',
                        prefixIcon: Icons.link_rounded,
                      ),
                    ),
                    if (!joined)
                      TextButton(
                        onPressed: _busy || !verified ? null : _reviewLink,
                        child: const Text('Review invitation'),
                      ),
                    if (joined)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Invitation accepted.'),
                      ),
                  ],
                ),
                complete: joined,
              ),
              _step(
                3,
                'Open the baby profile',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!joined)
                      const Text(
                        'Available after accepting the invitation.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AuthPalette.textMuted,
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: !joined || _busy
                          ? null
                          : () {
                              final baby = _babies.firstWhere(
                                (b) => b['id'] == _joinedBabyId,
                              );
                              BabyProfileStore.select(baby);
                              context.go(RoutePaths.dashboard);
                            },
                      icon: const Icon(Icons.child_care_rounded),
                      label: const Text('Open baby dashboard'),
                    ),
                  ],
                ),
                complete: joined,
              ),
              _card(
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Shared care alerts',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Optional · on this phone',
                    style: TextStyle(fontSize: 12),
                  ),
                  activeTrackColor: AuthPalette.softCoral,
                  value: _notifications,
                  onChanged: _busy || _notificationBusy || !joined
                      ? null
                      : _toggleNotifications,
                ),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AuthPalette.error,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedShares = _shares
        .where((s) => s['baby_id'] == _babyId)
        .toList();
    final members = selectedShares
        .where((s) => s['status'] == 'accepted')
        .toList();
    final pending = selectedShares
        .where((s) => s['status'] == 'pending')
        .toList();
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      appBar: AppBar(
        title: const Text('Family Sharing'),
        backgroundColor: AuthPalette.warmCream,
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(
                widget.joinMode ? RoutePaths.dashboard : RoutePaths.babyProfile,
              );
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          if (_joinFlow)
            _joinBody()
          else
            RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_busy) const LinearProgressIndicator(),
                  if (widget.joinMode && _signedIn) _invitationEntry(),
                  if (widget.joinMode &&
                      !_busy &&
                      _babies.any((b) => b['id'] == _babyId))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FilledButton.icon(
                        onPressed: () => context.go(RoutePaths.dashboard),
                        icon: const Icon(Icons.child_care_rounded),
                        label: const Text('Open baby dashboard'),
                      ),
                    ),
                  if (_error != null)
                    _card(
                      Column(
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: AuthPalette.error),
                          ),
                          TextButton(
                            onPressed: _busy ? null : _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  if (!_signedIn)
                    FilledButton(
                      onPressed: () => context.go(RoutePaths.login),
                      child: const Text('Sign in to review invitation'),
                    ),
                  if (_choices.isNotEmpty)
                    _card(
                      DropdownButtonFormField<String>(
                        key: ValueKey('selected_baby_$_babyId'),
                        initialValue: _babyId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Selected baby',
                          prefixIcon: Icon(Icons.child_care_rounded),
                          border: InputBorder.none,
                        ),
                        items: [
                          for (final b in _choices)
                            DropdownMenuItem(
                              value: b['id'] as String,
                              child: Text(
                                b['name'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (id) {
                                setState(() => _babyId = id);
                                final baby = _babies
                                    .where((b) => b['id'] == id)
                                    .firstOrNull;
                                if (baby != null) BabyProfileStore.select(baby);
                              },
                      ),
                    ),
                  if (_needsVerification)
                    _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verify your email to accept invitations.',
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _action(
                                    () async {
                                      await FirebaseAuth.instance.currentUser!
                                          .sendEmailVerification();
                                    },
                                    'Verification email sent. Verify it, then refresh.',
                                  ),
                            child: const Text('Send verification email'),
                          ),
                        ],
                      ),
                    ),
                  if (_babyId != null) ...[
                    _heading('Care team'),
                    _card(
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AuthPalette.lavenderMist,
                            child: Icon(
                              Icons.favorite_outline_rounded,
                              color: AuthPalette.softCoral,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _owner
                                  ? 'You · Parent'
                                  : 'Parent manages this care team',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final member in members) _entry(member),
                    if (_owner && members.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Invite someone you trust to help care for your baby.',
                          style: TextStyle(color: AuthPalette.textMuted),
                        ),
                      ),
                    if (_owner)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AuthPalette.softCoral,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _busy ? null : _invite,
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Invite caregiver'),
                      ),
                    if (pending.isNotEmpty) ...[
                      _heading('Pending invitations'),
                      for (final invitation in pending) _entry(invitation),
                    ],
                  ],
                  if (!_busy && _choices.isEmpty && _error == null)
                    _card(
                      const Text(
                        'No shared babies yet. Create a baby profile or accept an invitation.',
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (_signedIn) ...[
                    _card(
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Shared care alerts',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text(
                          'On this phone · all shared babies',
                          style: TextStyle(fontSize: 12),
                        ),
                        activeTrackColor: AuthPalette.softCoral,
                        value: _notifications,
                        onChanged: _busy || _notificationBusy
                            ? null
                            : _toggleNotifications,
                      ),
                    ),
                    if (!widget.joinMode) _invitationEntry(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
