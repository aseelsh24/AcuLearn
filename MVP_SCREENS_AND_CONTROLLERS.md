# MVP Screens and Controllers

## Overview

This document lists **all core screens and controllers** we will build for the AcuLearn MVP. Each screen and controller is described with its purpose, responsibilities, and key features.

---

## MVP Scope: End-to-End Flow

**User Journey:**
1. Launch app → Track Selection Screen
2. Choose track (Undergrad or Postgrad) → Home Screen
3. Select a module (e.g., "Neonatology") → Quiz Screen
4. Answer questions one by one → Result Screen
5. Review answers with explanations → Review Screen

**What's In MVP:**
- ✅ All 4 assessment modes (MCQ, Written, Oral, OSCE)
- ✅ Offline-first (no backend required)
- ✅ Track-based filtering (undergrad vs postgrad)
- ✅ Module-based organization
- ✅ Scoring and review
- ✅ Clean architecture with Riverpod

**What's NOT In MVP:**
- ❌ User accounts / authentication
- ❌ Backend sync
- ❌ Premium subscriptions (stub interface only)
- ❌ Analytics dashboard
- ❌ Arabic localization (English only)
- ❌ CSV/JSON import UI (questions bundled with app)

---

## Screens (UI Layer)

### 1. Track Selection Screen

**File:** `lib/ui/screens/track_selection_screen.dart`

**Purpose:**  
First screen the user sees. Allows user to select their academic track (Undergraduate or Postgraduate).

**Responsibilities:**
- Display two prominent options: "Undergraduate Track" and "Postgraduate Track"
- When user taps a track, update `TrackController` state
- Navigate to Home Screen

**Key UI Elements:**
- App title / logo
- Two large, tappable cards or buttons:
  - "Undergraduate Track" → Description: "For medical students (Years 1–6)"
  - "Postgraduate Track" → Description: "For residents, trainees, and practicing clinicians"
- Professional, clinical design (not playful)

**State Dependencies:**
- Writes to: `TrackController`
- Reads from: None (initial screen)

**Navigation:**
- Next: Home Screen (after track selected)

---

### 2. Home Screen (Dashboard)

**File:** `lib/ui/screens/home_screen.dart`

**Purpose:**  
Main dashboard showing available learning modules for the selected track. Entry point for starting quiz sessions.

**Responsibilities:**
- Display selected track ("Undergraduate Track" or "Postgraduate Track")
- Fetch and display available modules for the current track from `QuestionRepository`
- Allow user to select a module and start a quiz session
- Show lock icon for premium modules (future feature, currently all unlocked)

**Key UI Elements:**
- Header: "Welcome to AcuLearn" + current track indicator
- Module cards/buttons:
  - Module name (e.g., "Neonatology", "ICU / Sepsis")
  - Brief description (optional)
  - "Start Quiz" button
  - Lock icon (if premium, future feature)
- "Change Track" button (navigate back to Track Selection)

**State Dependencies:**
- Reads from: `TrackController.currentTrack`
- Reads from: `QuestionRepository.getAvailableModules(track)`
- Reads from: `SubscriptionService.isContentLocked(module)` (stub, always false in MVP)

**Navigation:**
- Previous: Track Selection Screen
- Next: Quiz Screen (after module selected)

**Controller Logic:**
- Calls `QuizController.startSession(moduleId, track)` before navigating to Quiz Screen

---

### 3. Quiz Screen

**File:** `lib/ui/screens/quiz_screen.dart`

**Purpose:**  
Main assessment screen. Displays questions one at a time and collects user responses.

**Responsibilities:**
- Render current question based on `mode`:
  - **MCQ:** Show question text + tappable option buttons
  - **Written:** Show question text + text input field
  - **Oral:** Show viva prompt + self-assessment checklist
  - **OSCE:** Show scenario + action checklist + self-grade
- Collect user's answer and submit to `QuizController`
- Show progress indicator (e.g., "Question 3 of 10")
- "Next" button to advance to next question
- Auto-navigate to Result Screen when quiz is finished

