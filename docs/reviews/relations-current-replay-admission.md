# #42 current Query/lifetime replay admission review

Reviewed HEAD `26316f52e6d1b0bcd1dac34a2c61a0d36a435ef1` and preflights `query-1791371054773342723` / `lifetime-1791371048586911394`. Read-only; no backend execution. All 491/449 input pins and every recorded staged source hash match. Both stage sets include current WorldIO C/JS assets, current World/System sources and unchanged original fixtures/oracles. Historical receipts were not substituted.

Backend admission is **held** pending these guard repairs:

1. Both runners compute mutant inventories/hashes after writing mutant bytes. Plan exact variant bytes, changed-key singleton and full inventory from pinned originals before copying/writing; verify the resulting stages against those prospective plans. Current inventories are retained observations, not pre-write checks.
2. Both inventory functions ignore unexpected stage files outside `.bend` and `src/ecs/*.c/*.js`; configuration presence/absence is not guarded at stage/root/cwd ancestors. Require exact file membership with explicitly planned generated outputs, plus prospective `check.json`/`bender.json`/`bend.json` configuration state. The installed check file alone does not cover newly appearing configuration.
3. Both installed-tool helpers execute `ldd` through `subprocess.run(timeout=5)` rather than the reviewed owned-descendant supervisor. Use the same finite descendant cleanup policy for these consumed tool-discovery commands before admission.
4. Query has no prospective unique command-label plan or explicit merged-text capture declaration. Its sequential indexed logs are guarded but do not satisfy the requested prospective label contract. Lifetime already has 41 unique planned labels and honestly declared raw merged capture.

For the intended negatives, both runners bind the expression/line and type words but accept any caret. Bind the exact staged diagnostic caret column/length as in the reviewed #46 capture boundary; retain full diagnostics with the actual declared channel semantics.

The semantic fixtures and old oracles were not changed by these wrappers. Fixing these evidence boundaries does not approve relations production semantics, laws/proofs or performance. A fresh repaired preflight must be independently reconciled before backend execution.

## Guarded-v2 reconciliation

Fresh preflights `guarded-v2/evidence/query-1791371345978671899` and `lifetime-1791371348292098613` resolve the findings above. All 495/452 input pins match current files. Each runner retains five prospective byte-derived stage plans before stage writes, and every complete stage inventory matches its plan, including the current WorldIO C/JS assets. Original fixtures, literal oracles and mutation subjects are unchanged.

Both runners now enforce exact stage membership, allowing only explicitly planned generated outputs; stage/root/cwd ancestor configuration states are retained and rechecked. Installed tool discovery uses the locally pinned raw owned-descendant supervisor with a five-second cap and an explicit ldd executable pin. Both have 41 unique prospective command labels and immutable raw merged-byte logs, honestly recording the synthetic empty stderr channel. Native remains one thread/GPU off; checker/runtime caps remain five seconds. Exact negative expression/caret spans are selected from the pinned staged source, with full diagnostics retained.

**Bounded backend replay is admitted for these exact guarded-v2 sources and unchanged fixtures/oracles.** No backend was run by this review. The old preflights remain held historical evidence; no passing result is transferred to them. Fresh actual TS/JS/Native controls and reached mutations still must execute. This admission does not approve production integration, laws/proofs, universal runtime refinement or performance acceptance.
