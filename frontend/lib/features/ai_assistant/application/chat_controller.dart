import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/chat_message.dart';
import 'assistant_providers.dart';

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
  @override
  ChatState build() {
    return ChatState(messages: [_welcomeMessage()], isTyping: false);
  }

  ChatMessage _welcomeMessage() {
    return ChatMessage(
      id: 'welcome',
      text: "Hi, I'm the LullaByte Assistant! Ask me anything about Lily's sleep, feeding, diapers, vaccines, "
          'growth, or milestones.',
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
    );
  }

  Future<void> sendMessage(String text, {required bool isOnline}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isTyping) return;

    final userMessage = ChatMessage(
      id: _newId(),
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, userMessage], isTyping: true);

    final String responseText;
    if (isOnline) {
      responseText = await ref.read(aiResponseServiceProvider).getResponse(trimmed);
    } else {
      await Future.delayed(const Duration(milliseconds: 700));
      responseText = ref.read(localResponseEngineProvider).respond(trimmed);
    }

    final assistantMessage = ChatMessage(
      id: _newId(),
      text: responseText,
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, assistantMessage], isTyping: false);
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(ChatController.new);
