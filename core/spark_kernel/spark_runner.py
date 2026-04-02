#!/usr/bin/env python3

import sys
import json
from dataclasses import asdict

sys.path.append("/data/data/com.termux/files/home/repos/odin_os/core/spark_kernel")

from spark_kernel import collapse
from spark_ledger import commit


def main() -> None:
    if len(sys.argv) < 2:
        print(json.dumps({
            "error": "missing input_text"
        }, indent=2))
        sys.exit(1)

    input_text = " ".join(sys.argv[1:])

    result = collapse(input_text)
    result_dict = asdict(result)
    ledger_meta = commit(input_text, result_dict)

    payload = {
        "kernel": "SPARK_V1",
        "input_text": input_text,
        "collapse_id": result_dict["collapse_id"],
        "aeel_audit": result_dict["aeel_audit"],
        "delta_detected": result_dict["delta_detected"],
        "entropy_injection": result_dict["entropy_injection"],
        "logic_trace": result_dict["logic_trace"],
        "response": result_dict["response"],
        "ledger": ledger_meta,
        "branches": result_dict["branches"]
    }

    print(json.dumps(payload, indent=2))


if __name__ == "__main__":
    main()
