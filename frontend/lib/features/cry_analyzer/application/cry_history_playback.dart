import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/cry_history_records.dart';

abstract class CryHistoryPlayback extends ChangeNotifier {
  String? get currentKey;
  bool get playing;
  Duration get position;
  Duration get duration;
  Future<void> toggle(Map<String, dynamic> row);
  Future<void> stop();
}

class DeviceCryHistoryPlayback extends CryHistoryPlayback {
  final _player = AudioPlayer();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  String? _key;
  bool _playing = false, _disposed = false;
  int _operation = 0;
  Duration _position = Duration.zero, _duration = Duration.zero;
  Directory? _directory;
  DeviceCryHistoryPlayback() {
    _subscriptions.add(
      _player.onPlayerStateChanged.listen((state) {
        _playing = state == PlayerState.playing;
        _notify();
      }),
    );
    _subscriptions.add(
      _player.onPositionChanged.listen((value) {
        _position = value;
        _notify();
      }),
    );
    _subscriptions.add(
      _player.onDurationChanged.listen((value) {
        _duration = value;
        _notify();
      }),
    );
  }
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  String? get currentKey => _key;
  @override
  bool get playing => _playing;
  @override
  Duration get position => _position;
  @override
  Duration get duration => _duration;
  @override
  Future<void> toggle(Map<String, dynamic> row) async {
    final key = CryHistoryRecords.key(row);
    if (_key == key && _playing) {
      await _player.pause();
      return;
    }
    if (_key == key && _player.state == PlayerState.paused) {
      await _player.resume();
      return;
    }
    final op = ++_operation;
    await _player.stop();
    final directory = _directory ??= await (await getTemporaryDirectory())
        .createTemp('cry_history_');
    if (_disposed || op != _operation) return;
    final format = row['format'] as String?;
    if (!['wav', 'mp3', 'm4a', 'ogg'].contains(format))
      throw StateError('Unsupported audio');
    final file = File(
      '${directory.path}${Platform.pathSeparator}playback.$format',
    );
    await file.writeAsBytes(base64Decode(row['audio_data'] as String));
    if (_disposed || op != _operation) return;
    _key = key;
    _position = Duration.zero;
    _duration = Duration.zero;
    _notify();
    await _player.play(DeviceFileSource(file.path));
  }

  @override
  Future<void> stop() async {
    _operation++;
    _key = null;
    _playing = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _notify();
    await _player.stop();
  }

  @override
  void dispose() {
    _disposed = true;
    _operation++;
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    unawaited(_cleanup());
    super.dispose();
  }

  Future<void> _cleanup() async {
    try {
      await _player.dispose();
    } catch (_) {}
    final dir = _directory;
    if (dir != null) {
      // Only this instance's generated playback files inside its temp directory.
      for (final format in ['wav', 'mp3', 'm4a', 'ogg']) {
        final file = File(
          '${dir.path}${Platform.pathSeparator}playback.$format',
        );
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
      try {
        await dir.delete();
      } catch (_) {}
    }
  }
}
