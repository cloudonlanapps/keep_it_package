# Implementation Plan: Architecture Restructure

This plan covers the systematic refactoring of the `keep_it` application to improve stability, maintainability, and architectural consistency.

## Constraints
- **Do Not Touch**: `cl_camera`, `cl_entity_viewers`, `cl_media_tools`, `form_factory`, `media_editors`, `yet_another_date_picker`, `store`, `local_store`, `store_tasks`.
- **Goal**: Ensure the app builds after every stage.

---

## Stage 1: App Initialization Fixes
**Goal**: Resolve the recursive `ShadApp` issue in `AppStartService`.

### Problem
`OnInitDone` wraps its children in a new `ShadApp` when loading/error occurs. This creates nested standard app widgets, causing theme conflicts and navigation split-brain.

### Proposal
1.  **Refactor `OnInitDone`**:
    - Remove `ShadApp` from `loading` and `error` states.
    - Return a plain `Scaffold` (from standard Flutter) or a `Directionality` + `Theme` wrapper if absolutely needed, but preferably just the specific specialized error/loading view that assumes a parent App exists.
    - Since `AppStartService` *already* puts a `ShadApp` at the root, the children of `onGenerateRoute` are already inside a `ShadApp`.
2.  **AppStart Logic**:
    - Ensure global providers (`appInitProvider`) are checked at the `builder` level of the root `ShadApp`, not deeper in the tree if possible.

---

## Stage 2: Widget Migration
**Goal**: Move generic UI components to `colan_widgets`.

### Candidates for Migration
I will scan `colan_services` for widgets that:
- Are `StatelessWidget`.
- Do not use `ref.watch` / `Consumer`.
- Take all data as parameters.

**Potential Targets**:
- `KeepItErrorView` / `KeepItLoadView` (if made generic)
- `MediaTitle`
- `RefreshButton` (if it just takes an `onPressed`)
- `StandardIcons` wrappers

---

## Stage 3: 3-Layer Architecture
**Goal**: Decouple Logic (Riverpod) from UI.

### Architecture Pattern
1.  **Layer 1: Models (Dart)**
    - Pure Dart classes (Freezed/JSON Serializable).
    - Located in `cl_basic_types` or `store`.
2.  **Layer 2: Services (Feature Builders)**
    - **Notifiers**: Riverpod classes managing state.
    - **Feature Builders**: Widgets that subscribe to Notifiers and return `AsyncValue<ViewModel>`.
    - **ViewModel**: A dedicated class (Model layer) holding specific UI state (e.g., `EntityGridViewModel`).
3.  **Layer 3: UI (Dumb Widgets)**
    - Pure `StatelessWidget` / `StatefulWidget` (non-consumer).
    - Constructor: `const MyView({required this.viewModel, required this.onAction});`
    - No `flutter_riverpod` imports.

### Execution Order
1.  **SettingsService**: Low risk, good pilot.
2.  **AuthService**: Medium risk, distinct state.
3.  **EntityViewerService**: High risk, core feature.

---

## Stage 4: Navigation (Navigator 2.0)
**Goal**: Replace current manual routing.

### Alternatives to GoRouter
Since you mentioned `go_router` issues, detailed evaluation:

1.  **auto_route** (Recommended)
    - **Pros**: Strong typing (Code Gen), highly popular, clear separation of route definition from UI.
    - **Cons**: Requires code generation step (`build_runner`).
2.  **classic navigation (Navigator 1.0) + strict types**
    - **Pros**: No dependencies.
    - **Cons**: Deep linking is manual hard work.
3.  **beamer**
    - **Pros**: Powerful Guards.
    - **Cons**: verbose.

**Recommendation**: **AutoRoute**. It fits your "Strict Model" philosophy perfectly because arguments are typed classes, not Maps.

### Migration Plan
1.  Install `auto_route` & generator.
2.  Define `AppRouter`.
3.  Replace `CLRouteDescriptor` system with `AppRouter`.
4.  Update `PageManager` to wrap `AutoRouter.of(context)`.

---

## Verification Strategy
- **Build Check**: Run `flutter build ios --release` (or android/macos) after each major move.
- **Run Check**: Launch app in Debug mode to verify no runtime crashes.
