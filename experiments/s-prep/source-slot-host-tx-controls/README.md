# Fresh Slot Host typed-cursor transaction controls

Finite diagnostic gates pass on frozen source29 `4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c`. These exercise the actual private typed-cursor row wrapper and FlatPair transaction path with supplied namespace/ID, not cursor enumeration, generic Host dispatch, universal refinement or all22 gates.

- Eight cached/raw, Motion/Health, normal/suppressed programs:576 complete records per backend. JS and O3 Native match the unchanged independent protected-write and suppressed-owner oracles.
- Four compiling live mutations,16 schema/observer cases: stale cached head, torn cached tail, omitted change mark, reversed actual flat rollback. Cached observers detect all four; raw observers detect mark/rollback corruption. Raw getters do not expose cached-only head/tail corruption.
- Reversed rollback produces the same corrupt result through both getters: the paired comparison reports zero, while the independent oracle and baseline full-record comparison detect it. No stronger oracle claim is made.

Limits: checker15s (approved executable diagnostic only), emit30s, private Clang19 O3 build120s, runtime5s, CPU5, Native one worker/GPUoff. Default/proof checker remains5s. No laws/proofs, dependency, compiler/kernel or reference changes.

Reproduce from the frozen Slot source with:

```sh
python3 experiments/s-prep/source-slot-host-tx-controls/run.py --output /tmp/fresh-slot-tx
python3 experiments/s-prep/source-slot-host-tx-controls/mutants.py --baseline /tmp/fresh-slot-tx --output /tmp/fresh-slot-tx-mutants
```

The retained successful mutation execution used `--reuse /tmp/bendvy-slot-host-tx-mutants-v2` for three byte-identical subjects, verifying source, fixture, program, command and observation hashes before reuse; the corrected flat rollback subject was compiled/executed fresh. This is not transfer from another source or approval of the failed aggregate.

`evidence.tar.gz` contains deduplicated source, generated JS/C, exact commands, output records and receipts from baseline v2 and mutation v1/v2/v3. Its adjacent manifest maps original evidence paths to decoded SHA256 blobs; native executables are hash-pinned but omitted. Decoded bytes were independently checked after archive creation. `status.json` contains the bounded result and observer-specific witnesses.

Failures are preserved: invalid CPU12 preparation (no checker ran), v1 overstrong raw-observer expectation, v2 mutation of generic rollback unused by this fixture. They were corrected without changing the frozen source or original independent oracle. Full capability/refinement/API/performance acceptance remains open; these results are specific to this source and route.
