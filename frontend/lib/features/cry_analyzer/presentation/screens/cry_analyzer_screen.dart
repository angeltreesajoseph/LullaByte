import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
/// Recording, the live waveform, and analysis are entirely simulated with
/// realistic sample data and timed delays — there is no microphone
/// capture, no file access, no backend call, and no real AI model here.
/// The recording/upload → analyzing → result state machine is fully
/// functional at the UI/state level so it is ready to be wired to the
/// real AI Prediction Service (SAD Section 7.7) later without any UI
/// change.
class CryAnalyzerScreen extends StatefulWidget {
  const CryAnalyzerScreen({super.key});

  @override
  State<CryAnalyzerScreen> createState() => _CryAnalyzerScreenState();
}

class _CryAnalyzerScreenState extends State<CryAnalyzerScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  late final AnimationController _breatheController;
  late final AnimationController _pulseController;

  _AnalyzerState _state = _AnalyzerState.idle;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  static const _history = <_HistoryEntry>[
    _HistoryEntry(result: 'Hungry', confidence: 86, time: 'Today, 2:15 PM'),
    _HistoryEntry(result: 'Tired', confidence: 78, time: 'Today, 11:40 AM'),
    _HistoryEntry(result: 'Discomfort', confidence: 65, time: 'Yesterday, 9:20 PM'),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _contentFade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
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
    _entranceController.dispose();
    _breatheController.dispose();
    _pulseController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  String get _statusText => switch (_state) {
        _AnalyzerState.idle => 'Ready to listen',
        _AnalyzerState.recording => 'Listening…',
        _AnalyzerState.analyzing => 'Analyzing…',
        _AnalyzerState.resultReady => 'Result ready',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            message,
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  Future<void> _handleMicTap() async {
    switch (_state) {
      case _AnalyzerState.idle:
      case _AnalyzerState.resultReady:
        _startRecording();
      case _AnalyzerState.recording:
        await _stopRecordingAndAnalyze();
      case _AnalyzerState.analyzing:
        break;
    }
  }

  void _startRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _state = _AnalyzerState.recording;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordingSeconds++);
    });
  }

  Future<void> _stopRecordingAndAnalyze() async {
    _recordingTimer?.cancel();
    setState(() => _state = _AnalyzerState.analyzing);
    // Simulated analysis pipeline — no real audio processing or AI model
    // call yet; see class documentation above.
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _state = _AnalyzerState.resultReady);
  }

  Future<void> _handleUpload() async {
    if (_state == _AnalyzerState.recording || _state == _AnalyzerState.analyzing) return;
    _showToast('Selected cry_recording.wav');
    setState(() => _state = _AnalyzerState.analyzing);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _state = _AnalyzerState.resultReady);
  }

  void _handleDelete() {
    _recordingTimer?.cancel();
    setState(() {
      _state = _AnalyzerState.idle;
      _recordingSeconds = 0;
    });
  }

  void _handlePlay() {
    _showToast('Playing recording…');
  }

  void _showHowItWorksSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _HowItWorksSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _state == _AnalyzerState.recording || _state == _AnalyzerState.analyzing;

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
                              AuthBackButton(onPressed: () => context.go(RoutePaths.dashboard)),
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
                              _state == _AnalyzerState.resultReady) ...[
                            const SizedBox(height: 14),
                            _AudioControlsRow(
                              state: _state,
                              onStop: _handleMicTap,
                              onPlay: _handlePlay,
                              onDelete: _handleDelete,
                            ),
                          ],
                          if (_state == _AnalyzerState.idle) ...[
                            const SizedBox(height: 16),
                            _UploadCard(enabled: !isBusy, onTap: _handleUpload),
                          ],
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: _state == _AnalyzerState.resultReady
                                ? Column(
                                    key: const ValueKey('result'),
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 22),
                                      const _AnalysisResultCard(),
                                      const SizedBox(height: 22),
                                      _SectionHeading(title: 'Recommended Actions'),
                                      const SizedBox(height: 10),
                                      _RecommendedActionsGrid(onTap: _showToast),
                                    ],
                                  )
                                : const SizedBox(key: ValueKey('no-result')),
                          ),
                          const SizedBox(height: 26),
                          _SectionHeading(title: 'Recent History'),
                          const SizedBox(height: 10),
                          _HistoryCard(entries: _history),
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

