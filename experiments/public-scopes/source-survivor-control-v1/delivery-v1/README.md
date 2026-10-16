# Source-level persistent survivor control (#45)

The unchanged ordinary Scene consumer and a single Bend-source fault compile and
run on stock JS and Native -O3. Both normal outputs match all 2,328 independently
derived bytes; both mutated outputs match all 2,310 counter-oracle bytes and
reject the complete normal oracle. The fault appends persistent entity 2 to the
scope cleanup list. No generated-code mutation is used by these runs.

The packet retains all 78 Bend inputs per variant, two foreign sidecars, exact
source difference, independent source-derived models and snapshots, complete
raw outputs, generated code/binaries, plans, guards and receipts. Pure scope
checks pass; whole IO entries retain the expected foreign-effect proof verdict.
No consumer stderr was produced. Limits remain emit 30s, Native build 120s,
runtime 5s. Scene-only coverage here does not replace the larger scope suite.

This changes no production core or #28 workload; comparative timing remains in
combined qualification. This packet alone makes no full-issue or performance
claim. Run `python3 verify.py --selftest` offline for full verification, exact
stream-parent negative controls and relocated-file drift detection.
