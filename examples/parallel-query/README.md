# Registered affine query execution

The application declares unlike input and output families, registers one system,
and calls `execution-app.run` three times. Gameplay receives the abstract
`execution-query.Each` capability. It does not split columns, dispatch native
tasks, or reconstruct the World.

The declaration is an abstract program over the library's closed builder. It
selects a pair of component leaves through a route in the closed component layout.
The actual column owners carry the keys in their slot types. Equality checks bind
the complete World storage type and selected pair to that layout. The library
derives both payload types and access keys from the same route, then extracts and
rejoins the actual owners. The application cannot supply an arbitrary storage
lens, capability provider, payload identity, or access catalog to the ordinary entry.
Its input projector produces a reusable `U32` view. The closed item body
receives that view and one affine output owner. Both families have nested affine
token arrays. The implementation partitions actual child column owners and their
metadata, runs native parallel calls between chunks, and rejoins those owners.
The serial entry uses the same item body and observations.

An affine projector can replace its returned owner. The declaration therefore
requires exclusive input storage access. The gameplay body receives a read-only
projection of that family. An affine return type alone does not prove that an
arbitrary projector or body preserves the original owner.

## Read the consumer

- `declarations.bend` binds component identities and the typed storage lens.
- `body.bend` invokes the query capability and retains its affine Local.
- `payloads.bend` defines the closed direct update and owner observations.
- `application.bend` creates the World, registers the system, runs it repeatedly,
  and tests refusal against a second World from the actual advanced factory.
- `observation.bend` consumes complete snapshots of both Worlds and the returned
  system owner.
- `oracle.py` independently derives the finite expected observations from the
  declared operations. It does not read Bend source or candidate output.

Both columns grow from 8 to 32 slots. The chunk at slots 8 through 15 stays
empty. Live slots 1 and 17 contain both families. Live slots 16 and 18 contain
only input and output, respectively. Slot 31 contains both families but is not
live. The library derives selection from the current World's live handles and
leaves that slot untouched.

The first execution succeeds. The second updates slot 1 and then returns its
item error, retains that update, and still updates slot 17. The third execution
succeeds. The final mutable token and value pairs are `104:19` and `205:35`.
The unmatched and inactive owners keep their initial values. Each output's
original added tick survives, and executed rows have changed tick 3.

The observations include every allocated input and output slot and lifecycle
stamp, allocator fields and slots, allocation order, resource owner, pending and
event counts, registration metadata, World clock, system cursor, and Local owner.
They also observe the complete incoming foreign World after admission refusal.
The consumer runs serial and parallel modes under one nominal schema and
parallel mode under a second nominal schema.

## Check the finite oracle

Revalidate the existing preserved compiler bundle and its 70 resource hashes
against `/tmp/bendvy21-bend2035-lifecycle-pin/BUNDLE-PROOF.json` before reuse.
Its regular compiler executable matches the repository's pinned compiler bytes.
The default installed resources can change independently of that executable.

```bash
export BEND=/tmp/bendvy21-bend2035-lifecycle-pin/bin/bend-2.0.35
export CLANG=/tmp/bendvy-clang19-diagnostic/clang19
export BENDVY_CLANG19_ROOT=/tmp/bendvy-clang19-diagnostic/root
source examples/common.sh
python3 examples/parallel-query/oracle.py > /tmp/parallel-query.expected.stdout
example_emit examples/parallel-query/main.bend /tmp/parallel-query.js
example_node /tmp/parallel-query.js > /tmp/parallel-query-js.stdout
cmp /tmp/parallel-query.expected.stdout /tmp/parallel-query-js.stdout
example_emit examples/parallel-query/main.bend /tmp/parallel-query.c
timeout --signal=KILL 120s "$CLANG" -O3 /tmp/parallel-query.c -o /tmp/parallel-query.native -pthread -lm
timeout --signal=KILL 5s /tmp/parallel-query.native --threads 1 --gpu off > /tmp/parallel-query-native1.stdout
cmp /tmp/parallel-query.expected.stdout /tmp/parallel-query-native1.stdout
timeout --signal=KILL 5s /tmp/parallel-query.native --threads 4 --gpu off > /tmp/parallel-query-native4.stdout
cmp /tmp/parallel-query.expected.stdout /tmp/parallel-query-native4.stdout
```

Use `scripts/bend-check` for `controls/positive.bend` and
`controls/layout-positive.bend`. The latter selects two columns with the same
payload type and different keys. Its otherwise identical wrong-key counterpart
must fail the equality check against the actual keyed owner types. This refusal
does not depend on differing component payload types.

The remaining controls must fail for their intended authority boundaries.
They test schema mismatch, an undeclared component capability, replacing the schema cached view with an affine input owner or a different view type, copying the affine output owner, and
escaping the abstract scope. They also reject selecting a single leaf as a query
pair and reject a layout containing duplicate query keys.
The source-current `examples/parallel-execution/controls/forged-declaration.bend`
additionally checks the shared ordinary entry. It must refuse a raw declaration
that exposes a resource while supplying an empty access catalog.

Passing the finite oracle at four configured threads does not prove that the
query used multiple workers. A source-bound semantic worker diagnostic remains
required. This consumer does not establish universal ownership preservation,
approved new laws, GPU execution, or numerical speedup.

Canonical schema views are cached beside actual affine payloads. Query reads
structurally copy only the cached Data value and preserve the input lifecycle
stamp. Every selected output write rebuilds its cache from the resulting actual
owner, including a body error. Occupied slot observations include `@cache` before
the lifecycle stamps. A fourth scenario stops immediately after the second run's
error and observes all owners, caches, and stamps before another write can mask
a stale cache. The independent oracle derives both the two-run and three-run
states. Untouched, absent, and nonlive rows keep their original caches and stamps.
