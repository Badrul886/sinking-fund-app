# Financial Engine Governance

## Always On for financial work

Treat financial calculations as a critical domain subsystem.

Rules:
- deterministic;
- unit-tested;
- no UI dependencies;
- explicit rounding policy;
- explicit date-period policy;
- explicit status rules;
- reject invalid values;
- never divide by zero;
- handle target completion and overfunding;
- handle withdrawals and missed contributions.

Any modification to financial logic requires tests covering the changed behavior and relevant boundaries.

Do not optimize away clarity in financial formulas.
