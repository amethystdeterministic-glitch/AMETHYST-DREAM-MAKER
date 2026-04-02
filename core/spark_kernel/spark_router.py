#!/usr/bin/env python3

import sys
import json
from dataclasses import asdict

sys.path.append("/data/data/com.termux/files/home/repos/odin_os/core/spark_kernel")

from spark_kernel import collapse
from spark_ledger import commit


BRANCH_ENGINE_MAP = {
    "B1": "deterministic_engine",
    "B2": "creative_engine",
    "B3": "hybrid_engine"
}


def _semantic_engine(input_text: str):
    lower = input_text.lower()

    if any(k in lower for k in ["fraud", "nhs", "anomaly", "launder", "laundering"]):
        return "fraud_engine"

    if any(k in lower for k in ["research", "brca", "cancer", "alzheim", "study", "trial"]):
        return "research_engine"

    return None


def route(input_text: str):
    result = collapse(input_text)
    result_dict = asdict(result)

    ledger_meta = commit(input_text, result_dict)

    collapse_id = result_dict["collapse_id"]
    engine = _semantic_engine(input_text)

    if engine is None:
        engine = BRANCH_ENGINE_MAP.get(collapse_id, "unknown_engine")

    return {
        "input_text": input_text,
        "collapse_id": collapse_id,
        "engine_selected": engine,
        "aeel_audit": result_dict["aeel_audit"],
        "logic_trace": result_dict["logic_trace"],
        "response": result_dict["response"],
        "ledger": ledger_meta
    }


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "missing input_text"}, indent=2))
        return

    input_text = " ".join(sys.argv[1:])
    output = route(input_text)

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
