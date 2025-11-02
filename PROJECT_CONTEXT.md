Medical Training & Assessment App (Flutter)

1. Product Vision

We are building a professional clinical training app for medical learners.
The app delivers exam-style questions and structured clinical assessments to two main groups:

- Undergraduate medical students
- Postgraduate trainees / residents / practicing doctors

This is not a trivia app.
This is a serious medical education tool designed for exam prep, bedside teaching, and skills reinforcement in real clinical environments (including low-resource settings and high-acuity settings like NICU / ICU / ED).

The app must feel professional, respectful, and clinically accurate.
Tone: direct, clinical, objective.

---

2. Core Learning Modes (Assessment Types)

The app must support multiple assessment modes. These modes are first-class citizens in the data model and UI:

1. MCQ (Single Best Answer)

   - Question stem
   - 3–5 options
   - One correctIndex
   - Explanation / rationale after answering

2. Written / Short Answer

   - User types a short free-text answer
   - App stores what they wrote
   - Then shows model answer / expected key points
   - Used for recall-based learning and differential diagnosis drills

3. Oral / Viva Style

   - Simulated viva: “You are being asked THIS on rounds. What would you say?”
   - App shows checklist of high-yield talking points
   - Learner self-scores whether they covered most points (self-assessment, honesty-based)
   - This models bedside teaching for postgrads

4. OSCE Station

   - Clinical scenario / case vignette
   - Tasks or required actions (“Resuscitation steps”, “Initial antibiotic”, “Infection control precautions”)
   - Learner reviews the expected actions and self-grades/checks completion
   - This is for skills, not just knowledge

All 4 modes must be supported by:

- The data model
- The quiz controller logic
- The review screen after the session

We treat all 4 modes as exam content. Not just MCQs.

---

3. Content Structure / Targeting

Questions and stations are not just “general medicine.” Content should be filterable and served based on:

- Training level

   - ""academicLevel"": ""undergrad"" or ""postgrad""
   - This determines difficulty, language strictness, and scenario depth.

- Specialty / Module

   - ""specialtyModule"": e.g. ""Neonatology"", ""Emergency Medicine"", ""ICU / Sepsis"", ""Pharmacology"", ""Infection Control"", ""OSCE: Neonatal Resuscitation"", etc.
   - This is how we surface “Modules” on the Home screen.

- Block / Semester / Rotation

   - ""blockOrSemester"": e.g. ""Year 4 Pediatrics Block"", ""NICU Rotation"", ""Internship ED Month"", etc.
   - This allows academic programs to map content to their own curriculum structure (years, blocks, rotations, modules).

Why this matters

We want to be able to say:

- “Show me Postgraduate ICU questions”
- “Show me Year 4 Neonatology block”
- “Show me OSCE stations for Neonatal Sepsis”

This must work without changing any UI code.
Only the data changes.

---

4. Offline-First Requirement

- App must run fully offline.
- All questions and explanations must be locally available without network.
- Scoring and review must not require backend.

Later we will add optional sync, analytics, and premium-gated modules via backend.
But MVP must be functional in a hospital with zero connectivity.

---

5. Paid Tiers / Future Monetization

We will introduce paid / premium content later.

To prepare for this:

- We define a service interface "SubscriptionService" that can answer:
   - "bool isContentLocked(SpecialtyModule module)"
   - "Future<bool> hasPremiumAccess()"

For MVP:

- These always return “unlocked”.
- BUT all UI that shows lists of modules should ask "SubscriptionService" whether a module is locked.
- This lets us later lock “ICU/Sepsis Advanced OSCE (Postgrad)” behind subscription, without redesigning UI.

---

6. High-Level App Flow

Track Selection Screen

User chooses:

- “Undergraduate”
- “Postgraduate”

We store this choice in memory (state).

Home / Dashboard Screen

- Shows the active track (“Undergraduate Track” or “Postgraduate Track”)
- Asks the repository: “what modules are available for this track?”
   - e.g. Neonatology, Pharmacology, ICU/Sepsis, OSCE Stations
- Displays them as selectable cards/buttons
- “Start Quiz” launches a session for the chosen module

Quiz Screen

- Shows questions one by one
- Renders according to "mode":
   - MCQ: list of tappable options
   - Written: text field input
   - Oral/Viva: prompt + self-score
   - OSCE: scenario + checklist
