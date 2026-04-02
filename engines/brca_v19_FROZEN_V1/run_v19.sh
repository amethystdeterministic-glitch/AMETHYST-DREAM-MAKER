#!/data/data/com.termux/files/usr/bin/bash

set -e

cd ~/repos/odin_os/engines/brca_v19

echo "[RUN START]"

python3 core/phase_a_reference.py test run
python3 core/phase_b_anchor.py test run
python3 core/phase_c_compendium.py test run
python3 core/phase_d_meta.py test run

echo "[DONE]"
