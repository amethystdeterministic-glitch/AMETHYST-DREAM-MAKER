#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os/amethyst/arm_apk_engine_v6"
DISC="$HOME/repos/odin_os/artifacts/apk_parse_discovery"

mkdir -p "$DISC"

cat > "$DISC/MISSION_OBJECTIVE.json" <<'JSON'
{
  "mission_id": "APK_PARSE_DISCOVERY_V1",
  "objective": "Determine the minimal manifest/build configuration that produces a successfully installable APK on the current Android device using the existing Termux manual toolchain.",
  "constraints": [
    "keep existing compile/dex/package/assemble/sign pipeline",
    "no Gradle",
    "no aapt2",
    "one variable change per iteration",
    "record every outcome",
    "no freeform experimentation"
  ],
  "success_condition": "APK installs successfully on device",
  "failure_condition": "All controlled hypotheses exhausted without install success"
}
JSON

cat > "$DISC/HYPOTHESIS_QUEUE.json" <<'JSON'
[
  {
    "id": "H1",
    "title": "Minimal explicit manifest",
    "change": "application + activity only, no launcher intent, no exported, no label"
  },
  {
    "id": "H2",
    "title": "Add launcher intent filter",
    "change": "Add MAIN and LAUNCHER intent filter to MainActivity"
  },
  {
    "id": "H3",
    "title": "Add application label",
    "change": "Add android:label=@string/app_name to application"
  },
  {
    "id": "H4",
    "title": "Add exported flag",
    "change": "Add android:exported=true to launcher activity"
  },
  {
    "id": "H5",
    "title": "Fully qualified activity name",
    "change": "Use com.amethyst.v6.MainActivity instead of .MainActivity"
  },
  {
    "id": "H6",
    "title": "aapt sdk flags",
    "change": "Add --min-sdk-version and --target-sdk-version to aapt packaging command"
  }
]
JSON

cat > "$DISC/ITERATION_LOG.jsonl" <<'EOFLOG'
EOFLOG

cat > "$DISC/CURRENT_STATE.md" <<EOFMD
# CURRENT STATE

## Root
$ROOT

## Verified pipeline state
- compile: pass
- dex: pass
- package: pass
- assemble: pass
- sign: pass
- install: fail ("There was a problem while parsing the package.")

## Current discovery mode
- heredoc-only
- one variable change per iteration
- manual install verdict captured by user
EOFMD

echo "DISCOVERY_INIT_COMPLETE"
echo "ARTIFACTS=$DISC"
