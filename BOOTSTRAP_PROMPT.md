# ANTIGRAVITY BOOTSTRAP PROMPT

You are entering an existing professional software project. Your first responsibility is NOT to build the app. Your first responsibility is to establish a persistent, recoverable engineering environment so that future Antigravity chats can continue the project without relying on conversation memory.

## AUTHORITATIVE SOURCES

Treat these as the persistent source of truth:

1. `docs/MASTER_PRODUCT_SPEC.md` — product truth
2. `docs/CURRENT_STATE.md` — operational project memory
3. `docs/ARCHITECTURE.md` — architecture truth
4. `docs/DESIGN_SYSTEM.md` — visual-system truth
5. `docs/CALCULATION_SPEC.md` — financial-domain truth
6. `docs/DECISIONS.md` — accepted architectural/product decisions
7. `.agents/rules/` — agent behavior rules
8. `.agents/workflows/` — reusable operating procedures
9. Existing source code and tests — implementation truth

Conversation history is NOT authoritative.

## YOUR FIRST JOB

Inspect the repository before modifying anything.

Determine:
- whether a mobile project already exists;
- which framework is being used;
- current dependency state;
- current platform configuration;
- existing source structure;
- Git status;
- existing tests;
- existing assets;
- whether any previous implementation exists.

Do not overwrite an existing project.

## PROJECT GOVERNANCE

Ensure the repository contains the `.agents/rules/`, `.agents/workflows/`, and `docs/` structure described by the project.

If files already exist, inspect them and preserve valid existing work. Merge carefully rather than blindly overwriting.

## PRODUCT CONTEXT

The application is a focused sinking-fund planner.

It is NOT a full budgeting platform, bank, investment manager, tax application, or accounting suite.

The core user transformation is:

future irregular expense
→ clear savings requirement
→ visible progress
→ confidence
→ preparedness

The product must be:
- simple;
- visual;
- calm;
- trustworthy;
- mathematically reliable;
- privacy-conscious;
- premium;
- tactile;
- cross-platform.

Do not introduce automated bank aggregation.

## ENGINEERING PRINCIPLES

- Keep financial calculations independent of UI.
- Make calculations deterministic and testable.
- Centralize design tokens.
- Reuse components.
- Avoid duplicate abstractions.
- Isolate platform-specific APIs.
- Do not log sensitive financial values unnecessarily.
- Do not add dependencies without justification.
- Do not perform unrelated refactors.
- Do not claim completion without verification.

## DESIGN QUALITY

The product must not look like a generic AI-generated fintech template.

Pay particular attention to:
- animation;
- interactions;
- iconography;
- illustrations;
- mascot consistency;
- widgets;
- haptics;
- App Store presentation;
- accessibility;
- loading/empty/error/success states.

Animation must communicate something meaningful.

## PHASE 0 DELIVERABLES

Before building product features, establish:

1. repository structure;
2. architecture decision;
3. technology decision;
4. design-system foundation;
5. calculation-domain contract;
6. testing strategy;
7. project documentation;
8. persistent state/handoff process.

Record important decisions in `docs/DECISIONS.md`.

Update `docs/CURRENT_STATE.md` when complete.

## STOP CONDITION

Do NOT start implementing the full application after bootstrap.

At the end of this task, report:

- detected project state;
- chosen/confirmed architecture;
- files created or changed;
- decisions made;
- tests run;
- unresolved questions;
- recommended next phase.

Then stop.

The next task will be issued separately.
