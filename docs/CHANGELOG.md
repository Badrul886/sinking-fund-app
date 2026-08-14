# Changelog

## Unreleased

### Added
- Persistent Antigravity handoff system.
- Repository-level product/engineering governance documents.
- Phase 0 Architectural Plan for Flutter (including Hybrid structure and Money domain model).
- Phase 5A Architectural Prerequisites:
  - AppSettings persistence and `v2` schema migration
  - `Transaction.note` support
  - `OnboardingSettingsRepository` and `CalculateFundPreviewUseCase`
  - `UpdateFundUseCase`
  - `TrajectoryCalculator` for historical/future visualization points

### Changed
- Pivoted core framework choice from React Native/Expo to Flutter.
- Superseded architecture decisions to reflect Flutter ecosystem (Riverpod, Drift, GoRouter).
- Refined Flutter architecture to strictly decouple pure logic from Riverpod and mandate dependency minimization.
- Migrated Android build-tool architecture from legacy KGP to AGP 9 Built-in Kotlin to resolve compatibility with Java 25.

### Fixed
- Replaced basic smoke test for schema migration with a robust `v1 -> v2` path test simulating real data.

### Known issues
None.
## [0.1.0] - Unreleased

### 2026-08-14: Phase 4 Composition Layer Implementation
- Created infrastructure ports and adapters (`SystemClock`, `SecureRandomIdentifierGenerator`).
- Established Riverpod dependency injection root in `presentation/providers`.
- Implemented `FundsListNotifier` and `FundDetailNotifier` as pure wiring layers.
- Pinned `flutter_riverpod ^3.4.2`, `go_router ^17.3.0`.

### Added
- Phase 1: Pure Dart financial domain foundation.
- Money and Currency models with strict integer minor-unit arithmetic and half-even rounding.
- CalendarDate and ContributionSchedule for recurring dates.
- FundCalculator that correctly resolves Fund progress, remaining amount, required contribution, expected balance, and status precedence.
- Comprehensive domain test suite.
- Phase 2: Local data persistence with Drift SQLite and DTO mapping.
- Phase 3: Pure Dart Application Layer with constructor-injected Use Cases (CreateFund, GetFund, AddContribution, AddWithdrawal).
- `FundState` presentation model and `ApplicationError` mapping.
- `IdentifierGenerator` port to isolate UUID generation from application logic.
