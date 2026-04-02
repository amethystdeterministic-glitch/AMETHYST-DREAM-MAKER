import sys
print("[PHASE OK]", sys.argv)

# ================================
# [PROBE] SIGNAL INTEGRITY CHECK
# ================================
try:
    import numpy as np

    if 'data' in globals():
        print("\n[PROBE] PHASE STATS")
        print("Min:", np.min(data))
        print("Max:", np.max(data))
        print("Mean:", np.mean(data))
        print("Std:", np.std(data))
    else:
        print("\n[PROBE] No 'data' variable found in this phase")

except Exception as e:
    print("[PROBE ERROR]", e)

# ================================
# [SMART_PROBE] UNIVERSAL DETECTOR
# ================================
try:
    import numpy as np

    print("\n[SMART_PROBE] SCANNING VARIABLES...")

    found = False

    for name, val in globals().items():

        try:
            # numpy array
            if hasattr(val, "shape"):
                arr = np.array(val)

                if arr.size > 0 and np.issubdtype(arr.dtype, np.number):
                    print(f"\n[SMART_PROBE] VAR: {name}")
                    print("Shape:", arr.shape)
                    print("Min:", np.min(arr))
                    print("Max:", np.max(arr))
                    print("Mean:", np.mean(arr))
                    print("Std:", np.std(arr))
                    found = True

        except:
            pass

    if not found:
        print("[SMART_PROBE] No numeric arrays detected")

except Exception as e:
    print("[SMART_PROBE ERROR]", e)

# ================================
# [SMART_PROBE_V3] STABLE DETECTOR
# ================================
try:
    import numpy as np

    print("\n[SMART_PROBE_V3] SCANNING VARIABLES...")

    found = False

    # FIX: snapshot globals to avoid mutation error
    snapshot = list(globals().items())

    for name, val in snapshot:
        try:
            if hasattr(val, "shape"):
                arr = np.array(val)

                if arr.size > 0 and np.issubdtype(arr.dtype, np.number):
                    print(f"\n[SMART_PROBE_V3] VAR: {name}")
                    print("Shape:", arr.shape)
                    print("Min:", np.min(arr))
                    print("Max:", np.max(arr))
                    print("Mean:", np.mean(arr))
                    print("Std:", np.std(arr))
                    found = True

        except:
            pass

    if not found:
        print("[SMART_PROBE_V3] No numeric arrays detected")

except Exception as e:
    print("[SMART_PROBE_V3 ERROR]", e)

# ================================
# [SMART_PROBE_V4] DATAFRAME + LIST DETECTOR
# ================================
try:
    import numpy as np

    print("\n[SMART_PROBE_V4] SCANNING VARIABLES...")

    found = False
    snapshot = list(globals().items())

    for name, val in snapshot:
        try:
            # pandas DataFrame
            if hasattr(val, "select_dtypes") and hasattr(val, "shape") and hasattr(val, "columns"):
                num = val.select_dtypes(include=["number"])
                if getattr(num, "size", 0) > 0:
                    arr = num.to_numpy()
                    print(f"\n[SMART_PROBE_V4] DATAFRAME: {name}")
                    print("Shape:", arr.shape)
                    print("Min:", np.nanmin(arr))
                    print("Max:", np.nanmax(arr))
                    print("Mean:", np.nanmean(arr))
                    print("Std:", np.nanstd(arr))
                    found = True
                    continue
        except Exception as e:
            print(f"[SMART_PROBE_V4 DF ERROR] {name}: {e}")

        try:
            # pandas Series
            if hasattr(val, "dtype") and hasattr(val, "to_numpy") and hasattr(val, "shape"):
                arr = val.to_numpy()
                arr = np.array(arr)
                if arr.size > 0 and np.issubdtype(arr.dtype, np.number):
                    print(f"\n[SMART_PROBE_V4] SERIES: {name}")
                    print("Shape:", arr.shape)
                    print("Min:", np.nanmin(arr))
                    print("Max:", np.nanmax(arr))
                    print("Mean:", np.nanmean(arr))
                    print("Std:", np.nanstd(arr))
                    found = True
                    continue
        except Exception as e:
            print(f"[SMART_PROBE_V4 SERIES ERROR] {name}: {e}")

        try:
            # numpy arrays / scalars
            if hasattr(val, "shape"):
                arr = np.array(val)
                if arr.size > 0 and np.issubdtype(arr.dtype, np.number):
                    print(f"\n[SMART_PROBE_V4] ARRAY: {name}")
                    print("Shape:", arr.shape)
                    print("Min:", np.nanmin(arr))
                    print("Max:", np.nanmax(arr))
                    print("Mean:", np.nanmean(arr))
                    print("Std:", np.nanstd(arr))
                    found = True
                    continue
        except Exception as e:
            print(f"[SMART_PROBE_V4 ARRAY ERROR] {name}: {e}")

        try:
            # plain python lists/tuples of numerics
            if isinstance(val, (list, tuple)) and len(val) > 0:
                arr = np.array(val, dtype=float)
                if arr.size > 0:
                    print(f"\n[SMART_PROBE_V4] LIST: {name}")
                    print("Shape:", arr.shape)
                    print("Min:", np.nanmin(arr))
                    print("Max:", np.nanmax(arr))
                    print("Mean:", np.nanmean(arr))
                    print("Std:", np.nanstd(arr))
                    found = True
                    continue
        except:
            pass

    if not found:
        print("[SMART_PROBE_V4] No numeric structures detected")

except Exception as e:
    print("[SMART_PROBE_V4 ERROR]", e)
