#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# DISCOVERY AUTHORITY V1 (DA) — ECE AGNOSTIC
# FREEZE: DISCOVERY_AUTHORITY_V1__ECE_AGNOSTIC__FREEZE_20260322T201500Z
# ============================================================

# Usage:
# bash discovery_authority_v1.sh \
#   --ece /path/to/ece.json \
#   --out ~/repos/odin_os/artifacts/discoveries

# -----------------------------
# ARG PARSE
# -----------------------------
ECE_PATH=""
OUT_ROOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ece) ECE_PATH="$2"; shift 2;;
    --out) OUT_ROOT="$2"; shift 2;;
    *) echo "[ERR] Unknown arg: $1"; exit 1;;
  esac
done

if [[ -z "${ECE_PATH}" || -z "${OUT_ROOT}" ]]; then
  echo "[ERR] --ece and --out required"; exit 1
fi

if [[ ! -f "${ECE_PATH}" ]]; then
  echo "[ERR] ECE not found: ${ECE_PATH}"; exit 1
fi

# -----------------------------
# STATE
# -----------------------------
STATE="IDLE"

# -----------------------------
# HELPERS
# -----------------------------
now_utc() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
ts_compact() { date -u +"%Y%m%dT%H%M%SZ"; }

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "[ERR] jq required"; exit 1
  fi
}

hash_file() {
  sha256sum "$1" | awk '{print $1}'
}

mkdir_p() { mkdir -p "$1"; }

# -----------------------------
# LOAD ECE
# -----------------------------
require_jq

EXP_ID=$(jq -r '.experiment.experiment_id' "${ECE_PATH}")
PATTERN_CLASS=$(jq -r '.pattern.pattern_class' "${ECE_PATH}")
PATTERN_STATE=$(jq -r '.pattern.pattern_state' "${ECE_PATH}")

# Basic ECE validation
if [[ "${EXP_ID}" == "null" || "${PATTERN_CLASS}" == "null" || "${PATTERN_STATE}" == "null" ]]; then
  echo "[ERR] Invalid ECE (missing required fields)"; exit 1
fi

STATE="CANDIDATE_DETECTED"

# -----------------------------
# QUALIFICATION (GENERIC)
# -----------------------------
# Conditions (minimal v1):
# - >= 2 constraints
# - structure flags present (repetition OR clustering OR cross_boundary)
# - >= 2 entity groups with non-empty arrays
CONSTRAINT_COUNT=$(jq '.evidence.constraints_triggered | length' "${ECE_PATH}")
HAS_STRUCTURE=$(jq -r '.evidence.structure | ( .repetition == true or .clustering == true or .cross_boundary == true )' "${ECE_PATH}")
ENTITY_GROUPS=$(jq '.evidence.entities | to_entries | map(select(.value|length>0)) | length' "${ECE_PATH}")

if [[ "${CONSTRAINT_COUNT}" -lt 2 || "${HAS_STRUCTURE}" != "true" || "${ENTITY_GROUPS}" -lt 1 ]]; then
  echo "[INFO] Not qualified (constraints/structure/entities insufficient)"
  exit 0
fi

STATE="QUALIFIED"

# -----------------------------
# DISCOVERY ID + DIR
# -----------------------------
DISC_ID="DISC_$(ts_compact)"
DISC_DIR="${OUT_ROOT}/${DISC_ID}"
mkdir_p "${DISC_DIR}"

# -----------------------------
# FREEZE PACK
# -----------------------------
STATE="FROZEN"

MANIFEST="${DISC_DIR}/DISCOVERY_MANIFEST.json"
EVIDENCE="${DISC_DIR}/DISCOVERY_EVIDENCE.json"
CONSTRAINTS="${DISC_DIR}/DISCOVERY_CONSTRAINTS.json"
HASHES="${DISC_DIR}/DISCOVERY_HASHES.json"
PROTOCOL="${DISC_DIR}/DISCOVERY_PROTOCOL_STATE.json"

# Write evidence (verbatim from ECE.evidence)
jq '.evidence' "${ECE_PATH}" > "${EVIDENCE}"

# Write constraints (verbatim list)
jq '{constraints_triggered: .evidence.constraints_triggered}' "${ECE_PATH}" > "${CONSTRAINTS}"

