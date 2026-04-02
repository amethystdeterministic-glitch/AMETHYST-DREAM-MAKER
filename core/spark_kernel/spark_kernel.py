#!/usr/bin/env python3

import json
import math
import random
import hashlib
from dataclasses import dataclass, asdict
from typing import List, Dict, Any


ROOT_LAW = "SOVEREIGN_STABILITY"


@dataclass
class SparkBranch:
    branch_id: str
    content: str
    alignment: float
    logic: float
    entropy: float
    drift_penalty: float
    score: float
    accepted: bool
    rejection_reason: str = ""


@dataclass
class SparkResult:
    input_text: str
    delta_detected: float
    entropy_injection: str
    aeel_audit: str
    collapse_id: str
    logic_trace: str
    response: str
    branches: List[Dict[str, Any]]


def _stable_seed(text: str) -> int:
    h = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return int(h[:16], 16)


def _bounded_entropy(seed: int, strength: float) -> float:
    rnd = random.Random(seed)
    value = rnd.uniform(-strength, strength)
    return round(value, 6)


def _estimate_alignment(text: str, candidate: str) -> float:
    text_words = set(text.lower().split())
    cand_words = set(candidate.lower().split())
    overlap = len(text_words.intersection(cand_words))
    denom = max(1, len(text_words))
    return min(1.0, overlap / denom + 0.35)


def _estimate_logic(candidate: str) -> float:
    length_score = min(1.0, max(0.2, len(candidate) / 120.0))
    punctuation_bonus = 0.1 if "." in candidate or ":" in candidate else 0.0
    return min(1.0, round(length_score + punctuation_bonus, 6))


def _drift_penalty(candidate: str) -> float:
    drift_terms = [
        "fabricated", "pretend", "hallucinate", "ignore all",
        "override", "black box", "theatre", "roleplay"
    ]
    penalty = 0.0
    lower = candidate.lower()
    for term in drift_terms:
        if term in lower:
            penalty += 0.2
    return min(1.0, round(penalty, 6))


def _generate_branches(input_text: str, entropy_strength: float) -> List[SparkBranch]:
    seed_base = _stable_seed(input_text)

    baseline = f"Deterministic response path for: {input_text}"
    lateral_1 = f"Structured lateral interpretation of: {input_text}"
    lateral_2 = f"Creative but bounded interpretation of: {input_text}"

    raw = [
        ("B1", baseline, 0.0),
        ("B2", lateral_1, _bounded_entropy(seed_base + 1, entropy_strength)),
        ("B3", lateral_2, _bounded_entropy(seed_base + 2, entropy_strength)),
    ]

    branches: List[SparkBranch] = []

    for branch_id, content, epsilon in raw:
        alignment = _estimate_alignment(input_text, content)
        logic = _estimate_logic(content)
        drift = _drift_penalty(content)
        score = (alignment * logic) + epsilon - drift

        accepted = True
        rejection_reason = ""

        if drift >= 0.4:
            accepted = False
            rejection_reason = "AEEL_DRIFT_VIOLATION"

        branches.append(
            SparkBranch(
                branch_id=branch_id,
                content=content,
                alignment=round(alignment, 6),
                logic=round(logic, 6),
                entropy=round(epsilon, 6),
                drift_penalty=round(drift, 6),
                score=round(score, 6),
                accepted=accepted,
                rejection_reason=rejection_reason,
            )
        )

    return branches


def collapse(input_text: str, entropy_strength: float = 0.05) -> SparkResult:
    branches = _generate_branches(input_text, entropy_strength)

    valid = [b for b in branches if b.accepted]

    if not valid:
        return SparkResult(
            input_text=input_text,
            delta_detected=0.0,
            entropy_injection="ACTIVE" if entropy_strength > 0 else "INACTIVE",
            aeel_audit="FAIL",
            collapse_id="NULL",
            logic_trace="No valid Green State branch passed AEEL audit.",
            response="NULL_STATE",
            branches=[asdict(b) for b in branches],
        )

    winner = sorted(valid, key=lambda b: b.score, reverse=True)[0]

    delta = max(0.0, abs(winner.entropy))
    audit = "PASS" if winner.accepted else "FAIL"

    return SparkResult(
        input_text=input_text,
        delta_detected=round(delta, 6),
        entropy_injection="ACTIVE" if entropy_strength > 0 else "INACTIVE",
        aeel_audit=audit,
        collapse_id=winner.branch_id,
        logic_trace=f"{winner.branch_id} selected by highest valid score after AEEL filtering.",
        response=winner.content,
        branches=[asdict(b) for b in branches],
    )


def main() -> None:
    import sys

    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "missing input_text"
        }, indent=2))
        return

    input_text = " ".join(sys.argv[1:])
    result = collapse(input_text)
    print(json.dumps(asdict(result), indent=2))


if __name__ == "__main__":
    main()
