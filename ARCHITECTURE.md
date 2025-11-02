# AcuLearn - Application Architecture

## Overview

AcuLearn is an **offline-first Flutter application** for medical training and clinical assessment. The architecture follows **clean architecture principles** with clear separation of concerns across UI, business logic, data, and services layers.

---

## Overall Architecture & Module Boundaries

### 1. **Presentation Layer (UI)**
- **Responsibility:** Render views, handle user interactions, display state
- **Components:**
  - **Screens:** Full-page views (Track Selection, Home, Quiz, Result, Review)
  - **Widgets:** Reusable UI components (MCQ buttons, result cards, etc.)
  - **Strings:** Centralized text constants for localization readiness
  - **Theme:** Visual design system (colors, typography, spacing)
- **Rules:**
  - NO business logic in widgets
  - Widgets are "dumb views" that consume state from controllers
  - All user-facing strings come from `AppStrings`
  - All visual tokens come from `AppTheme`

### 2. **Business Logic Layer (Controllers)**
- **Responsibility:** Application state management, business rules, session orchestration
- **Components:**
  - **QuizController:** Manages quiz session state, scoring, question progression
  - **TrackController:** Stores user's selected academic track (undergrad/postgrad)
  - **Future controllers:** Analytics, subscription state, etc.
- **Technology:** Riverpod providers and notifiers
- **Rules:**
  - Controllers never directly access widgets or BuildContext
  - All state mutations go through controller methods
  - Controllers are fully testable in isolation

### 3. **Data Layer (Models & Repositories)**
- **Responsibility:** Data access, filtering, parsing, business entities
- **Components:**
  - **Models:** `Question` model with serialization (fromJson/toJson)
  - **Repositories:** `QuestionRepository` for loading/filtering questions
- **Data Sources:**
  - Local JSON/CSV files bundled with the app
  - Future: Remote sync from backend API
- **Rules:**
  - Repository is the single source of truth for questions
  - All data filtering (by track, module, block) happens in repository
  - Models are immutable data classes

### 4. **Services Layer**
- **Responsibility:** Cross-cutting concerns, external integrations, abstractions
- **Components:**
  - **SubscriptionService:** Premium content access control (currently stub)
  - **Future services:** SyncService, AnalyticsService, LocalStorageService
- **Rules:**
  - Services define abstract interfaces
  - Implementation can be swapped (e.g., mock vs production)
  - Services are injected via Riverpod providers

### 5. **Navigation & Routing**
- **Responsibility:** Centralized app navigation
- **Component:** `app_router.dart` defines all routes
- **Rules:**
  - No hardcoded Navigator.push in screens
  - All navigation goes through named routes or router methods

---

## Module Boundaries

### Clear Separation of Concerns

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  Screens, Widgets, Strings, Theme                           │
│  (Renders UI, handles interactions)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │ consumes state via Riverpod
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                       │
│  QuizController, TrackController                            │
│  (State management, business rules)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │ reads/writes data
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  Models (Question), Repositories (QuestionRepository)       │
│  (Data access, filtering, parsing)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ uses services
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                     SERVICES LAYER                           │
│  SubscriptionService, (Future: SyncService, Analytics)      │
│  (Cross-cutting concerns, external integrations)            │
└─────────────────────────────────────────────────────────────┘
```

### Module Communication Rules

1. **UI → Logic:** Screens/widgets call controller methods and listen to state changes
2. **Logic → Data:** Controllers use repositories to fetch/filter questions
3. **Data → Services:** Repositories may check subscription status before returning content
4. **Services → Logic:** Services notify controllers of state changes (e.g., subscription updates)

**NEVER:**
- UI directly accesses repositories or models
- Controllers directly manipulate UI widgets
- Data layer makes UI decisions

---

## Folder Structure

```
lib/
├── main.dart                           # App entry point
├── app_router.dart                     # Centralized navigation
│
├── theme/
│   └── app_theme.dart                 # Colors, typography, ThemeData
│
├── ui/
│   ├── strings/
│   │   └── app_strings.dart           # All user-facing text
│   ├── screens/
│   │   ├── track_selection_screen.dart
│   │   ├── home_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── result_screen.dart
│   │   └── review_screen.dart
│   └── widgets/
│       ├── mcq_option_button.dart
│       ├── result_summary_card.dart
│       └── ...
│
├── logic/
│   ├── quiz_controller.dart           # Quiz session state management
│   ├── track_controller.dart          # Academic track selection state
│   └── ...
│
├── data/
│   ├── models/
│   │   └── question_model.dart        # Question entity + serialization
│   └── repositories/
│       └── question_repository.dart   # Data access, filtering
│
└── services/
    ├── subscription_service.dart      # Premium access control
    └── ...