**Key UI Elements:**
- Progress bar or text: "Question X of Y"
- Question text (large, readable font)
- Mode-specific input:
  - **MCQ:** List of `McqOptionButton` widgets (custom widget)
  - **Written:** `TextField` for short answer
  - **Oral:** Checklist items (read-only) + "Did you cover most points?" toggle
  - **OSCE:** Scenario description + checklist + "Mark as complete" button
- "Submit Answer" button
- "Next Question" button (enabled after answer submitted)

**State Dependencies:**
- Reads from: `QuizController.currentQuestion`
- Reads from: `QuizController.currentQuestionIndex`
- Reads from: `QuizController.totalQuestions`
- Reads from: `QuizController.isFinished`
- Writes to: `QuizController.answerQuestion(answer)`

**Navigation:**
- Previous: Home Screen
- Next: Result Screen (when quiz finished)

**Error Handling:**
- If no questions loaded, show error message and back button

---

### 4. Result Screen

**File:** `lib/ui/screens/result_screen.dart`

**Purpose:**  
Displays quiz completion summary and score (for MCQ). Entry point to review answers.

**Responsibilities:**
- Show completion message ("Quiz Complete!")
- Display score for MCQ questions (e.g., "7 out of 10 correct")
- For non-MCQ modes, show completion count (e.g., "10 questions completed")
- Provide "Review Answers" button to see explanations
- Provide "Back to Home" button to return to module selection

**Key UI Elements:**
- Completion icon / illustration
- Score display (custom widget: `ResultSummaryCard`)
  - MCQ: "7 / 10" + percentage
  - Other modes: "10 questions completed"
- Two action buttons:
  - "Review Answers" → Navigate to Review Screen
  - "Back to Home" → Navigate to Home Screen

**State Dependencies:**
- Reads from: `QuizController.getScore()` (for MCQ)
- Reads from: `QuizController.totalQuestions`
- Reads from: `QuizController.totalCorrect` (for MCQ)

**Navigation:**
- Previous: Quiz Screen
- Next: Review Screen (if user taps "Review Answers")
- Next: Home Screen (if user taps "Back to Home")

---

### 5. Review Screen

**File:** `lib/ui/screens/review_screen.dart`

**Purpose:**  
Allows user to review all questions, their answers, correct answers, and clinical explanations.

**Responsibilities:**
- Display all questions from the completed quiz session
- For each question, show:
  - Question text
  - User's answer
  - Correct answer (MCQ: correct option, others: expected answer)
  - Clinical explanation / rationale
- Use color coding:
  - Green for correct MCQ answers
  - Red for incorrect MCQ answers
  - Neutral for written/oral/OSCE (no right/wrong)
- Provide "Back to Results" or "Back to Home" button

**Key UI Elements:**
- Scrollable list of question review cards
- Each card contains:
  - Question number and text
  - "Your Answer:" (highlighted)
  - "Correct Answer:" or "Expected Answer:"
  - "Explanation:" (clinical rationale)
- Color indicators:
  - MCQ correct: green checkmark
  - MCQ incorrect: red X
  - Other modes: neutral icon
- Back button

**State Dependencies:**
- Reads from: `QuizController.getAllQuestions()`
- Reads from: `QuizController.getUserAnswers()`
- Reads from: `QuizController.getCorrectAnswers()`

**Navigation:**
- Previous: Result Screen
- Next: Home Screen (via back button)

---

## Controllers (Business Logic Layer)

### 1. QuizController

**File:** `lib/logic/quiz_controller.dart`

**Type:** Riverpod `StateNotifier<QuizState>` or `Notifier<QuizState>`

**Purpose:**  
Central controller for managing a quiz session. Handles question progression, answer storage, scoring, and session completion.

