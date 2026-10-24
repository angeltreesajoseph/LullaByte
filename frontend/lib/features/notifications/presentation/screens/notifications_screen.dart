import 'dart:async';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../../family_sharing/application/shared_care_connection.dart';
import '../../../family_sharing/presentation/screens/shared_care_activity_screen.dart';
import '../../data/shared_alert_inbox.dart';
import '../../data/reminder_inbox.dart';
import 'notification_preferences_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.api,
    this.initialActivity,
    this.initialReminder,
    this.reminderUid,
  });
  final Dio? api;
  final int? initialActivity;
  final String? initialReminder, reminderUid;
  @override
  State<NotificationsScreen> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _server = [], _reminders = [];
  int _unreadServer = 0;
  int? _next;
  bool _loading = false,
      _olderLoaded = false,
      _unreadOnly = false,
      _readBusy = false,
      _opening = false,
      _launchHandled = false;
  String? _error;
  Timer? _timer;
  String? get _uid =>
      widget.reminderUid ??
      (widget.api == null ? FirebaseAuth.instance.currentUser?.uid : null);
  Future<Dio> _client() async => widget.api ?? await sharedCareClient();
  List<Map<String, dynamic>> get _items => [..._server, ..._reminders]
    ..sort(
      (a, b) =>
          (DateTime.tryParse(b['created_at'].toString()) ?? DateTime(2000))
              .compareTo(
                DateTime.tryParse(a['created_at'].toString()) ?? DateTime(2000),
              ),
    );
  int get _unread =>
      _unreadServer + _reminders.where((r) => r['read'] != true).length;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _start();
  }

  @override
  void didUpdateWidget(covariant NotificationsScreen old) {
    super.didUpdateWidget(old);
    if (old.initialActivity != widget.initialActivity ||
        old.initialReminder != widget.initialReminder) {
      _launchHandled = false;
      _load();
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_olderLoaded && ModalRoute.of(context)?.isCurrent == true) _load();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) {
      if (!_olderLoaded) _load();
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    final uid = _uid;
    try {
      final api = await _client();
      final response = await api.get(
        '/sharing/alerts',
        queryParameters: {
          if (more && _next != null) 'before': _next,
          if (!_launchHandled && widget.initialActivity != null)
            'activity_id': widget.initialActivity,
        },
      );
      final data = response.data['data'] as Map;
      final rows = (data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final babies = (data['babies'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final reminders = uid == null
          ? <Map<String, dynamic>>[]
          : await ReminderInbox.due(
              uid,
              babies
                  .where((b) => b['access_role'] != 'viewer')
                  .map((b) => b['id'] as String)
                  .toSet(),
            );
      for (final r in reminders) {
        r['baby_name'] = babies.firstWhere(
          (b) => b['id'] == r['baby_id'],
        )['name'];
      }
      if (!mounted || uid != _uid) return;
      setState(() {
        _server = more
            ? [
                ..._server,
                ...rows.where((r) => !_server.any((e) => e['id'] == r['id'])),
              ]
            : rows;
        _reminders = reminders;
        _next = data['next_before'] as int?;
        _unreadServer = (data['unread_count'] as num).toInt();
        _olderLoaded = more;
        _error = null;
      });
      if (!_launchHandled &&
          (widget.initialActivity != null || widget.initialReminder != null)) {
        final target = widget.initialReminder != null
            ? _reminders
                  .where((r) => r['id'] == widget.initialReminder)
                  .firstOrNull
            : data['target'] is Map
            ? Map<String, dynamic>.from(data['target'] as Map)
            : _server
                  .where((r) => r['activity_id'] == widget.initialActivity)
                  .firstOrNull;
        _launchHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (target != null) {
            _open(target);
          } else {
            _notice(
              'This notification is no longer available for this account.',
            );
          }
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _error =
              'Could not load notifications. Check your connection and server update.';
          _server = [];
          _reminders = [];
          _unreadServer = 0;
          _next = null;
        });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _notice(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _readAll() async {
    if (_readBusy || _loading) return;
    setState(() => _readBusy = true);
    try {
      final api = await _client();
      if (_server.isNotEmpty)
        await api.post(
          '/sharing/alerts/read',
          data: {'through_id': _server.first['id']},
        );
      final uid = _uid;
      if (uid != null)
        await ReminderInbox.markRead(
          uid,
          _reminders.map((r) => r['id'] as String),
        );
      if (!mounted) return;
      setState(() {
        for (final r in [..._server, ..._reminders]) {
          r['read'] = true;
        }
        _unreadServer = 0;
      });
      SharedAlertInbox.updated();
    } catch (_) {
      if (mounted) _notice('Could not save read status. Please retry.');
    } finally {
      if (mounted) setState(() => _readBusy = false);
    }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final api = await _client();
      final response = await api.get(
        '/babies/${item['baby_id']}',
        options: Options(extra: {'fresh': true}),
      );
      final baby = Map<String, dynamic>.from(response.data['data'] as Map);
      if (item['source'] == 'reminder') {
        final uid = _uid;
        if (uid == null) throw StateError('Sign in again.');
        await ReminderInbox.markRead(uid, [item['id'] as String]);
      } else {
        await api.post('/sharing/alerts/${item['id']}/read');
      }
      if (!mounted) return;
      setState(() {
        if (item['read'] != true && item['source'] != 'reminder')
          _unreadServer = math.max(0, _unreadServer - 1);
        item['read'] = true;
      });
      BabyProfileStore.select(baby);
      SharedAlertInbox.updated();
      if (item['kind'] == 'chat') {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SharedCareActivityScreen(
              babyId: item['baby_id'] as String,
              chatOnly: true,
              api: widget.api,
            ),
          ),
        );
      } else {
        final route = switch (item['kind']) {
          'feeding' => RoutePaths.feeding,
          'sleep' => RoutePaths.sleep,
          'diaper' => RoutePaths.diaper,
          'growth' => RoutePaths.growth,
          'cry' => RoutePaths.cryAnalyzer,
          'vaccinations' => RoutePaths.vaccination,
          'memories' => RoutePaths.gallery,
          'milestones' => RoutePaths.milestones,
          _ => RoutePaths.babyProfile,
        };
        await context.push(route);
      }
      if (mounted && !_olderLoaded) await _load();
    } catch (_) {
      if (mounted) {
        _notice('This update could not be opened. Access may have changed.');
        await _load();
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '';
    return '${MaterialLocalizations.of(context).formatShortDate(date)} · ${TimeOfDay.fromDateTime(date).format(context)}';
  }

  IconData _icon(Map<String, dynamic> r) => switch (r['kind']) {
    'chat' => Icons.chat_bubble_outline_rounded,
    'feeding' => Icons.local_drink_outlined,
    'sleep' => Icons.bedtime_outlined,
    'vaccinations' => Icons.vaccines_outlined,
    'cry' => Icons.graphic_eq_rounded,
    'growth' => Icons.straighten_rounded,
    _ => Icons.favorite_outline_rounded,
  };
  Widget _entry(Map<String, dynamic> r) => Card(
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(
        color: r['read'] == true
            ? AuthPalette.lavenderMist
            : AuthPalette.softCoral,
      ),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: AuthPalette.blushPink,
        child: Icon(_icon(r), color: AuthPalette.softCoral, size: 21),
      ),
      title: Text(
        '${r['baby_name']} · ${r['summary']}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: r['read'] == true ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: Text(
        '${r['actor_name']}\n${_date(r['created_at'])}',
        style: const TextStyle(fontSize: 12),
      ),
      isThreeLine: true,
      trailing: Icon(
        r['read'] == true ? Icons.chevron_right : Icons.circle,
        size: r['read'] == true ? 20 : 9,
        color: AuthPalette.softCoral,
      ),
      onTap: _opening || _readBusy ? null : () => _open(r),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final rows = _items
        .where((r) => !_unreadOnly || r['read'] != true)
        .toList();
    final today = rows
        .where(
          (r) => DateUtils.isSameDay(
            DateTime.tryParse(r['created_at'].toString())?.toLocal(),
            DateTime.now(),
          ),
        )
        .toList();
    final earlier = rows.where((r) => !today.contains(r)).toList();
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AuthPalette.warmCream,
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              context.go(RoutePaths.dashboard);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Notification preferences',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationPreferencesScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: _loading || _readBusy || _unread == 0 ? null : _readAll,
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          RefreshIndicator(
            onRefresh: () => _load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: false, label: Text('All')),
                          ButtonSegment(value: true, label: Text('Unread')),
                        ],
                        selected: {_unreadOnly},
                        onSelectionChanged: (v) =>
                            setState(() => _unreadOnly = v.first),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_unread unread',
                      style: const TextStyle(
                        color: AuthPalette.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_loading || _opening) const LinearProgressIndicator(),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: AuthPalette.error),
                  ),
                  TextButton(
                    onPressed: _loading ? null : () => _load(),
                    child: const Text('Retry'),
                  ),
                ],
                if (_olderLoaded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Reading older alerts',
                            style: TextStyle(
                              fontSize: 12,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _loading ? null : () => _load(),
                          child: const Text('Refresh latest'),
                        ),
                      ],
                    ),
                  ),
                if (!_loading && _error == null && rows.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            size: 44,
                            color: AuthPalette.softCoral,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _unreadOnly
                                ? 'You’re all caught up'
                                : 'No notifications yet',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Shared updates and chosen reminders appear here. Phone alerts can be dismissed without removing this history.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AuthPalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final group in [
                  MapEntry('Today', today),
                  MapEntry('Earlier', earlier),
                ])
                  if (group.value.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 6),
                      child: Text(
                        group.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final item in group.value) _entry(item),
                  ],
                if (_next != null)
                  TextButton(
                    onPressed: _loading ? null : () => _load(more: true),
                    child: const Text('Load older alerts'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
