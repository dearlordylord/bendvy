> Verification policy: retired golden/model/check artifacts below remain historical and are not current acceptance commands. The user later authorized temporary host helpers for independent source-derived observations, provided those helpers are deleted after use. Such comparisons are finite execution evidence, not Bend proofs; the five approved helper laws retain their stated scope.

# Query lifecycle filters

## Run the current entries

From the repository root, select `main`, `history`, or `scheduled` as `entry`.
Use the qualified Bend 2.0.35 installation and the project's Clang 19 tool.
The commands use the existing [shared example commands](../common.sh), which
serialize backend work. Generated files stay outside the source tree.

```bash
entry=history
export BEND=/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35
export NODE=node
export CLANG=/home/node/.local/bin/clang-19
source examples/common.sh
example_emit "examples/parallel-lifecycle/$entry.bend" "/tmp/lifecycle-$entry.js"
example_node "/tmp/lifecycle-$entry.js"
example_emit "examples/parallel-lifecycle/$entry.bend" "/tmp/lifecycle-$entry.c"
timeout --signal=KILL 120s "${example_cpu[@]}" "$CLANG" -O3 "/tmp/lifecycle-$entry.c" -o "/tmp/lifecycle-$entry.native" -pthread -lm
timeout --signal=KILL 30s "${example_cpu[@]}" "/tmp/lifecycle-$entry.native" --threads 2 --gpu off
```

These are direct application runs, not a replacement oracle or acceptance check.
The paths above name local tools used for the receipts below. On another machine,
set `BEND`, `NODE`, and `CLANG` to the corresponding installed tools.

## Current source and finite observations

`main.bend` runs the existing filter scenarios, then `notice-scenario.bend`.
The notice application uses the current TaskIO bodies and IO schedule API. Its
four updates retain the fast and dormant removal readers, input/despawn readers,
first-reader body error and actual foreign-World reader transfer. The same
existing observations are printed after each application's IO completes.

The current original main emitted C with official Bend 2.0.37 at runtime source
`ee885651da7e1083358adef0293fa9e253121edf`, compiled with project clang 19.1.7
C11/O3/pthread/libm and ran with two workers and GPU off. Every stage exited zero;
stdout was six lines and 18,871 bytes and runtime stderr was empty. The retained
C, binary, individual exits and source binding are in
`/tmp/gh85-current-native/receipt.md`. The complete current JavaScript and native
outputs each matched an independently source-derived expectation frozen before
reading the actual outputs. That finite comparison is not a universal proof or
actual worker-operation observation.
The existing current JavaScript artifact remains reusable because its imported
runtime code is unchanged by subsequent control and documentation edits.
The old buffer-entry source diagnostic was repaired before the earlier migration
runs; no successful full proof-only check is inferred from backend execution.

[`history.bend`](history.bend) retains six QueryApp cases for an existing zero
cursor, low-word wrap, dormant old and recent stamps, and serial and parallel
body errors. Trusted setup preserves the actual payload owners while seeding
stamps, administrative time, and the registered owner's previous cursor.
Each case performs three admitted runs and a genuine foreign-World refusal.
World creation remains the pure `W.create` operation. The migrated caller binds
the QueryApp IO results and retains the returned application between runs.

The existing error setup now seeds physical slot 0, whose public handle is 1.
Physical slot 1 is absent from the Input and Output columns. With the existing input step 3, the seeded output 13
becomes 16 and reaches the existing after-write error. Both error cases then
perform two successful runs. Wrap and dormant selection already worked.
`success/[]` denotes an empty error list, not an empty query result.

[`scheduled.bend`](scheduled.bend) retains six command/query RootSchedule calls,
including Added and Changed filters, serial and native entries, and retained
queues when final publication is disabled. Its IO binds await the actual
application results before printing. The observations include the existing
after-enqueue error followed by peer execution.