**Responsibilities:**
1. **Load Questions:** Receive questions from repository and initialize session
2. **Track Current Question:** Expose `currentQuestion`, `currentQuestionIndex`
3. **Collect Answers:** Store user answers in a map (`questionId` → `answer`)
4. **Calculate Score:** For MCQ questions, track correct/incorrect answers
5. **Detect Session End:** Know when all questions have been answered
6. **Provide Review Data:** Return summary of questions, user answers, correct answers for Review Screen

**Key State Fields:**
```dart
class QuizState {
  final List<Question> questions;          // All questions in this session
  final int currentQuestionIndex;          // Which question we're on (0-based)
  final Map<String, dynamic> userAnswers;  // questionId → user's answer
  final int totalCorrect;                  // Number of correct MCQ answers
  final bool isFinished;                   // Has the session ended?
}
```

**Key Methods:**
```dart
class QuizController extends StateNotifier<QuizState> {
  // Initialize a new quiz session
  void startSession(String moduleId, String track);
  
  // Get the current question to display
  Question? get currentQuestion;
  
  // User submits an answer
  void answerQuestion(String questionId, dynamic answer);
  
  // Move to next question
  void nextQuestion();
  
  // Mark session as finished
  void finishSession();
  
  // Get score (for MCQ)
  int get totalCorrect;
  int get totalQuestions;
  double get scorePercentage;
  
  // Get review data
  List<QuestionReviewData> getReviewData();
}
```

**Dependencies:**
- Injects: `QuestionRepository` (to fetch questions)
- Injects: `TrackController` (to know current track)

**State Management:**
- Uses Riverpod `StateNotifier` pattern
- Exposes immutable `QuizState` snapshots
- UI listens via `ref.watch(quizControllerProvider)`

---

### 2. TrackController

**File:** `lib/logic/track_controller.dart`

**Type:** Riverpod `StateNotifier<String?>` or simple `StateProvider<String?>`

**Purpose:**  
Stores the user's selected academic track (Undergraduate or Postgraduate).

**Responsibilities:**
1. **Store Track Selection:** Save user's choice
2. **Expose Current Track:** Provide track value to other controllers and UI
3. **Persist Across Sessions (Future):** In MVP, track is in-memory only. Later: persist to local storage.

**Key State:**
```dart
// Simple string: "undergrad" or "postgrad"
String? currentTrack;
```

**Key Methods:**
```dart
class TrackController extends StateNotifier<String?> {
  TrackController() : super(null); // No track selected initially
  
  void setTrack(String track) {
    assert(track == "undergrad" || track == "postgrad");
    state = track;
  }
  
  void clearTrack() {
    state = null;
  }
}
```

**Usage:**
- Track Selection Screen: Calls `setTrack("undergrad")` or `setTrack("postgrad")`
- Home Screen: Reads `currentTrack` to filter modules
- Quiz Controller: Reads `currentTrack` to pass to repository

**State Management:**
- Simple Riverpod `StateNotifier` or `StateProvider`
- Lightweight (just a string value)

---

## Reusable Widgets (UI Components)

### 1. McqOptionButton

**File:** `lib/ui/widgets/mcq_option_button.dart`

**Purpose:**  
Renders a single MCQ answer option as a tappable button.

**Responsibilities:**
- Display option text
- Show "selected" state when tapped
- Show "correct" (green) or "incorrect" (red) state in review mode
- Handle tap events

**Props:**
```dart
class McqOptionButton extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final bool? isCorrect;  // null = not in review mode, true/false = review mode
  final VoidCallback onTap;
}
```

**Visual States:**
- Default: Grey border, white background
- Selected: Blue border, light blue background
- Correct (review): Green border, light green background
- Incorrect (review): Red border, light red background

---

### 2. ResultSummaryCard

**File:** `lib/ui/widgets/result_summary_card.dart`

**Purpose:**  
Displays quiz score or completion summary in a visually appealing card.

**Responsibilities:**
- Show total questions
- Show correct count (for MCQ)
- Show percentage (for MCQ)
- Show completion message (for other modes)

