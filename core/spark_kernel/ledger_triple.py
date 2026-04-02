import json
import os
import time
import uuid

BASE = "/data/data/com.termux/files/home/odin_runtime/ledger"
INTENT_LEDGER = os.path.join(BASE, "intent_ledger.jsonl")
EXECUTION_LEDGER = os.path.join(BASE, "execution_ledger.jsonl")
OUTCOME_LEDGER = os.path.join(BASE, "outcome_ledger.jsonl")
EVENT_LEDGER = os.path.join(BASE, "spark_events.jsonl")

def _ensure():
    os.makedirs(BASE, exist_ok=True)

def _write(path, record):
    _ensure()
    with open(path, "a") as f:
        f.write(json.dumps(record) + "\n")

def new_trace_id(prefix="TRACE"):
    return f"{prefix}_{uuid.uuid4().hex[:12]}"

def write_intent(trace_id, input_text, route_hint):
    record = {
        "ts": int(time.time()),
        "trace_id": trace_id,
        "ledger": "intent",
        "input": input_text,
        "route_hint": route_hint
    }
    _write(INTENT_LEDGER, record)
    return record

def write_execution(trace_id, engine, branches=None, selected=None, scores=None):
    record = {
        "ts": int(time.time()),
        "trace_id": trace_id,
        "ledger": "execution",
        "engine": engine,
        "branches": branches or [],
        "selected": selected,
        "scores": scores or {}
    }
    _write(EXECUTION_LEDGER, record)
    return record

def write_outcome(trace_id, decision, output):
    record = {
        "ts": int(time.time()),
        "trace_id": trace_id,
        "ledger": "outcome",
        "decision": decision,
        "output": output
    }
    _write(OUTCOME_LEDGER, record)
    return record

def write_event(event):
    record = {
        "ts": int(time.time()),
        **event
    }
    _write(EVENT_LEDGER, record)
    return record
