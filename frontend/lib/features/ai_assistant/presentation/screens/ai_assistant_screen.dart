import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import '../../application/chat_controller.dart';
import '../../application/assistant_voice.dart';
import '../../domain/usecases/assistant_routing.dart';
import '../../domain/entities/chat_message.dart';
import '../../../baby_management/application/baby_profile_store.dart';

const _suggestedQuestions = <String>[
  'Feeding records',
  'Sleep records',
  'Next saved vaccination',
  'Growth records',
  'Diaper records',
  'Cry records',
  'Milestones',
];

/// AI Assistant screen (SRS Section 10.15) — a single hybrid Offline +
/// Online chat screen.
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Dashboard and Feeding — the gradient backdrop, palette,
/// and rounded 28px card language come directly from
/// `features/authentication/presentation/widgets/` (read-only reuse;
/// those files are not modified). Chat state is owned by
/// [chatControllerProvider] (Riverpod), kept entirely local to this
/// feature/session — no backend, Firebase, or real Gemini/OpenAI call yet
/// (see `AiResponseService`'s doc comment for the future integration
/// point).
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _voice = AssistantVoice();
  bool _voiceConsent = false, _voiceBusy = false;
  String? _speakingId, _visibleBaby;
  int _voiceGeneration = 0;

  @override
  void initState() {
    super.initState();
    _visibleBaby = BabyProfileStore.id;
    BabyProfileStore.changes.addListener(_babyChanged);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    BabyProfileStore.changes.removeListener(_babyChanged);
    _voiceGeneration++;
    unawaited(_voice.stop().catchError((Object _) {}));
    _entranceController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _babyChanged() {
    if (_visibleBaby == BabyProfileStore.id) return;
    _visibleBaby = BabyProfileStore.id;
    _messageController.clear();
    _stopVoice();
  }

  void _stopVoice() {
    _voiceGeneration++;
    unawaited(_voice.stop().catchError((Object _) {}));
    if (mounted) setState(() => _speakingId = null);
  }

  Future<void> _dictate() async {
    if (_voiceBusy) return;
    if (!_voiceConsent) {
      final allowed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Speak a message'),
          content: const Text(
            'Your phone’s speech service converts your voice to editable text and may process speech online. LullaByte does not save this audio. Review the words before tapping Send.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (allowed != true || !mounted) return;
      _voiceConsent = true;
    }
    _stopVoice();
    final generation = _voiceGeneration;
    setState(() => _voiceBusy = true);
    try {
      final text = await _voice.dictate();
      if (!mounted ||
          generation != _voiceGeneration ||
          text == null ||
          text.trim().isEmpty)
        return;
      final combined = '${_messageController.text.trim()} ${text.trim()}'
          .trim();
      _messageController.text = combined.length > 1000
          ? combined.substring(0, 1000)
          : combined;
      _messageController.selection = TextSelection.collapsed(
        offset: _messageController.text.length,
      );
    } catch (_) {
      if (mounted)
        _showToast(
          'Voice input is unavailable. Check the phone’s speech service or type your message.',
        );
    } finally {
      if (mounted) setState(() => _voiceBusy = false);
    }
  }

  Future<void> _readReply(ChatMessage message) async {
    if (_speakingId == message.id) {
      _stopVoice();
      return;
    }
    _stopVoice();
    final generation = _voiceGeneration;
    setState(() => _speakingId = message.id);
    try {
      await _voice.speak(message.text);
    } catch (_) {
      if (mounted && generation == _voiceGeneration)
        _showToast(
          'Read aloud is unavailable. Check phone text-to-speech language settings.',
        );
    } finally {
      if (mounted && generation == _voiceGeneration)
        setState(() => _speakingId = null);
    }
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _messageController.text;
    if (text.trim().isEmpty) return;
    if (ref.read(chatControllerProvider).isTyping ||
        BabyProfileStore.id == null)
      return;
    final id = BabyProfileStore.id;
    final online = !AssistantRouting.usesRecords(text);
    if (!mounted ||
        BabyProfileStore.id != id ||
        ref.read(chatControllerProvider).isTyping)
      return;
    ref
        .read(chatControllerProvider.notifier)
        .sendMessage(text, isOnline: online);
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatControllerProvider, (previous, next) => _scrollToBottom());

    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _AssistantFloatingDecor()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _headerFade,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                AuthBackButton(
                                  onPressed: () =>
                                      context.go(RoutePaths.dashboard),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Clear conversation',
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  onPressed: chatState.messages.length <= 1
                                      ? null
                                      : () async {
                                          final id = BabyProfileStore.id;
                                          final clear = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Clear conversation?',
                                              ),
                                              content: Text(
                                                'This clears only this session’s conversation for ${BabyProfileStore.name}. Care records are not deleted.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Clear'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (clear == true &&
                                              mounted &&
                                              BabyProfileStore.id == id) {
                                            ref
                                                .read(
                                                  chatControllerProvider
                                                      .notifier,
                                                )
                                                .clearConversation();
                                            _showToast('Conversation cleared.');
                                          }
                                        },
                                ),
                              ],
                            ),
                            if (MediaQuery.viewInsetsOf(context).bottom ==
                                0) ...[
                              const _AssistantHeaderCard(),
                              const SizedBox(height: 12),
                              if (chatState.messages.length == 1 &&
                                  BabyProfileStore.id != null)
                                _SuggestedQuestionsRow(
                                  onSelected: _handleSend,
                                  questions: _suggestedQuestions,
                                ),
                              const SizedBox(height: 8),
                            ] else
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Saved records for ${BabyProfileStore.name}',
                                  style: GoogleFonts.nunito(
                                    color: AuthPalette.textMuted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        itemCount:
                            chatState.messages.length +
                            (chatState.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == chatState.messages.length) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _TypingIndicatorBubble(),
                              ),
                            );
                          }
                          final message = chatState.messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AnimatedMessageEntry(
                              key: ValueKey(message.id),
                              child: _MessageBubble(
                                message: message,
                                onRead:
                                    message.sender == ChatSender.assistant &&
                                        message.id != 'welcome'
                                    ? () => _readReply(message)
                                    : null,
                                speaking: _speakingId == message.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 2, 24, 6),
                      child: Text(
                        'Saved-record answers are handled on-device. General questions and recent online chat go to Google Gemini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AuthPalette.textMuted,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: _MessageComposer(
                        controller: _messageController,
                        onMic:
                            chatState.isTyping ||
                                _voiceBusy ||
                                BabyProfileStore.id == null
                            ? null
                            : _dictate,
                        onSend:
                            chatState.isTyping || BabyProfileStore.id == null
                            ? null
                            : () => _handleSend(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Assistant-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation matching the pattern already used across
/// the app, so no shared or sibling screen file needs to change.
class _AssistantFloatingDecor extends StatefulWidget {
  const _AssistantFloatingDecor();

  @override
  State<_AssistantFloatingDecor> createState() =>
      _AssistantFloatingDecorState();
}

class _AssistantFloatingDecorState extends State<_AssistantFloatingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.03,
      left: 0.09,
      size: 12,
      color: AuthPalette.softCoral,
      phase: 0.0,
    ),
    _DecorSpec(
      icon: Icons.cloud_rounded,
      top: 0.05,
      left: 0.85,
      size: 20,
      color: AuthPalette.powderBlue,
      phase: 0.4,
    ),
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.19,
      left: 0.91,
      size: 10,
      color: AuthPalette.mint,
      phase: 0.25,
    ),
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.28,
      left: 0.05,
      size: 11,
      color: AuthPalette.lavenderMist,
      phase: 0.6,
    ),
    _DecorSpec(
      icon: Icons.cloud_rounded,
      top: 0.85,
      left: 0.07,
      size: 16,
      color: AuthPalette.blushPink,
      phase: 0.15,
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

class _AssistantHeaderCard extends StatelessWidget {
  const _AssistantHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AuthPalette.lavenderMist.withValues(alpha: 0.5),
            AuthPalette.blushPink.withValues(alpha: 0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.softCoral.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.85),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AuthPalette.softCoral.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AuthPalette.softCoral,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LullaByte Assistant',
                  style: GoogleFonts.quicksand(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AuthPalette.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "For ${BabyProfileStore.name} · Care information, not a diagnosis",
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    color: AuthPalette.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedQuestionsRow extends StatelessWidget {
  const _SuggestedQuestionsRow({
    required this.onSelected,
    this.questions = _suggestedQuestions,
  });

  final ValueChanged<String> onSelected;
  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final question = questions[index];
          return Material(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(question),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  question,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AuthPalette.textDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Fades and slides a message bubble up on its own first build, giving the
/// "smooth animated insertion" the newest message in the list.
class _AnimatedMessageEntry extends StatefulWidget {
  const _AnimatedMessageEntry({required this.child, super.key});

  final Widget child;

  @override
  State<_AnimatedMessageEntry> createState() => _AnimatedMessageEntryState();
}

class _AnimatedMessageEntryState extends State<_AnimatedMessageEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    this.onRead,
    this.speaking = false,
  });
  final ChatMessage message;
  final VoidCallback? onRead;
  final bool speaking;
  @override
  Widget build(BuildContext context) {
    final user = message.sender == ChatSender.user;
    return Align(
      key: ValueKey('message-${message.id}'),
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .78,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 6),
        decoration: BoxDecoration(
          color: user
              ? AuthPalette.blushPink
              : Colors.white.withValues(alpha: .96),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(user ? 20 : 4),
            bottomRight: Radius.circular(user ? 4 : 20),
          ),
          border: Border.all(
            color: AuthPalette.lavenderMist.withValues(alpha: .5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.text,
              style: GoogleFonts.nunito(
                fontSize: 14,
                height: 1.4,
                color: AuthPalette.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onRead != null)
                  IconButton(
                    tooltip: speaking ? 'Stop reading' : 'Read aloud',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: onRead,
                    icon: Icon(
                      speaking ? Icons.stop_rounded : Icons.volume_up_outlined,
                      size: 18,
                      color: AuthPalette.textMuted,
                    ),
                  ),
                if (message.failed)
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.error_outline,
                      size: 14,
                      color: AuthPalette.error,
                    ),
                  ),
                Text(
                  '${message.sender == ChatSender.assistant && message.id != 'welcome' && !message.online && !message.failed ? 'Saved records · ' : ''}${TimeOfDay.fromDateTime(message.timestamp).format(context)}',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: AuthPalette.textMuted,
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

class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AuthPalette.lavenderMist.withValues(alpha: 0.4),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 14,
            color: AuthPalette.softCoral,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(
              color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t =
                        (math.sin(
                              (_controller.value + (i * 0.2)) * math.pi * 2,
                            ) +
                            1) /
                        2;
                    return Opacity(
                      opacity: 0.35 + (t * 0.65),
                      child: Transform.translate(
                        offset: Offset(0, -3 * t),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AuthPalette.softCoral,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onSend,
    this.onMic,
  });
  final VoidCallback? onMic;

  final TextEditingController controller;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.softCoral.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => onSend?.call(),
              maxLength: 1000,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AuthPalette.textDark,
              ),
              cursorColor: AuthPalette.softCoral,
              decoration: InputDecoration(
                counterText: '',
                hintText: "Ask about ${BabyProfileStore.name}'s care...",
                hintStyle: GoogleFonts.nunito(
                  fontSize: 13.5,
                  color: AuthPalette.textMuted.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: AuthPalette.blushPink.withValues(alpha: 0.22),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AuthPalette.lavenderMist.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AuthPalette.softCoral,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _ComposerIconButton(
            icon: Icons.mic_none_rounded,
            background: AuthPalette.lavenderMist,
            iconColor: AuthPalette.textDark,
            tooltip: 'Speak message',
            onTap: onMic,
          ),
          const SizedBox(width: 6),
          _ComposerIconButton(
            icon: Icons.send_rounded,
            background: AuthPalette.softCoral,
            iconColor: Colors.white,
            tooltip: 'Send',
            onTap: onSend,
          ),
        ],
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: onTap == null ? background.withValues(alpha: 0.4) : background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Icon(icon, size: 19, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
