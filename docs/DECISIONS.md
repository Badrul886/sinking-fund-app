# Architecture & Product Decisions

Use this format for meaningful decisions.

---

## Decision: Template

**Date:** YYYY-MM-DD  
**Status:** Proposed / Accepted / Superseded

### Context
What problem required a decision?

### Options considered
1.
2.
3.

### Decision
What was selected?

### Rationale
Why?

### Consequences
What becomes easier/harder?

### Related files
- 

---

## Decision: Mobile Application Framework
**Date:** 2026-08-12  
**Status:** Superseded by Flutter

### Context
We need a cross-platform (iOS/Android) mobile application framework that enables a highly tactile, premium feel while supporting rapid development and a shared codebase.

### Options considered
1. React Native (via Expo)
2. Flutter
3. Swift / Kotlin (Native)

### Decision
React Native via Expo.

### Rationale
Expo abstracts away native mobile complexities (linking, building) and provides deep integration with SQLite, routing, and haptics out of the box. React Native (specifically with Reanimated) is fully capable of meeting the "Premium interaction design" requirement in the Master Product Spec. Flutter is not currently installed globally in the dev environment.

### Consequences
- Easier onboarding and iteration loop.
- We must maintain discipline to prevent heavy synchronous JS tasks from blocking the UI thread during animations.

### Related files
- `ARCHITECTURE.md`
- `implementation_plan.md`

---

## Decision: State Management
**Date:** 2026-08-12  
**Status:** Superseded by Riverpod

### Context
We need a reactive state management solution that ties the application logic to the React presentation layer without excessive boilerplate.

### Options considered
1. Zustand
2. Redux Toolkit
3. Context API

### Decision
Zustand.

### Rationale
Zustand is minimal, unopinionated, and performant. It aligns perfectly with Clean Architecture by acting purely as the Application layer binding, without dictating its own heavy patterns (unlike Redux).

### Consequences
- Less boilerplate.
- Requires team discipline to keep stores isolated and modular.

### Related files
- `ARCHITECTURE.md`

---

## Decision: Local Persistence
**Date:** 2026-08-12  
**Status:** Superseded by Drift

### Context
The application needs to store Sinking Fund goals and transaction records persistently on the device.

### Options considered
1. Expo SQLite
2. AsyncStorage
3. WatermelonDB

### Decision
Expo SQLite.

### Rationale
The app is entirely local-first. SQLite provides a robust relational store for structured queries (e.g., aggregating transactions by fund, calculating remaining balances) that would be inefficient in a KV store like AsyncStorage.

### Consequences
- Requires writing and maintaining SQL migrations.
- Data is strictly device-bound unless cloud sync is implemented in the future.

### Related files
- `ARCHITECTURE.md`

---

## Decision: Mobile Application Framework (Revised)
**Date:** 2026-08-12  
**Status:** Accepted

### Context
We need a cross-platform (iOS/Android) mobile application framework that enables a highly tactile, premium feel while supporting rapid development and a shared codebase. Previous React Native choice was superseded prior to implementation.

### Options considered
1. Flutter
2. React Native

### Decision
Flutter (with Dart).

### Rationale
Flutter provides extreme control over every pixel on the screen, which is ideal for delivering custom micro-interactions, complex progress visualizations, and a highly polished UI. Its compiled nature and predictable rendering engine avoid the Javascript bridge overhead. 

### Consequences
- Requires using Dart.
- iOS builds will require a CI/CD pipeline since local dev is on Windows.

### Related files
- `ARCHITECTURE.md`
- `implementation_plan.md`

---

## Decision: State Management & Dependency Injection
**Date:** 2026-08-12  
**Status:** Accepted

### Context
We need a reactive state management and DI solution for Flutter that exposes application state to the UI without forcing the business logic to depend on the framework.

### Options considered
1. Riverpod
2. Bloc/Cubit
3. Provider

### Decision
Riverpod (used strictly for wiring and state exposure).

### Rationale
Riverpod provides compile-safe dependency injection and elegant handling of asynchronous state. However, the Application layer orchestrates business logic using pure Dart controllers/view models. Riverpod is used only to wire these controllers and inject repositories, keeping the Domain and Application logic completely independent of Riverpod.

