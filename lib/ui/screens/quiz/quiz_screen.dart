import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/quiz_controller.dart';
import '../../../models/question.dart';
import '../result/result_screen.dart';

/// Quiz Screen - Displays questions and handles user input
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final session = quizState.currentSession;
    final currentQuestion = quizState.currentQuestion;

    if (session == null || currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No active quiz session'),
        ),
      );
    }

    final progress = session.currentQuestionIndex / session.questionIds.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content: const Text('Your progress will be lost if you exit now.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Question ${session.currentQuestionIndex + 1}/${session.questionIds.length}'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question text
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion.questionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Answer options based on assessment type
              Expanded(
                child: _buildAnswerWidget(currentQuestion),
              ),
              
              // Submit button
              ElevatedButton(
                onPressed: selectedAnswer != null
                    ? () => _submitAnswer()
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerWidget(Question question) {
    switch (question.assessmentType) {
      case AssessmentType.mcq:
        return _buildMcqOptions(question);
      case AssessmentType.written:
        return _buildWrittenAnswer();
      case AssessmentType.oral:
        return _buildOralAnswer();
      case AssessmentType.osce:
        return _buildOsceChecklist(question);
    }
  }

  Widget _buildMcqOptions(Question question) {
    if (question.options == null) return const SizedBox();

    return ListView.builder(
      itemCount: question.options!.length,
      itemBuilder: (context, index) {
        final option = question.options![index];
        final isSelected = selectedAnswer == option;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isSelected ? Colors.teal.withOpacity(0.1) : null,
          child: RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedAnswer,
            onChanged: (value) {
              setState(() {
                selectedAnswer = value;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildWrittenAnswer() {
    return TextField(
      maxLines: 10,
      decoration: const InputDecoration(
        hintText: 'Type your answer here...',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          selectedAnswer = value;
        });
      },
    );
  }

  Widget _buildOralAnswer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mic, size: 48, color: Colors.orange),
                SizedBox(height: 12),
                Text(
                  'Oral/Viva Question',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Practice your verbal response. You can record notes below.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: 'Record your key points here...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                selectedAnswer = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOsceChecklist(Question question) {
    if (question.checklist == null) return const SizedBox();

    return ListView(
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OSCE Station',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Review the checklist items below',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...question.checklist!.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${item.points}'),
                ),
                title: Text(item.description),
                trailing: item.required
                    ? const Chip(
                        label: Text('Required', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.red,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
              ),
            )),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Your performance notes...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              selectedAnswer = value;
            });
          },
        ),
      ],
    );
  }

  void _submitAnswer() {
    if (selectedAnswer == null) return;

    final controller = ref.read(quizControllerProvider.notifier);
    controller.submitAnswer(selectedAnswer);

    final quizState = ref.read(quizControllerProvider);
    
    setState(() {
      selectedAnswer = null;
    });

    if (quizState.currentSession?.isAllAnswered == true) {
      // Quiz completed, navigate to results
      controller.completeQuiz();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ResultScreen(),
        ),
      );
    }
  }
}
