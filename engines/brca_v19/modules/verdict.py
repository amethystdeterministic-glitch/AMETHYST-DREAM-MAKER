def biological_verdict(result):
    if "logrank_p" not in result:
        return "PASS_TRANSFER_ONLY"

    p = result["logrank_p"]
    hr = result["hazard_ratio"]
    direction = result.get("direction_ok", False)

    if direction and p < 0.01 and hr >= 1.75:
        return "PASS_STRONG"

    if direction and p < 0.05 and hr >= 1.35:
        return "PASS_MODERATE"

    if not direction:
        return "FAIL_DIRECTION"

    return "FAIL_WEAK_EFFECT"
