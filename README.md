# AcuLearn

**A professional offline-first clinical training and assessment app for medical learners.**

---

## 🩺 What is AcuLearn?

AcuLearn is a **Flutter-based mobile application** designed for medical education and clinical skills assessment. It delivers exam-style questions and structured clinical assessments to support learning and exam preparation in real clinical environments—including low-resource settings with limited connectivity.

### Who is it for?

**Two Primary User Groups:**

1. **Undergraduate Medical Students (Years 1–6)**
   - Foundation clinical knowledge
   - Exam preparation (OSCEs, written exams)
   - Bedside teaching reinforcement
   - Curriculum-aligned content by block/semester

2. **Postgraduate Trainees & Practicing Clinicians**
   - Advanced clinical reasoning
   - Specialty-specific deep dives (Neonatology, ICU/Sepsis, Emergency Medicine)
   - Viva preparation and self-assessment
   - Skills reinforcement for high-acuity settings (NICU, ICU, ED)

---

## 🎯 Why AcuLearn?

### The Problem

Medical trainees need:
- **Structured clinical assessment** beyond textbooks and lectures
- **Offline-accessible content** (hospitals often have poor connectivity)
- **Multiple assessment modes** (not just MCQs—also written, oral, OSCE stations)
- **Track-specific content** (undergrad vs postgrad difficulty levels)
- **Specialty-focused modules** (Neonatology, ICU, Pharmacology, etc.)

### The Solution

AcuLearn provides:
- ✅ **Offline-first architecture** → Works in zero-connectivity environments
- ✅ **4 assessment modes** → MCQ, Written, Oral/Viva, OSCE stations
- ✅ **Track-based filtering** → Content tailored to undergrad or postgrad level
- ✅ **Module-driven content** → Specialty-specific question banks
- ✅ **Clinical accuracy** → Content authored by clinicians, not generic quizzes
- ✅ **Professional design** → Clean, readable, suitable for 3 AM ward rounds in dim light

---

## 📱 What's in the MVP?

### Core Features

#### 1. **Track Selection**
Users choose their training level:
- **Undergraduate Track** → Medical students (Years 1–6)
- **Postgraduate Track** → Residents, trainees, practicing doctors

#### 2. **Module-Based Content Organization**
Questions are grouped by clinical specialty/module:
- Example modules: Neonatology, ICU/Sepsis, Pharmacology, OSCE: Neonatal Resuscitation
- Modules are dynamically loaded from data (no hardcoding in UI)
- Future: Add new modules without changing code (just add data)

#### 3. **Four Assessment Modes**

**a) MCQ (Multiple Choice Questions)**
- Single best answer
- 3–5 options
- Immediate scoring
- Clinical explanations after answering

**b) Written / Short Answer**
- Free-text input
- User types their answer
- App shows model answer / expected key points
- Used for recall-based learning and differential diagnosis drills

**c) Oral / Viva Style**
- Simulated bedside teaching: "You are being asked THIS on rounds"
- Checklist of high-yield talking points
- Learner self-scores whether they covered key points
- Prepares postgrads for consultant-led teaching rounds

**d) OSCE Station**
- Clinical scenario / case vignette
- Required actions or tasks (e.g., "Resuscitation steps", "Initial antibiotic choice")
- Learner reviews expected actions and self-grades
- Skills assessment, not just knowledge

#### 4. **Quiz Session Flow**
1. Select a module → Start quiz
2. Answer questions one by one
3. Submit answers (mode-specific input)
4. See completion summary and score (for MCQ)
5. Review all answers with clinical explanations

#### 5. **Offline-First Design**
- All questions stored locally (no network required)
- Scoring and review work fully offline
- Perfect for clinical settings with poor connectivity

---

## 🏗️ Architecture & Technology

### Technology Stack
- **Framework:** Flutter (Dart) - stable channel
- **State Management:** Riverpod 2.x
- **Local Data:** JSON/CSV files (bundled assets)
- **Testing:** `flutter_test`, widget tests, integration tests
- **CI/CD:** GitHub Actions (builds APK on every push to `main`)

### Architecture Principles
- **Clean Architecture:** Clear separation of UI, business logic, data, and services
- **Offline-First:** No backend dependency for core functionality
- **Content-Driven UI:** Module lists and question types come from data, not hardcoded
- **Testability:** Controllers are testable without UI (no BuildContext dependency)
- **Future-Proof:** Designed for future features (premium tiers, analytics, Arabic localization)

