#!/data/data/com.termux/files/usr/bin/bash

echo "===== CURRENT LOCATION ====="
pwd
echo

echo "===== ROOT LISTING ====="
ls -la
echo

echo "===== CHECK CORE PATH ====="
ls -la core 2>/dev/null || echo "NO core DIR"
echo

echo "===== CHECK PILGRIM ====="
ls -la core/pilgrim 2>/dev/null || echo "NO pilgrim DIR"
echo

echo "===== CHECK MODULES ====="
ls -la core/pilgrim/modules 2>/dev/null || echo "NO modules DIR"
echo

echo "===== CHECK AIL_KERNEL ====="
ls -la core/pilgrim/modules/ail_kernel 2>/dev/null || echo "AIL_KERNEL NOT FOUND"
echo

echo "===== AIL FILE TREE ====="
find core/pilgrim/modules/ail_kernel -maxdepth 3 -type f 2>/dev/null | sort || echo "NO FILES"
echo

echo "===== SEARCH GLOBAL AIL ====="
grep -R "ail" -n . 2>/dev/null | head -n 50 || echo "NO REFERENCES"
echo

echo "===== DONE ====="