- When user submits an answer, we store it and move forward
- After last question, navigate to Result screen

Result Screen

- Displays score (for MCQ)
- Displays completion summary
- “Review Answers” button

Review Screen

- For each question in the session:
   - Show original question
   - Show user’s answer
   - Show correct or expected answer
   - Show explanation / rationale
- This reinforces learning and gives clinical reasoning, not just raw scores

---

7. State Management Strategy

We will use Riverpod as the state management layer.

Why Riverpod (not bare Provider):

1. It scales better for non-trivial logic like quiz sessions, subscription state, and user track selection.
2. It keeps logic/testability clean (providers can be tested without BuildContext).
3. It avoids putting business logic in Widgets.
4. It’s mature, null safe, widely used in production, and plays nicely with modular architecture.

All business logic (quiz flow, current question index, scoring, storing answers) must live in controllers / notifiers exposed via Riverpod providers, not directly in Widgets.

Widgets = dumb views.
Controllers = logic and state.

---

8. Clean Architecture / Folder Layout

We will enforce a predictable structure under "lib/":

lib/
  main.dart
  app_router.dart            // Centralized navigation/routes

  theme/
    app_theme.dart           // Light/Dark ThemeData, colors, text styles

  ui/
    strings/
      app_strings.dart       // All user-visible text (English for now)
    screens/
      track_selection_screen.dart
      home_screen.dart
      quiz_screen.dart
      result_screen.dart
      review_screen.dart
    widgets/
      mcq_option_button.dart
      result_summary_card.dart
      ... (reusable visual components only)

  logic/
    quiz_controller.dart     // Riverpod notifier for quiz session state
    track_controller.dart    // Stores selected track (undergrad/postgrad)
    // (later) analytics_controller.dart

  data/
    models/
      question_model.dart    // Question/Station model + fromJson/toJson
    repositories/
      question_repository.dart
      // Responsible for loading/filtering questions for track/module

  services/
    subscription_service.dart  // Premium access interface / stub impl
    // (later) sync_service.dart for backend sync, analytics, etc.

Key rules:

- UI never hardcodes module lists like "Neonatology", "ICU/Sepsis".
UI asks "QuestionRepository" for available modules for the current track.
- Business logic (what is the current question? did we finish?) lives in "quiz_controller.dart".
- Visual style (padding, colors, rounded corners) lives in reusable widgets + "app_theme.dart".
- All strings (button labels, headers) live in "app_strings.dart".
This makes Arabic/RTL and localization possible later without hunting strings everywhere.

---

9. Data Model (Question)

Each question, station, or viva prompt is a "Question".

Fields (all MUST exist in "question_model.dart"):

- "id" (int or string-like unique ID)
- "text" (String): the question stem / case prompt
- "mode" (String): ""mcq" | "written" | "oral" | "osce""
- "options" (List<String>?):
   - Present for MCQ
   - "null" for written/oral/OSCE
- "correctIndex" (int?):
   - MCQ index of the correct option
   - "null" for non-MCQ modes
- "expectedAnswer" (String?):
   - For written: model answer / key points
   - For oral/viva: checklist of talking points
   - For OSCE: required actions / steps
- "explanation" (String?):
   - Clinical reasoning / guideline rationale
   - Shown in Review screen
- "specialtyModule" (String):
   - e.g. ""Neonatology"", ""ICU / Sepsis"", ""Pharmacology""
- "academicLevel" (String):
   - ""undergrad"" or ""postgrad""
- "blockOrSemester" (String):
   - e.g. ""Year 4 Pediatrics Block"", ""NICU Rotation""

The same model covers MCQ, written, oral, and OSCE.
The "mode" tells the UI how to render it.

We will implement:

- "Question.fromJson(Map<String, dynamic>)"
- "Map<String, dynamic> toJson()"

---

10. Question Import (JSON / CSV)

We want non-programmers (clinicians, educators) to be able to add content.

JSON format (array of questions/stations)

