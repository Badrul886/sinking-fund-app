# Calculation Specification

## Status
`DOMAIN CONTRACT`

## Core Concepts
All monetary values must be represented by an explicit `Money` domain model.
- MUST NOT use Dart `double` for monetary representation.
- MUST use an integer-safe mechanism (e.g., cents).
- MUST define currency, strict arithmetic operations, and comparison semantics.
- MUST be independent of Flutter, Riverpod, and Drift.

remaining = targetAmount - currentBalance
requiredContribution = remaining / remainingPeriods (Half-Even rounded)

expectedMinorUnits = roundHalfEven(targetMinorUnits * elapsedPeriods / totalPeriods)
expectedBalance = Money(expectedMinorUnits, currency)

The implementation precisely defines scheduled contribution dates `D` where `startDate <= D <= targetDate`.
`elapsedPeriods` counts dates strictly `< currentDate`.

## Fund Status Precedence
Status is resolved in this strict order:
1. `OVERFUNDED` (balance > target)
2. `COMPLETE` (balance == target)
3. `DEADLINE_PASSED` (currentDate > targetDate)
4. `NOT_STARTED` (0 elapsed periods and 0 contributions)
5. `AHEAD` (balance > expectedBalance)
6. `ON_TRACK` (balance == expectedBalance)
7. `BEHIND` (balance < expectedBalance)

## Required Calculations & Edge Cases
The calculation engine must handle and identify:
- Date-period and contribution-period boundaries (timezone/date-boundary aware).
- Remaining amount and required contribution.
- Progress and fund status.
- Milestone detection.
- **Target = 0**: An open-ended savings pool. The product specification explicitly requires Target = 0 to be handled without division by zero, but does not explicitly state the UX/status semantics. As a domain implementation decision, the status is evaluated predictably based on existing precedence rules without introducing new edge-case states:
  - target = 0, balance = 0 -> Status: `COMPLETE` (because balance == target)
  - target = 0, balance > 0 -> Status: `OVERFUNDED` (because balance > target)
  - target = 0, no contributions -> Status: `COMPLETE` (balance == target)
  - target = 0, withdrawal -> permitted as normal.
- current balance > target (overfunding)
- current balance = target
- deadline = today
- deadline in the past
- missed contribution
- extra contribution
- withdrawal
- partial contribution
- invalid/negative amount
- month/year/leap year boundaries
- daylight-saving transitions where applicable

## Requirements
- pure Dart;
- deterministic;
- side-effect free where practical;
- independently unit-testable;
- independent of Flutter/Riverpod/Drift;
- no UI dependencies (no haptics or navigation in calculations);
- no financial calculation hidden inside presentation components.
