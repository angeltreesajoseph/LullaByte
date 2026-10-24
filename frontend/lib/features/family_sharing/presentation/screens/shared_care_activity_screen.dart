import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../application/shared_care_connection.dart';
import '../../../baby_management/presentation/widgets/baby_avatar.dart';

class SharedCareActivityScreen extends StatefulWidget {
  const SharedCareActivityScreen({
    super.key,
    required this.babyId,
    this.api,
    this.initialChat = false,
    this.chatOnly = false,
    this.photoData,
  });
  final String babyId;
  final Dio? api;
  final bool initialChat, chatOnly;
  final String? photoData;
  @override
  State<SharedCareActivityScreen> createState() => _SharedCareActivityState();
}

class _SharedCareActivityState extends State<SharedCareActivityScreen>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  Timer? _timer;
  List<Map<String, dynamic>> _events = [];
  String _name = 'Baby', _role = 'viewer';
  String? _error, _clientId, _retryText;
  bool _loading = true,
      _fetching = false,
      _sending = false,
      _chat = false,
      _canChat = false;
  DateTime? _lastUpdate;
  @override
  void initState() {
    super.initState();
    _chat = widget.initialChat || widget.chatOnly;
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed) {
      _refresh();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Dio> _api() async => widget.api ?? await sharedCareClient();
  Future<void> _refresh() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final api = await _api();
      final result = await api.get(
        '/sharing/babies/${widget.babyId}/activity',
        queryParameters: widget.chatOnly ? {'chat_only': true} : null,
      );
      if (!mounted) return;
      setState(() {
        _name = result.data['data']['baby_name'] as String? ?? 'Baby';
        _role = result.data['data']['role'] as String;
        _canChat =
            result.data['data']['can_chat'] as bool? ?? _role != 'viewer';
        _events = (result.data['data']['events'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _error = null;
        _lastUpdate = DateTime.now();
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = sharedCareError(e);
          if (e is DioException &&
              {403, 404}.contains(e.response?.statusCode)) {
            _events = [];
            _role = 'viewer';
            _canChat = false;
          }
        });
    } finally {
      _fetching = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  String _uuid() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (_sending || text.isEmpty) return;
    if (_retryText != text) {
      _clientId = _uuid();
      _retryText = text;
    }
    setState(() => _sending = true);
    try {
      final api = await _api();
      await api.post(
        '/sharing/babies/${widget.babyId}/messages',
        data: {'text': text, 'client_id': _clientId},
      );
      if (!mounted) return;
      _text.clear();
      _clientId = null;
      _retryText = null;
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _error = sharedCareError(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _remove(Map<String, dynamic> event) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this message?'),
        content: const Text(
          'It will be removed from this chat, but may already have been read.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    try {
      final api = await _api();
      await api.delete(
        '/sharing/babies/${widget.babyId}/messages/${event['id']}',
      );
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _error = sharedCareError(e));
    }
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return 'Date unavailable';
    return '${MaterialLocalizations.of(context).formatMediumDate(date)} · ${TimeOfDay.fromDateTime(date).format(context)}';
  }

  Widget _chatView() {
    final messages = _events
        .where((e) => e['kind'] == 'chat')
        .toList()
        .reversed
        .toList();
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      appBar: AppBar(
        backgroundColor: AuthPalette.warmCream,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AuthPalette.blushPink,
              child: BabyAvatar(
                size: 34,
                profile: {'photo_data': widget.photoData},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Care team chat',
                    style: TextStyle(
                      fontSize: 12,
                      color: AuthPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh messages',
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          Column(
            children: [
              if (_loading) const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: AuthPalette.blushPink.withValues(
                                    alpha: .5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.forum_outlined,
                                  size: 40,
                                  color: AuthPalette.softCoral,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'A little conversation, shared care',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Messages stay with this baby’s invited care team.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AuthPalette.textMuted),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final mine = message['mine'] == true;
                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width * .82,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                              decoration: BoxDecoration(
                                color: mine
                                    ? const Color(0xFFF9DDE8)
                                    : Colors.white.withValues(alpha: .95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AuthPalette.lavenderMist.withValues(
                                    alpha: .35,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          mine
                                              ? 'You'
                                              : message['actor_name'] as String,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AuthPalette.textMuted,
                                          ),
                                        ),
                                      ),
                                      if (message['can_delete'] == true &&
                                          message['message'] != null)
                                        PopupMenuButton<String>(
                                          tooltip: 'Message actions',
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.more_horiz,
                                            size: 18,
                                            color: AuthPalette.textMuted,
                                          ),
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(
                                              value: 'remove',
                                              child: Text('Remove message'),
                                            ),
                                          ],
                                          onSelected: (_) => _remove(message),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    (message['message'] ?? message['summary'])
                                        as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: message['message'] == null
                                          ? AuthPalette.textMuted
                                          : AuthPalette.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _date(message['created_at']),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AuthPalette.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_canChat)
                Container(
                  color: Colors.white.withValues(alpha: .85),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('care_chat_composer'),
                              controller: _text,
                              enabled: !_sending,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 2000,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Message the care team…',
                                counterText: '',
                                filled: true,
                                fillColor: AuthPalette.blushPink.withValues(
                                  alpha: .25,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _text,
                            builder: (context, value, _) => IconButton.filled(
                              tooltip: 'Send message',
                              style: IconButton.styleFrom(
                                backgroundColor: AuthPalette.softCoral,
                              ),
                              onPressed: _sending || value.text.trim().isEmpty
                                  ? null
                                  : _send,
                              icon: _sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!_loading && !_canChat)
                const SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Messaging is unavailable. Refresh or check your shared access.',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chat) return _chatView();
    final rows = _events
        .where((e) => _chat ? e['kind'] == 'chat' : e['kind'] != 'chat')
        .toList()
        .reversed;
    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      appBar: AppBar(
        title: Text('$_name’s care team'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Activity',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SharedCareActivityScreen(
                                babyId: widget.babyId,
                                api: widget.api,
                                chatOnly: true,
                                photoData: widget.photoData,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Chat'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastUpdate == null
                          ? 'Connecting…'
                          : 'Synced ${TimeOfDay.fromDateTime(_lastUpdate!).format(context)} · refreshes every 5 seconds',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                    if (_loading) const LinearProgressIndicator(),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              Expanded(
                child: rows.isEmpty
                    ? Center(
                        child: Text(
                          _chat
                              ? 'No messages yet.'
                              : 'New saved care records will appear here.',
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          for (final event in rows)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AuthCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            event['actor_name'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (event['can_delete'] == true &&
                                            event['message'] != null)
                                          IconButton(
                                            tooltip: 'Remove message',
                                            onPressed: () => _remove(event),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    SelectableText(
                                      (event['message'] ?? event['summary'])
                                          as String,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _date(event['created_at']),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AuthPalette.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const Text(
                            'Showing the latest 100 activity items. Full care records remain in each tracker.',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
              ),
              if (_chat && _canChat)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _text,
                            enabled: !_sending,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 2000,
                            decoration: authPastelDecoration(
                              label: 'Message your care team',
                              hint: 'Write a message',
                              prefixIcon: Icons.chat_bubble_outline,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Send message',
                          onPressed: _sending ? null : _send,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: AuthPalette.softCoral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_chat && !_canChat)
                const SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Messaging is unavailable. Refresh or check that your shared access is active.',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
