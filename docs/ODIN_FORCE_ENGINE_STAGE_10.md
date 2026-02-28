# ODIN FORCE ENGINE — Stage 10
## External Deterministic Orchestration Layer (Layer D)

Purpose:
Separate OS-level process supervision from deterministic enforcement runtime.

This stage introduces a dedicated Orchestrator crate responsible for:

- Service registration
- Process lifecycle management
- Port reservation metadata
- Deterministic service state reporting

Architectural Position:

Applications
↑
Orchestrator (Layer D)
↑
Subsystem (Layer C)
↑
Core (Layer B)
↑
Kernel (Layer A)

Key Invariants:

1. Orchestrator does NOT sign ledger entries.
2. Orchestrator does NOT append ledger entries.
3. Orchestrator does NOT bypass lifecycle enforcement.
4. Core remains pure deterministic enforcement spine.
5. Replay determinism unaffected by service processes.
6. External service state is not part of deterministic state S.

Operational Guarantees:

- Zombie process handling moves to Orchestrator.
- PowerOn/PowerOff logic relocates here.
- Core remains constitution.
- Orchestrator remains environment manager.

Stage 10 establishes permanent separation between:

Deterministic Constitutional Law
and
Runtime Process Supervision.

Status: COMPLETE