[
  {
    "id": 101,
    "text": "A newborn is hypothermic at 35.0°C. What is the FIRST priority?",
    "mode": "mcq",
    "options": [
      "Start broad-spectrum antibiotics",
      "Immediate warming / incubator / skin-to-skin",
      "Give paracetamol",
      "No action, this is normal"
    ],
    "correctIndex": 1,
    "expectedAnswer": null,
    "explanation": "35.0°C = hypothermia. Priority is rewarming and thermal protection, not drugs.",
    "specialtyModule": "Neonatology",
    "academicLevel": "undergrad",
    "blockOrSemester": "Year 4 Pediatrics Block"
  },
  {
    "id": 202,
    "text": "You are asked in viva: Outline immediate steps in suspected neonatal sepsis.",
    "mode": "oral",
    "options": null,
    "correctIndex": null,
    "expectedAnswer": "Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation.",
    "explanation": "These are core first-hour sepsis steps in neonates in most low-resource protocols.",
    "specialtyModule": "Neonatology / Sepsis",
    "academicLevel": "postgrad",
    "blockOrSemester": "NICU Rotation"
  }
]

CSV format

Each row is one question/station.
Header row MUST include (order can be defined, but names must match):

id,text,mode,options,correctIndex,expectedAnswer,explanation,specialtyModule,academicLevel,blockOrSemester
101,"A newborn is hypothermic at 35.0°C. What is the FIRST priority?","mcq","[Start broad-spectrum antibiotics;Immediate warming / incubator / skin-to-skin;Give paracetamol;No action, this is normal]",1,,"35.0°C = hypothermia. Priority is rewarming, not drugs.","Neonatology","undergrad","Year 4 Pediatrics Block"
202,"You are asked in viva: Outline immediate steps in suspected neonatal sepsis.","oral",,, "Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation.","These are core first-hour sepsis steps in neonates in most low-resource protocols.","Neonatology / Sepsis","postgrad","NICU Rotation"

Notes:

- "options" for MCQ is a ";"-separated list inside "[...]".
- For non-MCQ modes, "options" and "correctIndex" can be empty.
- "academicLevel" MUST be exactly ""undergrad"" or ""postgrad"" so filtering works.
- "mode" MUST be ""mcq"", ""written"", ""oral"", or ""osce"".

The repository will eventually:

- Parse JSON/CSV
- Filter by "academicLevel"
- Filter by "specialtyModule" or "blockOrSemester"

This is how we add new modules in the future without touching UI code.

---

11. Quiz Session Logic

We will have a central quiz controller (Riverpod notifier) called e.g. "QuizController" with responsibilities:

- Hold current list of "Question" objects for this session
- Track:
   - "currentQuestionIndex"
   - "userAnswers" (map: question.id → user’s answer)
   - "score" (for MCQ only)
   - "isFinished"
- Expose methods:
   - "startSession(List<Question> questions)"
   - "currentQuestion"
   - "answerQuestion(userAnswer)"
      - For MCQ: store selected option index and update score if correct
      - For written/oral/OSCE: store free text / self-check result
   - "nextQuestion()"
   - "getSummary()" for Result screen and Review screen

The UI should never implement scoring logic manually.
The UI just calls controller methods.

We will also have a "TrackController" (or similar) to store and expose the current academic track (""undergrad"" or ""postgrad"") and pass that into the repository.

---

12. Visual Design / Theming

- The app must look clinical, not childish.
- Default palette: clean white / grey surfaces with medical blue accents.
Dark mode is allowed and should remain legible in low-light wards.
- Rounded cards, good spacing, readable type.
- Typography should look serious (no playful fonts).
Use consistent text styles via "ThemeData" ("titleMedium", "bodyMedium", etc.).

All color tokens and text styles must live in "theme/app_theme.dart".
Do not hardcode magic colors or font sizes across random widgets.

Reusable UI components:

- "McqOptionButton"
   - Renders an MCQ choice
   - Knows how to appear "selected"
   - Knows how to show "correct / incorrect" styling in review mode
- "ResultSummaryCard"
   - Shows score %, total correct, total questions
   - Used in ResultScreen and potentially future analytics dashboard

---

13. Localization / Future Arabic

All user-facing strings go in "ui/strings/app_strings.dart" as constants or getters.

For now:

- English only
- Left-to-right layout

Later:

- We will add Arabic translations in the same centralized file or convert it to a proper localization class (e.g. "AppLocalizations").
- We will enable RTL via "Directionality(TextDirection.rtl)" for Arabic track if needed.

