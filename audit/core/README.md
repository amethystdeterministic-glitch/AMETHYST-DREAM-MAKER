# ODIN Core v1 — Production Freeze Audit Harness

This folder contains deterministic checks + drills.

Outputs:
- audit/core/out/*.txt  (captured evidence)
- audit/core/out/REPORT.md (single report)

Run:
  bash audit/core/run_all.sh

Notes:
- The harness is best-effort: it auto-detects binaries, ledger paths, authority key paths.
- If a component isn't present, the report will mark it as NOT_FOUND / SKIPPED.
