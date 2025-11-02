# State Management Rationale: Why Riverpod over Provider

## Decision Summary

**AcuLearn uses Riverpod as the state management solution** instead of the older Provider package.

This document justifies that choice based on:
1. Offline-first usage patterns
2. Quiz session state complexity
3. Testability requirements
4. Future scalability needs

---

## The Problem: Quiz Session State Complexity

### What We Need to Manage

AcuLearn's quiz session requires managing:

- **Current question index** (which question are we on?)
- **List of questions** for the current session
- **User answers** (map of question ID → user's response)
- **Score tracking** (for MCQ mode)
- **Session completion status** (are we done?)
- **Academic track state** (undergrad vs postgrad)
- **Module selection** (which specialty/rotation?)

Additionally:
- State must survive widget rebuilds
- Controllers need to be **testable without BuildContext**
- Multiple screens need to access the same session state
- We need to support undo/redo, pause/resume in the future

This is **non-trivial state** that goes beyond simple UI state like "is this button pressed?"

---

## Why Not Bare Provider?

### Provider's Limitations for This Use Case

1. **BuildContext Dependency:**
   - Provider requires `BuildContext` to access state
   - Makes unit testing controllers awkward (need to mock BuildContext)
   - Forces business logic to live close to UI code

2. **No Compile-Time Safety:**
   - Easy to forget to provide a dependency
   - Runtime errors if you try to read a provider that wasn't provided
   - No way to catch missing providers at compile time

3. **Global State is Awkward:**
   - Provider encourages putting providers at the root of the widget tree
   - Makes it hard to scope state to specific flows
   - Can lead to "god objects" that know too much

4. **Testing Friction:**
   - Testing Provider-based controllers requires `ProviderContainer` or widget testing
   - Cannot easily test business logic in isolation
   - Mock setup is verbose

### Example of the Problem (Pseudocode)

```dart
// With Provider: Business logic tightly coupled to BuildContext
class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizController = Provider.of<QuizController>(context);
    final currentQuestion = quizController.currentQuestion;
    
    // What if we need this logic elsewhere?
    // What if we want to test this without a widget tree?
  }
}
```

---

## Why Riverpod is the Right Choice

### Riverpod's Advantages for AcuLearn

#### 1. **No BuildContext Dependency**

- Controllers are pure Dart classes, not tied to widgets
- Can be tested without any Flutter infrastructure
- Business logic is truly separated from UI

```dart
// Riverpod: Business logic is independent
final quizControllerProvider = StateNotifierProvider<QuizController, QuizState>((ref) {
  return QuizController(ref.read(questionRepositoryProvider));
});

// Testing (no widgets needed):
test('QuizController advances to next question', () {
  final container = ProviderContainer();
  final controller = container.read(quizControllerProvider.notifier);
  
  controller.nextQuestion();
  expect(container.read(quizControllerProvider).currentIndex, 1);
});
```

#### 2. **Compile-Time Safety**

- If you forget to provide a dependency, **compiler catches it**
- No runtime surprises
- Refactoring is safer (rename a provider, and all usages are flagged)

#### 3. **Better for Offline-First Apps**

**Offline-first apps need predictable, synchronous state management.**

- No async surprises when reading quiz state
- State is always available (no "waiting for network")
- Riverpod's caching and memoization align perfectly with offline data

**Example:** User starts a quiz → all questions loaded locally → session state managed synchronously → no network delays or loading spinners mid-session.

Riverpod's approach:
- Providers are lazy-loaded
- Cached by default
- Can be invalidated when fresh data arrives (future backend sync)
- Perfect for "load once, use offline" patterns

#### 4. **Quiz Session State is Complex**

Our `QuizController` needs to:
- Track current question index
- Store user answers (map of question ID → answer)
- Calculate score on the fly (for MCQ)
- Know when the session is finished
- Support review mode (replay answers)

With Riverpod:
- Use `StateNotifier` or `Notifier` for mutable state
- Expose immutable state snapshots to UI
- UI rebuilds only when state changes
- Controller logic is clean and testable

```dart
class QuizController extends StateNotifier<QuizState> {
  QuizController(this._repository) : super(QuizState.initial());

  final QuestionRepository _repository;

  void startSession(String moduleId, String track) {
    final questions = _repository.getQuestionsForModule(moduleId, track);
    state = QuizState.active(questions: questions);
  }

  void answerQuestion(String questionId, dynamic answer) {
    state = state.copyWith(
      userAnswers: {...state.userAnswers, questionId: answer},
      currentIndex: state.currentIndex + 1,
    );
  }

  void finishSession() {
    state = state.copyWith(isFinished: true);
  }
}
```

UI just listens:

```dart
class QuizScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final currentQuestion = quizState.currentQuestion;
    
    // UI is dumb, controller is smart
  }
}
```

#### 5. **Testability Without Widgets**

```dart
test('Answering question updates state and advances index', () {
  final container = ProviderContainer(
    overrides: [
      questionRepositoryProvider.overrideWithValue(mockRepository),
    ],
  );
  
  final controller = container.read(quizControllerProvider.notifier);
  controller.startSession('Neonatology', 'undergrad');
  
  controller.answerQuestion('q1', 2); // Answer index 2
  
  final state = container.read(quizControllerProvider);
  expect(state.userAnswers['q1'], 2);
  expect(state.currentIndex, 1);
});
```

**No widget tree. No BuildContext. Pure business logic testing.**

#### 6. **Future-Proof for Advanced Features**

As AcuLearn evolves, we'll need:

- **Multiple simultaneous sessions** (e.g., pause quiz, start another module, resume)
  - Riverpod supports scoped providers per session
- **Cross-controller dependencies** (e.g., SubscriptionService needs to notify QuizController when premium status changes)
  - Riverpod's `ref.listen` and `ref.watch` make this clean
- **Undo/redo logic** (go back to previous question)
  - Easier to implement with immutable state snapshots
- **Analytics tracking** (send events when user answers incorrectly)
  - Controllers can emit side effects without polluting UI

Riverpod scales better for these scenarios than Provider.

---

## Offline-First: Why Riverpod Wins

### The Offline-First Challenge

In offline-first apps:
1. Data is **always local** (no network dependency)
2. State transitions are **synchronous** (no waiting for API calls)
3. Users expect **instant feedback** (no loading spinners mid-quiz)
4. Offline data must be **cached and reusable** (don't re-parse JSON every time)

### How Riverpod Addresses This

1. **Lazy Loading with Caching:**
   - Questions loaded once from local JSON
   - Cached in memory by Riverpod
   - No redundant file I/O during quiz session

2. **Synchronous State Reads:**
   - `ref.read(quizControllerProvider)` is synchronous
   - No `Future` or `async` when accessing quiz state
   - Perfect for offline data that's already loaded

3. **State Invalidation for Future Sync:**
   - When backend sync adds new questions (future feature):
     - Call `ref.invalidate(questionRepositoryProvider)`
     - Riverpod re-fetches data
     - UI updates automatically
   - Clean separation: offline = immediate, sync = background

4. **No Rebuild Storms:**
   - Riverpod rebuilds only affected widgets
   - Quiz screen doesn't rebuild when track selection changes
   - Better performance in low-resource clinical settings (older devices)

---

## Decision Matrix: Provider vs Riverpod

| Requirement | Provider | Riverpod |
|-------------|----------|----------|
| **No BuildContext in controllers** | ❌ Requires context | ✅ Context-free |
| **Compile-time safety** | ❌ Runtime errors | ✅ Compile-time checks |
| **Testability without widgets** | ⚠️ Requires ProviderContainer setup | ✅ Simple unit tests |
| **Offline-first sync state** | ⚠️ Manual caching | ✅ Built-in caching |
| **Complex session state** | ⚠️ Awkward with ChangeNotifier | ✅ Clean with StateNotifier |
| **Scoped state (multiple sessions)** | ❌ Hard to scope | ✅ Easy with family/scoped providers |
| **Cross-controller communication** | ⚠️ Manual listeners | ✅ `ref.listen` / `ref.watch` |
| **Future analytics / side effects** | ⚠️ Must pollute UI | ✅ Clean side effect handling |
| **Community momentum** | ⚠️ Legacy, stable | ✅ Modern, actively developed |

---

## Counter-Arguments & Responses

### "Provider is simpler for beginners"

**Response:**  
True for trivial apps. But AcuLearn has:
- Multi-mode quiz logic (MCQ, written, oral, OSCE)
- Academic track filtering
- Session state persistence
- Future premium features

Provider's simplicity becomes a liability at this scale. Riverpod's structure enforces clean architecture, which is **more important** than initial simplicity.

### "Provider is more mature / battle-tested"

**Response:**  
Riverpod is built by the same author (Remi Rousselet) as Provider. It's the "Provider 2.0" that fixes Provider's design flaws. Riverpod is:
- Used in production by many large apps
- Null-safe and modern
- Actively maintained

Provider is in maintenance mode. Riverpod is the future.

### "We don't need Riverpod's advanced features yet"

**Response:**  
**Correct!** But we know we'll need them (subscription state, analytics, multi-session support). Choosing Riverpod now avoids a painful migration later.

Migration from Provider to Riverpod mid-project = high risk, high cost.

---

## Final Justification: Offline-First + Quiz Complexity = Riverpod

### Summary

1. **Offline-first apps need synchronous, cached state management.**  
   → Riverpod's lazy-loaded, cached providers fit perfectly.

2. **Quiz session state is complex** (current question, user answers, scoring, multi-mode support).  
   → Riverpod's `StateNotifier` pattern keeps this clean and testable.

3. **We need testable controllers** (no UI mocking).  
   → Riverpod providers are pure Dart, testable in isolation.

4. **Future features require cross-controller communication** (subscription → quiz, analytics → review).  
   → Riverpod's `ref.listen` / `ref.watch` make this easy.

5. **We're building a professional medical app, not a toy.**  
   → Riverpod enforces clean architecture that scales.

---

## Conclusion

**Riverpod is the right choice for AcuLearn.**

It handles offline-first data, complex quiz session state, and future scalability better than Provider. The investment in learning Riverpod pays off immediately in testability and maintainability.

---

**Decision Date:** 2025-11-03  
**Decision Owner:** Lead Engineer  
**Status:** Approved - Riverpod is the official state management solution
