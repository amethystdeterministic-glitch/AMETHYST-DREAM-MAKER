import time

# === HEURISTIC SCORING ===
def heuristic_score(label, content, input_text):
    score = 0
    text = input_text.lower()

    # --- Governance weight ---
    if "governance" in text and label == "governance_path":
        score += 40

    # --- Risk weight ---
    if "risk" in text and label == "risk_path":
        score += 40

    # --- Execution bias ---
    if ("plan" in text or "execute" in text) and label == "execution_path":
        score += 30

    # --- Default structure bonus ---
    if label == "execution_path":
        score += 10

    # --- Content sanity ---
    if len(content) > 20:
        score += 5

    return score


def _make_branch(label, content, input_text):
    return {
        "label": label,
        "content": content,
        "score": heuristic_score(label, content, input_text)
    }


def dqi_engine_v1(input_text):
    branches = [
        _make_branch("governance_path", f"Apply governance analysis to: {input_text}", input_text),
        _make_branch("risk_path", f"Apply risk assessment to: {input_text}", input_text),
        _make_branch("execution_path", f"Create execution plan for: {input_text}", input_text)
    ]

    # Collapse
    selected = max(branches, key=lambda b: b["score"])

    return {
        "ts": int(time.time()),
        "engine": "dqi_engine_v1",
        "input": input_text,
        "decision": "collapse",
        "branches": branches,
        "selected": selected["label"],
        "output": selected["content"]
    }
