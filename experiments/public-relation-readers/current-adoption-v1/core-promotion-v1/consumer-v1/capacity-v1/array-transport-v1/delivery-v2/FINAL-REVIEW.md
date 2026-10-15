# #43 array-transport-v2 final review

**Verdict: PASS for the bounded delivery packet.** This review is bound to producer commit `504db0d0ed77b6d8cba64eed3c1dce661e524966` in `parity-43-js-array-transport-sparse`. The integration selection is exactly the 14 paths in `delivery-v2/OWNERSHIP.json` (SHA-256 `30fef006e748077a795db5466f1800605a472075db68de2bee8954ce47e631ac`); unrelated, untracked experiment history remains outside that selection.

The retained packet joins are consistent: DELIVERY `135400a4f228e2df935163102b1b437faaa7f96c82086df0fbd09a1eb774b824`, MANIFEST `cc094f78c00d7ddbff8c61ace902f336842a36c630d159a381bbb97e903b14d2`, EVIDENCE.zip `e21ccf9c01f5508197c9226c167151bc518c665ef2fe84c5fb59721ff60dd7a0`, RESULT `976bed3f954bec39fb7d49b8cfefdf480a91959bf5789b146347fd081b382b1e`, and verifier `090671727e14894c3d0474691ae812ec96f5f64c7581cf62ccf3bff6e90884ab`. I independently ran `python3 verify.py` and `python3 verify.py --selftest`; both passed. The verifier covers 155 archive objects and 195 logical paths. Its self-tests reject a same-basename stream from the wrong role directory and altered stream hashes.

The source change is a bounded output-shape adapter: it groups the existing lifecycle and mixed observations in a singleton `Array<LifecycleMixed>`, and transports nonempty power-of-two sequences as complete arrays while preserving other sequences as full lists. The inverse restores the prior report shape and sequence wire. The source identity map retains the 41-source closure, maps all 107 inherited constructor identities, and identifies the added transport constructors. No shared ECS source changes. The retained source-check transcript is provenance only, not a proof claim.

Fresh v2 JS and Native runs each emitted the complete 252,206,150-byte output and matched the independent source-derived oracle (SHA-256 `68690efc7af836ff49eebc6e4dd99f73f09f106430571ea919a507920ec4823f`). The pinned command order, caps, tools, output streams, artifacts, and guard progression are joined in the packet. The independent oracle did not consult runtime output; its inverse recovers the 244,722,906-byte predecessor wire (SHA-256 `aab843ba201e4514a51737be82f960d38feb912bc37bfda099cd63eafc14fcc9`), and the archived predecessor bytes are checked. The v1 Native arity failure remains explicitly incomplete history. The reused #42 evidence is limited to its independently created, same-schema foreign-operation/queue-preservation boundary; it is not a new #42 run or full #42 qualification.

This establishes one bounded, full-capacity JS/Native consumer result, not full #43 acceptance. Complete feature-specific TS parity and timing/scaling, the unchanged #28 regression gate, and the remaining issue acceptance criteria stay open. No performance, production-adoption, universal proof/refinement, or global authority/identity conclusion follows.


# #43 array-transport-v2 relocation repair review

**Verdict: PASS for the relocation-only successor.** Bound to commit `e406b41ca3fe16e925e3a63ce09dae747826fdb9` in the producer worktree. The change is limited to `DELIVERY.json`, `OWNERSHIP.json`, and `verify.py`; source, plans, receipts, manifest, archive, oracle and backend artifacts are unchanged.

The delivery and ownership files now distinguish the producer’s absolute paths from the 14 canonical repository-root-relative paths selected for integration. The verifier derives each local path from the declared producer root and rejects noncanonical paths, duplicate mappings and symlink escapes. Its active packet verification calls this local-selection check before validating archived plans, receipts, streams and guards. Hashing is performed on the local copy, while each `sourcePath` remains bound to the producer path.

I ran the ordinary verifier and `--selftest` on the successor; both pass. The self-test copies all 14 selected files to a temporary checkout at the same relative location, validates the relocated selection, confirms the producer README remains unchanged, then alters the copied README and requires a local metadata-mismatch rejection. This verifies that the original producer file cannot mask local drift.

Exact successor bindings: DELIVERY `846eff7d4b0b126c0e871c35238b3dde7d5ede4e8e20c2c604860dcc7d828eea`; OWNERSHIP `45e04cd5d0a8a87852c3328e14751f783a68d6ad8b3b949e558702e17e8b0937`; verifier `9606ba77dbf08c6d3e552a54a59bb8d836341d8585cae677d87395c334a13d19`. The EVIDENCE.zip and MANIFEST remain `e21ccf9c01f5508197c9226c167151bc518c665ef2fe84c5fb59721ff60dd7a0` and `cc094f78c00d7ddbff8c61ace902f336842a36c630d159a381bbb97e903b14d2`.

This fixes portable ownership validation only. It adds no runtime evidence or broader #43 acceptance.
