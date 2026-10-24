import 'package:flutter/material.dart';
import '../../domain/cry_history_records.dart';
import '../../../authentication/presentation/widgets/auth_palette.dart';
import 'cry_analysis_result.dart';

class CryRecordingCard extends StatelessWidget {
  const CryRecordingCard({
    super.key,
    required this.entry,
    this.playing = false,
    this.position = Duration.zero,
    this.playbackDuration = Duration.zero,
    this.active = false,
    this.onPlay,
    this.onDelete,
  });
  final Map<String, dynamic> entry;
  final bool playing, active;
  final Duration position, playbackDuration;
  final VoidCallback? onPlay, onDelete;
  @override
  Widget build(BuildContext context) {
    final at = CryHistoryRecords.date(entry);
    final date = at == null
        ? 'Date unavailable'
        : '${MaterialLocalizations.of(context).formatMediumDate(at)} · ${TimeOfDay.fromDateTime(at).format(context)}';
    final duration = active && playbackDuration > Duration.zero
        ? playbackDuration
        : CryHistoryRecords.duration(entry);
    final hasResult =
        entry['mode'] != null || entry['scores'] is Map || entry['tip'] != null;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEAD6E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5DFEB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: Color(0xFFAD7197),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cryResultTitle(entry),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AuthPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            duration == null
                ? 'Duration available on playback'
                : 'Duration: ${CryHistoryRecords.clock(duration)}',
            style: const TextStyle(fontSize: 12, color: AuthPalette.textMuted),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onPlay,
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(playing ? 'Pause' : 'Play'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
          if (active) ...[
            LinearProgressIndicator(
              value: playbackDuration.inMilliseconds <= 0
                  ? 0
                  : (position.inMilliseconds / playbackDuration.inMilliseconds)
                        .clamp(0, 1)
                        .toDouble(),
            ),
            const SizedBox(height: 5),
            Text(
              '${CryHistoryRecords.clock(position)} / ${CryHistoryRecords.clock(playbackDuration)}',
              style: const TextStyle(
                fontSize: 11,
                color: AuthPalette.textMuted,
              ),
            ),
          ],
          if (hasResult)
            Material(
              type: MaterialType.transparency,
              child: ExpansionTile(
                key: PageStorageKey(
                  'cry_details_${CryHistoryRecords.key(entry)}',
                ),
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'Analysis details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                children: [CryAnalysisResult(entry: entry)],
              ),
            ),
        ],
      ),
    );
  }
}
