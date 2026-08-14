# Current State

> This file is the project's persistent operational memory. Update it after every meaningful implementation session.

## Project
Sinking Fund Mobile Application

## Current phase
- Implemented AppSettings persistence and v2 schema migration
- Added Transaction.note support
- Added OnboardingSettingsRepository and UseCases
- Implemented UpdateFundUseCase for non-financial modifications
- Implemented TrajectoryCalculator for historical/future points
- Implemented CalculateFundPreviewUseCase for onboarding
- Validated via real v1->v2 migration test and unit tests

## Phase 3 status
COMPLETE (Pending Commit)

Actual Phase 3 achievements:
- Implemented pure Dart Application Layer.
- Created constructor-injected Use Cases (CreateFund, GetFund, GetAllFunds, AddContribution, AddWithdrawal).
- Created FundState aggregate model.
- Created ApplicationError mapping from data/domain exceptions.
- Abstracted IdentifierGenerator port.
- Deferred all Riverpod and external UUID dependencies to Phase 4.
- 100% test pass rate for use cases.

## Documentation Status
- The canonical product specification is `MASTER_PRODUCT_SPEC.md` at the repository root.
- It is tracked by Git.
- It is the authoritative product requirements source.
- No duplicate `docs/MASTER_PRODUCT_SPEC.md` should exist.

## Phase 2 status
COMPLETE AND COMMITTED

Actual Phase 1 achievements:
- Implemented pure Dart Currency and Money models
- Implemented deterministic half-even rounding and direct ratio expected balance
- Implemented Fund, CalendarDate, Transaction, and ContributionSchedule
- Implemented robust FundCalculator with status precedence
- 100% test pass rate for all domain components

## Phase 0 status
COMPLETE AND COMMITTED

Actual Phase 0 achievements:
- Flutter project scaffold
- hybrid feature-oriented architecture
- Riverpod state/dependency wiring strategy
- Drift persistence architecture
- GoRouter routing architecture
- pure Dart domain boundary
- Money value-object requirement
- AGP 9.0.1
- built-in Kotlin enabled
- android.newDsl=false compatibility configuration
- Gradle 9.1.0
- Java 25.0.2
- Android SDK 36
- NDK 28.2.13676358
- Gradle cache moved to D:\DevCaches\Gradle
- Pub cache moved to D:\DevCaches\Pub
- flutter analyze passed
- flutter test passed
- debug APK build passed
- Git Phase 0 checkpoint created

## Phase 4 status
COMPLETE AND COMMITTED

Actual Phase 4 achievements:
- Created infrastructure ports and adapters (`SystemClock`, `SecureRandomIdentifierGenerator`).
- Established Riverpod dependency injection root.
- Implemented `FundsListNotifier` and `FundDetailNotifier` as pure wiring layers.

## Phase 5A status
COMPLETE AND READY FOR GIT CHECKPOINT

Actual Phase 5A achievements:
- Added AppSettings persistence and schema v2 migration
- Added Transaction.note
- Added OnboardingSettingsRepository
- Added UpdateFundUseCase
- Added TrajectoryCalculator
- Added CalculateFundPreviewUseCase

## Current state
- Phase 5A architectural prerequisites are complete.
- The next active work is Phase 5B Presentation & UI.

## Active work
PHASE 5B — PRESENTATION AND UI

## Blocked / unresolved
None.

## Tests
`flutter test` and `flutter analyze` passed. Debug APK build passed.

## Important decisions
See `docs/DECISIONS.md`.

## Next action
Review/Implement Phase 5B Presentation and UI.

## Last updated
2026-08-14
