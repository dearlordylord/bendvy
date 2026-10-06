# Integrated private cursor-to-row handoff diagnostic

Base: immutable Slot Host source4baa (`4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c`). Current candidate: `/tmp/bendvy-slot-host-handoff-v7`, closure `a9a2fa20913658b9561056e660803e3afd74870f321ff3a30c839e62fa44a56b`. This is a new bounded source experiment, not production API, proof, full22 or performance acceptance. The original Slot Host service algorithms are untouched.

## Exact route

Only query/held-adapter/measurement change. Original Q/HA prefixes are byte-identical; all original measurement declarations except two private tick invocation arguments are identical. Two new invoke functions call the new entry with the **original** `SC.motion_body`/`SC.health_body` callbacks; initialization, dispatcher/capture/clock/log/Audit, commit and post-write queries remain.

`prototype_packed_{motion,health}_tick` → new `prototype_handoff_{motion,health}_invoke` → `HA.prototype_handoff_flatfold_{motion,health}`.

- Accept the complete incoming `X.PrototypeFlatTx`: World, selected handle, flat undo, commands, pings, marks and total. LedgerNone runs the original Q cursor + original HA fold **before any evacuation**, including its nonidentity Main callback behavior.
- LedgerSome checks `Array.size(Maybe<Slot>,columns)` without inspecting or duplicating payloads. If physical size is below declared capacity, run the original query/fold unchanged.
- Otherwise Q clones the original descending ID/capacity/live/flag/selection/Main checks in the same order. Selected Some owners move into nominal affine `PrototypeHandoffRow<Schema,M:Type>` and `List<&1,...>`; columns retain None at these cells. Prepend during descending scan gives ascending callback order. No callback runs during scan.
- `PrototypeHandoffBatch<Schema,M,A,F,L,Mode>` owns the entire World context and every detached Main together. HA drain consumes one row, passes `(columns,Some{owner})` directly to the **unchanged** old packed taken helper, original rank2 row invoke/providers and returned helper. Returned Main is reinstalled once; remaining owners stay exclusively in the batch/drain. Namespace binds to this owning World, not a separately supplied receiving World.
- A None-ledger drain branch first recovers **all current and remaining owners** and their original ascending Data IDs, then calls the **original** cursor loop. Its returned nonidentity World is authoritative: no stale detached owners are reattached afterward. Finish/rollback/storage commit are original functions and see fully restored columns.

Generic Q carrier/restore functions accept arbitrary affine `M:Type`, `A:Type`, `L:Type`; no Data conversion of owners. Private consumers specialize nominal Slot payloads, while all generic/public ECS routes and original opaque callback headers remain. Snapshot/Data view fields and raw owning arrays are transported by existing providers.

## Guard rationale and API limits

V2 exposed a real malformed-capacity bug: size1/capacity2/high2 aliases both logical IDs; original query restores the owner and visits both, while evacuation visited only one. Preserve that failed candidate and its independent executed witness. V7 checks actual physical size before evacuation and uses the original path for that mismatch.

A size guard is justified here by the **compiled representation**, not a universal source theorem: independent JS/Native canary executes balanced arrays and observes ragged unequal-child construction fail-stop before size/swap; Native `blk_node` class equality and JS `array_node` equal-length checks enforce balance. See independent `source-cursor-row-handoff-review` runtime-canary package. No foreign/FFI array admission or universal model/runtime refinement is claimed. A temporary full topology traversal was retained as v6, then removed after this actual runtime evidence; it would cost O(n) each frame.

The batch constructor and Q producer remain exposed experimental helpers. Callers can extract an ordinary World with temporary holes or directly bypass HA's ledger/size precheck. **Types alone do not establish production confinement.** The checked diagnostic uses only the closed producer/drain call graph above; no authored callback or generic World observer receives future holes. A production opaque constructor/receipt boundary needs a separate specification and fresh authority gates. Partial batch drop, forged batches/IDs and external helper calls are outside this admission; every internal exit must drain or recover all owners.

## Own fresh checks

- Three executable module checks on v7, CPU10, actual argv/exit/source hashes; authorized diagnostic15, unchanged default/proof5. `--verdict` and ECS proofs are not run.
- Exact source29/cache maps/digests and original-definition audit (`verify.py`); new guards do not mutate original algorithms or public headers.
- Fresh Motion and Health **actual entry registration** typing: two declared read/write positives and four intended negatives each (undeclared other-schema provider, wrong token, concrete write in read-only scope, affine owner clone). Each callback retains the expected `Owner & U32` contract, so negative diagnostics identify the intended owner/token violation. Scope is finite opaque callback typing, not Batch/API confinement or runtime acceptance.

Runtime/full65/true-old undo/rollback/selection/mutation checks are independently executed by sibling tasks against their own v7 source pins. Their acceptance must come from their fresh receipts, not this package's module checks or earlier v2/v6 passes. Root owns comparative observations; no speed claim here. New row/list transport may add constructors or packing, so avoiding duplicate validation/take does not establish net savings.

## Failure history and replay

V1: missing explicit `+ns` copy permission in recovered helper. V2: checked source, then actual capacity-alias divergence. V3: materializer NameError left only copied baseline4baa; its later checks are **not candidate checks**. V4: tuple-pattern parser failure. V5: checked but C emission failed open erased Array element type. V6: frozen `~T` topology helper fixes emission and independently executes; then superseded by minimal v7 after representation canary. Every consumed root remains immutable; recipe snapshots bind their exact source versions. Access v6-r1 expected unqualified diagnostic names; actual frozen `body~Owner`/`read_scope~Owner` rejections were preserved and subsequent exact classifier corrected.

`derive.py --source BASE --output FRESH` checks exact base29/manifest/cache before copying. It creates coherent new29/cache digests; use `verify.py --candidate FRESH --output FRESH_JSON` and `check.py --candidate FRESH --output FRESH_DIRECTORY`. `access.py --schema Motion|Health --overlay FRESH --output FRESH_DIRECTORY` runs the finite controls. No original core/shared runners/references/compiler/dependencies change. The source delta and portable exact evidence are packaged alongside this recipe; verify archive hashes before replay.
