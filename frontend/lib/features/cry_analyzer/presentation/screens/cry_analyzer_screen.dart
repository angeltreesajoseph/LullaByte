import '../../../../core/network/care_dio.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/analysis_error_message.dart';
import '../../application/cry_completion_feedback.dart';
import '../widgets/cry_analysis_result.dart';
import '../widgets/cry_recording_card.dart';
import '../../domain/cry_history_records.dart';
import 'cry_history_screen.dart';
import '../../../../core/config/app_config.dart';
import '../../../baby_management/application/baby_profile_store.dart';
import '../../../baby_management/application/profile_tracker.dart';

import '../../../../core/router/route_paths.dart';
import '../../../authentication/presentation/widgets/auth_background.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';

/// AI Cry Analyzer screen (SRS Section 10.6).
///
/// Reuses the same pastel "calm, safe, caring" design language already
/// established by Login, Register, Baby Registration, and Dashboard — the
/// gradient backdrop, palette, and rounded 28px card language come
/// directly from `features/authentication/presentation/widgets/`
/// (read-only reuse; those files are not modified).
///
/// Audio selection and microphone capture are real. Valid audio stops at an
/// "audio ready" boundary; no backend call or AI model is connected yet.
class CryAnalyzerScreen extends StatefulWidget {
  const CryAnalyzerScreen({super.key});

  @override
  State<CryAnalyzerScreen> createState() => _CryAnalyzerScreenState();
}

