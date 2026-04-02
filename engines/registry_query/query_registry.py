import json
from pathlib import Path

BASE = Path.home() / "repos/odin_os/artifacts/trial_registry/trials"

def load_trials():
    trials = []
    for f in BASE.glob("*.json"):
        with open(f) as fh:
            trials.append(json.load(fh))
    return trials

def infer_domain(intent: str):
    intent = intent.lower()

    if "cancer" in intent or "survival" in intent:
        return "medical"
    if "biodiversity" in intent or "habitat" in intent:
        return "ecological"

    return "general"

def query(intent: str):
    trials = load_trials()
    domain = infer_domain(intent)

    relevant = [t for t in trials if t["domain"] == domain and t["status"] == "PROVEN"]

    if not relevant:
        return {
            "intent": intent,
            "domain": domain,
            "recommendation": "no prior pattern — explore"
        }

    # pick best by metric (simple heuristic)
    best = max(relevant, key=lambda x: x.get("key_metric_value", 0))

    return {
        "intent": intent,
        "domain": domain,
        "recommended_pattern": best["pattern_type"],
        "signal_type": best["signal_type"],
        "source_trial": best["trial_id"]
    }

if __name__ == "__main__":
    import sys
    intent = " ".join(sys.argv[1:])
    result = query(intent)
    print(json.dumps(result, indent=2))
