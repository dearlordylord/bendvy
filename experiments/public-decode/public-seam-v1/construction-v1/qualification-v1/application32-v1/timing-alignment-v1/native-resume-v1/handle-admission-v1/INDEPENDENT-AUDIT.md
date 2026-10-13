# Independent handle-admission oracle audit

This is a source-derived audit of the current `handle-admission-v1` entrypoint. It is an independent model/evidence note for the primary `model.py`; it does not consume runtime output and does not replace the owner’s frozen source basis.

## Source scope checked

The current application path is `main.bend` -> `handle-application.bend` -> `handle-controls.bend`. The current controls formatter walks the physical column from ID `1` through `nextId - 1` (`stored_column`/`column_rows`) and reads both `Col.view` and `Col.lifecycle` for every row. The three child source files are currently untracked and have no freeze/receipt yet:

| file | SHA-256 |
| --- | --- |
| `main.bend` | `43845b7faaa61280e1211af7b3ed22069b0267193cde2dc62bc29fc6ff35ce83` |
| `handle-application.bend` | `d5fe8041cca40234380e0ee2b2c11c939c9ac3ca2af36ebac8c1c2c3e0aa2f1b` |
| `handle-controls.bend` | `fb803001e368d6eb211e023bd13643a65a8b99213fe4cd19f1a2bc32a1af4c10` |

The application imports the core through absolute `/workspace/formal-proofs/bendvy/src/ecs` paths. A final freeze must bind the exact current core closure and these source hashes; this note is not a portable source freeze.

Relevant current core observations are `decode-data` handle validation (`namespace` equal and `id > 0`), `component.replace`/`Column.mark` clock and lifecycle writes, `bundle-batch` staging, `world` reverse pending accumulator plus FIFO barrier, and `resource.tx_replace` with rollback-only old-resource ownership. The old `prototype/handle-oracle.py` retains retired resources and is not applicable to this source.

## Initial and foreign worlds

Each `run(~S, which)` starts from a fresh `W.factory()` and creates two worlds with namespaces 1 and 2. The first world reserves and immediately activates/populates ID 1 with `seed:11,12,:1:1`; the second world reserves and activates/populates ID 1 with `seed:21,22,:2:1`. The factory cursor after both creations is `3`. The second world is passed as `foreign`; its ID 1 is a genuine creation/reservation result, not a literal-only handle.

Before the tested admission, the first world is:

```
1/2/1/01/2/1/row1={cells:[u32:11,u32:12],name:str:seed,target:handle:1:1};stamp:1:1;/resource:100,101,:null//0//1/1
```

The foreign snapshot is unchanged in every case:

```
2/2/1/01/2/1/row1={cells:[u32:21,u32:22],name:str:seed,target:handle:2:1};stamp:1:1;/foreignresource:300,301,:null//0//1/1
```

The first admission is followed by an explicit event marker `[77]`, then the same admission is attempted again. `world.enqueue` stores a reverse accumulator; `W.barrier` applies the oldest pending closure first. Thus accepted deferred writes run as `first admission`, marker, `second admission`.

## 22-case selector matrix

The 11 selectors are run for both phantom schemas (`First`, then `Second`). The formatter contains no schema tag, so the 11 `Second` lines must byte-match the 11 `First` lines.

| selector | route | payload target | operation target | expected admission result | final state family |
| ---: | --- | --- | --- | --- | --- |
| 0 | component spawn | foreign `2:1` | ignored by spawn | validation refusal (`same-world handle`) | base |
| 1 | component insert | foreign `2:1` | own `1:1` | validation refusal | base |
| 2 | resource replace | foreign `2:1` | n/a | validation refusal | base |
| 3 | component spawn | zero `1:0` | ignored by spawn | validation refusal (`id > 0`) | base |
| 4 | component insert | zero `1:0` | own `1:1` | validation refusal | base |
| 5 | resource replace | zero `1:0` | n/a | validation refusal | base |
| 6 | component spawn | own `1:1` | ignored by spawn | accepted; two deferred spawns | spawn |
| 7 | component insert | own `1:1` | own `1:1` | accepted; two deferred replacements | insert |
| 8 | resource replace | own `1:1` | n/a | accepted; two `tx_replace`s | resource-own |
| 9 | component insert | own `1:1` | foreign `2:1` | validation succeeds, entity delivery refuses | entity |
| 10 | resource replace | `null` | n/a | accepted; two `tx_replace`s | resource-null |

Foreign payload and foreign operation target are intentionally separate: selector 9 has a valid same-world payload but a foreign `Insert` target. The zero target is rejected by the codec before any operation because `HandleValue` requires a positive ID.

For selectors 0--5, the checked text is a rejection with `$.target:same-world handle:<actual raw handle>`, the incoming owner is returned, and `host:not-attempted` is reported. Selector 9 has accepted canonical checked text, returns the incoming owner, and reports `host:rejected:MissingEntity`. Selectors 6--8 and 10 report accepted canonical checked text, `none;`, and `host:accepted`.

The canonical accepted object has field order `cells`, `name`, `target`; raw rendering has no trailing array/object commas:

```
{cells:[u32:41,u32:42,u32:43,u32:44],name:str:incoming,target:handle:1:1}
```

Change the target rendering to `handle:2:1`, `handle:1:0`, or `null` for the other input classes. Typed incoming text retains the same target text and a trailing semicolon.

## Final state transitions

All final snapshots include event text `77,`, pending count `0`, empty registration text, `nextSystemId=1`, and the unchanged foreign snapshot above.

- **base** (selectors 0--5 and 9): first world remains at the initial state, with `resource` and seed row unchanged and `clock=1`.
- **spawn** (selector 6): reservations allocate IDs 2 and 3 before the barrier; FIFO execution activates/populates them. Final metadata is `nextId=4/highWater=3/live=0111/capacity=4/depth=2/clock=3`. Row 1 remains seed `1:1`; rows 2 and 3 are incoming with stamps `2:2` and `3:3`.
- **insert** (selector 7): the two queued replacements both target row 1. Final metadata remains `nextId=2/highWater=1/live=01/capacity=2/depth=1`; row 1 is incoming with stamp `1:3`, and `clock=3`.
- **resource-own** (selector 8): the resource is incoming with target `1:1`; component row/stamp and clock remain at seed/`1:1`/`1`. The old resource is only the transaction undo value and is not a retained-resource output field.
- **resource-null** (selector 10): same as resource-own with resource target `null`.

The formatter’s row loop must retain absent rows as `none;stamp:0:0;`; in particular, the foreign world has row 2 absent only if its source snapshot has `nextId=2` (the current source does), while the spawned first world has rows 1--3. No model may infer row contents from live bits alone.

## Rebinding conditions

This audit is valid only for the three source hashes above plus the exact core closure used by the owner’s freeze. A source change affecting `main.bend` target mapping, `handle-application.bend` route/capability wiring, `handle-controls.bend` row traversal/formatter, world queue/barrier, component stamps, or resource replacement requires regenerating the expected model. No runtime output has been used as an oracle input.
