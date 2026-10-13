# Protected #28 regression final review

Verdict: **PASS** for the bounded protected-cohort evidence packet.

Packet commit: `14f30e097c8992d1c2dcca5f7bdd2af0a6a99b6e`.

- `EVIDENCE.zip`: 4,256,114 bytes, SHA-256 `49a0bf32b7f57a7f89f507231ba547585964eec0a0b7fa3b09fd873ab2ca1b09`.
- `DELIVERY.json`: SHA-256 `d12aff7294211ac53cb372a388a06ba1adc04b3508f0ab546f3b615ece9f1d3f`.
- Existing `verify.py.source` completed with PASS: 739 archive members, 110 decompressed streams, and 1,100 complete applications compared.
- Result, outer/cohort receipt, stdout/stderr, plan, launch, quietness, and archive joins all pass.
- Corrected `LAUNCH.json` SHA-256 is `62cce0e347c8c1eb6870c1b757c78f8df65ffaa3939c89c69167d84a1b834b54`; it executes the pinned worktree boundary wrapper, SHA-256 `a32c1e74a5862ee468f6b3e38a2d102e2ebe4ee8650a9f8e7ed810e3b617f050`.
- The superseded root-wrapper proposal remains preserved as `LAUNCH.json.root-wrapper-proposal.source`, SHA-256 `f4e06767598e46ed257058d823e4cce4e5a09d80371983b7bb4e229c53c9410c`.
- Recorded decision is `NO_CONFIRMED_REGRESSION`: JS and Native each have 4/20 slower pairs, with `p=0.9987115859985352`; median paired ratios are 0.8805230205778194 and 0.923028712140922.

Scope is the protected same-copied-`f259` whole-process source regression, including startup and output. The evidence does not establish isolated compiler overhead, feature timing, adoption, speedup, or #54 closure.
