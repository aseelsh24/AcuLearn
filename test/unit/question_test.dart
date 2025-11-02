import 'package:flutter_test/flutter_test.dart';
import 'package:acullearn/models/question.dart';

void main() {
  group('Question Model Tests', () {
    test('MCQ question validation - valid question', () {
      final question = Question(
        id: 'test-1',
        assessmentType: AssessmentType.mcq,
        questionText: 'What is the capital of France?',
        academicLevel: 'undergraduate',
        specialtyModule: 'geography',
        options: ['London', 'Paris', 'Berlin', 'Madrid'],
        correctAnswer: 'Paris',
      );

      expect(question.isValid(), true);
    });

    test('MCQ question validation - invalid question (no correct answer)', () {
      final question = Question(
        id: 'test-2',
        assessmentType: AssessmentType.mcq,
        questionText: 'What is the capital of France?',
        academicLevel: 'undergraduate',
        specialtyModule: 'geography',
        options: ['London', 'Berlin', 'Madrid'],
        correctAnswer: 'Paris', // Not in options
      );

      expect(question.isValid(), false);
    });

    test('Written question validation - valid question', () {
      final question = Question(
        id: 'test-3',
        assessmentType: AssessmentType.written,
        questionText: 'Describe the pathophysiology of diabetes',
        academicLevel: 'undergraduate',
        specialtyModule: 'endocrinology',
        modelAnswer: 'Diabetes is characterized by...',
      );

      expect(question.isValid(), true);
    });

    test('OSCE question validation - valid question', () {
      final question = Question(
        id: 'test-4',
        assessmentType: AssessmentType.osce,
        questionText: 'Perform a cardiovascular examination',
        academicLevel: 'undergraduate',
        specialtyModule: 'cardiology',
        stationDescription: 'Examine the cardiovascular system',
        checklist: [
          OsceChecklistItem(
            description: 'Wash hands',
            points: 1,
            required: true,
          ),
          OsceChecklistItem(
            description: 'Introduce self to patient',
            points: 1,
            required: true,
          ),
        ],
      );

      expect(question.isValid(), true);
    });
  });
}
