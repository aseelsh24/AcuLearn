import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';
import '../data/repositories/question_repository.dart';

/// Provider for QuizController
final quizControllerProvider = StateNotifierProvider<QuizController, QuizState>((ref) {
  final questionRepository = ref.watch(questionRepositoryProvider);
  return QuizController(questionRepository);
});

/// Quiz state
class QuizState {
  final QuizSession? currentSession;
  final List<Question> questions;
  final Question? currentQuestion;
  final bool isLoading;
  final String? error;

  QuizState({
    this.currentSession,
    this.questions = const [],
    this.currentQuestion,
    this.isLoading = false,
    this.error,
  });

  QuizState copyWith({
    QuizSession? currentSession,
    List<Question>? questions,
    Question? currentQuestion,
    bool? isLoading,
    String? error,
  }) {
    return QuizState(
      currentSession: currentSession ?? this.currentSession,
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Quiz Controller - Manages quiz session state
class QuizController extends StateNotifier<QuizState> {
  final QuestionRepository _questionRepository;

  QuizController(this._questionRepository) : super(QuizState());

  /// Start a new quiz session
  Future<void> startQuiz({
    required String trackId,
    required AssessmentType assessmentType,
    int questionCount = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch questions for the track and assessment type
      final questions = await _questionRepository.getQuestionsByType(
        trackId: trackId,
        assessmentType: assessmentType,
        limit: questionCount,
      );

      if (questions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No questions available for this track and assessment type.',
        );
        return;
      }

      // Create new quiz session
      final session = QuizSession(
        id: const Uuid().v4(),
        trackId: trackId,
        assessmentType: assessmentType,
        questionIds: questions.map((q) => q.id).toList(),
        startTime: DateTime.now(),
      );

      state = state.copyWith(
        currentSession: session,
        questions: questions,
        currentQuestion: questions.first,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to start quiz: $e',
      );
    }
  }

  /// Submit answer for current question
  void submitAnswer(dynamic answer) {
    if (state.currentSession == null) return;

    final session = state.currentSession!;
    final currentIndex = session.currentQuestionIndex;

    if (currentIndex >= state.questions.length) return;

    final questionId = state.questions[currentIndex].id;
    final updatedAnswers = {...session.userAnswers, questionId: answer};

    final updatedSession = QuizSession(
      id: session.id,
      trackId: session.trackId,
      assessmentType: session.assessmentType,
      questionIds: session.questionIds,
      userAnswers: updatedAnswers,
      startTime: session.startTime,
      isCompleted: updatedAnswers.length == session.questionIds.length,
    );

    // Move to next question or complete quiz
    final nextIndex = currentIndex + 1;
    final nextQuestion = nextIndex < state.questions.length
        ? state.questions[nextIndex]
        : null;

    state = state.copyWith(
      currentSession: updatedSession,
      currentQuestion: nextQuestion,
    );
  }

  /// Complete the quiz and calculate results
  Future<void> completeQuiz() async {
    if (state.currentSession == null) return;

    final session = state.currentSession!;
    int score = 0;
    int totalPoints = 0;

    // Calculate score based on assessment type
    for (int i = 0; i < state.questions.length; i++) {
      final question = state.questions[i];
      final userAnswer = session.userAnswers[question.id];

      if (question.assessmentType == AssessmentType.mcq) {
        totalPoints += 1;
        if (userAnswer == question.correctAnswer) {
          score += 1;
        }
      }
      // For other types, scoring can be manual or based on key points
    }

    final completedSession = QuizSession(
      id: session.id,
      trackId: session.trackId,
      assessmentType: session.assessmentType,
      questionIds: session.questionIds,
      userAnswers: session.userAnswers,
      startTime: session.startTime,
      endTime: DateTime.now(),
      isCompleted: true,
      score: score,
      totalPoints: totalPoints,
    );

    state = state.copyWith(currentSession: completedSession);

    // TODO: Save session to local storage
  }

  /// Reset quiz state
  void resetQuiz() {
    state = QuizState();
  }
}