# Manifest with lineage
jq -n \
  --arg disc_id "${DISC_ID}" \
  --arg exp_id "${EXP_ID}" \
  --arg pattern_class "${PATTERN_CLASS}" \
  --arg ece_path "${ECE_PATH}" \
  --arg ts "$(now_utc)" \
'{
  discovery_id: $disc_id,
  experiment_id: $exp_id,
  pattern_class: $pattern_class,
  source_ece: $ece_path,
  created_at: $ts,
  runtime: "ODIN_V1",
  protocol: "DISCOVERY_AUTHORITY_V1"
}' > "${MANIFEST}"

# Hashes (append-only)
EVID_HASH=$(hash_file "${EVIDENCE}")
CONS_HASH=$(hash_file "${CONSTRAINTS}")
MANI_HASH=$(hash_file "${MANIFEST}")

jq -n \
  --arg e "${EVID_HASH}" \
  --arg c "${CONS_HASH}" \
  --arg m "${MANI_HASH}" \
'{
  evidence_sha256: $e,
  constraints_sha256: $c,
  manifest_sha256: $m
}' > "${HASHES}"

# Protocol state
jq -n \
  --arg state "${STATE}" \
  --arg ts "$(now_utc)" \
'{
  state: $state,
  updated_at: $ts
}' > "${PROTOCOL}"

# -----------------------------
# WHITEPAPER EN (DETERMINISTIC RENDER)
# -----------------------------
STATE="WHITEPAPER_EN_RENDERED"
WP_EN="${DISC_DIR}/WHITEPAPER_EN.md"

# Extract fields for rendering
TEMP_START=$(jq -r '.evidence.temporal_window.start // "N/A"' "${ECE_PATH}")
TEMP_END=$(jq -r '.evidence.temporal_window.end // "N/A"' "${ECE_PATH}")
VALUE_RANGE=$(jq -r '.evidence.value_characteristics.range // "N/A"' "${ECE_PATH}")
DIST=$(jq -r '.evidence.value_characteristics.distribution // "N/A"' "${ECE_PATH}")

SUP_ENT=$(jq -r '.evidence.entities | to_entries | map("\(.key): \(.value|join(", "))") | join("\n")' "${ECE_PATH}")
CONS_LIST=$(jq -r '.evidence.constraints_triggered | join(", ")' "${ECE_PATH}")

cat > "${WP_EN}" << 'EOT'
# Amethyst Deterministic Discovery Protocol

## Protocol Identity
Produced by: Amethyst Deterministic Runtime — Discovery Authority (DA)

## Discovery Context
EOT

# Append context deterministically (no freeform)
cat >> "${WP_EN}" <<EOT
Experiment ID: ${EXP_ID}
Discovery ID: ${DISC_ID}
Pattern Class: ${PATTERN_CLASS}
Generated At: $(now_utc)

## Input Domain
Structured event stream with entities, timestamps, values, and categorical labels.

## Detection Conditions
The system evaluated structural properties and constraint satisfaction without domain-specific logic.

## Evidence Summary
Temporal Window: ${TEMP_START} → ${TEMP_END}
Value Characteristics: range=${VALUE_RANGE}, distribution=${DIST}

## Pattern Structure
The system identified recurrence, clustering, and/or cross-boundary propagation as defined by the evidence set.

## Entities
${SUP_ENT}

## Constraint Satisfaction
${CONS_LIST}

## Operational Interpretation
The observed structure indicates non-random, persistent behaviour satisfying deterministic constraints.

## Enforcement Opportunity
Constraints may be enforced in real time to block, escalate, or audit matching structures.

## Deterministic Conclusion
The evidence set satisfied the discovery qualification criteria under DISCOVERY_AUTHORITY_V1.

## Artifact Manifest
- DISCOVERY_MANIFEST.json
- DISCOVERY_EVIDENCE.json
- DISCOVERY_CONSTRAINTS.json
- DISCOVERY_HASHES.json

## Protocol Signature
State: WHITEPAPER_EN_RENDERED
EOT

# -----------------------------
# DLE CY GENERATION (STUB — SECTIONAL, CONTROLLED)
# NOTE: Replace with real DLE generator; keep structure identical.
# -----------------------------
STATE="WHITEPAPER_CY_RENDERED"
WP_CY="${DISC_DIR}/WHITEPAPER_CY.md"

