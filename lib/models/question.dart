import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

/// Assessment type enumeration
enum AssessmentType {
  @JsonValue('mcq')
  mcq,
  @JsonValue('written')
  written,
  @JsonValue('oral')
  oral,
  @JsonValue('osce')
  osce,
}

/// Base Question model supporting all assessment types
@JsonSerializable()
class Question {
  final String id;
  final AssessmentType assessmentType;
  final String questionText;
  
  // Content Filtering Fields
  final String academicLevel; // 'undergraduate' or 'postgraduate'
  final String specialtyModule; // e.g., 'cardiology', 'pediatrics'
  final String? blockOrSemester; // optional: 'block1', 'semester2'
  
  // MCQ-specific fields
  final List<String>? options;
  final String? correctAnswer;
  
  // Written/Oral-specific fields
  final String? modelAnswer;
  final List<String>? keyPoints;
  
  // OSCE-specific fields
  final String? stationDescription;
  final List<OsceChecklistItem>? checklist;
  
  // Metadata
  final String? difficulty; // 'easy', 'medium', 'hard'
  final List<String>? tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Question({
    required this.id,
    required this.assessmentType,
    required this.questionText,
    required this.academicLevel,
    required this.specialtyModule,
    this.blockOrSemester,
    this.options,
    this.correctAnswer,
    this.modelAnswer,
    this.keyPoints,
    this.stationDescription,
    this.checklist,
    this.difficulty,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
  
  /// Validation helper
  bool isValid() {
    switch (assessmentType) {
      case AssessmentType.mcq:
        return options != null && 
               options!.length >= 2 && 
               correctAnswer != null &&
               options!.contains(correctAnswer);
      case AssessmentType.written:
      case AssessmentType.oral:
        return modelAnswer != null || (keyPoints != null && keyPoints!.isNotEmpty);
      case AssessmentType.osce:
        return stationDescription != null && 
               checklist != null && 
               checklist!.isNotEmpty;
    }
  }
}

/// OSCE checklist item
@JsonSerializable()
class OsceChecklistItem {
  final String description;
  final int points;
  final bool required;

  OsceChecklistItem({
    required this.description,
    required this.points,
    this.required = false,
  });

  factory OsceChecklistItem.fromJson(Map<String, dynamic> json) => 
      _$OsceChecklistItemFromJson(json);
  Map<String, dynamic> toJson() => _$OsceChecklistItemToJson(this);
}
