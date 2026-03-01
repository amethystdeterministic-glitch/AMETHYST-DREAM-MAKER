# Pilgrim AI v1.0.1 — Hardened Advisory Gateway

## Status
Frozen and tagged as `pilgrim_v1.0.1_hardened`.

## Delta from v1.0.0
- Structured request_id added to all responses.
- All panic paths removed.
- Deterministic JSON error surface.
- Runtime health probe hardened.
- Version surfaced via /pilgrim/status.
- Minimal structured logging added.

## Guarantees
- No empty replies.
- No uncontrolled panics.
- Graceful failure if runtime unavailable.
- Advisory-only execution (no mutation surface).

Pilgrim AI v1 is now operationally stable and sealed.
