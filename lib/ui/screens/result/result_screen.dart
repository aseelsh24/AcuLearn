import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/quiz_controller.dart';
import '../review/review_screen.dart';

/// Result Screen - Displays quiz results and score
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final session = quizState.currentSession;

    if (session == null || !session.isCompleted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(
          child: Text('No completed quiz session'),
        ),
      );
    }

    final score = session.score ?? 0;
    final totalPoints = session.totalPoints ?? 0;
    final percentage = totalPoints > 0 ? (score / totalPoints * 100).toInt() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score card
            Card(
              color: _getScoreColor(percentage).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      _getScoreIcon(percentage),
                      size: 64,
                      color: _getScoreColor(percentage),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(percentage),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: $score / $totalPoints',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreMessage(percentage),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quiz details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiz Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Questions',
                      value: '${session.questionIds.length}',
                    ),
                    _DetailRow(
                      label: 'Correct Answers',
                      value: '$score',
                    ),
                    _DetailRow(
                      label: 'Incorrect Answers',
                      value: '${totalPoints - score}',
                    ),
                    _DetailRow(
                      label: 'Time Taken',
                      value: _formatDuration(
                        session.endTime!.difference(session.startTime),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Action buttons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReviewScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.review),
              label: const Text('Review Answers'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(quizControllerProvider.notifier).resetQuiz();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.thumb_up;
    return Icons.refresh;
  }

  String _getScoreMessage(int percentage) {
    if (percentage >= 80) return 'Excellent! Keep it up!';
    if (percentage >= 60) return 'Good job! Room for improvement.';
    return 'Keep practicing!';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
