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
requiredContribution = remaining / remainingContributionPeriods

The actual implementation must define contribution-period boundaries precisely and test them.

## Fund States
- NOT_STARTED
- ON_TRACK
- AHEAD
- BEHIND
- COMPLETE
- OVERFUNDED
- DEADLINE_PASSED

## Required Calculations & Edge Cases
The calculation engine must handle and identify:
- Date-period and contribution-period boundaries (timezone/date-boundary aware).
- Remaining amount and required contribution.
- Progress and fund status.
- Milestone detection.
- target = 0
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
