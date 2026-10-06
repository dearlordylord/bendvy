# Private cursor → row owner handoff: bounded feasibility

Source analysis is bound to immutable descending source `b0fdd6c41be12b34efc79e45edc98225c1b0158a51976b432a1646bfcae9e8f0`, `/tmp/bendvy-private-id-query-descending-v1`. Neither b0 nor Slot Host4baa is changed. This package is a standalone typed miniature and architectural follow-up, not an integrated candidate, new ECS law/proof, production API or performance result.

## Actual repeated work

`query.bend:284–288`: selected query membership takes a Main with `Array.swap(...,None{})`, inspects Some/None, restores the same opaque Main with Array.set, then prepends its ID. Descending scan finishes before any authored callback. `measurement-bend.bend:452,547`: the private entry receives World+cursor, then begins/packs the transaction. `held-adapter.bend:791–798`: ascending ID loop constructs a typed Handle and calls the unchanged packed fold step. `held-adapter.bend:664–680`: the step rechecks namespace/capacity/high, ledger presence, live membership, and takes the same Main again; the taken helper invokes the original rank2 row client, and returned helper reinstalls its returned Main.

## Source sketch

Private nominal affine types:

```text
DetachedRow<Schema:Data,Main:Type> = { id:U32, main:Main }
HandoffBatch<Schema:Data,Main:Type,Context:Type> =
  { original complete World context, evacuated columns,
    affine List<&1,DetachedRow<Schema,Main>> }
```

The batch owns all World fields and detached owners together; it must never publish an ordinary World containing temporary holes. A private query first checks ledgerSome. LedgerNone takes the existing query+fold fallback **before evacuation**. The existing descending presence/selection scan moves each Some into the affine row list; prepend yields ascending consumption. No callback runs during the descending scan.

The consumer keeps complete context outside the original opaque row capability, passes `(columns,Some{main})` directly into the existing `taken`/rank2 invoke/returned family, and consumes the returned Main exactly once. Namespace/schema membership is attached to the owning batch; there is no separately supplied receiving World to alias. The current Main is reinstated at row return; remaining owners stay in the batch. Commands, marks and FIFO effects execute after complete drain, as before. If any route needs the original generic World, first rehydrate **all** detached rows, then invoke the original fallback. Do not hand a world with holes to a generic callback/provider/observer.

## Hazards and required later gates

- Interleaving callbacks with descending inspection changes callback/undo/mark order. The two-phase scan then ascending callback phase must remain.
- Detaching future Main owners changes physical World membership. Existing row providers can inspect only their selected Main and ledger; they must not receive the batch or future columns. Any generic whole-World path requires complete recovery first. General clients and nonidentity returned owners need fresh executed witnesses, not an assumption that benchmark clients are identity.
- LedgerNone fallback, rejected/malformed IDs, missing/dead membership, foreign namespace, sparse selection and all immutable snapshots must retain the original observations. Check complete raw array trees and metadata, pending commands/pings, selected handle, true-old paired inverse entries and mark order, including failed transactions.
- Scope is arbitrary affine Main/Context; Data-only payloads or a duplicated Data owner list would be invalid. Nominal schema and affine kind checks are necessary but are not universal authority approval. Concrete constructors are not a production confinement design by themselves.
- Dropping a partially drained batch would discard components. Every successful/failure return must drain or recover it. JavaScript/C runtime faults are not a typed recovery mechanism.
- A Type row list may add record/node transport costs (DetachedRow plus list node instead of an ID node), and generated generic calls could pack the nominal Main again. Directly invoking taken with Some also adds a transient wrapper unless lowered away. Avoided swaps/validation do not establish a net speed gain. Allocation attribution and both-schema full workloads would be needed after actual integration.

## Miniature scope

`miniature.bend` demonstrates generic `M:Type` payload transport in `List<&1,DetachedRow<Schema,M>>`, owning Array payload recovery, and descending take2→take1 producing ascending rows1,2. It contains no original ECS callback, ledger fallback or complete World; those remain architectural requirements above. Its finite runtime checks and two type negatives are not an ECS proof or a passed integration gate. The final literal observer renders every cell and raw frame of both restored payloads; order observation consumes/restores both opaque owners without cloning them. Final v7 executes three literal records separately in JavaScript and Native. Affine clone and cross-schema controls reject at `bad`. The actual recovery owner-omission mutant passes checking/emission and executes in both backends; it produces exactly `7:missing`, `1,2,`, `7:missing`, detecting the intended lost owner. This is a miniature recovery counterexample, not an ECS mutant gate.

Preliminary checker failures are retained: restore recursion must put shrinking rows before changed columns; take_one must explicitly allow copying U32 ID; an incorrect String.concat call and an undefined `data` observer helper were subsequently corrected using ordinary string concatenation and a consuming Type-list renderer. The first two captures are terminal diagnostics, with no earlier source hash reconstructed; later failures retain exact subject snapshots and commands. `run.py` snapshots the final subject and records real commands/caps/stdout/stderr: executable check15, emit30, Clang19 compile120, runtime5 on CPU10; proof/default5 is unchanged. It checks intended affine-clone and cross-schema rejection. No authored benchmark algorithms or shared source files are changed.

`evidence/index.json` maps159 exact files to72 deduplicated objects (301KB), including original source29/cache/manifest, installed Base, preliminary failures, final v7 commands/programs/binaries/outputs and both mutation attempts. `verify-evidence.py` validates every archive/object hash without executing work. Fresh reproduction: `python3 run.py --output FRESH`; `python3 mutant.py --output FRESH`. The default/proof checker cap remains5s; these miniature executable diagnostics use the specifically authorized15s cap.