### Consequences
- Strong reliance on Riverpod for the Presentation-Application boundary.
- Must remain disciplined to avoid putting pure domain logic directly inside Riverpod Notifiers.

### Related files
- `ARCHITECTURE.md`

---

## Decision: Local Persistence
**Date:** 2026-08-12  
**Status:** Accepted

### Context
The application needs to store Sinking Fund goals and transaction records locally, ensuring ACID properties for financial data.

### Options considered
1. Drift (SQLite)
2. Isar (NoSQL)
3. Hive / SharedPrefs

### Decision
Drift (SQLite wrapper for Dart).

### Rationale
Financial transactions are highly relational (Funds 1:N Transactions) and require strict querying logic. Drift provides a robust, type-safe SQLite implementation in Dart, with built-in schema migration tools and reactive streams that pair perfectly with Riverpod.

### Consequences
- Requires writing Drift schemas and running code generation.
- Highly structured data modeling compared to NoSQL.

### Related files
- `ARCHITECTURE.md`

---

## Decision: Navigation & Routing
**Date:** 2026-08-12  
**Status:** Accepted

### Context
We need a routing solution for Flutter that supports deep linking and nested tab navigation cleanly.

### Options considered
1. GoRouter
2. AutoRoute
3. Navigator 2.0 (Raw)

### Decision
GoRouter.

### Rationale
GoRouter is the official declarative routing package for Flutter. It uses a URL-based approach, making deep linking trivial, and provides `StatefulShellRoute` which is perfect for maintaining state across bottom navigation tabs.

### Consequences
- URL-based navigation paradigm rather than push/pop paradigm.
- Configuration is centralized in a single router provider.

### Related files
- `ARCHITECTURE.md`

---

## Decision: Financial Domain Representation (Money)
**Date:** 2026-08-12  
**Status:** Accepted

### Context
We need a safe, deterministic way to represent and manipulate monetary values. Using floating-point numbers (`double`) introduces rounding errors and violates financial calculation safety.

### Options considered
1. Custom `Money` Value Object (integer cents/fixed point)
2. Dart `double`
3. Third-party `money2` package

### Decision
Custom pure Dart `Money` Value Object.

### Rationale
A custom abstraction guarantees deterministic arithmetic, explicit rounding, and exact representation. It must remain pure Dart, independent of Flutter, Riverpod, or Drift, to ensure the financial calculation engine is fully isolated and testable.

### Consequences
- More upfront work to build the Money operations and validation.
- Every layer of the app must map to/from this object (e.g. Drift storing integers mapped to `Money`).

### Related files
- `CALCULATION_SPEC.md`
- `ARCHITECTURE.md`

---

## Decision: Android Build-Tool Architecture (Built-in Kotlin)
**Date:** 2026-08-14  
**Status:** Accepted

### Context
Using the bleeding-edge combination of Java 25, Gradle 9.1.0, and Flutter 3.44.9 caused analysis warnings (`Incompatible KGP/Gradle versions`) and native build task crashes (`JdkImageTransform jlink`). The legacy standalone Kotlin plugin (`org.jetbrains.kotlin.android`) forced AGP 9 to fallback on legacy interop tasks.

### Options considered
1. Downgrade Java to 17/21.
2. Downgrade Flutter or AGP.
3. Migrate to AGP 9 Built-in Kotlin.

### Decision
Migrate to AGP 9 Built-in Kotlin.

### Rationale
AGP 9's Built-in Kotlin safely bypasses the legacy `JdkImageTransform`/`jlink` task which is incompatible with Java 25. This allows us to keep the modern toolchain intact without downgrading components or maintaining legacy boilerplate.

### Consequences
- Removes `org.jetbrains.kotlin.android` from `settings.gradle.kts`.
- Relies on `android.builtInKotlin=true` and temporarily retains `android.newDsl=false` in `gradle.properties`. Opting out of the new DSL is required because the Flutter Gradle plugin internally crashes against AGP 9's strict DSL API boundaries.

