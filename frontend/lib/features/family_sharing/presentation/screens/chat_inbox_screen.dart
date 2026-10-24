import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../baby_management/presentation/widgets/baby_avatar.dart';
import '../../application/shared_care_connection.dart';
import 'shared_care_activity_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key, this.api});
  final Dio? api;
  @override
  State<ChatInboxScreen> createState() => _ChatInboxState();
}

class _ChatInboxState extends State<ChatInboxScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _conversations = [];
  Timer? _timer;
  bool _loading = true, _fetching = false, _conversationOpen = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _conversationOpen) return;
      final router = GoRouter.maybeOf(context);
      if (router == null ||
          router.routeInformationProvider.value.uri.path == RoutePaths.chat)
        _load();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) {
      _load();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final api = widget.api ?? await sharedCareClient();
      final response = await api.get('/sharing/conversations');
      if (!mounted) return;
      setState(() {
        _conversations = (response.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _error = null;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = sharedCareError(e);
          if (e is DioException && {401, 403}.contains(e.response?.statusCode))
            _conversations = [];
        });
    } finally {
      _fetching = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Map<String, dynamic> conversation) async {
    _conversationOpen = true;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SharedCareActivityScreen(
          babyId: conversation['baby_id'] as String,
          photoData: conversation['photo_data'] as String?,
          chatOnly: true,
          api: widget.api,
        ),
      ),
    );
    _conversationOpen = false;
    if (mounted) _load();
  }

  String _when(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '';
    return DateUtils.isSameDay(date, DateTime.now())
        ? TimeOfDay.fromDateTime(date).format(context)
        : MaterialLocalizations.of(context).formatShortDate(date);
  }

  @override
  Widget build(BuildContext context) {
    // A single care team needs no extra selection screen or navigation tap.
    if (!_loading && _error == null && _conversations.length == 1) {
      final conversation = _conversations.single;
      return SharedCareActivityScreen(
        key: ValueKey('messages_${conversation['baby_id']}'),
        babyId: conversation['baby_id'] as String,
        photoData: conversation['photo_data'] as String?,
        chatOnly: true,
        api: widget.api,
      );
    }
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AuthPalette.blushPink.withValues(alpha: .65),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: AuthPalette.softCoral,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Messages',
                          style: GoogleFonts.quicksand(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AuthPalette.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh conversations',
                        onPressed: _fetching ? null : _load,
                        icon: const Icon(Icons.refresh),
                      ),
                      IconButton(
                        tooltip: 'Baby profile',
                        onPressed: () => context.push(RoutePaths.babyProfile),
                        icon: const Icon(Icons.person_outline_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'One conversation for each baby’s care team.',
                    style: TextStyle(color: AuthPalette.textMuted),
                  ),
                  const SizedBox(height: 24),
                  if (_loading) const LinearProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          TextButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  if (!_loading && _error == null && _conversations.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 48,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: AuthPalette.softCoral,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your care team starts here',
                            style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create a baby profile or accept a parent’s invitation to join their chat.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AuthPalette.textMuted),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                context.push(RoutePaths.familySharing),
                            child: const Text('Open Family Sharing'),
                          ),
                        ],
                      ),
                    ),
                  for (final conversation in _conversations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Material(
                        color: Colors.white.withValues(alpha: .94),
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          key: ValueKey('chat_${conversation['baby_id']}'),
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => _open(conversation),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: AuthPalette.blushPink.withValues(
                                      alpha: .5,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: BabyAvatar(
                                    size: 50,
                                    profile: {
                                      'photo_data': conversation['photo_data'],
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        conversation['baby_name'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.quicksand(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        conversation['last_message'] == null
                                            ? ((conversation['members']
                                                              as int? ??
                                                          1) >
                                                      1
                                                  ? 'Say hello to the care team'
                                                  : 'Invite your care team from Profile')
                                            : '${conversation['last_sender']}: ${conversation['last_message']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AuthPalette.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Column(
                                  children: [
                                    Text(
                                      _when(conversation['last_time']),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AuthPalette.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AuthPalette.textMuted,
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
            ),
          ),
        ],
      ),
    );
  }
}
