# Canonical Sparse runtime: final source and evidence review

Bounded Spec/Standards result: PASS for Motion and Health Sparse correctness at
64,256 and1024 entities, each with64 iterations. This is not full #21 acceptance
or a timing/performance verdict. Root integration hooks and CI remain delivery
steps after this review.

Reviewed consumer source is Motion52f8f3c0ac43324c27222ca30e27bc987e57fe95 and
Health40e0cdee3a440efc6f73a6a33124c436f0816941. Author packet
`a58d38f497b8e267cee713a5b83791531fbf854c` adds only the
[owned Sparse leaf](../../canonical-api-v1/sparse-runtime-v1/README.md).
The oracle commits are Motion64 `b2faa2c70`, Health64 `272d1b4aa`, size256
`0efd8e6784d7d914a825eec1babef301d9c6a973` and size1024
`261dbf6405707fa303bdfaa7b9672a709e309d2b`.

I authored these independent source-derived oracles before subject execution.
This review independently checks the source/evidence joins and applicability;
it is not an independent second derivation of my own model. Root separately
inspected the original workload, query membership, score formulas and framework
state assumptions and confirmed them. No compiler, backend, Node, benchmark or
profile was executed by this reviewer.

## Source and authored work

Both runtime entries parse actual IO arguments with U32.read and pass count to
canonical deferred spawning and iterations to the ordinary-system loop. The
64-produced JS and Native artifacts are reused unchanged at256 and1024, with
actual argument and producer provenance retained. This establishes the observed
runtime-input dependence at these cases, not a universal claim about generated
unspecialized work or other iteration counts.

All entities are genuinely reserved, activated and retained. Main exists at
zero-based indices divisible by8; Aux at indices divisible by3; Flag at indices
congruent to1 modulo3, including payloads on entities without Main. Main is
required by the update and detached query. The old Q.Optional selection did not
make Main optional: its read_selected drops Main=None. The new canonical
O.read/Main plus O.optional/Aux and Flag preserves that membership.

Every selected row performs the complete Main get, sum of four old cells and
set of only the first cell, followed by a full Ledger get and first-cell set.
Ledger writes remain inside the row loop. All sibling cells and Motion
frame/moving metadata or Health reserve/class/grade metadata are preserved.
The public ordinary declaration derives component/resource capabilities and
registration metadata; no trusted administrative update bypass or invented
event is used. Canonical reserve, transaction finish and World.barrier perform
provisioning before gameplay.

After each ordinary commit, three fresh identical Main-required queries each
project optional Aux and Flag for all Main rows. Only then do detached Data
filters select Aux-present and Aux-absent scoring subsets. Pushing those
filters into the query would remove authored projection work; the source does
not do that. Each inclusion set starts rank1 and adds the final rank at the
end. Row scores include actual namespace and Key.index, all Main metadata,
present Aux metadata and present Flag. The combination is all+3*present+
5*absent, with U32 arithmetic. Cumulative adds prior, pre-write row sums and
post-write weighted score. Generation0 remains explicitly observed in handles;
it is not silently inserted into the historical checksum.

Read-only scans use fresh Inspector frames without new registration or clock
increments and return the same physical World. The source performs the actual
final detached read and then observes physical World again. Every row return,
all64 audits, all three complete projected and included row sets and their
scores, cumulative state, final logical rows, resources, physical column leaves
and stamps, allocator slots/free/order, reservations, registrations and cursor
are retained. Pending observations expose counts and ordered Raw/Observed
constructors. Opaque callback identities and captured payloads are not directly
inspected or executed for observation; reservation order and complete
post-barrier state expose the provisioning effects.

Each frozen entry has59 consuming Bend modules and two namespace sidecars.
All50 src members per entry (48 Bend plus two sidecars) match Git
`cc951d346213c9a3d1cb2b557b2eafc8eefc972c` byte for byte. Source uses ordinary
columns; no Prepared constructor or unsupported rendering fallback is reached.
Pure source checks pass under the existing default five-second wrapper. IO host
checks report their six actual foreign-dependent definitions; these diagnostics
are not claimed as whole-runtime proof checks. The actual stock pairs provide
the executable qualification.

## Whole output and portable joins

All12 roles have COMPLETE_CONSUMER_DEVELOPMENT_PASS with empty consumer stderr
and all18 actual commands exit0. The initial64 pairs contain emit/consumer and
emit/build/consumer respectively; larger cases contain consumer-only commands.
No new compilation is attributed to larger cases. Commands preserve the
existing30/120/5-second caps, stock Bend2.0.35, Node24.20 and Clang19 selection.

Complete expected/actual byte counts and SHA256 are:

