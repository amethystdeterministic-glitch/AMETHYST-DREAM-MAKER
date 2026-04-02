def run_qc(df, genes_matched):
    qc = {}

    qc["n_samples"] = len(df)
    qc["genes_matched"] = genes_matched
    qc["score_variance"] = float(df["score"].var())

    qc["pass_sample_size"] = qc["n_samples"] >= 100
    qc["pass_gene_coverage"] = genes_matched >= 20
    qc["pass_variance"] = qc["score_variance"] > 0

    qc["TECH_PASS"] = all([
        qc["pass_sample_size"],
        qc["pass_gene_coverage"],
        qc["pass_variance"]
    ])

    return qc
