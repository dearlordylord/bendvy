# Post-initialization validation compensation oracle

Independent source-only expectation for producer commit
`f9cebf26df788df61a0133bf5bc9bae35c504382`, scenario
`experiments/public-schedules/named-app-v1/post-init-validation-v1`.
Main SHA256 `6d734237517126d654e32ae470ab7e383126803a0888bdc2bda0e42b90e3dbd4`.
No runtime output, generated backend artifact, or receipt was consulted and no
backend was invoked. The previous oracle artifacts are unchanged.

`expected.stdout`:1140 bytes, SHA256
`1c1111b464a9edbc740f73a650901e2d1dc1d0c49c4a8a5742c23b5c9afda518`.
The exact source protocol is JSON-shaped with raw `context(world(...),...)`
constructor expressions inserted for before/after, not quoted JSON strings.
The oracle preserves that protocol and every event/array/error byte. Main's
result ends with `}` without an embedded LF; Base `IO.print` adds exactly one LF.

## Derivation

`fixture.bend` `setup` through `setup_stored` uses actual W creation/reservation/
activation and `Col.swap`: namespace1, entity1, nextId2/highWater1,
live `[false, true]`, capacity2/depth1, sole column leaf some42, no lifecycle
stamps, Unit resource, no pending commands, no registrations, nextSystemId1,
clock0. It publishes, in order, original Value11, original Removed(entity1,value),
and the complete Parent hierarchy self-relation error. `Mixed.start` does not
synchronize that log: journal/typed batches and keyed domains/positions are
empty, all clocks0, leaf and keyed nextReader1.

`main.before` first records this exact Context through `observer.bend` `context`.
It then calls fixture `define_all(context,"invalid-initialized")` using the
actual ordinary `define_mixed` and mixed parameter initialization.
`reader-parameter.bend` concatenates parameter access in product order:
`[value,values:read,values:read,removal,value,Parent:read]` (duplicates preserved).
`ordinary-reader-system.bend` `registration_result` registers actual registry1,
then `initialized_provider` initializes the product, then `initialized_values`
invokes fixture `validate_all` on those actual owners.

Initialization consumes system ID1, event IDs1 and2, and keyed ID1. Query owner
is Unit, removal reader owns registry1/name value/cursor0. Thus nextSystemId2,
leaf nextReader3, keyed nextReader2 before validation. No callback, prepare,
before-attempt, clock advance, transaction, barrier, or ingestion runs. Positions,
keyed domains, typed batches and journal are still empty. `validate_all` is the
trusted explicit `(context,(owner,False{}))`, preserving both actual arguments.

The false branch in `ordinary-reader-system.bend` `initialized_checked` passes
the actual provider to `dispose_provider`. `Sys.dispose` and
`registration.bend` `remove` match the existing namespace/id/name/access and
remove registry1, leaving the consumed monotonic nextSystemId2.
`provider_disposal_result` calls `RP.release` only after `Sys.Disposed`.
Fixture `release_all` uses actual pair release hooks:

- query release returns Context;
- both event releases remove their positions (already empty), preserving
  allocators and typed history;
- removal release checks the now-empty registrations. With no remaining removal
  registration, `removal_release_world_checked` filters events using the actual
  selector. It removes only the original Removed record. Original Value11 and
  the raw, not-yet-ingested relation failure are retained in that order. The
  empty journal remains empty;
- keyed release removes membership/position from empty metadata. It does not
  ingest or remove an unrelated raw World notice; domains remain empty.

`definition_cleanup_result` maps successful compensation to `DefinitionRejected`
with the **original supplied descriptor**, rather than the initialized temporary
parameter, and original Unit declaration. `main.result` destructures its actual
Param access and Unit; `rejected_observed` renders status rejected-after-initialize,
full returnedAccess, returnedDeclaration null, and the final Context.
No owner or registry is reported as surviving compensation.

All entity metadata, actual live array, component tree/value42, stamps, resource,
pending count, clocks and frame metadata remain unchanged. Observed differences
are exactly removal payload cleanup and the three consumed allocator IDs:
nextSystemId1→2, leaf nextReader1→3, keyed nextReader1→2. Registrations are empty
both before and after; no callback-generated positions or histories appear.
This is cleanup of the actual rejected initialized provider, not preflight-only
rejection of an unallocated descriptor.

## Serialization and pinning

`observer.bend` `world_final` emits every World field in order:
namespace/nextId/highWater/live/capacity/depth/column/resource/events/pendingcount/
registrations/nextSystemId/clock. `column_array` renders actual tree shape and
`column_returned` includes all stamps. `state` emits complete typed stream,
journal, typed frameStart and keyed failures. `stream` includes domain/batches/
positions/nextReader/frameStart/boundary/capacity/dropped; `failures` includes
all domains/positions/tick/frameStart/boundary/capacity/nextReader.
The source `list_json` uses compact separators. Installed Base `Array.to_list`
traverses left-first, and `List.show.go` inserts comma-space only in live bits.
Fixture serializers preserve the full descriptor/operation/source/target/error
for the retained raw failure. Actual `print.js` and `print.c` append one LF.

`source-pins.json` preserves all112 historical source paths in the producer's
SOURCE-FREEZE inventory:4 fixtures and108 core paths, including duplicate paths
with identical module bytes. It additionally pins the freeze manifest, installed
Base, and both print effects:116 files. Those duplicate path names do not imply
different semantics or separate World owners. The normalized canonical-import
successor can bind the same calculation through a separately retained source
map without replacing this historical inventory or expected output.

`python3 derive.py` checks all116 hashes, full expected bytes, actual initialized
owner/ID order, validation argument preservation, successful compensation,
empty registration/retention state, nonrecycled IDs, exact cleanup event subset
and order, recovered original descriptor/declaration, preserved clocks and full
serialization. `--write` regenerates only from the source calculation.
Python source checks pass. No source check is needed for this Python-only leaf;
the supplied Bend source-check result is not treated as backend acceptance.

Scope is the focused post-init validationFalse compensation path. It introduces
no contract, law, runner, compiler, dependency or numerical changes and does not
qualify callback execution, failure-frame retention, WorldIO provenance,
performance or combined regression. Un-ingested raw relation notice preservation
is precisely the current release operation's behavior; it is not a claim about
post-callback keyed queue disposal.

## Canonical-import successor binding

The normalized integration entry SHA256 is
`6d045a3e21d697534b9a992890340c159d0049c0cb7c5142c0db071fcb031377`.
`normalized-source-pins.json` preserves all76 actual canonical-import bodies plus
Base and both print effects (79 files). `import-rewrite.json` records exact
before/after hashes for the four fixtures. Self-test now verifies both historical
and normalized inventories. It independently recomputes each fixture rewrite
from historical bytes, replacing only line-leading `import /tmp/.../src/ecs/`
with `import ../../../../src/ecs/`, and asserts exact resulting byte equality.
For every historical core path it checks the canonical candidate body has the
same content hash;108 source paths collapse to72 equivalent core modules.
Thus no function, renderer, operation, literal payload or parameter behavior
changes. The same independently derived1140 bytes remain applicable. This
binding preserves the original112-body basis and expected artifact without
rewriting either. No runtime or generated output was inspected for the join.
