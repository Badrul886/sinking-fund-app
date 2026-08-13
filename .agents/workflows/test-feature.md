# Test Feature

Determine the appropriate test levels:
- domain/unit;
- integration;
- UI;
- platform.

Run the smallest sufficient test set first, then broader verification.

For failures:
- diagnose root cause;
- fix if in scope;
- otherwise document in `docs/KNOWN_ISSUES.md`.

Never mark a feature verified if tests were skipped without explanation.