The caller migration is committed at `9a6aa7e7f452be1b6b124c45d2cc08dfb70d611e`.
The history seed correction is committed at
`dc4dc6642997986c994a99333c5d478634fb53a7`. Fixed history JavaScript and native
outputs match at six lines and 14,882 bytes. Scheduled outputs match at six lines
and 9,445 bytes. Both routes exit zero with empty runtime stderr. The local
receipt is `/tmp/lifecycle85-history-io-receipt.md`. The two read-only GH85 round 2
reviews found no concrete defect in this two-entry migration and seed repair.
Those reviews do not review the separate main/notice migration described above.

The fixed history receipt is reused narrowly for its selected basic-query behavior:
history, payloads, tick/filter operations, pure row traversal and returned-owner
execution semantics remain unchanged. Later generalized/taskful additions are not
selected by history. Widened Builder selector plumbing is exercised by current
ordinary consumers, not retroactively by the old native binary. The source map is
`/tmp/gh85-current-source-map.md`; this is not whole-import-closure identity or a
claim that every old artifact was rebuilt. A separately source-derived corrected-history expectation also matched the
complete fixed-history JavaScript and native outputs at six lines and 14,882 bytes.
This supports the narrowly unchanged selected history path, not a current rebuild
of the old binary or a whole-import-closure pass.

## Returned errors, refusal and fatal failures

As specified in [SPEC](../../docs/SPEC.md), ordinary execution is
nontransactional. Writes and yielded-reader progress before a returned `BodyError`
remain in the returned owners. An executed body error advances that system's
last-run cursor; an admission refusal does not invoke the body or advance its
cursor. A false condition skips its target body and is distinct from a returned
body error. Ordering dependencies require completion and visibility, not predecessor
success; handler-directed continuation does not undo independent work.
A fatal foreign/runtime abort is a different boundary: it is not a returned
`BodyError`, does not promise recoverable owner return, and introduces no rollback
or artificial crash-control API. These finite consumers do not establish universal
behavior for every fatal runtime failure. Historical setup exposes no gameplay
cursor/clock mutation; the five approved helper laws keep their limited scope.

## Current authority and worker evidence scope

Five existing World-authority control files were migrated at `7cd09d1b0` to the
current Permit/Task/FrameworkProgram signatures. The correct-World and detached
positive counterparts reported only their existing 18 unsafe/foreign-dependent
definitions, not parser, type or affinity errors; these are not proof passes.
The wrong-World definition rejected `World<...,Array<U32>,...>` where Unit storage
was required, and detached laundering rejected metadata carrying the wrong actual
owner family. Exact source bindings and intended diagnostics remain in
`/tmp/gh85-controls-receipt/receipt.md`; no new authority case was introduced.
Existing notice controls also retain narrow source-current reader schema, stream,
origin, affinity, route, classification and refresh-boundary reuse evidence in
`/tmp/gh85-notice-authority-reuse.md`. That binding does not promote historical
whole import closures or dependency-limited source checks into proof passes.

Accepted GH81 actual row-operation evidence is reused narrowly for the unchanged
component-and-metadata traversal: two OS workers executed actual Output-owner row
operations within one query invocation, and the complete independent observations
included values, cache, stamps and cursors. The shared physical column split/join
and basic query path retain their definitions; each leaf carries its lifecycle
stamps with the affine component arrays. This establishes finite reached
component/metadata worker evidence, not worker placement for populated lifecycle
journal publication, foreign-reader transfer or every filtered branch. The exact
source comparison and limits are in `/tmp/gh85-current-source-map.md`. No new
worker probe or multiple-worker journal ownership claim follows.

## Historical source-bound receipts

The following text records the earlier contracts and exact source bindings.
`filters-oracle.py`, `history.expected.stdout`, and `scheduled.expected.stdout`
were retired and are absent from the current tree. Their names and hashes below
describe historical evidence only. Do not use those outputs as expectations for
the current IO callers or the corrected history seed.