### Folder Structure
```
lib/
├── main.dart                    # App entry point
├── app_router.dart              # Centralized navigation
│
├── theme/
│   └── app_theme.dart          # Colors, typography, ThemeData
│
├── ui/
│   ├── strings/
│   │   └── app_strings.dart    # All user-facing text (localization-ready)
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
│   ├── quiz_controller.dart    # Quiz session state management
│   ├── track_controller.dart   # Academic track selection
│   └── ...
│
├── data/
│   ├── models/
│   │   └── question_model.dart # Question entity + JSON serialization
│   └── repositories/
│       └── question_repository.dart  # Data access, filtering
│
└── services/
    ├── subscription_service.dart  # Premium access control (stub in MVP)
    └── ...
```

For detailed architecture documentation, see:
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Complete architecture overview
- [STATE_MANAGEMENT_RATIONALE.md](./STATE_MANAGEMENT_RATIONALE.md) - Why Riverpod?
- [MVP_SCREENS_AND_CONTROLLERS.md](./MVP_SCREENS_AND_CONTROLLERS.md) - All screens and controllers

---

## 📝 Content Format: How to Add Questions

AcuLearn supports **JSON** and **CSV** formats for question import. Content can be authored by clinicians and educators without programming skills.

### Quick Example (JSON)

```json
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
    "explanation": "35.0°C = hypothermia. Priority is rewarming and thermal protection, not drugs. Per WHO thermal care guidelines.",
    "specialtyModule": "Neonatology",
    "academicLevel": "undergrad",
    "blockOrSemester": "Year 4 Pediatrics Block"
  },
  {
    "id": 202,
    "text": "You are on rounds and asked: Outline immediate steps in suspected neonatal sepsis.",
    "mode": "oral",
    "options": null,
    "correctIndex": null,
    "expectedAnswer": "Thermal support, IV access, broad-spectrum antibiotics per protocol, glucose monitoring, early escalation.",
    "explanation": "These are core first-hour sepsis steps in neonates per most low-resource protocols.",
    "specialtyModule": "Neonatology / Sepsis",
    "academicLevel": "postgrad",
    "blockOrSemester": "NICU Rotation"
  }
]
```

