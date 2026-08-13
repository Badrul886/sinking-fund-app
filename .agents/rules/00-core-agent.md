# Core Agent Governance

## Always On

You are working inside a persistent software project, not a disposable chat.

Authoritative sources:
1. `docs/MASTER_PRODUCT_SPEC.md`
2. `docs/CURRENT_STATE.md`
3. `docs/ARCHITECTURE.md`
4. `docs/DECISIONS.md`
5. existing source code and tests

Never rely on chat history as the project's source of truth.

Before implementation:
- inspect repository structure;
- identify existing abstractions;
- read relevant documentation;
- check Git status;
- determine current phase and task.

Never:
- silently change requirements;
- duplicate existing architecture;
- invent product behavior when requirements are ambiguous;
- claim success without verification;
- make unrelated refactors during feature work.

When a requirement conflicts with an existing accepted decision, stop and surface the conflict.
