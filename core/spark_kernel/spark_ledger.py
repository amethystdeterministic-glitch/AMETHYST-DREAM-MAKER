#!/usr/bin/env python3

import os
import json
import uuid
from datetime import datetime

LEDGER_ROOT = os.path.expanduser(
    "~/repos/odin_os/artifacts/ledger/triple_spark_v1"
)


def _ts():
    return datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")


def _write(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)


def commit(input_text, spark_result_dict):
    run_id = f"SPARK_{_ts()}_{str(uuid.uuid4())[:8]}"

    base = os.path.join(LEDGER_ROOT, run_id)
    os.makedirs(base, exist_ok=True)

    # Ledger A — Input
    ledger_a = {
        "run_id": run_id,
        "timestamp": _ts(),
        "type": "LEDGER_A_INPUT",
        "input_text": input_text,
    }

    # Ledger B — Internal Trace
    ledger_b = {
        "run_id": run_id,
        "timestamp": _ts(),
        "type": "LEDGER_B_TRACE",
        "branches": spark_result_dict.get("branches", []),
    }

    # Ledger C — Collapse
    ledger_c = {
        "run_id": run_id,
        "timestamp": _ts(),
        "type": "LEDGER_C_OUTPUT",
        "collapse_id": spark_result_dict.get("collapse_id"),
        "response": spark_result_dict.get("response"),
        "aeel_audit": spark_result_dict.get("aeel_audit"),
        "delta_detected": spark_result_dict.get("delta_detected"),
    }

    _write(os.path.join(base, "ledger_a.json"), ledger_a)
    _write(os.path.join(base, "ledger_b.json"), ledger_b)
    _write(os.path.join(base, "ledger_c.json"), ledger_c)

    return {
        "run_id": run_id,
        "path": base
    }
