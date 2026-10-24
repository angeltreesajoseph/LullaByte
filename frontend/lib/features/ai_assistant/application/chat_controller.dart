import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../domain/entities/chat_message.dart';
import 'assistant_providers.dart';
import '../../baby_management/application/baby_profile_store.dart';

class ChatState {
  const ChatState({required this.messages, required this.isTyping});

  final List<ChatMessage> messages;
  final bool isTyping;

  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

/// Owns the chat transcript and dispatches each question to either
/// [LocalResponseEngine] (Offline Helper) or [AiResponseService] (Online
/// AI), depending on the caller-supplied `isOnline` flag — kept entirely
/// local to this feature/session; nothing is persisted.
class ChatController extends Notifier<ChatState> {
  final _threads = <String, ChatState>{};
  String? _babyId;
  int _generation = 0;
  int _serial = 0;
  bool _alive = true;
  @override
  ChatState build() {
    _alive = true;
    _babyId = BabyProfileStore.id;
    void reset() {
      if (_babyId == BabyProfileStore.id) return;
      _generation++;
      if (_babyId != null) _threads[_babyId!] = state.copyWith(isTyping: false);
      _babyId = BabyProfileStore.id;
      if (_babyId == null) _threads.clear();
      state =
          _threads[_babyId] ??
          ChatState(messages: [_welcomeMessage()], isTyping: false);
    }

    BabyProfileStore.changes.addListener(reset);
    ref.onDispose(() {
      _alive = false;
      _generation++;
      BabyProfileStore.changes.removeListener(reset);
    });
    return ChatState(messages: [_welcomeMessage()], isTyping: false);
  }

  ChatMessage _welcomeMessage() {
    return ChatMessage(
      id: 'welcome',
      text: BabyProfileStore.id == null
          ? 'Select a baby profile to get started.'
          : "Hi! Ask about ${BabyProfileStore.name}'s saved records or general baby-care questions. Chats last for this app session only.",
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
    );
  }

  Future<void> sendMessage(String text, {required bool isOnline}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isTyping || BabyProfileStore.id == null)
      return;
    final babyId = BabyProfileStore.id;
    final generation = _generation;
    final onlineHistory = state.messages
        .where((m) => m.online && !m.failed && m.id != 'welcome')
        .toList();
    final history = onlineHistory
        .skip(onlineHistory.length > 8 ? onlineHistory.length - 8 : 0)
        .map(
          (m) => <String, String>{
            'role': m.sender == ChatSender.user ? 'user' : 'model',
            'text': m.text,
          },
        )
        .toList();

    final userMessage = ChatMessage(
      id: _newId(),
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
      online: isOnline,
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    String responseText;
    bool failed = false;
    try {
      if (isOnline) {
        responseText = await ref
            .read(aiResponseServiceProvider)
            .getResponse(trimmed, history: history);
      } else {
        await Future<void>.value();
        if (!_alive ||
            _generation != generation ||
            BabyProfileStore.id != babyId)
          return;
        responseText = ref.read(localResponseEngineProvider).respond(trimmed);
      }
    } catch (error) {
      failed = true;
      responseText = isOnline
          ? 'General answers are temporarily unavailable. Please try again. You can still ask about saved baby records.'
          : 'I could not read the saved records. Please try again.';
      if (error is DioException && error.response?.statusCode == 503)
        responseText =
            'General answers are not ready on the server. Saved baby records are still available here.';
      if (error is DioException && error.response?.statusCode == 404)
        responseText =
            'General answers need a server update before they can work. You can still ask about saved baby records.';
      if (error is DioException && error.response?.statusCode == 429)
        responseText =
            'Request limit reached. Please wait a moment. Saved baby records are still available.';
    }

    if (!_alive || _generation != generation || BabyProfileStore.id != babyId)
      return;
    final assistantMessage = ChatMessage(
      failed: failed,
      id: _newId(),
      text: responseText,
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
      online: isOnline,
    );
    state = state.copyWith(
      messages: [...state.messages, assistantMessage],
      isTyping: false,
    );
  }

  void clearConversation() {
    _generation++;
    if (_babyId != null) _threads.remove(_babyId);
    state = ChatState(messages: [_welcomeMessage()], isTyping: false);
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_serial++}';
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(
  ChatController.new,
);