class _CryAnalyzerScreenState extends State<CryAnalyzerScreen>
    with TickerProviderStateMixin, ProfileTracker<CryAnalyzerScreen> {
  final AudioPlayer _player = AudioPlayer();
  final List<Map<String, dynamic>> _recordings = [];
  String? _recordingBabyId;
  bool _inputBusy = false;
  bool _savingAudio = false;
  bool _uploadConsent = false;
  String? _savedAudioPath;
  String? _playbackPath;
  Map<String, dynamic>? _analysis;
  String? _analysisError;
  bool _deletingAudio = false;
  PlayerState _playState = PlayerState.stopped;
  String? _playingKey;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final List<StreamSubscription<dynamic>> _playSubscriptions = [];
  String _historyKey(Map<String, dynamic> entry) =>
      CryHistoryRecords.key(entry);
  String? _historyBabyId;

  @override
  String get trackerKind => 'cry';
  @override
  bool get allowSnapshotReady => true;
  @override
  List<Map<String, dynamic>> encodeEntries() => List.of(_recordings);
  @override
  void decodeEntries(List<Map<String, dynamic>> entries) {
    if (_historyBabyId != BabyProfileStore.id) {
      _historyBabyId = BabyProfileStore.id;
      _analysis = null;
      _analysisError = null;
      _savedAudioPath = null;
      _playingKey = null;
      _state = _AnalyzerState.idle;
      unawaited(_player.stop());
    }
    _recordings
      ..clear()
      ..addAll(entries);
  }

  Future<Dio> _cryClient() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in required');
    return careDio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(minutes: 3),
        headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
      ),
    );
  }

  Future<void> _saveAudio() async {
    final id = _recordingBabyId;
    final path = _audioPath;
    if (_savingAudio || id == null || path == null) return;
    if (_savedAudioPath == path) {
      _showToast('This recording is already saved.');
      return;
    }
    if (!trackerReady || BabyProfileStore.id != id) {
      _showToast('Select the baby this recording belongs to before saving.');
      return;
    }
    if (_recordings.length >= 20) {
      _showToast(
        'Delete an older recording before saving another (limit: 20).',
      );
      return;
    }
    if (!_uploadConsent) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save recording online?'),
          content: const Text(
            'Internal-testing model: it failed on tired, discomfort and belly-pain test cries. Scores are not probabilities of your baby’s needs. This uploads and saves audio for the selected baby; delete it from history. Exact dataset matches show the saved label, not AI confidence. Audio is not used for training.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (accepted != true || !mounted) return;
      _uploadConsent = true;
    }
    setState(() {
      _savingAudio = true;
      _analysisError = null;
      _state = _AnalyzerState.analyzing;
    });
    try {
      final bytes = await File(path).readAsBytes();
      if (bytes.length > 2000000) throw StateError('Recording exceeds 2 MB');
      final client = await _cryClient();
      final response = await client.post(
        '/babies/$id/cry/analyze',
        data: {
          'audio_data': base64Encode(bytes),
          'format': _extensionOf(path),
          'accept_experimental': true,
        },
      );
      if (!mounted || BabyProfileStore.id != id) return;
      acceptServerTrackerMutation();
      _savedAudioPath = path;
      setState(() {
        _analysis = Map<String, dynamic>.from(
          response.data['data']['entry'] as Map,
        );
        _state = _AnalyzerState.resultReady;
        _savingAudio = false;
        decodeEntries(
          (response.data['data']['history'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
        );
      });
      unawaited(
        cryCompletionFeedback(
          visible:
              ModalRoute.of(context)?.isCurrent == true &&
              WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed,
        ),
      );
      _showToast('Analysis ready and saved. Check the result below.');
    } on DioException catch (error) {
      final message = error.type == DioExceptionType.receiveTimeout
          ? 'Analysis timed out. The server may still finish saving it. Reopen history before retrying.'
          : cryAnalysisErrorMessage(
              error.response?.data,
              error.response?.statusCode,
            );
      if (mounted) {
        setState(() => _analysisError = message);
        _showToast(message);
      }
    } catch (_) {
      if (mounted) {
        const message =
            'Could not analyze audio. Use a recording under 2 MB and 30 seconds.';
        setState(() => _analysisError = message);
        _showToast(message);
      }
    } finally {
      if (mounted)
        setState(() {
          _savingAudio = false;
          if (_state == _AnalyzerState.analyzing)
            _state = _AnalyzerState.audioReady;
        });
    }
  }

  Future<void> _playSaved(Map<String, dynamic> entry) async {
    if (_savingAudio || _deletingAudio || _state == _AnalyzerState.recording)
      return;
    try {
      final key = _historyKey(entry);
      if (_playingKey == key && _playState == PlayerState.playing) {
        await _player.pause();
        return;
      }
      if (_playingKey == key && _playState == PlayerState.paused) {
        await _player.resume();
        return;
      }
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}${Platform.pathSeparator}cry_playback.${entry['format']}',
      );
      _playbackPath = file.path;
      await _player.stop();
      if (!mounted) return;
      setState(() {
        _playingKey = key;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      await file.writeAsBytes(base64Decode(entry['audio_data'] as String));
      await _player.play(DeviceFileSource(file.path));
    } catch (_) {
      if (mounted) _showToast('Could not play this recording.');
    }
  }

  Future<void> _deleteSaved(Map<String, dynamic> entry) async {
    if (_savingAudio || _deletingAudio || !trackerReady) return;
    final id = BabyProfileStore.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recording?'),
        content: const Text('This removes the saved audio and its analysis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || BabyProfileStore.id != id) return;
    setState(() => _deletingAudio = true);
    try {
      final entries = _recordings
          .where((item) => _historyKey(item) != _historyKey(entry))
          .toList();
      await _player.stop();
      final client = await _cryClient();
      await client.put('/babies/$id/trackers/cry', data: entries);
      if (mounted && BabyProfileStore.id == id)
        setState(() {
          decodeEntries(entries);
          if (_analysis != null &&
              _historyKey(_analysis!) == _historyKey(entry)) {
            _analysis = null;
            _savedAudioPath = null;
            _state = _AnalyzerState.audioReady;
          }
        });
    } catch (_) {
      if (mounted) _showToast('Could not delete recording. Please retry.');
    } finally {
      if (mounted) setState(() => _deletingAudio = false);
    }
  }

  Future<void> _openHistory() async {
    final id = BabyProfileStore.id;
    if (id == null ||
        _savingAudio ||
        _deletingAudio ||
        _inputBusy ||
        _state == _AnalyzerState.recording)
      return;
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _playingKey = null;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CryHistoryScreen()));
    if (!mounted || BabyProfileStore.id != id) return;
    try {
      final client = await _cryClient();
      final response = await client.get('/babies/$id');
      if (!mounted || BabyProfileStore.id != id) return;
      final rows =
          ((response.data['data']['tracker_data'] as Map?)?['cry'] as List? ??
                  [])
              .map((r) => Map<String, dynamic>.from(r as Map))
              .toList();
      setState(() {
        decodeEntries(rows);
        if (_analysis != null &&
            !rows.any((r) => _historyKey(r) == _historyKey(_analysis!))) {
          _analysis = null;
          _savedAudioPath = null;
          _state = _audioPath == null
              ? _AnalyzerState.idle
              : _AnalyzerState.audioReady;
        }
      });
    } catch (_) {
      if (mounted)
        _showToast(
          'Could not refresh recent recordings. Reopen history to retry.',
        );
    }
  }

  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  late final AnimationController _breatheController;
  late final AnimationController _pulseController;

  _AnalyzerState _state = _AnalyzerState.idle;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  final AudioRecorder _audioRecorder = AudioRecorder();
  DateTime? _recordingStartedAt;
  String? _audioPath;
  bool _ownsAudioFile = false;

  static const _supportedExtensions = <String>{'wav', 'mp3', 'm4a', 'ogg'};
  static const _minimumRecordingDuration = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    _playSubscriptions.add(
      _player.onPlayerStateChanged.listen((value) {
        if (mounted) setState(() => _playState = value);
      }),
    );
    _playSubscriptions.add(
      _player.onPositionChanged.listen((value) {
        if (mounted) setState(() => _position = value);
      }),
    );
    _playSubscriptions.add(
      _player.onDurationChanged.listen((value) {
        if (mounted) setState(() => _duration = value);
      }),
    );
    startTracker();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    stopTracker();
    for (final subscription in _playSubscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_cleanUpAudio());
    _entranceController.dispose();
    _breatheController.dispose();
    _pulseController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _cleanUpAudio() async {
    try {
      await _player.dispose();
      await _audioRecorder.dispose();
      await _discardOwnedAudioFile();
      final path = _playbackPath;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {
      // Temporary files may already have been removed by the operating system.
    }
  }

  String get _statusText => switch (_state) {
    _AnalyzerState.idle => 'Ready to listen',
    _AnalyzerState.recording => 'Listening…',
    _AnalyzerState.analyzing => 'Analyzing audio…',
    _AnalyzerState.audioReady =>
      _savingAudio ? 'Analysing audio…' : 'Audio ready',
    _AnalyzerState.error => 'Audio input error',
    _AnalyzerState.resultReady => 'Analysis complete',
  };

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
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

  Future<void> _handleMicTap() async {
    if (_inputBusy || _savingAudio || _deletingAudio) return;
    _inputBusy = true;
    try {
      switch (_state) {
        case _AnalyzerState.idle:
        case _AnalyzerState.audioReady:
        case _AnalyzerState.error:
        case _AnalyzerState.resultReady:
          await _startRecording();
        case _AnalyzerState.recording:
          await _stopRecording();
        case _AnalyzerState.analyzing:
          break;
      }
    } finally {
      _inputBusy = false;
    }
  }

  Future<void> _startRecording() async {
    _analysis = null;
    if (!trackerReady || BabyProfileStore.id == null) {
      _showToast('Wait for the selected baby’s history to load.');
      return;
    }
    _recordingBabyId = BabyProfileStore.id;
    try {
      await _player.stop();
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _setInputError('Microphone permission is required to record audio.');
        return;
      }

      await _discardOwnedAudioFile();
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}${Platform.pathSeparator}lullabyte_cry_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
          bitRate: 64000,
        ),
        path: path,
      );
      if (!mounted) return;

      _recordingTimer?.cancel();
      setState(() {
        _state = _AnalyzerState.recording;
        _recordingSeconds = 0;
        _recordingStartedAt = DateTime.now();
        _audioPath = path;
        _ownsAudioFile = true;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordingSeconds++);
        if (_recordingSeconds >= 30) unawaited(_handleMicTap());
      });
    } catch (_) {
      _setInputError('Unable to start recording. Please try again.');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final elapsed = _recordingStartedAt == null
        ? Duration.zero
        : DateTime.now().difference(_recordingStartedAt!);

    try {
      final stoppedPath = await _audioRecorder.stop();
      _recordingStartedAt = null;
      final path = stoppedPath ?? _audioPath;
      if (elapsed < _minimumRecordingDuration ||
          !await _isValidAudioFile(path)) {
        await _discardOwnedAudioFile();
        _setInputError(
          'No audio was recorded. Please record a baby cry and try again.',
        );
        return;
      }
      _audioPath = path;
      await _markAudioReady();
      await _saveAudio();
    } catch (_) {
      _recordingStartedAt = null;
      await _discardOwnedAudioFile();
      _setInputError('Unable to save the recording. Please try again.');
    }
  }

  Future<void> _handleUpload() async {
    if (!trackerReady ||
        _savingAudio ||
        _deletingAudio ||
        _inputBusy ||
        BabyProfileStore.id == null)
      return;
    _recordingBabyId = BabyProfileStore.id;
    final babyId = _recordingBabyId;
    if (_state == _AnalyzerState.recording ||
        _state == _AnalyzerState.analyzing) {
      return;
    }
    _inputBusy = true;
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: _supportedExtensions.toList(),
      );
      if (picked == null || !mounted || BabyProfileStore.id != babyId) return;

      final path = picked.path;
      final extension = _extensionOf(picked.name);
      if (!_supportedExtensions.contains(extension)) {
        _setInputError('Please select a WAV, MP3, M4A, or OGG audio file.');
        return;
      }
      if (!await _isValidAudioFile(path)) {
        _setInputError('Unable to read this audio file.');
        return;
      }

      await _player.stop();
      await _discardOwnedAudioFile();
      _analysis = null;
      _analysisError = null;
      _savedAudioPath = null;
      _audioPath = path;
      _ownsAudioFile = false;
      await _markAudioReady();
      await _saveAudio();
    } catch (_) {
      _setInputError('Unable to open this audio file. Please try again.');
    } finally {
      _inputBusy = false;
    }
  }

  Future<void> _markAudioReady() async {
    if (!mounted) return;
    setState(() => _state = _AnalyzerState.audioReady);
  }

  Future<bool> _isValidAudioFile(String? path) async {
    if (path == null || path.trim().isEmpty) return false;
    if (!_supportedExtensions.contains(_extensionOf(path))) return false;
    final file = File(path);
    if (!await file.exists()) return false;
    return await file.length() > 0;
  }

  String _extensionOf(String path) {
    final separator = path.lastIndexOf('.');
    return separator < 0 ? '' : path.substring(separator + 1).toLowerCase();
  }

  void _setInputError(String message) {
    if (!mounted) return;
    setState(() {
      _state = _AnalyzerState.error;
      _recordingSeconds = 0;
      _recordingStartedAt = null;
    });
    _showToast(message);
  }

  Future<void> _discardOwnedAudioFile() async {
    final path = _audioPath;
    if (_ownsAudioFile && path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    _audioPath = null;
    _ownsAudioFile = false;
  }

  Future<void> _handleDelete() async {
    if (_savingAudio || _deletingAudio) return;
    if (_analysis != null) {
      await _deleteSaved(_analysis!);
      if (!mounted || _analysis != null) return;
    }
    await _player.stop();
    _recordingTimer?.cancel();
    await _discardOwnedAudioFile();
    if (!mounted) return;
    setState(() {
      _state = _AnalyzerState.idle;
      _recordingSeconds = 0;
    });
  }

  Future<void> _handlePlay() async {
    final path = _audioPath;
    if (path == null) return;
    try {
      final key = _analysis == null ? path : _historyKey(_analysis!);
      if (_playingKey == key && _playState == PlayerState.playing) {
        await _player.pause();
        return;
      }
      if (_playingKey == key && _playState == PlayerState.paused) {
        await _player.resume();
        return;
      }
      await _player.stop();
      if (!mounted) return;
      setState(() {
        _playingKey = key;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      await _player.play(DeviceFileSource(path));
    } catch (_) {
      if (mounted) _showToast('Could not play audio.');
    }
  }

  void _showHowItWorksSheet() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cry recordings'),
        content: const Text(
          'Tap the microphone to start, then again to stop (maximum 30 seconds). With consent, audio is analyzed and saved for the selected baby. Exact training-file matches show the stored dataset label. Other audio gets uncalibrated experimental model scores. The model failed on tired, discomfort and belly-pain test cries: these scores cannot establish why your baby is crying. Play, inspect or delete saved entries in history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy =
        _state == _AnalyzerState.recording ||
        _state == _AnalyzerState.analyzing;

    return Scaffold(
      backgroundColor: AuthPalette.warmCream,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackgroundGradient()),
          const Positioned.fill(child: _CryFloatingDecor()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
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
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Cry Analyzer',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: AuthPalette.textDark,
                                    ),
                                  ),
                                ),
                                _InfoButton(onTap: _showHowItWorksSheet),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'Understand what your baby may be trying to tell you',
                              style: GoogleFonts.nunito(
                                fontSize: 14.5,
                                color: AuthPalette.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _HeroCard(
                            state: _state,
                            statusText: _statusText,
                            recordingLabel: _formatDuration(_recordingSeconds),
                            breatheController: _breatheController,
                            pulseController: _pulseController,
                            onMicTap: _handleMicTap,
                          ),
                          if (_state == _AnalyzerState.recording ||
                              _state == _AnalyzerState.analyzing ||
                              _state == _AnalyzerState.audioReady ||
                              _state == _AnalyzerState.resultReady) ...[
                            const SizedBox(height: 14),
                            _AudioControlsRow(
                              state: _state,
                              playing:
                                  _playState == PlayerState.playing &&
                                  _playingKey ==
                                      (_analysis == null
                                          ? _audioPath
                                          : _historyKey(_analysis!)),
                              onStop: _handleMicTap,
                              onPlay: _handlePlay,
                              onDelete: _handleDelete,
                            ),
                          ],
                          const SizedBox(height: 16),
                          _UploadCard(
                            enabled:
                                !isBusy &&
                                !_savingAudio &&
                                !_deletingAudio &&
                                trackerReady,
                            onTap: _handleUpload,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Unvalidated model: results performed poorly for tiredness, discomfort and belly pain. Scores are sound-pattern matches, not medical probabilities.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AuthPalette.textDark,
                            ),
                          ),
                          if (_savingAudio)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: LinearProgressIndicator(),
                            ),
                          if (_analysis != null) ...[
                            const SizedBox(height: 16),
                            CryAnalysisResult(entry: _analysis!),
                          ],
                          const SizedBox(height: 26),
                          _SectionHeading(title: 'Recent History'),
                          const SizedBox(height: 10),
                          Text('Recordings for ${BabyProfileStore.name}'),
                          if (_state == _AnalyzerState.audioReady)
                            TextButton(
                              onPressed: _savingAudio ? null : _saveAudio,
                              child: Text(
                                _savingAudio
                                    ? 'Analysing…'
                                    : 'Analyse and save recording',
                              ),
                            ),
                          if (!trackerReady) const LinearProgressIndicator(),
                          if (_analysisError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                _analysisError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          if (trackerReady && _recordings.isEmpty)
                            const Text('No saved recordings yet.'),
                          for (final entry in CryHistoryRecords.sorted(
                            _recordings,
                          ).take(3))
                            CryRecordingCard(
                              key: ValueKey(CryHistoryRecords.key(entry)),
                              entry: entry,
                              active: _playingKey == _historyKey(entry),
                              playing:
                                  _playingKey == _historyKey(entry) &&
                                  _playState == PlayerState.playing,
                              position: _position,
                              playbackDuration: _duration,
                              onPlay: _savingAudio || _deletingAudio || isBusy
                                  ? null
                                  : () => _playSaved(entry),
                              onDelete: _savingAudio || _deletingAudio || isBusy
                                  ? null
                                  : () => _deleteSaved(entry),
                            ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed:
                                isBusy ||
                                    _savingAudio ||
                                    _deletingAudio ||
                                    !trackerReady
                                ? null
                                : _openHistory,
                            icon: const Icon(Icons.history_rounded),
                            label: const Text('View all history'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AnalyzerState {
  idle,
  recording,
  analyzing,
  audioReady,
  error,
  resultReady,
}

/// Cry Analyzer-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation (not imported from Dashboard, which keeps
/// its own private version) so no shared or sibling screen file needs to
/// change.
class _CryFloatingDecor extends StatefulWidget {
  const _CryFloatingDecor();

  @override
  State<_CryFloatingDecor> createState() => _CryFloatingDecorState();
}

class _CryFloatingDecorState extends State<_CryFloatingDecor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.02,
      left: 0.85,
      size: 12,
      color: AuthPalette.softCoral,
      phase: 0.0,
    ),
    _DecorSpec(
      icon: Icons.cloud_rounded,
      top: 0.05,
      left: 0.10,
      size: 22,
      color: AuthPalette.powderBlue,
      phase: 0.5,
    ),
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.15,
      left: 0.05,
      size: 10,
      color: AuthPalette.mint,
      phase: 0.25,
    ),
    _DecorSpec(
      icon: Icons.star_rounded,
      top: 0.35,
      left: 0.92,
      size: 11,
      color: AuthPalette.lavenderMist,
      phase: 0.7,
    ),
    _DecorSpec(
      icon: Icons.cloud_rounded,
      top: 0.55,
      left: 0.88,
      size: 18,
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

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'How cry analysis works',
      child: Material(
        color: Colors.white.withValues(alpha: 0.75),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.info_outline_rounded,
              color: AuthPalette.textDark,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AuthPalette.textDark,
        ),
      ),
    );
  }
}