### Related files
- `android/gradle.properties`
- `android/settings.gradle.kts`
- `android/app/build.gradle.kts`

---
## Decision: Financial Domain Representation (Phase 1 Refinement)
**Date:** 2026-08-14
**Status:** Accepted

### Context
We needed a detailed implementation of Money that supports multiple global currencies and strict integer arithmetic.

### Options considered
1. Integer minor units + Currency model
2. Floating point arithmetic

### Decision
Strict Integer minor units + Currency model. Cross-currency operations are blocked and throw CurrencyMismatchException.
Calculations for expected balances use direct ratio multiplication (	argetMinorUnits * elapsed / totalPeriods) followed by Half-Even rounding to prevent cumulative rounding error.

### Consequences
- Math operations are safe and deterministic.
- UI will have to format these minor units appropriately.
- Domain cannot do FX calculations.

### Related files
- lib/domain/currency.dart
- lib/domain/money.dart
- lib/domain/fund_calculator.dart

---

## Decision: Open-Ended Funds (Target = 0)
**Date:** 2026-08-14
**Status:** Accepted

### Context
The product specification requires the application to handle Target = 0 without dividing by zero ("Target = 0 — Do not divide by zero."). However, it does not explicitly state the UX or status semantics for a zero-target fund. We needed to formally define these semantics as an implementation/domain decision based on the existing status precedence rules (OVERFUNDED > COMPLETE).

### Decision
A fund with `targetAmount = 0` acts as an open-ended savings pool. The standard calculation engine evaluates its status predictably derived from precedence rules:
- Balance = 0 -> `COMPLETE` (Current balance == target)
- Balance > 0 -> `OVERFUNDED` (Current balance > target)
- Withdrawals are evaluated purely against the existing balance.

### Rationale
This avoids defining special edge-case states in the domain logic while strictly honoring the product specification's constraint to not divide by zero. The existing precedence correctly interprets the math.

### Consequences
- Math operations natively bypass division by zero because the target check stops the flow.
- A zero-target fund immediately hits COMPLETE or OVERFUNDED.

### Related files
- docs/CALCULATION_SPEC.md
- lib/domain/fund_calculator.dart

---

## Decision: Application Layer Boundaries & Framework Deferral
**Date:** 2026-08-14
**Status:** Accepted

### Context
Phase 3 requires building the Application layer (Use Cases) to orchestrate the Domain and Data layers without tightly coupling the core logic to Flutter or Riverpod.

### Decision
The Application layer is built as pure Dart, utilizing strict Constructor Dependency Injection. All Riverpod providers, Notifiers, and external framework dependencies (like UUID) are explicitly deferred to Phase 4 (Composition and Wiring).

### Rationale
This ensures that the business logic can be tested entirely in isolation (using simple Fakes) without needing ProviderScopes or Flutter testing environments. It forces a clean boundary before introducing reactive state.

### Consequences
- Requires explicit `Port` interfaces (e.g., `IdentifierGenerator`) for external concerns.
- Use Cases must be manually wired in tests.

### Related files
- `lib/application/use_cases/`
- `docs/ARCHITECTURE.md`

---

## Decision: Error Handling & Mapping Boundary
**Date:** 2026-08-14
**Status:** Accepted

### Context
The Domain layer throws `ValidationException` and `InsufficientFundsException`. The Data layer throws `RecordNotFoundException` and `ConstraintViolationException`. The Presentation layer needs a unified way to handle these expected errors without exposing underlying implementation details.

### Decision
The Application layer catches expected Domain and Data exceptions and maps them into a sealed `ApplicationError` hierarchy (`FundNotFoundError`, `InvalidFundDataError`, `PersistenceConstraintError`, `InsufficientFundsError`). Unexpected exceptions (e.g., network, filesystem crashes) are allowed to bubble up naturally.

### Rationale
This prevents the Presentation layer from needing to know about Drift-specific or Domain-specific exception types, enforcing the Application layer as the authoritative boundary for error translation.

### Consequences
- Requires try/catch blocks in every Use Case to map known exceptions.
- Provides a clean, exhaustive error enum/sealed class for the UI to handle.

### Related files
- `lib/application/errors/application_error.dart`