```

---

## Key Architectural Decisions

### 1. Offline-First Architecture
- All questions stored locally (bundled JSON/CSV)
- No network required for core functionality (MVP)
- Scoring and review work fully offline
- Future: Optional sync for content updates and analytics

### 2. Content-Driven UI
- UI **never hardcodes** module names or question types
- Home screen asks repository: "What modules exist for this track?"
- Adding new modules = adding data, **not changing code**

### 3. Multi-Mode Assessment Support
- Single `Question` model handles all modes: MCQ, Written, Oral, OSCE
- `mode` field determines rendering strategy
- Quiz controller logic is mode-agnostic

### 4. Future-Proof for Monetization
- `SubscriptionService` interface exists from day 1
- UI always checks "is this module locked?"
- MVP: All content unlocked
- Future: Premium content behind paywall

### 5. Testability & Maintainability
- Controllers testable without UI (no BuildContext dependency)
- Repositories testable with mock data
- Services mockable for testing
- GitHub Actions CI runs tests on every push

---

## Data Flow Example: Starting a Quiz

1. **User Action:** User taps "Neonatology" module on Home screen
2. **UI → Controller:** Home screen calls `QuizController.startQuiz(moduleId: "Neonatology")`
3. **Controller → Repository:** QuizController asks `QuestionRepository.getQuestionsForModule("Neonatology", track: "undergrad")`
4. **Repository → Data:** Repository filters local question bank by `specialtyModule` and `academicLevel`
5. **Repository → Service:** Repository checks `SubscriptionService.isContentLocked("Neonatology")` (returns false in MVP)
6. **Repository → Controller:** Returns `List<Question>`
7. **Controller → UI:** QuizController updates state with questions, navigates to Quiz screen
8. **UI Renders:** Quiz screen listens to QuizController state and renders first question

---

## Scalability Considerations

### Adding New Content
- Content authors provide JSON/CSV files
- No code changes required
- Repository auto-discovers new modules

### Adding New Assessment Modes
- Add new `mode` value (e.g., `"simulation"`)
- Add rendering logic in Quiz screen
- Question model remains unchanged

### Adding Premium Features
- Toggle `SubscriptionService` implementation from stub to real
- UI already checks subscription status
- No UI redesign needed

### Internationalization (Arabic/RTL)
- All strings already centralized in `AppStrings`
- Add Arabic translations
- Enable RTL via `Directionality`
- No widget changes needed

---

## Non-Negotiable Rules

1. ❌ **No business logic in widgets**
2. ❌ **No hardcoded module names in UI**
3. ❌ **No direct string literals in UI** (use `AppStrings`)
4. ❌ **No magic colors/font sizes** (use `AppTheme`)
5. ✅ **All public classes/methods have doc comments**
6. ✅ **Every feature has at least one test**
7. ✅ **CI passes on every push to main**

---

## Technology Stack

- **Framework:** Flutter (stable channel)
- **State Management:** Riverpod 2.x
- **Local Storage:** JSON/CSV files (bundled assets)
- **Navigation:** Named routes or Flutter routing
- **Testing:** `flutter_test`, `mockito` (optional)
- **CI/CD:** GitHub Actions

---

## Next Steps After Architecture

1. Implement core models (`Question`)
2. Build QuestionRepository with mock data
3. Implement QuizController with Riverpod
4. Build UI screens (track selection → home → quiz → result → review)
5. Add CI/CD pipeline
6. Write unit tests for controllers and repository
7. Test end-to-end flow with sample questions

---

**Last Updated:** 2025-11-03  
**Document Owner:** Lead Engineer  
**Status:** Architecture Definition Complete
