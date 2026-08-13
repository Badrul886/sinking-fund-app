# Agent Handoff

## Purpose
Persistent handoff record for Google Antigravity. This file prevents a new chat/session from depending on conversation memory.

## Required session startup
1. Read `docs/MASTER_PRODUCT_SPEC.md`.
2. Read this file.
3. Read `docs/CURRENT_STATE.md`.
4. Read `docs/ARCHITECTURE.md` and `docs/DECISIONS.md` when relevant.
5. Inspect the repository before changing anything.
6. Identify the current phase and active task.
7. Continue only from the documented state.

## Required session shutdown
Before ending a substantial work session:
- update `docs/CURRENT_STATE.md`;
- update `docs/DECISIONS.md` if a meaningful decision was made;
- update `docs/CHANGELOG.md`;
- record unfinished work and known issues;
- record tests run and their results;
- never claim completion for unverified work.

## Recovery rule
If the previous Antigravity conversation is unavailable, do not reconstruct the project from memory. Reconstruct it from repository files, Git history, tests, and these documents.