`filters.bend` runs the ordinary QueryApp with Added and Changed filters on its
written family. Two nominal schemas use genuinely affine Array payloads. Four
cases run three times, using query serial and parallel entries, then attempt the
same actual system owner against a genuine second World. The full observation
includes all 32 component slots and lifecycle stamps, cached views, actual token
contents, Local/cursor, allocator, registration, pending/events and clock state.
Seed tick zero is a valid timestamp, not absence.

The independent model in `filters-oracle.py` derives all four lines before
backend capture. It reuses the unchanged query fixture's declared initial state
and observation formatting, then models lifecycle selection independently. The
first invocation selects live paired rows 1 and 17. Each later invocation sees
its own previous cursor and selects neither, so the Type owners change once.

At source `261e4b4fa`, manual execution through the unchanged `examples/common.sh`
passed JavaScript and native with 1 and 4 workers. Each output is exactly 9,282
bytes with SHA256
`ef7f24ed7eb2e48a30135e650fc3d7b1f0ac18738f09a2db32e2d6f6252bcfe3`;
all consumer stderr streams are empty. The portable World namespace adapter is
included through `3e28f146a` and `261e4b4fa` (originals `616b52fff` and
`e9532e41b`). The matching private Bend 2.0.35 compiler and all 70 resources,
Node 24.20.0 and private Clang19 wrapper were bound before capture and unchanged
afterward. Source bindings and emitted JS/C/native artifacts were verified before
consumption. Raw normal-development evidence and terminal exit0 receipt are in
`/tmp/gh85-filter-normal-v1`. This is not a canonical qualification receipt.

The ordinary first filter consumer does not establish actual native worker
participation, system-parallel filter execution, errors, false conditions,
wrap/dormant behavior or removal/despawn readers. Those remain GH85 work. The
serial query cases provide behavior controls, not instrumentation. No new runner
is added or executed by this checkpoint, and no universal runtime theorem is
claimed.

`history.bend` adds six ordinary QueryApp scenarios. Trusted historical setup
retains actual payload owners while seeding their stamps, administrative time and
the actual registered owner's previous cursor. It distinguishes an existing
zero cursor from first execution, crosses the low-word wrap, rejects maximally
old component/cursor pairs, observes a recent write after a dormant cursor, and
retains the actual written/cache/Local state and advanced cursor after a query
body returns an error. Every case then runs twice more and performs the same
genuine foreign-World admission refusal. Its independent model freezes all
observations in `history.expected.stdout` with SHA256
`ea3cfdda072a9e0a3a046bfb6d157c6a4888ba72afa19e3da0d74ade04b264ae`.
This historical fixture is explicit setup, not a claim that ordinary gameplay
can set its execution cursor or clock. Source and full JS/native1/native4 observations pass at source `624f13f4d`.

`scheduled.bend` uses the actual closed command/query RootSchedule consumer. It
covers both system and query serial/native entries, two nominal schemas,
handled errors after writes and enqueueing, final publication and retained raw
queues. Changed observes publication's later stamp on the next admitted run;
Added does not treat replacement of an existing component as a new insertion.
The independent model includes actual displaced owner receipts, all component
and administration state, exact pending status, handler state and both system
cursors. `scheduled.expected.stdout` has SHA256
`e629e4352ac6e75e941bfe3f5ffaf1f040f22212e60d0bea930b38e78fc7ed39`.
Source and full JS/native1/native4 observations pass at source `624f13f4d`. No native worker participation claim
follows from selecting a native entry or running with four configured workers.

The historical and scheduled normal-development run terminated exit0 with all
six output streams matching their pre-capture full oracles. History is 14,066
bytes per backend and scheduled is 9,391 bytes. All consumer stderr streams are
empty. Source, all 70 qualified compiler resources and selected tools match their
pre-launch bindings afterward. Raw artifacts, guards and unconditional terminal
receipt are retained at `/tmp/gh85-history-scheduled-normal-v1`. These remain
finite source-bound observations; they do not qualify later journal migrations
or establish native worker participation.
