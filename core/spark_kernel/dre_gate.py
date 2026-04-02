#!/usr/bin/env python3

from typing import Dict, Any


BLOCK_TERMS = [
    "ignore all previous",
    "override root law",
    "hallucinate",
    "fabricate",
    "black box",
    "bypass"
]


def validate_execution(input_text: str, routing: Dict[str, Any]) -> Dict[str, Any]:
    lower = input_text.lower()

    if routing.get("aeel_audit") != "PASS":
        return {
            "allowed": False,
            "reason": "AEEL_AUDIT_FAIL"
        }

    if routing.get("collapse_id") == "NULL":
        return {
            "allowed": False,
            "reason": "NULL_STATE"
        }

    if routing.get("engine_selected") in [None, "", "unknown_engine"]:
        return {
            "allowed": False,
            "reason": "UNKNOWN_ENGINE"
        }

    for term in BLOCK_TERMS:
        if term in lower:
            return {
                "allowed": False,
                "reason": f"DRE_BLOCK_TERM:{term}"
            }

    return {
        "allowed": True,
        "reason": "GREEN_STATE"
    }
