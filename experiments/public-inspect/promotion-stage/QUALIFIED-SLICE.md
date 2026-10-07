# Qualified Inspector query methods and stateless Check slice

This owned candidate adds `each`, `get`, `single`, `single_optional` and a nominal cursor-free Check frame. It has complete current two-schema actual TS and Bend IO output evidence, standalone emitted JS and Native baselines, six matched source confinement controls, and a reached JS reader-consumption mutation. It is a focused promotion candidate; #54 is not closed and shared `src/ecs` has not been edited. Earlier COVERAGE/PLAN development entries describe their frozen historical stage, not current pending status.

## Exact reader and clock behavior

Pinned `Runtime.ts:1695–1703` executes the Inspector projection, then assigns its own `reader.lastRun = world.advanceTick()` and updates its own stream reader. This success consumes the Inspector's previous window and advances the physical world tick. It does not consume another System's reader. The candidate `inspect.bend` successful path calls actual `W.advance_clock` and records the returned clock in its own `Instance`; the callback retains and returns the actual affine World. No whole-world tick noninterference claim applies to Inspector evaluation.

Pinned `Runtime.ts:1172–1176` evaluates a Check projection directly. Its comment states: “evaluating it never advances the world tick or any reader position.” Candidate `condition.bend` invokes the rank-two Bool callback on a nominal Frame containing the actual World, without Inspector cursor/registration/tick machinery. The finite diagnostic fixture compares the complete actual preloaded World before and after this Check boundary, including every diagnostic field. Snapshot observation, preload/record writes and System dispatch happen outside that read-only boundary and are explicitly excluded from feature timing. The entire instrumented Schedule condition is not claimed unchanged.

## Evidence and limits

All commands used exact frozen inputs, raw logs, CPU5, private environment/config guards, and the shared heavy lock. Source checks used cap5; emission cap30; approved private Clang19 compilation cap120; runtime cap5, Native one thread/GPU off. Ordinary owned-tool probes are individually retained where admitted. Source PASS is feasibility only, not law/proof/verdict evidence.

| Evidence | Frozen plan | Result and exact scope |
|---|---|---|
| Actual pinned TS | `41bfe831` | Two complete independent query/cardinality/check JSON oracles passed, both schemas |
| Pure Check source | `9448b52b` | Safe source feasibility; genuine Sys.register/Sys.identity/Sch.build/Sch.run/Sys.run consumer |
| CLI generated-JS IO | `4c01b723` cardinality raw plus `6f0d1ad1` check | Full original 74/84 String lines plus exact IO.print LF; containing `4c01` cohort remains INCOMPLETE |
| Standalone JS | `fc18c29f` | Four emit/runtime subjects passed full 74/84-line two-schema oracles; 45 execution probes |
| Native baseline | `5fa99a47` | Six emit/compile/runtime subjects passed the same complete outputs; 65 execution probes |
| Matched source siblings | `0d3095e3` | Owner/query/read source5 each passed |
| Source negatives | `ea29a27d`, `923ed0b0` | Six actual exit1 typed/quantity refusals, separately classified; raw receipts retain pending-diagnostic-review status |
| Pure mutant source | `0fa9aeff` | Successful source5 compilation of pure cardinality main; no runtime/proof credit |
| Reached JS cursor mutant | `c228dcd1` | Emit/runtime exit0; complete independent defect output equals raw and differs from original at twelve semantic query lines; 25 execution probes |

Original full baseline cardinality IO stdout SHA256 is `9ad67109de3094164dbd73ff3a916b8550ec5e8687b7fcad647f7dcbce64832e`; check is `e297ae2d2d2e223fc8a83dd692e1325f85a7a978e8fbbb3408b9664cdb06d9e9`. The JS mutant stdout is `7e7263f87aeb5f225e13bb4dcc8b663a943524e93c7b408ffd69c91714d45221`. Successful observation preserves the prior reader cursor in this mutant while still executing the actual callback and `World.advance_clock`. Both schemas' one-repeat/many/many-repeat `added` and `changed` rows, get tags and single/singleOptional cardinalities differ at lines 23,24,29,30,35,36,60,61,66,67,72,73. Complete output equals the independently authored defect model; no framing-only disagreement, unrelated failure, or timeout counts as a kill. Native mutation was not executed or inferred.

The six negative targets are undeclared concrete grant versus abstract owner, foreign abstract owner, query read grant used as write grant, Check ValueRead used as write grant, duplicated affine owner, and owner returned as String. Each diagnostic identifies the intended operation/type/quantity and has an exact successful sibling join. Other prepared schema/lifecycle/event exclusion files remain unexecuted and receive no acceptance credit.

Missing-resource evidence records actual Check.run refusal before the callback/projection. The driver's manual Schedule resource preflight is distinguished from actual Sys runner rejection; no manually constructed branch is relabelled as a system rejection. All registration/World/argument owners are retained on refused paths. Snapshot/reprojection checks compare complete actual rows and resource cells; expected literal output is not used as the callback predicate.

The pure term_snf runtime deadline remains INCOMPLETE and is not rerun or counted. The original Bool.show formatter mismatch remains INCOMPLETE; only source-backed diagnostic spelling was corrected in the additive oracle-v2. Existing query/resource and real retainer success/disposal/failure/skip capsules are selected by their original delivery manifests, byte-bound and retained without replay or relabeling.

## Promotion handoff

The portable capsule contains full source/input/oracle/raw/generated-JS/C/probe/receipt bytes and selected older evidence, with content-addressed objects and a path-independent integrity verifier. Private environment raw bytes and executable/tool binaries are excluded and remain hash-only local qualification requirements. The verifier checks bytes; it does not confer semantic or mathematical acceptance.

Independent final Spec/Standards review and an exact owned selected commit are pending. Root alone reviews/integrates any common Frame/provisioning interface into shared core and runs unchanged #28 on the combined result. Foreign Inspector instance/held-view/service alias policies remain unselected. Full public Inspector declarations/reflection, heterogeneous selectors/with-without, remaining category integration, throw/retry and equivalent feature timing/scaling/full #54 gates remain outside this slice; machine/relation extension is #55.