**Props:**
```dart
class ResultSummaryCard extends StatelessWidget {
  final int totalQuestions;
  final int? totalCorrect;  // null for non-MCQ modes
  final String mode;  // "mcq", "written", etc.
}
```

**Visual Design:**
- Large card with rounded corners
- Icon (checkmark for good scores, neutral for others)
- Text: "7 out of 10 correct" or "10 questions completed"
- Percentage displayed prominently (for MCQ)

---

## Data Layer Components

### 1. Question Model

**File:** `lib/data/models/question_model.dart`

**Purpose:**  
Represents a single question/station. Includes serialization for JSON/CSV import.

**Fields:**
```dart
class Question {
  final dynamic id;                  // int or String
  final String text;                 // Question stem
  final String mode;                 // "mcq" | "written" | "oral" | "osce"
  final List<String>? options;       // MCQ choices (null for other modes)
  final int? correctIndex;           // MCQ correct answer index
  final String? expectedAnswer;      // Model answer for non-MCQ modes
  final String? explanation;         // Clinical rationale
  final String specialtyModule;      // Module name
  final String academicLevel;        // "undergrad" | "postgrad"
  final String blockOrSemester;      // Curriculum mapping
}
```

**Methods:**
```dart
// JSON deserialization
factory Question.fromJson(Map<String, dynamic> json);

// JSON serialization
Map<String, dynamic> toJson();

// Equality and hashCode (for comparing questions)
@override
bool operator ==(Object other);
@override
int get hashCode;
```

---

### 2. QuestionRepository

**File:** `lib/data/repositories/question_repository.dart`

**Purpose:**  
Single source of truth for question data. Handles loading, filtering, and querying questions.

**Responsibilities:**
1. **Load Questions:** Parse JSON file from assets
2. **Filter by Track:** Return only questions matching `academicLevel`
3. **Filter by Module:** Return questions for a specific `specialtyModule`
4. **Get Available Modules:** Return list of unique module names for a track
5. **Check Subscription (Future):** Coordinate with `SubscriptionService` to exclude locked content

**Key Methods:**
```dart
class QuestionRepository {
  // Load all questions from JSON asset
  Future<void> loadQuestions();
  
  // Get all questions for a track
  List<Question> getQuestionsForTrack(String track);
  
  // Get questions for a specific module and track
  List<Question> getQuestionsForModule(String moduleId, String track);
  
  // Get unique module names for a track
  List<String> getAvailableModules(String track);
  
  // Filter by block/semester (future feature)
  List<Question> getQuestionsForBlock(String block, String track);
}
```

**Data Source (MVP):**
- JSON file bundled in `assets/questions.json`
- Loaded once at app startup or lazily on first access
- Cached in memory

**Future Enhancements:**
- Local database (SQLite) for better performance with large question banks
- Backend sync to download updated questions

---

## Services Layer Components

### 1. SubscriptionService (Stub)

**File:** `lib/services/subscription_service.dart`

**Purpose:**  
Abstract interface for premium content access control. Stubbed in MVP (all content unlocked).

**Responsibilities:**
1. Check if a module is locked (requires premium subscription)
2. Check if user has premium access
3. (Future) Handle subscription purchases

**Key Methods:**
```dart
abstract class SubscriptionService {
  // Is this module locked behind paywall?
  bool isContentLocked(String moduleId);
  
  // Does user have premium access?
  Future<bool> hasPremiumAccess();
  
  // (Future) Unlock premium content
  Future<void> purchaseSubscription();
}

// Stub implementation (MVP)
class SubscriptionServiceStub implements SubscriptionService {
  @override
  bool isContentLocked(String moduleId) => false;  // All unlocked in MVP
  
  @override
  Future<bool> hasPremiumAccess() async => true;
}
```

**Usage in MVP:**
- Home Screen checks `isContentLocked(module)` before displaying module
- Always returns `false` (unlocked) in MVP
- Allows future premium features without UI redesign

