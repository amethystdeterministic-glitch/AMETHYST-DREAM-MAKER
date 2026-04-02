#!/usr/bin/env python3

import sys
import json

sys.path.append("/data/data/com.termux/files/home/repos/odin_os/core/spark_kernel")

from spark_router import route
from dre_gate import validate_execution
from creative_pipeline import generate_creative_artifact
from fraud_pipeline import run_fraud_pipeline
from research_pipeline import run_research_pipeline


def deterministic_engine(input_text: str):
    return {
        "engine": "deterministic_engine",
        "result": f"[DETERMINISTIC] Processed: {input_text}"
    }


def creative_engine(input_text: str):
    return generate_creative_artifact(input_text)


def hybrid_engine(input_text: str):
    creative = generate_creative_artifact(input_text)
    return {
        "engine": "hybrid_engine",
        "result": f"[HYBRID] Combined structured + creative output for: {input_text}",
        "creative_artifact": creative
    }


def fraud_engine(input_text: str):
    return run_fraud_pipeline(input_text)


def research_engine(input_text: str):
    return run_research_pipeline(input_text)


ENGINE_DISPATCH = {
    "deterministic_engine": deterministic_engine,
    "creative_engine": creative_engine,
    "hybrid_engine": hybrid_engine,
    "fraud_engine": fraud_engine,
    "research_engine": research_engine
}


def execute(input_text: str):
    routing = route(input_text)

    dre = validate_execution(input_text, routing)

    if not dre["allowed"]:
        return {
            "input_text": input_text,
            "dre_gate": dre,
            "routing": routing,
            "execution_result": {
                "engine": None,
                "result": "EXECUTION_BLOCKED"
            }
        }

    engine_name = routing["engine_selected"]
    engine_fn = ENGINE_DISPATCH.get(engine_name)

    if not engine_fn:
        return {
            "input_text": input_text,
            "dre_gate": {
                "allowed": False,
                "reason": "UNKNOWN_ENGINE"
            },
            "routing": routing,
            "execution_result": {
                "engine": None,
                "result": "EXECUTION_BLOCKED"
            }
        }

    execution = engine_fn(input_text)

    return {
        "input_text": input_text,
        "dre_gate": dre,
        "engine_selected": engine_name,
        "execution_result": execution,
        "routing": routing
    }


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "missing input_text"}, indent=2))
        return

    input_text = " ".join(sys.argv[1:])
    output = execute(input_text)

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
