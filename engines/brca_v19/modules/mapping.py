def map_genes(requested, available):
    mapped = []
    missing = []

    for g in requested:
        if g in available:
            mapped.append(g)
        else:
            missing.append(g)

    return mapped, missing
