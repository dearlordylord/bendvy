# T06 — bounded Data/owned-payload rollback probe

[Issue #7](https://github.com/dearlordylord/bendvy/issues/7), [SPEC](../../docs/SPEC.md).

The experimental transaction writes a Data component, Data resource and a field
of an affine Type Payload containing an owned Array<U32>. It records actual old
values before each in-place array write, then restores the inverse journal in
reverse order on typed failure. Events and structural command intents are staged
until success. Existing committed publications are kept on failure.

The successful first system commits 5/7/13 and event 1/remove command. The failing
second system sees those values, sees its own two writes (9/11/17, 12/13/19), then
fails as `Failure{"Fail",7}`. Externally visible values return to 5/7/13 and only
the first system's publications remain. A successful two-write control ends at
12/13/19 and appends event 9/insert command. Full payload/other-position projections
check unwritten slots, not just the modified element.

## Execution and verification

```
python3 experiments/t06/run.py
# Optional Linux affinity:
BENDVY_CPU=11 python3 experiments/t06/run.py
```

Seventeen ordered observations (8 failing, 4 successful second-system control,
5 Good-provider observations) match native/JS/freshly executed bevy-ts. The same
abstract Step callback is instantiated repeatedly with explicit typed configs;
no ordinary affine function is duplicated. Abstract handles and the three supplied
operations preserve the provider boundary; the paired read-only negative control
rejects `Tx` operations on arbitrary `T` at the intended type error.

The callback records observations using actual get/set calls. A narrow IO driver
prints those observations before `finish`, then performs commit/rollback. It does
not return owned Stores through an unnecessarily large stack of IO continuations.
The first committed state in failure/success-control fixtures is made by the exact
core begin/set/stage/finish operations; a separate Good callback fixture verifies
the declared-provider route. These are experimental transaction/provider fixtures,
not integrated T09 schedules or general application closure support.

Reference commands are observed through the public debug dump's actual tag and
publishing system. That API omits targets; the adapter maps each publishing system
to its single predeclared reservation slot 0. Publication history is cumulative
reader-observed history, not an assertion about physical event retention.
The TS payload updater explicitly copies its array before replacement, as required
for its transaction boundary; Bend mutates its owned array and journals old values.
Equivalent observations do not imply equivalent allocation strategies.

Bend 2.0.34 / pinned Base, clang 14.0.6 `-std=c11 -O3 -lpthread -lm`, Node 24.20.0,
native `--threads 1 --gpu off`. The explicit checker and every runtime probe stay
within five seconds. C/JS generation has a thirty-second build deadline; clang optimization has
a separate 120-second deadline. Compilation is excluded from runtime/performance
claims. No new dependency or compiler version was introduced.

Compiling mutants cover absent undo, forward undo, whole-schedule reset and
premature failed-system event publication. No ECS proof was written; the
[CANDIDATE-LAWS](CANDIDATE-LAWS.md) remain unapproved.

## Remaining obligations

The Store has fixed two-slot position/four-slot payload columns and a singleton
resource; only known-valid slots 0/1 are addressed. It does not establish generic
lookup/bounds, arbitrary component bundles, allocation rollback, marker application,
change tick restoration, event reader cursor rollback or integrated schedules.
T05 separately covers structural lifecycle; T07/T08 cover the distinct reader
contracts. Command kinds here are only Insert/Remove publication intents.

General affine Type elements, captured closures, IO-handle payloads and irreversible
payload-consuming updates still need an ownership-preserving rollback design;
these are not discarded in favor of Data-only components. Scaling, journaling
costs, optimized storage, approved numerical performance criteria and universal
refinement remain return conditions. This is bounded executable evidence, not
production API/full-core/performance acceptance.