**Complete schema documentation:** [IMPORT_SCHEMAS.md](./IMPORT_SCHEMAS.md)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable channel) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter plugin
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aseelsh24/AcuLearn.git
   cd AcuLearn
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/quiz_controller_test.dart
```

### Building APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## 🧪 Testing & CI/CD

### Automated Testing
- **Unit Tests:** Controllers, repositories, models
- **Widget Tests:** UI components
- **Integration Tests:** End-to-end user flows

### GitHub Actions CI
- **Trigger:** Every push to `main` branch
- **Steps:**
  1. Checkout code
  2. Install Flutter
  3. Run `flutter pub get`
  4. Run `flutter analyze` (linting)
  5. Run `flutter test` (all tests)
  6. Build release APK
  7. Upload APK as artifact

**CI ensures:**
- Code always builds successfully
- Tests always pass
- Fresh APK available after each push

---

## 🗺️ Roadmap

### MVP (Current Phase)
- ✅ Track selection (undergrad/postgrad)
- ✅ Module-based content organization
- ✅ All 4 assessment modes (MCQ, Written, Oral, OSCE)
- ✅ Offline-first architecture
- ✅ Scoring and review screens
- ✅ Clean architecture with Riverpod
- ✅ GitHub Actions CI/CD

### Post-MVP Features

#### Phase 2: Content Management
- [ ] Bulk content import (CSV/JSON upload in app)
- [ ] Content validation tool (CLI for educators)
- [ ] Expand question banks (hundreds of questions per module)
- [ ] Multi-specialty coverage (Surgery, Internal Medicine, OB/GYN, etc.)

#### Phase 3: Premium Subscriptions
- [ ] Implement `SubscriptionService` (real, not stub)
- [ ] Lock advanced modules behind paywall (e.g., "ICU/Sepsis Advanced OSCE")
- [ ] In-app purchases (Play Store, App Store)
- [ ] UI: Display locked content with unlock prompts

#### Phase 4: Analytics & Performance Tracking
- [ ] Track user performance by module and specialty
- [ ] Identify weak areas (e.g., "You consistently miss sepsis timing questions")
- [ ] Progress dashboard (charts, trends)
- [ ] For postgrads: Highlight patient safety risk areas

#### Phase 5: Backend Sync & Cloud Features
- [ ] Backend API for content distribution
- [ ] Download updated question banks from server
- [ ] Sync user progress across devices
- [ ] Optional analytics upload (anonymized data for educators)

#### Phase 6: Localization (Arabic & RTL)
- [ ] Arabic translations
- [ ] RTL layout support
- [ ] Multi-language question banks (English + Arabic)
- [ ] Critical for non-English clinical environments

#### Phase 7: Advanced Features
- [ ] Oral/OSCE rubric capture (structured feedback)
- [ ] Competency sign-off for supervisors
- [ ] Spaced repetition algorithm (adaptive learning)
- [ ] Peer-to-peer content sharing

---

## 👥 Contributing

### For Developers

**We welcome contributions!** Please follow these guidelines:

1. **Read the architecture docs first:**
   - [ARCHITECTURE.md](./ARCHITECTURE.md)
   - [MVP_SCREENS_AND_CONTROLLERS.md](./MVP_SCREENS_AND_CONTROLLERS.md)

2. **Follow coding standards:**
   - ❌ No business logic in widgets
   - ✅ All strings in `AppStrings`
   - ✅ All colors/styles in `AppTheme`
   - ✅ Doc comments on all public classes/methods

3. **Write tests:**
   - Unit tests for controllers
   - Widget tests for UI components

4. **Submit pull requests:**
   - Fork the repo
   - Create a feature branch (`feature/add-analytics`)
   - Write clear commit messages
   - Ensure CI passes
   - Open PR with description

### For Content Authors (Clinicians, Educators)

**You can contribute without coding!**

1. **Create question banks:**
   - Use the JSON or CSV format (see [IMPORT_SCHEMAS.md](./IMPORT_SCHEMAS.md))
   - Focus on clinical accuracy and teaching value
   - Include explanations with guideline references

2. **Submit content:**
   - Open an issue on GitHub with your question bank
   - Or email to [content@aculearnclinical.com] (future)

3. **Review existing content:**
   - Clinical accuracy review
   - Suggest improvements or corrections

---

## 📄 License

**License:** [Choose appropriate license - e.g., MIT, GPL, proprietary]

*(If open-source:)*  
This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.

*(If proprietary:)*  
© 2025 AcuLearn. All rights reserved. This software is proprietary and confidential.

---

## 🤝 Acknowledgments

- **Medical Educators:** For clinical content authorship and review
- **Flutter Community:** For excellent tooling and packages
- **Riverpod:** For clean state management architecture
- **Open-Source Contributors:** For bug fixes and feature additions

---

## 📞 Contact & Support

- **GitHub Issues:** [Report bugs or request features](https://github.com/aseelsh24/AcuLearn/issues)
- **Documentation:** See `/docs` folder for architecture and API specs
- **Email:** [your-email@domain.com] (for project inquiries)

---

## 📊 Project Status

- **Current Version:** MVP (v0.1.0)
- **Status:** ✅ Active Development
- **Last Updated:** 2025-11-03
- **Platform:** Android (iOS support planned)

---

## 🎓 Philosophy

> "This is not a trivia app. This is a serious medical education tool designed for exam prep, bedside teaching, and skills reinforcement in real clinical environments."

AcuLearn is built with:
- **Clinical Accuracy** → Content reviewed by medical professionals
- **Offline Resilience** → Works in low-resource and high-acuity settings
- **Professional Design** → Clean, readable, respectful of clinical context
- **Future-Proof Architecture** → Designed to scale with feature additions

We treat this like a **professional clinical education product**, not a toy quiz app.

---

**Built with ❤️ for medical learners worldwide.**

---

## Quick Links

- [Architecture Overview](./ARCHITECTURE.md)
- [State Management Rationale](./STATE_MANAGEMENT_RATIONALE.md)
- [Content Import Schemas](./IMPORT_SCHEMAS.md)
- [MVP Screens & Controllers](./MVP_SCREENS_AND_CONTROLLERS.md)
- [Project Context (Full Requirements)](./PROJECT_CONTEXT.md)

---

**Ready to improve medical education? Let's build something impactful.** 🚀
