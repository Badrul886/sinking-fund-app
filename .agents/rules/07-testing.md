# Testing Governance

Every meaningful feature needs acceptance criteria.

Minimum expectations:
- unit tests for domain logic;
- integration tests for important data flows;
- UI verification for major screens;
- edge-case coverage;
- platform verification where applicable.

Before claiming completion:
1. run relevant tests;
2. inspect failures;
3. fix or document failures;
4. verify the final state;
5. update `docs/CURRENT_STATE.md`.
