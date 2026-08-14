# Architecture

### Composition & Presentation (Phase 4 & 5)
Riverpod is strictly used for dependency injection and presentation logic wiring.
* **Dependencies:** `lib/presentation/providers/dependencies.dart` contains providers for infrastructure components (Repositories, Clock, IdentifierGenerator) and Use Cases.
* **State Management:** Riverpod `AsyncNotifier` is used to expose Domain state (e.g. `FundState`) to the UI.
* **Phase 5A Pre-requisites:**
  * Application provides decoupled use cases for previewing funds (`CalculateFundPreviewUseCase`) and onboarding status (`OnboardingSettingsRepository`), ensuring UI doesn't instantiate Domain objects.
  * Trajectory calculations (`TrajectoryCalculator`) are explicitly part of the Domain, providing read-only projections.
* **Rules:**
  * Riverpod notifiers **MUST NOT** contain core business logic (calculating progress, balancing amounts). They delegate entirely to Application Use Cases.
  * We use manual provider definitions, specifically preferring `AsyncNotifier` combined with constructor-based arguments for family providers.
  * The clock and identifier generator are injected via Application ports to keep the Domain pure.
  
## Data Flow
1. UI interacts with Riverpod Notifier methods.
2. Notifier calls an Application Use Case.
3. Use Case performs logic using pure Domain entities and calls Data Repository to persist.
4. Notifier explicitly invalidates itself (and related list providers) using `ref.invalidateSelf()` and `ref.invalidate(provider)`.
5. UI rebuilds by observing the updated `AsyncNotifier` state.

## Status
`ACCEPTED — Phase 0 Foundation (Hybrid Feature-Oriented Flutter)`

## Principles
1. Cross-platform application with shared domain logic using Flutter and Dart.
2. Hybrid feature-oriented structure keeping core domain/application/data layers separate while clustering presentation features.
3. Financial calculation logic (including an explicit `Money` value object) must be independent of UI, Riverpod, and Drift.
4. Persistent data access must be abstracted behind a repository/data layer (Drift/SQLite). UI never queries the DB directly.
5. Platform-specific capabilities (e.g., haptics, routing) must be isolated behind interfaces (Infrastructure layer). Haptics are strictly UI-driven, not domain-driven.
6. Riverpod is solely for dependency wiring and exposing state to UI, NOT the core application architecture.
7. Design tokens must be centralized.
8. No speculative future dependencies (Rive, RevenueCat) until explicitly required.

## Conceptual layers
Strict unidirectional dependency flow:

Presentation (Flutter Widgets, GoRouter, Riverpod Wiring)
↓
Application (Use Cases, `FundState`, `ApplicationError`, Ports, independent of Riverpod, uses Constructor Injection)
↓
Domain (Pure Dart Entities, `Money`, Calculation Engine, Repository Interfaces)
↑
Data / Infrastructure (Drift, DTOs, Platform Services)

## Domain
- `Money` (Pure, integer-safe value object)
- Fund
- Transaction
- Contribution schedule
- Fund status
- Calculation engine (Pure deterministic math)

## Infrastructure / Platform adapters
Potentially:
- haptics (Triggered by Presentation, not Application logic)
- widgets
- notifications

## Platform Constraints
Android development/testing will happen locally on Windows, utilizing AGP 9 built-in Kotlin to ensure compatibility with modern environments (Java 25). iOS development, testing, and release builds cannot be performed locally on Windows and will require a macOS CI/CD or cloud environment.

## Rule
Architecture is finalized. See `docs/DECISIONS.md`.