| Case | Bytes | SHA256 |
| --- | ---: | --- |
| Motion64 | 413934 | `7bc64f59bd9975f79ff6bf51e1156b90170e345898c3c889779686f37f90002b` |
| Health64 | 428396 | `d7393285db308541d8c56a6125ae955f9803652bf3bb4c043b3504418c253f5a` |
| Motion256 | 1642138 | `b770f6028e2fca3f7ebdec84a1f37d44d14283044e28311f9bf75f2969c788bc` |
| Health256 | 1701031 | `e83229491f2225f5756eaa3070cec55c7038d8e0b9d12a1f5a858fac8d11a46a` |
| Motion1024 | 6595523 | `4ec399768f5eedd5a7ea911b7f3830b97d721e364a0a4a79b4aebb40a6e906ef` |
| Health1024 | 6832144 | `41b7af0a005d73d4a30e8c9f6912e83db1cc497f595f6fb6102d77612a99d80a` |

Independent formula checks give seed clocks51/203/811, update counts512/2048/
8192, final clock/cursor563/2251/9003 and Ledger first cells512/2048/8192.
Each audit has8/32/128 row returns and three fresh scans of those rows. The
six reports retain all of them rather than first/last samples. Source report LF
plus IO.print LF is compared exactly, with no normalization.

[RETENTION.json](../../canonical-api-v1/sparse-runtime-v1/runtime-v1/actual-batch01/RETENTION.json)
SHA256 is `58bf9b1cffbb478ecfea5f8b980b2f2354bc5237ede868f970df7c94f9245227`.
Read-only verification using the prior runtime-batch verification pattern passes:

- 707 exact bindings,543 content-addressed gzip objects and22 installed ELF
 identities; generated Native executables are retained objects.
- 12 current roles,18 commands and zero historical attempts in this batch.
- 66 guard files and8264 evolving actualPins joins, including generated artifacts
 and earlier raw/guard inputs, not only initial plan pins.
- Eight complete producer-plan/receipt/generated-artifact chains for larger roles.
- All plan/resource/source/raw stream hashes, exact command argv/caps/exit joins,
 full oracle equality and empty consumer stderr.
- Six isolated model reproductions using only retained Python model dependencies.

These checks were run offline on CPU9 with `/tmp/review21-sparse-batch.py`,
adapting the existing Dense batch verification to this manifest and its six
models. Source-only verifier commands remain `verify.py.source`,
`verify-health.py.source`, `size256/verify.py.source` and
`size1024/verify.py.source` in this oracle leaf. They verify source pins,
retained bodies, independent closed-form scores and exact existing TS hashes.
No retainer, backend or benchmark was replayed.

## Shared TS and protected regression applicability

Pinned TS3040a3b source/input assertions have matching complete final rows,
Ledger fields and all64 iteration audits at all three sizes and both schemas.
The independent shared models reproduce the exact retained final/oracle/audit
hashes. The TS checksum deliberately uses fold33 modulo2147483647; the authored
Bend checksum remains weighted1/3/5 with namespace/index. The two checksums are
not equated. TS retained evidence contains hashes and samples with internal
full-field assertions, not this full raw physical report. Canonical allocator,
stamps, framework registration and clocks remain additional Bend observations.
TS Seed/Dump scheduling is not asserted identical to canonical provisioning and
detached inspection.

[PROTECTED-GATE-REUSE.json](../../canonical-api-v1/sparse-runtime-v1/runtime-v1/actual-batch01/PROTECTED-GATE-REUSE.json)
SHA256 `435f329fad770280af1ef36931a01439825fc77617c9df1e52892b24aedfd420`
binds the existing #28 receipt
`ecc63d4df043d4d30de86e78baa8a6f4ee72ae5753bda3371cbad8e7c43d560d`.
All351 monitored current-source hashes match both Gitcc951 and this delivery's
Git tree. Every changed delivery path is inside the additive Sparse leaf; no
core, benchmark, contract or runner is changed. The existing archive
`fa56ce86e81025a2940cdfb22a49628ad0ba97fc3b097b58751a2acc5476a091` and its
manifest identity were rechecked. Its earlier full902-member/110-whole-output
review and exact decision recomputation remain applicable:123 commands0,
40 pairs and NO_CONFIRMED_REGRESSION. No new benchmark is needed for this
source-identical protected workload. This is protected Workshop regression
reuse, not Sparse timing, equivalence or a speedup claim.

## Remaining scope

Dense and Sparse semantic runtime-input matrices do not complete #21. The
remaining lifecycle, reader and failed-transaction workload qualifications,
required capture styles, actual transaction/heap metrics, common timed work and
forcing, same-process warmup, seven rotations, reset child peak RSS,
resolution-limited shared batching and approved uncertainty margin retain their
existing obligations. No target ratio, universal capacity/refusal law, global
parity, optimization result or full timing/scaling acceptance is claimed.
