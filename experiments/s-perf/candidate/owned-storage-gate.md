# Actual indexed storage finite gate

Implemented after the independent architecture review and frozen candidate design,
against base `85a8712`. This extends the primitive canary; it is not full #20
acceptance, a production capacity policy or an approved ECS proof.

Replay: `python3 experiments/s-perf/candidate/owned-storage-run.py`.
Observed exit0: 39 complete NativeO3/JS semantic checkpoints, three intended
compiler negatives. The original milestone detects two compiling semantic mutants;
the clean-checkout replay additionally detects lost-growth-owner (three total).
The independently assembled expected fields cover independent nominal affine
Motion/Health payloads, each owning a four-cell nested array plus scalar.

`Rows<M,A,F>` owns separate Main/Aux arrays and Data metadata entries (liveness,
optional Flag, added/changed), synchronized balanced capacity/depth and committed
high-water. IDs map to id-1 after checks. Empty capacity1 doubles through equal
fresh vacant halves; ID65537 actually grows capacity131072/depth17 and retains
first/middle/old-last/new-last values and every payload/metadata field. High-water
is preserved by extract/restore/remove/marks and only extended by successful place.
The private finite domain is IDs1..131072; zero/larger IDs reject before subtraction
or masked Array access. Doubling checks capacity<=65536 before c+c. This private
bound is a harness capability boundary, not an approved public exhaustion result.

Public coordination signatures are unchanged from the coordinator contract:
rows_empty; rows_high_water; rows_can_place (domain-only, unchanged owner);
rows_extract (temporary None owners, metadata remains live); rows_restore
(trusted same previously extracted ID); rows_remove (tombstone); rows_place
(Placed or Rejected preserving incoming Row). Occupied live placement rejects.
Restoring a Row has a trusted extracted-ID precondition; malformed detached public
constructors are not claimed to be universally validated or root authority.

Main-only take/put/with_main, structural rows_replace_main and marks never extract
Aux or reconstruct Row/list. Structural changes retain exact baseline added/changed
rules and consume stale applied payloads as before; rejected *placement* instead
returns its owned Row. The fixture checks live-without-Main separately from tombstone,
repeated removal/reinstallation, foreign namespace, missing/bounds, main inverse
round-trip, main structural add/change/remove/nochange/stale, unchanged Aux fields,
mark preservation and returned incoming payloads on rejected placement.

The duplicate Rows and Type-column clone controls fail for intended quantities;
nominal swapped Row schemas fail at exact parameterized types. Their valid paired
subject is the checked executable fixture. Wrong-slot extraction and reversed Main
growth and discarded old Main owners are compiling runtime mutations, independently checked and observed rather
than counted as ownership compiler negatives. No Type clone/fork/join, unsafe/foreign
operation, checker patch, dependency or new law/proof is introduced.

Native: CPU8, O3, one worker, GPUoff. JS: CPU8, existing Node. Checker/runtime5s,
codegen30s, clang120s. Runner kills only its own process groups on deadline and removes
its temporary immutable overlay. Source closure hashes and raw observations are
retained. Types is the byte-identical existing integration types module; the owner
of this change modifies only storage, identity and finite-control artifacts.
The replay materializes `types.bend` from `a976667` in its temporary package; no
untracked worktree file is required. `BENDVY_CPU` overrides the default CPU8.
The coordinator's CPU4 and independent CPU11 replays have identical output; see
`../owned-storage-clean-replay-evidence.json`. Historical milestone evidence stays
unchanged and is not relabeled with the additional mutation.

Remaining gates belong to integrated #20 replay/review: real registered callback
and command/queue retention, complete ordered queries, failed/retried transactions,
rollback across growth/reservation holes, all actual access negatives and mutations,
E11 full retention, all five measured workloads and memory/occupancy instrumentation.
This finite storage gate supplies no performance or universal refinement acceptance.
