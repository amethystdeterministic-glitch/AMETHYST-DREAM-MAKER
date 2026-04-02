import sys

required = ["numpy","pandas","scipy"]

missing = []
for pkg in required:
    try:
        __import__(pkg)
    except:
        missing.append(pkg)

if missing:
    print("[ERROR] Missing packages:", ",".join(missing))
    print("Install with: pip install numpy pandas scipy")
    sys.exit(1)

print("[ENV] OK")