enum _AnalyzerState { idle, recording, analyzing, resultReady }

/// Cry Analyzer-local "stars and clouds" ambient decoration — a fresh,
/// screen-local implementation (not imported from Dashboard, which keeps
/// its own private version) so no shared or sibling screen file needs to
/// change.
class _CryFloatingDecor extends StatefulWidget {
  const _CryFloatingDecor();

  @override
  State<_CryFloatingDecor> createState() => _CryFloatingDecorState();
}

class _CryFloatingDecorState extends State<_CryFloatingDecor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _specs = <_DecorSpec>[
    _DecorSpec(icon: Icons.star_rounded, top: 0.02, left: 0.85, size: 12, color: AuthPalette.softCoral, phase: 0.0),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.05, left: 0.10, size: 22, color: AuthPalette.powderBlue, phase: 0.5),
    _DecorSpec(icon: Icons.star_rounded, top: 0.15, left: 0.05, size: 10, color: AuthPalette.mint, phase: 0.25),
    _DecorSpec(icon: Icons.star_rounded, top: 0.35, left: 0.92, size: 11, color: AuthPalette.lavenderMist, phase: 0.7),
    _DecorSpec(icon: Icons.cloud_rounded, top: 0.55, left: 0.88, size: 18, color: AuthPalette.blushPink, phase: 0.15),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
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
                      final t = (math.sin((_controller.value + spec.phase) * math.pi * 2) + 1) / 2;
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
            child: Icon(Icons.info_outline_rounded, color: AuthPalette.textDark, size: 20),
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
        style: GoogleFonts.quicksand(fontSize: 17, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
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
        border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.5)),
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
    final isResult = state == _AnalyzerState.resultReady;

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
                  child: Center(child: _centerIcon(isRecording, isAnalyzing, isResult)),
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

