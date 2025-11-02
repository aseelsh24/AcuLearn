import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/track.dart';
import '../../../models/question.dart';
import '../../../controllers/quiz_controller.dart';
import '../quiz/quiz_screen.dart';

/// Home/Dashboard Screen - Main hub after track selection
class HomeScreen extends ConsumerWidget {
  final Track track;

  const HomeScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(track.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome section
            Card(
              color: Colors.teal.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to AcuLearn!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track: ${track.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (track.specialtyModule != null)
                      Text(
                        'Specialty: ${track.specialtyModule}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Assessment type selection
            const Text(
              'Choose Assessment Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _AssessmentTypeCard(
                    title: 'MCQ',
                    icon: Icons.quiz,
                    color: Colors.blue,
                    assessmentType: AssessmentType.mcq,
                    track: track,
                  ),
                  _AssessmentTypeCard(
                    title: 'Written',
                    icon: Icons.edit_note,
                    color: Colors.green,
                    assessmentType: AssessmentType.written,
                    track: track,
                  ),
                  _AssessmentTypeCard(
                    title: 'Oral/Viva',
                    icon: Icons.record_voice_over,
                    color: Colors.orange,
                    assessmentType: AssessmentType.oral,
                    track: track,
                  ),
                  _AssessmentTypeCard(
                    title: 'OSCE',
                    icon: Icons.assignment,
                    color: Colors.purple,
                    assessmentType: AssessmentType.osce,
                    track: track,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Assessment Type Card Widget
class _AssessmentTypeCard extends ConsumerWidget {
  final String title;
  final IconData icon;
  final Color color;
  final AssessmentType assessmentType;
  final Track track;

  const _AssessmentTypeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.assessmentType,
    required this.track,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () async {
          // Start quiz with selected assessment type
          await ref.read(quizControllerProvider.notifier).startQuiz(
                trackId: track.id,
                assessmentType: assessmentType,
                questionCount: 10,
              );

          final quizState = ref.read(quizControllerProvider);
          
          if (quizState.error != null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(quizState.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (quizState.currentSession != null) {
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QuizScreen(),
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