/// The hero card: large animated microphone button, status text, elapsed
/// timer, and live waveform.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.state,
    required this.statusText,
    required this.recordingLabel,
    required this.breatheController,
    required this.pulseController,
    required this.onMicTap,
  });

  final _AnalyzerState state;
  final String statusText;
  final String recordingLabel;
  final AnimationController breatheController;
  final AnimationController pulseController;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AuthPalette.blushPink.withValues(alpha: 0.55),
            AuthPalette.lavenderMist.withValues(alpha: 0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AuthPalette.lavenderMist.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AuthPalette.softCoral.withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AuthPalette.lavenderMist.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _MicButton(
            state: state,
            breatheController: breatheController,
            pulseController: pulseController,
            onTap: onMicTap,
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              statusText,
              key: ValueKey(statusText),
              style: GoogleFonts.quicksand(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textDark,
              ),
            ),
          ),
          if (state == _AnalyzerState.recording) ...[
            const SizedBox(height: 4),
            Text(
              recordingLabel,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 18),
          _LiveWaveform(active: state == _AnalyzerState.recording),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.state,
    required this.breatheController,
    required this.pulseController,
    required this.onTap,
  });

  final _AnalyzerState state;
  final AnimationController breatheController;
  final AnimationController pulseController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRecording = state == _AnalyzerState.recording;
    final isAnalyzing = state == _AnalyzerState.analyzing;
    final isResult =
        state == _AnalyzerState.audioReady ||
        state == _AnalyzerState.resultReady;

    final gradientColors = isResult
        ? const [AuthPalette.mint, AuthPalette.powderBlue]
        : isRecording
        ? const [AuthPalette.softCoral, Color(0xFFEF6FA0)]
        : const [AuthPalette.softCoral, AuthPalette.lavenderMist];

    return Semantics(
      button: true,
      label: isRecording ? 'Stop recording' : 'Start recording',
      child: GestureDetector(
        onTap: isAnalyzing ? null : onTap,
        child: SizedBox(
          width: 168,
          height: 168,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isRecording)
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _pulseRing(pulseController.value),
                        _pulseRing((pulseController.value + 0.5) % 1.0),
                      ],
                    );
                  },
                ),
              AnimatedBuilder(
                animation: breatheController,
                builder: (context, child) {
                  final scale = isRecording || isAnalyzing
                      ? 1.0
                      : 1.0 + (breatheController.value * 0.035);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AuthPalette.softCoral.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _centerIcon(isRecording, isAnalyzing, isResult),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerIcon(bool isRecording, bool isAnalyzing, bool isResult) {
    if (isAnalyzing) {
      return const SizedBox(
        width: 34,
        height: 34,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      );
    }
    if (isResult) {
      return const Icon(Icons.check_rounded, color: Colors.white, size: 44);
    }
    return Icon(
      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
      color: Colors.white,
      size: 42,
    );
  }

  Widget _pulseRing(double t) {
    final size = 108 + (t * 70);
    return Opacity(
      opacity: (1 - t) * 0.45,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AuthPalette.softCoral, width: 2),
        ),
      ),
    );
  }
}

