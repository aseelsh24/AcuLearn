import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/quiz_controller.dart';
import '../../../models/question.dart';

/// Review Screen - Allows users to review their answers
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final session = quizState.currentSession;
    final questions = quizState.questions;

    if (session == null || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(
          child: Text('No quiz to review'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final userAnswer = session.userAnswers[question.id];
          
          return _QuestionReviewCard(
            questionNumber: index + 1,
            question: question,
            userAnswer: userAnswer,
          );
        },
      ),
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  final int questionNumber;
  final Question question;
  final dynamic userAnswer;

  const _QuestionReviewCard({
    required this.questionNumber,
    required this.question,
    required this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = _checkIfCorrect();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isCorrect ? Colors.green : Colors.red,
          child: Icon(
            isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Question $questionNumber',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          question.questionText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                
                // Display based on assessment type
                if (question.assessmentType == AssessmentType.mcq) ...[
                  _buildMcqReview(),
                ] else if (question.assessmentType == AssessmentType.written ||
                    question.assessmentType == AssessmentType.oral) ...[
                  _buildWrittenOralReview(),
                ] else if (question.assessmentType == AssessmentType.osce) ...[
                  _buildOsceReview(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _checkIfCorrect() {
    if (question.assessmentType == AssessmentType.mcq) {
      return userAnswer == question.correctAnswer;
    }
    // For other types, correctness is subjective
    return true; // Placeholder
  }

  Widget _buildMcqReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Answer:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      userAnswer?.toString() ?? 'Not answered',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correct Answer:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      question.correctAnswer ?? 'N/A',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWrittenOralReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Answer:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(userAnswer?.toString() ?? 'Not answered'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Model Answer:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(question.modelAnswer ?? 'N/A'),
              if (question.keyPoints != null && question.keyPoints!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Key Points:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...question.keyPoints!.map((point) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(point)),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOsceReview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OSCE Checklist:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (question.checklist != null)
            ...question.checklist!.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        child: Text(
                          '${item.points}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.description)),
                      if (item.required)
                        const Icon(Icons.star, size: 16, color: Colors.red),
                    ],
                  ),
                )),
          const SizedBox(height: 12),
          const Text(
            'Your Notes:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(userAnswer?.toString() ?? 'No notes'),
        ],
      ),
    );
  }
}
