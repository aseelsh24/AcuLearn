import 'package:json_annotation/json_annotation.dart';
import 'question.dart';

part 'quiz_session.g.dart';

/// Represents an active or completed quiz session
@JsonSerializable()
class QuizSession {
  final String id;
  final String trackId;
  final AssessmentType assessmentType;
  final List<String> questionIds; // References to questions
  final Map<String, dynamic> userAnswers; // questionId -> user's answer
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  
  // Results
  final int? score;
  final int? totalPoints;
  
  QuizSession({
    required this.id,
    required this.trackId,
    required this.assessmentType,
    required this.questionIds,
    Map<String, dynamic>? userAnswers,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.score,
    this.totalPoints,
  }) : userAnswers = userAnswers ?? {};

  factory QuizSession.fromJson(Map<String, dynamic> json) => 
      _$QuizSessionFromJson(json);
  Map<String, dynamic> toJson() => _$QuizSessionToJson(this);
  
  /// Calculate progress percentage
  double get progressPercentage {
    if (questionIds.isEmpty) return 0.0;
    return (userAnswers.length / questionIds.length) * 100;
  }
  
  /// Check if all questions are answered
  bool get isAllAnswered {
    return userAnswers.length == questionIds.length;
  }
  
  /// Get current question index
  int get currentQuestionIndex {
    return userAnswers.length;
  }
}
