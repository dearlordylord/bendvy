# Actual admitted acquisition v2: incomplete

The exact independently admitted plan `18957d17…` ran once through the original session 11303 and terminated with exit1: `TimeoutError: child deadline`. The owned CPU5 acquisition worker used the unchanged outer metadata cap5. No retry or cap increase occurred.

All 24 archived members are losslessly verified, including original plan, exact executed helper/caller/preparation bytes, unconditional receipt, empty outer raw streams, four source/plan guards and `inner/started.json`. Post/final guards retain the same started artifact and all source pins unchanged. The receipt is explicitly INCOMPLETE, with no guard failures and returned supervisor failure `child deadline` / exit null.

No complete probe-result artifact or acquired resolver snapshot exists. The started marker confirms the worker reached acquisition setup after metadata/resource-membership and historical tool validation; it does not identify the exact hashing/discovery operation at cutoff. The substantial existing hash scope remains unchanged. This result does not admit a resolver or demonstrate an installed-tool incompatibility.

Run `python3 verify.py` to check complete archive membership/digests, original command/cap/source bindings, raw result, four guards and exact partial output membership without children. Compiler/simulation/Native runtime stages were not launched.
