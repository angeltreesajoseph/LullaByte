import 'package:flutter/services.dart';

/// Android's installed speech services; no audio is sent to our backend.
class AssistantVoice {
  static const _channel = MethodChannel('lullabyte/assistant_voice');
  Future<String?> dictate() => _channel.invokeMethod<String>('dictate');
  Future<void> speak(String text) =>
      _channel.invokeMethod<void>('speak', {'text': text});
  Future<void> stop() => _channel.invokeMethod<void>('stop');
}
