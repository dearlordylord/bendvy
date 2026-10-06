# Descending private ID presence scan

Source-only causal probe from immutable cursor closure `bdf6b2fc…` to `b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0`. Overlay `/tmp/bendvy-private-id-query-descending-v1`; both exact full64 builds `/tmp/bendvy-cursor-descending-{motion,health}-build-v1`.

Only query.bend changes: private cursor traversal starts at high, decrements after each fuel step and prepends selected IDs. A private finish returns values directly. The resulting IDs remain ascending, so original row callback execution order is unchanged. Generic/public query prefix and every other28 modules, including all HA/providers/callbacks/journals, are byte-identical. This does not change general query traversal or assume arbitrary getter purity.

The selected presence path invokes no authored getter/client: it performs intrinsic aligned Bool/flag reads and swaps/restores opaque Maybe<M> in the unique owned Main array. It never destructs or converts M; arbitrary affine Type Main/Aux and all live/flags/stamps/context stay intact. Each inspected slot is restored before the next. Original valid ID/capacity, live, selection and Main-presence checks are retained. Fuel=high and initialID=high ensure the final decrement1→0 occurs only before zero-fuel finish; high0 performs no inspection. Descending temporary slot inspection changes order, but introduces no callback or external observer. This is source reasoning plus finite tests, not universal refinement or a new ECS proof.

Fresh executed gates, no inherited pass:

- Both schemas/backends full65 complete worlds against fresh actual TS.
- Protected cursor+generic lifecycle, two nominal schemas and JS/Native:320 literal checkpoints.
- Generic affine Owned Array depths0–4, all cells/metadata/context and four selections:40 complete observations.
- Four-selection multi-ID ascending order:8 observations.
- Actual private Motion row cursor valid/foreign/zero/hole/above-high/empty/duplicate, retained Data and complete rollback:24 observations.
- Eight compiling runtime mutants detected on actual new query family: lost opaque Main restore, ignored selection, reversed final result, ignored live membership ×JS/Native.

`status.json` and evidence archive retain exact source/cache/driver/compiler/program/oracle/command/output receipts. No failures occurred in this probe. `derive.py` verifies original29/cache maps/digests before copying; a fresh reproduction matches all29. `build.py` retains the pinned original full64 driver and authored fresh-entry suffix. CPU10, executable checker15, emission30, approved Clang19 O3 compile120, runtime5; proof/default checker5 unchanged. Bend2.0.35 version/guide read before work.

Independent Native attribution belongs to `149abcd` (`native-private-id-query-descending-counts`), not this package's gates: fresh actual bothschema requests/RFC decrease1,044,480 each versus cursor parent; constructor counts remain equal. The old reverse reuses Cons storage but creates an RFC redirect for its accumulator, removed here. Do not infer removal of Native Cons allocations or elapsed improvement. Root owns performance observation and qualification.

No compiler/kernel/reference/dependency/canonical-defense edits or new laws/proofs. No full22, universal ownership/authority, production API, performance acceptance, adoption or canonical packet/keep/reset claim. Follow-ups: fresh generated-JS chain/control admission on this closure, broader connected gates and stable equivalent-work JS≥TS / Native≥2×TS qualification. Source parent and generated bdf gates do not transfer.
