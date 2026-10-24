import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/auth/account_profile_service.dart';
import '../../../../core/auth/firebase_auth_service.dart';
import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../family_sharing/application/shared_care_connection.dart';
import '../../../family_sharing/presentation/widgets/join_care_team_card.dart';
import '../../application/baby_profile_store.dart';
import '../widgets/baby_avatar.dart';
import 'baby_profile_screen.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({super.key, this.service, this.api});
  final AccountProfileService? service;
  final Dio? api;
  @override
  State<AccountProfileScreen> createState() => _AccountProfileState();
}

class _AccountProfileState extends State<AccountProfileScreen> {
  late final AccountProfileService _service;
  AccountProfile? _account;
  List<Map<String, dynamic>> _babies = [];
  String? _error;
  String? _accountError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? AccountProfileService();
    try {
      _account = _service.read();
    } catch (_) {}
    _babies = List.of(BabyProfileStore.babies);
    BabyProfileStore.changes.addListener(_changed);
    _load();
    _loadAccount();
  }

  void _changed() {
    if (mounted) setState(() => _babies = List.of(BabyProfileStore.babies));
  }

  @override
  void dispose() {
    BabyProfileStore.changes.removeListener(_changed);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = widget.api ?? await sharedCareClient();
      final response = await api.get('/babies');
      if (!mounted) return;
      final babies = (response.data['data'] as List)
          .map((b) => Map<String, dynamic>.from(b as Map))
          .toList();
      BabyProfileStore.babies = babies;
      setState(() {
        _babies = babies;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not refresh baby profiles. Tap Retry.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadAccount() async {
    try {
      final account = await _service.load();
      if (mounted) {
        setState(() {
          _account = account;
          _accountError = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _accountError = accountSaveError(error));
    }
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<AccountProfile>(
      MaterialPageRoute(
        builder: (_) =>
            _EditAccountScreen(service: _service, account: _account!),
      ),
    );
    if (saved != null && mounted) {
      setState(() {
        _account = saved;
        _accountError = null;
      });
    }
  }

  Future<void> _logout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign in again anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await FirebaseAuthService().signOut();
      if (mounted) context.go(RoutePaths.login);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not log out. Please retry.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AuthPalette.warmCream,
    appBar: AppBar(title: const Text('Profile')),
    body: Stack(
      children: [
        const Positioned.fill(child: AuthBackgroundGradient()),
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _card(
                Column(
                  children: [
                    _AccountAvatar(
                      url: _account?.photoUrl,
                      bytes: _accountBytes(_account),
                      size: 88,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _account?.name.isNotEmpty == true
                          ? _account!.name
                          : 'Your account',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _account?.email ?? 'Please sign in to view your account',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _account == null ? null : _edit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit account'),
                    ),
                    if (_accountError != null) ...[
                      Text(_accountError!, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: _loadAccount,
                        child: const Text('Retry account photo'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Baby profiles',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your account stays the same for every baby.',
                style: TextStyle(color: AuthPalette.textMuted),
              ),
              const SizedBox(height: 14),
              if (_loading) const LinearProgressIndicator(),
              if (_error != null) ...[
                Text(_error!),
                TextButton(onPressed: _load, child: const Text('Retry')),
              ],
              for (final baby in _babies)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _card(
                    ListTile(
                      key: ValueKey('account_baby_${baby['id']}'),
                      contentPadding: EdgeInsets.zero,
                      leading: BabyAvatar(size: 52, profile: baby),
                      title: Text(baby['name'] as String? ?? 'Baby'),
                      subtitle: Text(
                        baby['access_role'] == 'owner'
                            ? 'Baby details and care contacts'
                            : 'Baby details · shared access',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        BabyProfileStore.select(baby);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BabyProfileScreen(
                              api: widget.api,
                              showAccountActions: false,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => context.push(RoutePaths.babyRegistration),
                icon: const Icon(Icons.add),
                label: const Text('Add baby profile'),
              ),
              const SizedBox(height: 16),
              _card(
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.people_outline,
                    color: AuthPalette.softCoral,
                  ),
                  title: const Text('Family Sharing'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RoutePaths.familySharing),
                ),
              ),
              const SizedBox(height: 12),
              const JoinCareTeamCard(),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _card(Widget child) => Material(
  color: Colors.white.withValues(alpha: .94),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(28),
    side: const BorderSide(color: AuthPalette.lavenderMist),
  ),
  child: Padding(padding: const EdgeInsets.all(20), child: child),
);

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({this.url, this.bytes, required this.size});
  final String? url;
  final Uint8List? bytes;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: SizedBox(
      width: size,
      height: size,
      child: bytes != null
          ? Image.memory(bytes!, fit: BoxFit.cover)
          : url != null
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            )
          : _fallback(),
    ),
  );
  Widget _fallback() => ColoredBox(
    color: AuthPalette.blushPink,
    child: Icon(
      Icons.person_rounded,
      size: size * .55,
      color: AuthPalette.softCoral,
    ),
  );
}

Uint8List? _accountBytes(AccountProfile? account) {
  final data = account?.photoData;
  if (data == null) return null;
  try {
    return base64Decode(data.split(',').last);
  } catch (_) {
    return null;
  }
}

class _EditAccountScreen extends StatefulWidget {
  const _EditAccountScreen({required this.service, required this.account});
  final AccountProfileService service;
  final AccountProfile account;
  @override
  State<_EditAccountScreen> createState() => _EditAccountState();
}

class _EditAccountState extends State<_EditAccountScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.account.name,
  );
  Uint8List? _photo;
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 65,
      );
      if (photo == null) return;
      final bytes = await photo.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 374970) {
        setState(() => _error = 'Choose a photo smaller than 375 KB.');
        return;
      }
      setState(() {
        _photo = bytes;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open this photo. Please retry.');
      }
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || name.length > 160) {
      setState(() => _error = 'Enter a name between 1 and 160 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await widget.service.save(name, _photo);
      if (mounted) Navigator.pop(context, saved);
    } catch (error) {
      if (mounted) {
        setState(() => _error = accountSaveError(error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AuthPalette.warmCream,
    appBar: AppBar(title: const Text('Edit account')),
    body: Stack(
      children: [
        const Positioned.fill(child: AuthBackgroundGradient()),
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _card(
              Column(
                children: [
                  _AccountAvatar(
                    url: widget.account.photoUrl,
                    bytes: _photo ?? _accountBytes(widget.account),
                    size: 100,
                  ),
                  TextButton.icon(
                    onPressed: _saving ? null : _pick,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Change photo'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _name,
                    enabled: !_saving,
                    maxLength: 160,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Account email'),
                    subtitle: Text(widget.account.email),
                  ),
                  const Text(
                    'Your sign-in email stays unchanged. Baby details are edited in each baby profile.',
                    style: TextStyle(color: AuthPalette.textMuted),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving...' : 'Save account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
