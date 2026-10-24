/// Who a given chat message is from.
enum ChatSender { user, assistant }

/// A single message in the AI Assistant conversation.
///
/// Immutable by design — the chat transcript only ever grows via
/// [ChatController.sendMessage] appending new instances, never by
/// mutating an existing message in place.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.online = false,
    this.failed = false,
  });

  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final bool online;
  final bool failed;
}
