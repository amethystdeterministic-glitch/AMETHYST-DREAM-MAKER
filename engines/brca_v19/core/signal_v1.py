def apply_signal_v1(df):
    """
    SIGNAL_V1 — REAL DATA VERSION

    Using actual dataset columns
    """

    # === SIGNAL DEFINITION ===
    df["SIGNAL_V1"] = df["GENE1"]

    # === GROUP SPLIT ===
    median = df["SIGNAL_V1"].median()
    df["group"] = (df["SIGNAL_V1"] > median).astype(int)

    return df
