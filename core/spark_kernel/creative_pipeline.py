#!/usr/bin/env python3

import os
import json
import uuid
from datetime import datetime


ART_ROOT = os.path.expanduser(
    "~/repos/odin_os/artifacts/creative_pipeline"
)


def _ts():
    return datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")


def _slug(text: str) -> str:
    cleaned = "".join(ch.lower() if ch.isalnum() else "_" for ch in text)
    while "__" in cleaned:
        cleaned = cleaned.replace("__", "_")
    return cleaned.strip("_")[:60] or "creative_task"


def generate_creative_artifact(input_text: str):
    ts = _ts()
    run_id = f"CREATIVE_{ts}_{str(uuid.uuid4())[:8]}"
    slug = _slug(input_text)

    run_dir = os.path.join(ART_ROOT, run_id)
    os.makedirs(run_dir, exist_ok=True)

    concept = {
        "run_id": run_id,
        "timestamp": ts,
        "input_text": input_text,
        "artifact_type": "creative_concept",
        "title": f"Concept derived from: {input_text}",
        "core_idea": f"A bounded creative expansion of '{input_text}' that can be developed into a structured engine, feature, or content object.",
        "directions": [
            f"Extend '{input_text}' into a reusable module.",
            f"Translate '{input_text}' into an app, engine, or interface surface.",
            f"Identify one deterministic component and one exploratory component inside '{input_text}'."
        ],
        "next_actions": [
            "Define scope",
            "Name the artifact",
            "Create first deterministic spec",
            "Wire into ledger or runtime if approved"
        ]
    }

    json_path = os.path.join(run_dir, f"{slug}.json")
    txt_path = os.path.join(run_dir, f"{slug}.txt")

    with open(json_path, "w") as f:
        json.dump(concept, f, indent=2)

    with open(txt_path, "w") as f:
        f.write("CREATIVE PIPELINE OUTPUT\n")
        f.write("========================\n")
        f.write(f"RUN_ID: {run_id}\n")
        f.write(f"INPUT: {input_text}\n\n")
        f.write(f"TITLE: {concept['title']}\n\n")
        f.write(f"CORE IDEA:\n{concept['core_idea']}\n\n")
        f.write("DIRECTIONS:\n")
        for item in concept["directions"]:
            f.write(f"- {item}\n")
        f.write("\nNEXT ACTIONS:\n")
        for item in concept["next_actions"]:
            f.write(f"- {item}\n")

    return {
        "engine": "creative_engine",
        "run_id": run_id,
        "artifact_dir": run_dir,
        "json_artifact": json_path,
        "text_artifact": txt_path,
        "result": f"[CREATIVE] Artifact created for: {input_text}"
    }


def main():
    import sys

    if len(sys.argv) < 2:
        print(json.dumps({"error": "missing input_text"}, indent=2))
        return

    input_text = " ".join(sys.argv[1:])
    output = generate_creative_artifact(input_text)
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
