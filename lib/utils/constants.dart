/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'AcuLearn';
  static const String appVersion = '1.0.0';
  
  // Academic Levels
  static const String academicLevelUndergrad = 'undergraduate';
  static const String academicLevelPostgrad = 'postgraduate';
  
  // Hive Box Names
  static const String questionsBoxName = 'questions';
  static const String tracksBoxName = 'tracks';
  static const String quizSessionsBoxName = 'quiz_sessions';
  static const String userPrefsBoxName = 'user_prefs';
  
  // Default Quiz Settings
  static const int defaultQuestionCount = 10;
  static const int minimumQuestionCount = 5;
  static const int maximumQuestionCount = 50;
  
  // Scoring
  static const int passingPercentage = 60;
  static const int excellentPercentage = 80;
  
  // Difficulty Levels
  static const String difficultyEasy = 'easy';
  static const String difficultyMedium = 'medium';
  static const String difficultyHard = 'hard';
}
