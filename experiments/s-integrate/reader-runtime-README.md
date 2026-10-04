# Actual reader and stream module controls

`readers.bend` and `streams.bend` implement the frozen hooks from
`reader-contracts.bend` and `READER-LAWS-DRAFT.md`. This package tests actual module
bodies. It does not claim the integrated #19 dispatcher/storage trace, production
performance acceptance, or a universal ECS proof.

Run `python3 experiments/s-integrate/reader-runtime-run.py`. The runner checks each
original and mutant with installed Bend 2.0.34 (`--check-only`, five seconds),
builds C with clang `-O3` and JavaScript, and bounds each execution to five seconds.
Native uses one thread and GPU off. Code generation and compilation have separate
30/120-second limits; no checker/kernel allowance is increased. These executable
controls do not use the scoped proof-checker repair.

The original runs MotionPing and HealthPing independently at C3 and C65536, with
26 observations per lane (104 per backend). Every actual returned value is
compared, in order, before printing a compact PASS/FAIL. Clock and cursor inputs
come from `R.begin`, `R.frame`, `R.advance`, `R.skip`, and `R.complete`; reads carry
the actual affine Run and log through `S.read_ping`, `S.read_lifecycle`, and
`S.missed`. No expected cursor is substituted for a runtime cursor.

The driver supplies bounded hook sequences, not public systems: publication uses
a fresh system/post-publication tick, deletion uses a barrier tick, and registry
keys identify fixture instances. U32 lifecycle values exercise the generic log;
these values are not factory-issued entity authority. Actual handles, world
identity, nested/gated base identity, declared access, commit-time marks,
transaction rollback, disposal, and dispatcher failure reporting must be exercised
by the integrated adapter. Added/changed retention uses storage marks, outside
these log modules. Trusted setup must enforce its actual clock/key/count bounds.
The fixture validates 1 <= C <= 65536 before mutation; each scenario has fewer
than 32 operations and at most 2*C+2 transient entries. Rejected C65537 is run on
both backends. These are experiment bounds, not approved production limits.

Scenarios cover a full message publication followed by one message, entire loss
of an oversized C+1 publication, C+1 individual lifecycle records at one tick,
reads before frame trimming, B's failing read and unchanged retry, independently
completed Fast, late registration without historical lag, skip suppressing only
messages, registration surviving a first failed invocation, and unheld expiration.
Completion, lag, and holders are calculated by actual module code. Retained old
records remain readable by a new reader; registration only alters lag.

Compiling mutations target failure completion, skip's two boundaries, global
completion, omitted first registration, ignored capacity, ignored holders,
ignored registration, whole-group lifecycle dropping, global consumption,
partial message-batch dropping, and eager lifecycle trimming. The unchanged
original controls must pass; each mutant must check, build and execute on both
backends and produce an actual false observation. Type control pairs require
Motion/Health message rejection and prohibit consuming Run twice. Declared-access
and write-through-read negatives belong to the trusted public adapter; these
module controls do not claim those gates.

The runner also freshly executes the pinned public TypeScript E11 adapter for
Motion and Health: message, removed, despawned, unheld, and surviving marks.
Those executions independently establish source observations; they do not replace
an integrated Bend execution. `reader-runtime-evidence.json` records tool versions,
source hashes, original/mutant outputs, and fresh reference results. Timings are
bounded execution evidence, not comparable-work benchmarks or threshold approval.

The queue caches total value count and per-batch count. Append uses a reversed
rear list; trim reverses it when the front is exhausted, then subtracts cached
counts while dropping. Message append creates one atomic batch; lifecycle append
creates unit batches, allowing partial same-tick retention. Reads accumulate and
reverse once. No repeated remaining-list length is computed. The initial JS
fixture's recursive boolean validator exceeded stack depth at C65536; making
that fixture validator tail recursive resolved it without changing reader/log
bodies. A first temporary checkout outside the repository hit the five-second
checker bound; the final runner uses task-local temporary directories, as the
existing build runners do, and does not increase the bound.

The modules are trusted adapter internals, not a public constructor API. Run is an
affine owner consumed by completion; constructing/cloning authority is unavailable
through the eventual declared views. General Type message fan-out, reader removal,
production clock exhaustion and retention configuration remain explicit follow-ups.