The important rule:
DO NOT sprinkle user-facing text directly into Widgets everywhere.
Always pull text from "AppStrings".

---

14. CI/CD and GitHub Actions

We require automated builds from day one.

Pipeline requirements (".github/workflows/ci.yml"):

1. Trigger on every push to "main"
2. Steps:
   - Checkout repo
   - Install Flutter (stable channel)
   - "flutter pub get"
   - "flutter analyze"
   - "flutter test"
   - "flutter build apk --release"
   - Upload the built APK as an artifact

We will also include at least one basic test under "test/", e.g. "quiz_controller_test.dart", so CI actually passes.

This guarantees:

- Code always builds
- Lint/analyze stays clean
- We always have a fresh APK artifact after each push

This is critical because we eventually want to hand APK builds directly to testers / trainees / clinical educators without manual builds.

---

15. Roadmap Preview

After MVP works end-to-end (track select → pick module → run session → result → review):

Next steps:

1. Bulk Content Import

   - Admin (educator) provides JSON/CSV files with new modules
   - App ingests without code changes
   - Scaling to hundreds of questions / multiple rotations

2. Premium Subscription

   - "SubscriptionService" stops always returning “unlocked”
   - Some modules (e.g. “ICU/Sepsis Advanced OSCE”) become premium for postgrads
   - UI visually marks locked modules

3. Performance Analytics

   - Track per-user weak areas by "specialtyModule"
   - Show trends (“You consistently miss neonatal sepsis escalation timing”)
   - For postgrads: highlight risk areas with patient safety impact

4. Oral / OSCE Rubric Capture

   - Convert self-score data into structured rubrics
   - Useful for bedside teaching / competency sign-off
   - Eventually could export summary for supervisors

5. Localization / Arabic

   - Add Arabic strings
   - Allow RTL mode
   - This is important for training in non-English environments and for non-native English staff

6. Backend Sync (Future)

   - Securely download updated question banks from server
   - Optionally upload anonymized performance data to analytics dashboard for educators
   - Control premium access by account / subscription

Everything above must be possible without rewriting the app architecture.
That is why we are enforcing clean separation (UI / logic / data / services) from day one.

---

16. Non-Negotiable Engineering Rules

1. No business logic in Widgets.
Widgets render state. Controllers own logic.

2. All UI strings centralized.
We are preparing for Arabic and other languages.

3. All module lists must come from data, not be hardcoded.
The Home screen must ask the repository, “Which modules exist for this track?”
That’s how we add new specialties / semesters later without touching code.

4. Every public class and method has a short doc comment.
We work like a team. Code must be understandable by someone else.

5. Dark mode support, clinical readability.
Doctors use phones in dim wards at 3AM.

6. CI from day 1.
Each push to "main" produces a fresh APK artifact and runs tests.

---

17. How AI Contributors Should Work

When asking an AI/code agent to implement or modify something:

- You MUST reference "PROJECT_CONTEXT.md".
- You MUST say which phase / task you’re working on.
- You MUST specify which file(s) are allowed to change.
- You MUST forbid it from renaming or breaking existing public APIs unless absolutely necessary.
- You MUST ask it to keep code compilable and consistent with Riverpod, folder structure, and naming conventions here.

Examples of safe tasks:

- “Add a new module ‘ICU / Sepsis’ for postgrad. Update QuestionRepository and show the JSON sample. Do NOT touch UI widgets.”
- “Refactor quiz_screen.dart visuals only. Do NOT change quiz_controller.dart logic or signatures.”
- “Generate .github/workflows/ci.yml according to PROJECT_CONTEXT.md.”

We do not let AI ‘rewrite the project from scratch’. We evolve phase by phase.

---

18. Summary

This app is an offline-first Flutter training tool for medical learners.
It supports MCQ, written answers, viva/oral self-assessment, and OSCE-style stations.
Content is filtered by track (undergrad vs postgrad), specialty/module, and academic block/rotation.

Architecture is deliberately clean:

- Riverpod controllers for logic
- Repository for data loading/filtering
- UI screens consume state and render it
- Strings centralized for future Arabic
- SubscriptionService stubbed now for future paid tiers
- GitHub Actions builds APK on every push to "main"

We treat this like a serious clinical education product with future commercial potential, not a toy quiz app.