# Persistent Main Slot staging and ingress controls

**Bounded pass; #21/#24 and full22 remain incomplete.** Independent fresh controls
bind the actual 29-source Slot Host closure
`4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c`.
No source, compiler/kernel, authored Host body, dependency or law is changed.

The original [staging control](../fivehour-connected-gates/staging-controls.py)
checks `X.tx_stage_command` with a Cache-shaped command. Its raw-ID fixture
cannot establish foreign-world command behavior. This package separates that
Type boundary from executable actual command ingress and owned payloads.

## Reached routes and observations

- Actual `cached-payload.bend` declares affine `PrototypeMotionMainSlot` and
  `PrototypeHealthMainSlot`. For both concrete schema/world/command types,
  `X.tx_stage_command` accepts `S.InsertMain` containing that Slot. Raw components,
  old Cache wrappers and the other schema's Slot are refused at `stage`, with
  exact expected/observed diagnostics. Actual `C.insert_main` refuses the other
  schema's handle; duplicating the affine Slot is refused. **2 positive and
  10 intended negative type cases**, not ECS proofs or universal authority.
- `I.factory → I.create → C.reserve → C.apply_checked` creates two worlds in
  one factory lineage and makes ID1 live in each. No caller-selected world
  namespaces or independently minted factory roots establish isolation.
  Actual reserve-produced local/foreign handles are threaded through the tests.
- Receiver queue preparation uses actual `C.reserve`, then `C.despawn`,
  `C.remove_flag`, `C.remove_main`, `C.insert_flag`, and `C.insert_main` on its
  retained local handle. All six command variants remain pending. No invented
  queue publisher stands in for these public APIs.
- `C.queue_owned → queue_checked` is reached by five foreign calls
  (`insert_flag/remove_main/remove_flag/despawn/insert_main`). Every call must
  return `CommandMissing`; final observation compares the entire pre-existing
  queue and live receiver Main before/after. Full returned foreign InsertMain
  payload is observed. A subsequent actual same-world InsertMain must queue its
  payload while the live component still retains its deferred pre-barrier value.
- `S.with_main` observes the receiver's live Slot; owned-array reads thread the
  original owner back. The fixture renders every raw array element, raw metadata
  and cached scalar/metadata field. Depths0–4 cover physical sizes1/2/4/8/16,
  including values beyond the public four-element view.
- A separate actual factory-created world/reserved handle runs
  `X.tx_begin → tx_stage_command(32) → tx_stage_ping(81,82) → tx_finish_success`.
  Every ordered InsertMain payload and both pings match an independently generated
  Python oracle at each depth. **640 complete Slot payload observations** over
  both schemas/backends; this is not inherited from the old generic1024 fixture.

Both schemas run emitted JS and privateClang19 Native, yielding **40 complete
printed checkpoints**, with **100 foreign API calls** in those finite traces.
`fixtures.py` derives expected array/cached values and queue/staging order directly
from prescribed inputs; it does not decode Bend output to produce the oracle.
Runtime uses Unit auxiliaries/flags/ledger/mode to isolate Main ownership and
command ingress. Concrete production-shaped ledger/aux/flag/mode types are
checked at the Type boundary, but their runtime behavior belongs to other gates.

## Live semantic defects

Four private source-copy mutations each **typecheck and run** on both schemas
and JS/Native, and disagree with the unchanged full oracle:

| Defect | Actual source anchor | Observed detection |
| --- | --- | --- |
| Accept foreign handles | `commands.queue_owned` namespace condition → True | `BAD_QUEUED` |
| Reject local handles | same condition → False | `BAD_SEED_MISSING` |
| Clear queue on foreign refusal | `queue_checked` False branch drops receiver pending | Full queue comparison becomes False |
| Drop staged command | `transaction.tx_stage_command` omits command prepend | Empty Tx command output with pings retained |

These are **16 compiling/detected schema/backend roles**, not a claim that every
incorrect implementation is caught. Source copies and exact outputs are archived.

## Reproduce and limits

```sh
python3 experiments/s-prep/source-slot-staging/run.py \
  --overlay /tmp/bendvy-slot-host-v1 --output /tmp/bendvy-slot-staging-final-r2 --cpu 6
python3 experiments/s-prep/source-slot-staging/mutants.py \
  --baseline /tmp/bendvy-slot-staging-final-r2 \
  --output /tmp/bendvy-slot-staging-mutants-r3 --cpu 6
```

Baseline and mutant fixtures are byte-identical. Baseline records recipe/toolchain
hashes, world namespace/allocator state and exact output equality. Manifest checks run before and after baseline;
core imports must remain inside the exact source directory. Checker15s applies
only to these approved executable diagnostics; default/proof5s is unchanged.
Emission30s, privateClang120s, runtime5s; CPU6, Native O3/oneworker/GPUoff.

[Summary](summary.json) and [archive manifest](evidence/manifest.json) retain all
observations, original source closure, fixture/generated C/JS, private Native
artifacts, commands and decoded-member SHA256 verification. Preparation failures
are preserved: grammar/helper ordering, missing Base names, affine binders and an
initial oracle preparation error (Base renders `True`, and `S.publish` preserves
the supplied list). They were repaired in the fixture/oracle without changing
core source or accepting an import/parser error as a negative type gate.

**Open follow-ups:** actual Slot Host dispatch/provider execution and original
full22 fixtures/metric mutations; independent undeclared-access/write-through-read
provider controls; arbitrary affine component/generic fallback coverage; runtime
aux/resource/flag/mode payloads; global factory-root unforgeability; universal
runtime refinement and approved ECS proofs; qualified five-family/three-size
performance. No elapsed speed measurement, qualified keep, attempt reset or
product/fullcore acceptance follows from this package.
