"""Exact nonparametric paired regression decision; no third-party dependencies."""
import math
import statistics


def assess(rows, pairs, alpha):
    if pairs < 20 or not 0 < alpha < 1:
        raise ValueError("Invalid statistical contract")
    endpoints = {}
    for backend in ("JS", "Native"):
        selected = [r for r in rows if r["backend"] == backend]
        if len(selected) != pairs or {r["pair"] for r in selected} != set(range(pairs)):
            raise ValueError("Missing/duplicated pairs")
        differences, ratios = [], []
        for row in selected:
            before, after = row["baselineMs"], row["candidateMs"]
            if any(isinstance(x, bool) or not isinstance(x, (int, float))
                   or not math.isfinite(x) or x <= 0 for x in (before, after)):
                raise ValueError("Invalid timing")
            differences.append(after - before)
            ratios.append(after / before)
        nonzero = [d for d in differences if d != 0]
        slower = sum(d > 0 for d in nonzero)
        n = len(nonzero)
        probability = sum(math.comb(n, k) for k in range(slower, n + 1)) / 2**n
        endpoints[backend] = {"nonTiePairs": n, "slowerPairs": slower,
                              "pValue": probability,
                              "medianPairedRatio": statistics.median(ratios),
                              "confirmedRegression": False}
    # Holm step-down controls the family error rate for both tested backends.
    for rank, (backend, result) in enumerate(sorted(endpoints.items(), key=lambda item: item[1]["pValue"])):
        cutoff = alpha / (len(endpoints) - rank)
        result["holmCutoff"] = cutoff
        if result["pValue"] > cutoff:
            break
        result["confirmedRegression"] = True
    return {"status": "REGRESSION" if any(r["confirmedRegression"] for r in endpoints.values())
            else "NO_CONFIRMED_REGRESSION", "endpoints": endpoints}
