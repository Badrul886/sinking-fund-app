# Architecture Governance

## Always On

Keep domain logic independent of UI.

Required conceptual separation:
Presentation → Application/Use Cases → Domain → Data/Persistence → Platform adapters

Financial calculations must not be implemented inside screen components.

Platform-specific functionality must be isolated where practical:
- widgets
- notifications
- haptics
- secure storage
- cloud synchronization
- purchases

Before adding a dependency:
- verify it is necessary;
- inspect current dependencies;
- consider platform implications;
- record major architectural choices in `docs/DECISIONS.md`.