---

## Navigation & Routing

**File:** `lib/app_router.dart`

**Purpose:**  
Centralized navigation configuration. Defines all app routes.

**Key Routes:**
```dart
class AppRouter {
  static const String trackSelection = '/';
  static const String home = '/home';
  static const String quiz = '/quiz';
  static const String result = '/result';
  static const String review = '/review';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case trackSelection:
        return MaterialPageRoute(builder: (_) => TrackSelectionScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case quiz:
        return MaterialPageRoute(builder: (_) => QuizScreen());
      case result:
        return MaterialPageRoute(builder: (_) => ResultScreen());
      case review:
        return MaterialPageRoute(builder: (_) => ReviewScreen());
      default:
        return MaterialPageRoute(builder: (_) => TrackSelectionScreen());
    }
  }
}
```

**Usage:**
```dart
// In main.dart
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
  initialRoute: AppRouter.trackSelection,
);

// In screens
Navigator.pushNamed(context, AppRouter.home);
```

---

## Theme & Strings

### 1. AppTheme

**File:** `lib/theme/app_theme.dart`

**Purpose:**  
Centralized visual design system. All colors, typography, and spacing.

**Key Elements:**
```dart
class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(...);
  static const TextStyle bodyMedium = TextStyle(...);
  
  // ThemeData
  static ThemeData lightTheme = ThemeData(...);
  static ThemeData darkTheme = ThemeData(...);
}
```

---

### 2. AppStrings

**File:** `lib/ui/strings/app_strings.dart`

**Purpose:**  
Centralized user-facing text. Prepares for localization.

**Key Strings:**
```dart
class AppStrings {
  static const String appTitle = "AcuLearn";
  static const String trackSelectionTitle = "Select Your Track";
  static const String undergradTrack = "Undergraduate Track";
  static const String postgradTrack = "Postgraduate Track";
  static const String startQuiz = "Start Quiz";
  static const String reviewAnswers = "Review Answers";
  static const String backToHome = "Back to Home";
  // ... (all UI text)
}
```

---

## Summary: MVP Components Checklist

### Screens (5 total)
- [ ] TrackSelectionScreen
- [ ] HomeScreen
- [ ] QuizScreen
- [ ] ResultScreen
- [ ] ReviewScreen

### Controllers (2 total)
- [ ] QuizController
- [ ] TrackController

### Widgets (2+ reusable components)
- [ ] McqOptionButton
- [ ] ResultSummaryCard

### Data Layer (2 components)
- [ ] Question Model (with fromJson/toJson)
- [ ] QuestionRepository (load, filter questions)

### Services (1 stub)
- [ ] SubscriptionService (stub implementation)

### Infrastructure
- [ ] AppRouter (navigation)
- [ ] AppTheme (visual design)
- [ ] AppStrings (text constants)

---

## Implementation Order (Suggested)

1. **Setup:**
   - Create Flutter project
   - Add Riverpod dependency
   - Set up folder structure

2. **Data Layer:**
   - Implement `Question` model
   - Create sample `assets/questions.json`
   - Implement `QuestionRepository`

3. **Logic Layer:**
   - Implement `TrackController`
   - Implement `QuizController`
   - Write unit tests

4. **UI Layer:**
   - Build `TrackSelectionScreen`
   - Build `HomeScreen`
   - Build `QuizScreen` (MCQ mode first)
   - Build `ResultScreen`
   - Build `ReviewScreen`

5. **Polish:**
   - Add `AppTheme`
   - Extract strings to `AppStrings`
   - Add reusable widgets (`McqOptionButton`, etc.)
   - Implement other assessment modes (written, oral, OSCE)

6. **Testing:**
   - Write widget tests
   - Write integration tests (end-to-end flow)

7. **CI/CD:**
   - Set up GitHub Actions
   - Ensure APK builds on every push

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-03  
**Owner:** Lead Engineer  
**Status:** Final - Ready for Implementation