/// A continuously-animating waveform. Amplitude scales down to near-flat
/// when [active] is false, rather than starting/stopping the underlying
/// controller, avoiding any risk of a stuck animation across state
/// transitions.
class _LiveWaveform extends StatefulWidget {
  const _LiveWaveform({required this.active});

  final bool active;

  @override
  State<_LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<_LiveWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _barCount = 28;

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
    return SizedBox(
      height: 44,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < _barCount; i++) ...[
                if (i > 0) const SizedBox(width: 3),
                Expanded(
                  child: _WaveBar(
                    t: _controller.value,
                    index: i,
                    amplitude: widget.active ? 1.0 : 0.06,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  const _WaveBar({
    required this.t,
    required this.index,
    required this.amplitude,
  });

  final double t;
  final int index;
  final double amplitude;

  @override
  Widget build(BuildContext context) {
    final phase = index * 0.55;
    final wobble = (math.sin((t * math.pi * 2) + phase) + 1) / 2;
    final heightFactor = (0.18 + (wobble * 0.82)) * amplitude.clamp(0.06, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6 + (38 * (amplitude < 0.5 ? 0.06 : heightFactor)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [AuthPalette.softCoral, AuthPalette.lavenderMist],
        ),
      ),
    );
  }
}

class _AudioControlsRow extends StatelessWidget {
  const _AudioControlsRow({
    required this.state,
    required this.playing,
    required this.onStop,
    required this.onPlay,
    required this.onDelete,
  });

  final _AnalyzerState state;
  final bool playing;
  final VoidCallback onStop;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (state == _AnalyzerState.recording) {
      return AuthOutlineButton(
        label: 'Stop',
        icon: Icons.stop_circle_outlined,
        accent: AuthPalette.softCoral,
        isLoading: false,
        onPressed: onStop,
      );
    }

    final canInteract =
        state == _AnalyzerState.audioReady ||
        state == _AnalyzerState.resultReady;
    return Row(
      children: [
        Expanded(
          child: AuthOutlineButton(
            label: playing ? 'Pause' : 'Play',
            icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            accent: AuthPalette.powderBlue,
            isLoading: false,
            onPressed: canInteract ? onPlay : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AuthOutlineButton(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            accent: AuthPalette.softCoral,
            isLoading: false,
            onPressed: canInteract ? onDelete : null,
          ),
        ),
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: AuthCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AuthPalette.powderBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AuthPalette.textDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload audio file',
                      style: GoogleFonts.nunito(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textDark,
                      ),
                    ),
                    Text(
                      'WAV, MP3, M4A, OGG · up to 2 MB / 30 seconds',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AuthPalette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
