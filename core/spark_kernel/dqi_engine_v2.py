import time

def score_components(label, input_text):
    text = input_text.lower()

    governance_weight = 0
    risk_weight = 0
    execution_weight = 0
    constraint_weight = 0
    structure_weight = 5

    if "governance" in text or "compliance" in text or "policy" in text:
        if label == "governance_path":
            governance_weight += 40

    if "risk" in text or "exposure" in text or "threat" in text:
        if label == "risk_path":
            risk_weight += 40

    if "plan" in text or "execute" in text or "rollout" in text or "deploy" in text:
        if label == "execution_path":
            execution_weight += 30

    if label == "governance_path":
        constraint_weight += 10

    if label == "execution_path":
        structure_weight += 10

    total = (
        governance_weight +
        risk_weight +
        execution_weight +
        constraint_weight +
        structure_weight
    )

    return {
        "governance_weight": governance_weight,
        "risk_weight": risk_weight,
        "execution_weight": execution_weight,
        "constraint_weight": constraint_weight,
        "structure_weight": structure_weight,
        "total": total
    }

def make_branch(label, content, input_text):
    components = score_components(label, input_text)
    return {
        "label": label,
        "content": content,
        "score": components["total"],
        "score_components": components
    }

def dqi_engine_v2(input_text):
    branches = [
        make_branch("governance_path", f"Apply governance analysis to: {input_text}", input_text),
        make_branch("risk_path", f"Apply risk assessment to: {input_text}", input_text),
        make_branch("execution_path", f"Create execution plan for: {input_text}", input_text)
    ]

    selected = max(branches, key=lambda b: b["score"])

    return {
        "ts": int(time.time()),
        "engine": "dqi_engine_v2",
        "input": input_text,
        "decision": "collapse",
        "branches": branches,
        "selected": selected["label"],
        "output": selected["content"]
    }
