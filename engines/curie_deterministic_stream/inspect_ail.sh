#!/data/data/com.termux/files/usr/bin/bash

echo "===== CURRENT LOCATION ====="
pwd
echo

echo "===== ROOT LISTING ====="
ls -la
echo

echo "===== AIL KERNEL PATH ====="
echo "core/pilgrim/modules/ail_kernel"
echo

echo "===== AIL KERNEL DIRECTORY ====="
ls -la core/pilgrim/modules/ail_kernel 2>/dev/null || echo "AIL_KERNEL NOT FOUND"
echo

echo "===== AIL FILE TREE (DEPTH 2) ====="
find core/pilgrim/modules/ail_kernel -maxdepth 2 -type f 2>/dev/null | sort || echo "NO FILES"
echo

echo "===== SEARCH REFERENCES TO AIL ====="
grep -R "ail" -n core 2>/dev/null | head -n 50 || echo "NO REFERENCES"
echo

echo "===== DONE ====="
