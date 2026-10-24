import 'package:flutter/material.dart';
import '../../../authentication/presentation/widgets/auth_form_controls.dart';

String cryResultTitle(Map<String, dynamic> entry) {
  final label = (entry['label'] as String? ?? '').replaceAll('_', ' ');
  if (entry['mode'] == 'known_dataset')
    return 'Known dataset recording: $label';
  if (entry['uncertain'] == true) return 'No clear sound-pattern match';
  if (label == 'noise') return 'Possible non-baby sound';
  if (label.isNotEmpty) return 'Possible sound match: $label';
  return entry['result'] as String? ?? 'Analysis unavailable';
}

class CryAnalysisResult extends StatelessWidget {
  const CryAnalysisResult({super.key, required this.entry});
  final Map<String, dynamic> entry;
  @override
  Widget build(BuildContext context) {
    final scores = entry['scores'] is Map
        ? (entry['scores'] as Map).entries.toList()
        : <MapEntry<dynamic, dynamic>>[];
    scores.sort((a, b) => (b.value as num).compareTo(a.value as num));
    final alternatives = entry['alternatives'] as List? ?? [];
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            cryResultTitle(entry),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (entry['mode'] == 'known_dataset')
            const Text(
              'Exact training-file match. This is its saved dataset label, not 100% AI confidence.',
            ),
          if (scores.isNotEmpty) ...[
            const Text('Sound-pattern model scores'),
            for (final score in scores)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${score.key.toString().replaceAll('_', ' ')} · ${(score.value as num).toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: ((score.value as num) / 100)
                          .clamp(0, 1)
                          .toDouble(),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
          const Text(
            'Comfort checks — assess your baby, not just the score',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            entry['tip'] as String? ??
                'Check your baby’s comfort and seek advice if concerned.',
          ),
          for (final alternative in alternatives.skip(1)) ...[
            const SizedBox(height: 10),
            Text(
              'Also consider: ${alternative['label'].toString().replaceAll('_', ' ')}',
            ),
            Text(alternative['tip'] as String? ?? ''),
          ],
          const SizedBox(height: 12),
          const Text(
            'Seek urgent help for breathing difficulty or unresponsiveness. Seek medical advice for unusual or persistent crying or signs of illness.',
          ),
          const SizedBox(height: 6),
          const Text('General guidance: NHS — Soothing a crying baby'),
        ],
      ),
    );
  }
}