class _LiveWaveformState extends State<_LiveWaveform> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _barCount = 28;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
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
  const _WaveBar({required this.t, required this.index, required this.amplitude});

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
    required this.onStop,
    required this.onPlay,
    required this.onDelete,
  });

  final _AnalyzerState state;
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

    final canInteract = state == _AnalyzerState.resultReady;
    return Row(
      children: [
        Expanded(
          child: AuthOutlineButton(
            label: 'Play',
            icon: Icons.play_arrow_rounded,
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
                child: const Icon(Icons.upload_file_rounded, color: AuthPalette.textDark, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload audio file',
                      style: GoogleFonts.nunito(fontSize: 14.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                    ),
                    Text(
                      'Supported formats: wav, mp3, m4a',
                      style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AuthPalette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisResultCard extends StatelessWidget {
  const _AnalysisResultCard();

  static const _breakdown = <_ConfidenceEntry>[
    _ConfidenceEntry(label: 'Hungry', percent: 86, color: AuthPalette.softCoral),
    _ConfidenceEntry(label: 'Tired', percent: 10, color: AuthPalette.powderBlue),
    _ConfidenceEntry(label: 'Discomfort', percent: 4, color: AuthPalette.lavenderMist),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AuthPalette.softCoral.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_drink_rounded, color: AuthPalette.textDark, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Likely reason',
                      style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                    ),
                    Text(
                      'Hungry',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AuthPalette.mint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '86%',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AuthPalette.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final entry in _breakdown) ...[
            _ConfidenceRow(entry: entry),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: AuthPalette.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'This is a gentle guide, not a diagnosis. Trust your instincts.',
                  style: GoogleFonts.nunito(fontSize: 11, color: AuthPalette.textMuted, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfidenceEntry {
  const _ConfidenceEntry({required this.label, required this.percent, required this.color});

  final String label;
  final int percent;
  final Color color;
}

class _ConfidenceRow extends StatelessWidget {
  const _ConfidenceRow({required this.entry});

  final _ConfidenceEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.label,
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
              ),
            ),
            Text(
              '${entry.percent}%',
              style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w800, color: AuthPalette.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 9, color: AuthPalette.lavenderMist.withValues(alpha: 0.25)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: entry.percent / 100),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(height: 9, color: entry.color),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendedActionsGrid extends StatelessWidget {
  const _RecommendedActionsGrid({required this.onTap});

  final ValueChanged<String> onTap;

  static const _actions = <_RecommendedAction>[
    _RecommendedAction(label: 'Offer feeding', icon: Icons.local_drink_rounded, color: AuthPalette.powderBlue),
    _RecommendedAction(label: 'Burp baby', icon: Icons.air_rounded, color: AuthPalette.mint),
    _RecommendedAction(label: 'Check diaper', icon: Icons.child_care_rounded, color: AuthPalette.lavenderMist),
    _RecommendedAction(label: 'Try soothing', icon: Icons.spa_rounded, color: AuthPalette.softCoral),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final action = _actions[index];
        return _RecommendedActionTile(action: action, onTap: () => onTap('Marked "${action.label}" as tried 💛'));
      },
    );
  }
}

class _RecommendedAction {
  const _RecommendedAction({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;
}

class _RecommendedActionTile extends StatefulWidget {
  const _RecommendedActionTile({required this.action, required this.onTap});

  final _RecommendedAction action;
  final VoidCallback onTap;

  @override
  State<_RecommendedActionTile> createState() => _RecommendedActionTileState();
}

class _RecommendedActionTileState extends State<_RecommendedActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AuthPalette.lavenderMist.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.action.color.withValues(alpha: 0.32),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.action.icon, size: 17, color: AuthPalette.textDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.action.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(fontSize: 12.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryEntry {
  const _HistoryEntry({required this.result, required this.confidence, required this.time});

  final String result;
  final int confidence;
  final String time;
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entries});

  final List<_HistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _HistoryTile(entry: entries[i]),
            if (i != entries.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Divider(color: AuthPalette.lavenderMist.withValues(alpha: 0.4), height: 1),
              ),
          ],
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final _HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AuthPalette.softCoral.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.graphic_eq_rounded, size: 18, color: AuthPalette.textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.result} • ${entry.confidence}%',
                  style: GoogleFonts.nunito(fontSize: 13.5, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
                ),
                Text(
                  entry.time,
                  style: GoogleFonts.nunito(fontSize: 12, color: AuthPalette.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSheet extends StatelessWidget {
  const _HowItWorksSheet();

  static const _steps = <(IconData, String)>[
    (Icons.mic_rounded, "We listen to the pattern and rhythm of your baby's cry."),
    (Icons.psychology_alt_rounded, 'The sound is compared against thousands of known cry patterns.'),
    (Icons.lightbulb_outline_rounded, 'We suggest the most likely reason — gently, and never as a diagnosis.'),
    (Icons.favorite_outline_rounded, 'Always trust your instincts, and check with a pediatrician if you\'re concerned.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AuthPalette.warmCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AuthPalette.lavenderMist,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'How Cry Analysis Works',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(fontSize: 19, fontWeight: FontWeight.w700, color: AuthPalette.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              'A gentle, science-informed guide — never a substitute for medical advice.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 13, color: AuthPalette.textMuted),
            ),
            const SizedBox(height: 18),
            for (final (icon, text) in _steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AuthPalette.powderBlue.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 18, color: AuthPalette.textDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          text,
                          style: GoogleFonts.nunito(fontSize: 13.5, color: AuthPalette.textDark, height: 1.35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            AuthPrimaryButton(
              label: 'Got it',
              isLoading: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
