# Changelog

## Unreleased

### Added
- Persistent Antigravity handoff system.
- Repository-level product/engineering governance documents.
- Phase 0 Architectural Plan for Flutter (including Hybrid structure and Money domain model).

### Changed
- Pivoted core framework choice from React Native/Expo to Flutter.
- Superseded architecture decisions to reflect Flutter ecosystem (Riverpod, Drift, GoRouter).
- Refined Flutter architecture to strictly decouple pure logic from Riverpod and mandate dependency minimization.
- Migrated Android build-tool architecture from legacy KGP to AGP 9 Built-in Kotlin to resolve compatibility with Java 25.

### Fixed
None.

### Known issues
None.
## [Unreleased]
### Added
- Phase 1: Pure Dart financial domain foundation.
- Money and Currency models with strict integer minor-unit arithmetic and half-even rounding.
- CalendarDate and ContributionSchedule for recurring dates.
- FundCalculator that correctly resolves Fund progress, remaining amount, required contribution, expected balance, and status precedence.
- Comprehensive domain test suite.