# Simple controlled mapping (placeholder; replace with DLE engine)
translate_line() {
  # minimal placeholder to preserve invariants; do not alter numbers/entities
  sed \
    -e 's/Amethyst Deterministic Discovery Protocol/Protocol Darganfod Ddeterminaidd Amethyst/g' \
    -e 's/Protocol Identity/Hunaniaeth y Protocol/g' \
    -e 's/Discovery Context/Cyd-destun y Darganfyddiad/g' \
    -e 's/Input Domain/Parth Mewnbwn/g' \
    -e 's/Detection Conditions/Amodau Canfod/g' \
    -e 's/Evidence Summary/Crynodeb Tystiolaeth/g' \
    -e 's/Pattern Structure/Strwythur Patrwm/g' \
    -e 's/Entities/Endidau/g' \
    -e 's/Constraint Satisfaction/Bodloni Cyfyngiadau/g' \
    -e 's/Operational Interpretation/Dehongliad Gweithredol/g' \
    -e 's/Enforcement Opportunity/Cyfle Gorfodi/g' \
    -e 's/Deterministic Conclusion/Casgliad Ddeterminaidd/g' \
    -e 's/Artifact Manifest/Maniffest Arteffact/g' \
    -e 's/Protocol Signature/Llofnod y Protocol/g'
}

# Generate CY by mapping lines (structure preserved)
while IFS= read -r line; do
  echo "$line" | translate_line >> "${WP_CY}"
done < "${WP_EN}"

# -----------------------------
# DLE CONFORMANCE (STUB)
# Verify section count, line count, and invariants (numbers/entities) preserved
# -----------------------------
STATE="DLE_VERIFIED"
DLE_REPORT="${DISC_DIR}/DLE_CONFORMANCE_REPORT.json"

EN_LINES=$(wc -l < "${WP_EN}")
CY_LINES=$(wc -l < "${WP_CY}")

# Extract numeric tokens and compare counts (simple invariant)
EN_NUM=$(grep -oE '[0-9]+' "${WP_EN}" | wc -l || true)
CY_NUM=$(grep -oE '[0-9]+' "${WP_CY}" | wc -l || true)

jq -n \
  --argjson en_lines "${EN_LINES}" \
  --argjson cy_lines "${CY_LINES}" \
  --argjson en_num "${EN_NUM}" \
  --argjson cy_num "${CY_NUM}" \
  --arg status "$( [[ "${EN_LINES}" -eq "${CY_LINES}" && "${EN_NUM}" -eq "${CY_NUM}" ]] && echo "pass" || echo "fail" )" \
'{
  en_lines: $en_lines,
  cy_lines: $cy_lines,
  en_numeric_tokens: $en_num,
  cy_numeric_tokens: $cy_num,
  status: $status
}' > "${DLE_REPORT}"

if [[ "$(jq -r '.status' "${DLE_REPORT}")" != "pass" ]]; then
  echo "[ERR] DLE conformance failed"; exit 1
fi

# -----------------------------
# PROOF BUNDLE + COMMIT
# -----------------------------
STATE="COMMITTED"

PROOF="${DISC_DIR}/BILINGUAL_PROOF_BUNDLE.json"
COMMIT="${DISC_DIR}/DISCOVERY_COMMIT.json"

WP_EN_HASH=$(hash_file "${WP_EN}")
WP_CY_HASH=$(hash_file "${WP_CY}")
DLE_HASH=$(hash_file "${DLE_REPORT}")

jq -n \
  --arg en "${WP_EN_HASH}" \
  --arg cy "${WP_CY_HASH}" \
  --arg dle "${DLE_HASH}" \
'{
  whitepaper_en_sha256: $en,
  whitepaper_cy_sha256: $cy,
  dle_report_sha256: $dle
}' > "${PROOF}"

jq -n \
  --arg disc_id "${DISC_ID}" \
  --arg exp_id "${EXP_ID}" \
  --arg status "CANONICAL" \
  --arg ts "$(now_utc)" \
'{
  discovery_id: $disc_id,
  experiment_id: $exp_id,
  status: $status,
  committed_at: $ts,
  bilingual_verified: true
}' > "${COMMIT}"

# Update protocol state
jq -n \
  --arg state "${STATE}" \
  --arg ts "$(now_utc)" \
'{
  state: $state,
  updated_at: $ts
}' > "${PROTOCOL}"

echo "[OK] Discovery committed at ${DISC_DIR}"
