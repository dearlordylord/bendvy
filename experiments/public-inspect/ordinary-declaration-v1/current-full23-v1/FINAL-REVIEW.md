# Independent #54 Spec / Standards review

Status: **reviewed #54 delivery and required integration gates pass**.
This is one review with the combined regression, compiler-compatibility, integration
and CI results appended. Issue closure remains the coordinator's action.

## Reviewed boundary

- Live [issue #54](https://github.com/dearlordylord/bendvy/issues/54),
  `docs/parity/inspect.md`, `docs/SPEC.md` and `CODING_STANDARDS.md`.
- ECS diff: `e9096051b8f659a07e6ae5013569d07e5cca5144` to `8b82b0145`;
  only `inspector-query-projection.bend` and `inspector-query.bend` are changed.
  Delivery manifest `9da3442d8` binds the qualified source to combined
  `2a414174b82a9314d7c55cd5872ec43383732c13` with 30/30 exact core bodies.
- Independent model `32d05a7d7937559c2b92e1fdcd87d887c07fc630`;
  source author and model author are separate from this reviewer.
- Reference authority remains Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`,
  Bend `a950fd683c0d76f09794078e6174fe98a1492876`, then TS feature inventory
  `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`. No new contract, law or proof is approved here.

## Standards

**No demonstrated code defect or documented-standard violation in the reviewed change.**

Runtime callback forwarding extracts the same declared callbacks without executing
projection early. Matching retains left-to-right short circuiting; constraints
check selection before predicate; paired projection threads the returned affine
owner left-to-right; mapping follows projection. Lookup validates first, matches
second, then projects. Scan preserves target and output order.

Outer `pair`, `both`, `constrain`, `map`, selection/predicate and composed-query
signatures and constructor layouts remain. The sixteen exported worker signatures
change; the compatibility limitation is real and documented. I independently
checked all 548 canonical **import records across 390 distinct files** and found
zero qualified calls to those changed workers. This is not an unknown-external-client
compatibility guarantee.

The opaque `H:Type` owner and nominal schema/handle types remain carried through
the APIs. Detached `Data` projections do not impose a Data-only component-owner
restriction or expose mutable owners. Trusted presenters/lenses are not universally
proved pure. Affine usage is not claimed to establish exactly-once cleanup or Rust
Drop semantics. The five fresh controls reject undeclared selection, cross-schema
grant, opaque-owner escape, write-through-read and duplication for their intended
primary type/quantity reasons; parse, arity and missing-symbol errors are excluded.

## Spec and execution evidence

The current ordinary consumer retains all 23 drivers (14 Inspector declarations,
nine stateless Check grants), both nominal schemas, five phases and same-instance
retries. Seventeen non-import bodies remain exact; six adapt full keys or complete
physical observation. I reproduced the independent model's 70 public logical
records and its complete **6,731,751 bytes**, SHA-256
`9a0c40434386a57ff2f29cdd0853c110fb1a7e84575914649e8bb8892f550159`.
No result projection, digest-only comparison or output normalization is substituted.

Offline verification of `runtime-v1/actual-attempt01` and
`selected-tool-v1/runtime-v1/actual-attempt01` checked all retained objects, plan
pins, raw stream hashes, unchanged guards, terminal receipts and complete oracle
joins for four actual roles: stock JS, private cache-candidate Native, selected
wrapper JS and selected wrapper Native. Every required command in those completed
roles exits zero; consumer stderr is empty. Selected Native C is bound as byte-equal
to the previously qualified candidate artifact. Historical stock Native emit30
failures, aborted work and diagnostics retain their actual verdicts: **stock Native
full23 is not qualified**.

The selected compiler is the existing pinned ELF, an exactly reversible nine-edit
CLI recipe and a project-local wrapper/config successor. The unique embedded CLI
prefix, original 333,165 bytes, selected CLI
`ddb0fd6ead0d442a19c257f15628af8b91cd083439c1b7ca02d0e656171d408f`,
70 installed Base/effect inputs, wrapper mode755, underlying-ELF library discovery
and actual wrapper version/check/emit paths are bound. No system install, dependency
or historical shared-config edit is implied. Installed-resource alias changes were
followed by the actual selected JS/Native pair, not source-only reuse. Launch
label and sampler alias defects were corrected in preserved successors before
execution. Cache review includes both live-cell invalidations, per-book reset,
unchanged structural keys/recursive placeholder and captured-map memo semantics;
finite controls are not a universal compiler theorem.

The delivery manifest's 1,326 members were independently verified against SHA-256,
Git blob identity, executable modes and all 18 literal symlink targets. Root must
preserve those modes/targets when materializing; original execution paths remain
provenance, not a claim that receipts ran in the destination checkout.

## Acceptance joins and integration gates

1. **Shared TS and reached reader-consumption applicability: accepted within the
   retained primitive scope.** Applicability commit `624bd6fb7`, record SHA-256
   `86a4a462dc9715bdc455de90af963097664aa47c55ae8451688a969328da8e7f`,
   binds the historical paired-writer TS packet and actual reader counter to the
   current call paths. I checked all 36 unchanged TS reference bodies, archive
   integrity, Node24.20 plan/receipt and full546,520-byte EXPECTED-plus-LF equality
   with empty stderr. The current component literal remains exact `73d269167d7bffa03843b62eb179121a72d6386794a55e5ff9fcd8cf2b0b38fa`.
   This covers shared rows, payloads, cardinality, Check dispatch and writers;
   physical clocks, owners, registries, storage and full-key encoding remain outside
   TS comparison. It is retained execution reuse, not a fresh Node run.

   The reached counter changes public Getter restoration from putting the stream
   back to advancing it before put. Both archived stock backends produce the full
   independent211,671-byte counter and reject the complete211,157-byte normal
   oracle; receipts, streams and empty stderr were checked. Current Getter,
   binder, stream, event and capability bodies match; changed notice wrappers have
   exact selected/take/put and family bridges. I independently checked the recorded
   function joins at combined `2a414174b82a9314d7c55cd5872ec43383732c13`
   as well as the record's later `9fec2186122e4920419fa103373b067e6c074f7b`.
   This is primitive-operation applicability, not old full-closure/current physical
   wire equality or a fresh current mutant execution. The unused full23
   omit-projection option and five authority refusals are not runtime mutants.
2. **Unchanged combined #28:** retain its original workload, baseline, statistics,
   caps and full correctness observations. Focused selected-tool launch binding
   review is **conditional PASS**, not an actual regression result: child binding
   `56f2d94501672ac42b3a317bdf1a74e23ecb219b58c9f70b59107facec6400e9`
   has 383 exact direct pins, 351 monitored inputs and 14 archived workload inputs.
   The absolute existing runner selects the combined ROOT; PATH selects the
   reviewed wrapper and pinned Node. The unchanged contract retains two warmups,
   twenty balanced pairs, whole-process timing and complete ten-application JSON
   observations. Coordinator binding `7ea8d9911aa182f432c7860a049ed61871e46c68588a7b90facf81c03ef03b30`
   is exactly `/usr/bin/flock /tmp/bendvy-parity-heavy.lock` plus that child argv;
   the binary hash is exact and the runner has no internal heavy lock. Root must
   retain fresh CPU11/host/exclusive-queue checks and extra tool/resource pre/post
   guards. The inherited 349-resource set was inspected as binding metadata, not
   freshly swept by this reviewer. Completed default cohort is now independently
   checked: receipt `18a730c1582889521ea264d57a0565e572269be3a4f044ec3efe41fe03ae7604`,
   123 zero-exit commands, 110 retained complete outputs (1,100 applications),
   forty backend pairs and `NO_CONFIRMED_REGRESSION`. Every retained JSON line
   equals the frozen expected observation with the existing foreign-reference
   exclusion. Coordinator postguard reports all383 pins and349 resources exact.
   This is whole-process protected-workload evidence, not full Inspector timing.
3. **Same-source stock versus selected compiler runtime compatibility:** a default
   gate compiling both source roles with the selected CLI alone does not establish
   compiler non-regression. Retain the separate applicable comparison or exact
   artifact/branch reuse before delivery. Focused launch review of commit
   `2a053a591` is conditional PASS; cohort binding SHA-256
   `ea5a94fc08be5b4b3f30515a614fae58ce7f26d04c7b2dedeb45492fc89fd52a`.
   All396 direct pins were checked. Actual old-stock/current-selected JS artifacts
   are byte-identical (`ff38eb9061342bba1fa8539f78afe105a55c09468ec551b88a9023ffd38ec4a7`).
   Selected C equals stock C after only the two reviewed host-lookup anchors;
   Native ELFs differ. Actual artifact and source-receipt hashes join the retained
   stock57 and completed selected default cohort. Source affinity binds the same
   29-module protected program and fourteen migrated workload inputs, not arbitrary
   compiler programs. The existing retained-artifact selector differs from its
   historical body only in RUNNER path/hash; compilation-block replacement keeps
   the original complete checks, TS noise role, two warmups, twenty balanced pairs
   and decision method. Canonical outer flock, CPU11, environment and fresh root
   pre/post guards remain required. The actual comparison is now complete:
   receipt `02f8499335bec072438b92138c40f4dec2d10325c80e43088b6a64a4804ccda5`
   has 115 zero-exit commands, 110 complete outputs (1,100 applications), forty
   backend pairs and `NO_CONFIRMED_REGRESSION`. I independently checked the receipt
   hash and every retained full JSON output. Root's postguard binds all396 pins,
   349 resources and four actual artifacts unchanged. This establishes the existing
   statistical gate for stock versus selected compilation of this same protected
   current program; it is not a full Inspector or global compiler performance
   claim. Portable capture commit `84e03eaff` is now checked: the default packet
   has909 archive members and the compiler-comparison packet has1,643, each under
   `selected-tool-v1/<cohort>/runtime-v1/actual-attempt01`. I ran both isolated
   offline verifiers with only their final report-write disabled. Archive/member
   hashes, retained source/artifact/receipt joins, all110 full outputs per cohort,
   seeded balanced orders, original decision recomputation and actual root
   pre/post guard bindings pass. Compiler capture includes the actual stock and
   selected source roots/ELFs and exact JS/two-anchor C join. No backend replay
   occurred. Final integration gates are recorded below.
4. **Final integration, hooks and CI: PASS.** Read-only inspection of master
   `81316652ee2568016ce72b5f01b576c7daa7fefd` verified all1,349 manifest
   members against committed Git blobs, modes, lengths, SHA-256 and literal symlink
   targets, all30 qualified core affinities, and the exact integrated review note.
   The commit contains4,179 owned paths; unrelated working-tree changes were not
   edited or treated as delivered. Root reports actual configured hooks and owned
   path checks passed, push exited zero, and GitHub Actions run
   [39010187646](https://github.com/dearlordylord/bendvy/actions/runs/39010187646)
   completed successfully with the functional gate passing for that commit.
   These are actual destination integration results, distinct from prior source
   affinity and retained execution provenance. This final prose append introduces
   no source, tool, model or expected-output change.

Full comparative feature timing/scaling remains under #21/#23/#24. Compilation
samples are scoped instrumented-compiler evidence, not stock phase timing, JS
allocation/RSS evidence or a full-feature speed verdict. No numerical gate or
budget waiver is granted. This review does not add a held-view, borrowed cursor,
registration-liveness, arbitrary presenter-purity or new ownership policy.

## Reviewer execution limits

Only source reading and CPU9 offline hash/packet/model verification were performed.
No compiler, Node control, backend or benchmark was rerun. Existing failed evidence,
old source freezes and independent expected outputs were not edited.
