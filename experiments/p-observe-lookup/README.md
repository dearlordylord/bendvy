# P-OBS stage 0/1 — exact total lookup proof

[GitHub #18](https://github.com/dearlordylord/bendvy/issues/18),
[approved proof task](../../docs/tickets/17-approved-observation-proofs.md).
**One approved endpoint proved:** `lookup_full_exact`, selected unchanged from
law SHA256 `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
The canonical 31-law proposal and model/spec are untouched; its remaining open
laws stay separate. This package does not prove the other six approved endpoints
or any of the 24 unapproved supporting candidates.

## Exact subject and argument

[subjects.json](subjects.json) freezes the original law block and canonical
source hashes. [verify.py](verify.py) mechanically checks the block, sole selected
ID and imports against those files; [LAWS.bend](LAWS.bend) changes only relative
import paths to select exactly the original type/model/spec subjects.
[PROOF.bend](PROOF.bend) fills that selected law for every world, handle and
selection, without an admissibility/reachability premise. Empty, duplicate or
out-of-counter row lists are included. The total model fixes first-row lookup
behavior; this does not endorse malformed states as a production API.

The original law/core hashes and exact selection were persisted before the first
proof check. The contextual helpers were developed in the proof source, with
checks during development; the explanatory inventory below was written afterward.
The ticket requested the helper-purpose inventory before execution, so that
documentation sequence is a recorded deviation rather than a claimed prior gate.
All helpers are now explicit for independent review.

The proof decomposes into narrowly contextual lemmas:

| Helper | Derivation / dependency |
|---|---|
| `comparison_sym` | Structural induction on Nat constructors proves the equality of the two row-search comparison directions. No U32 bridge or new arithmetic policy. |
| `eligibility` | Selection/tag cases connect the different predicate definitions. |
| `selected` | Bool cases connect Found/Mismatch constructors. |
| `node` | Comparison cases connect eager lookup selection to independent lazy `S.pick`/`S.describe`, given the tail equality. |
| `rows_correspond` | Induction on the entire arbitrary physical row list, using the tail hypothesis and comparison direction lemma. |
| `namespace_correspond` | Comparison cases connect actual local/foreign dispatch; EQ uses row induction. |
| `L.lookup_full_exact` | World/handle constructor elimination supplies actual fields to namespace correspondence. |

These ordinary contextual proof-local facts serve this approved endpoint; no
unapproved catalogue law is filled, assumed or duplicated under another name.
Only existing Base Nat/Cmp definitions, equality rewrites and the pinned pure
model/spec/types are used. No unsafe/foreign proof dependency or new dependency.
The kernel validates all imported safe definitions in this proof's dependency
closure; this is not approval or proof of their unrelated catalogue laws.

## Executed evidence and reproduction

```sh
BENDVY_PROOF_CPU=8 python3 experiments/p-observe-lookup/verify.py
```

The executor ran `bend version` (2.0.34) and `bend guide` before proof work.
Every checker/kernel call uses `experiments/t01/bend-check`, with five-second
kill limit. The runner's six-second process watchdog only detects wrapper failure;
it does not allow a checker past the wrapper's five seconds. Native/JS emission
and performance are unnecessary for this pure proof gate.

[evidence.json](evidence.json) records terminal **exit0 PASS**, exact commands,
outputs, source/Base/runner hashes and these distinct controls:

- General proof: ordinary checker and `--verdict` kernel both exit0, `ALL PROOFS CHECK`.
- Seven fresh literal expected-result controls: empty, local Found, selection Mismatch, colliding foreign Missing, duplicate first-row mismatch, live row outside counter and pending-only Missing. These ground observations; they are not the general theorem.
- `BENDTT=/usr/bin/false` produces an expected verdict failure, confirming kernel invocation.
- An exact copied unmutated package passes the kernel from the mutant's location.
- A semantic mutant replaces only actual `M.lookup` namespace dispatch with always-False. Its implementation still typechecks. The **unchanged general proof fails at `Location: L.lookup_full_exact`**, not a shared helper. A newly checked positive local Found instance, true on the original, also fails on that mutant.

One exploratory rewrite used the equality in the wrong direction and failed at
`rows_correspond`; swapping the contextual symmetry instantiation corrected it.
That error is not credited as mutation evidence. No core or approved law revision
was made to obtain the final pass.

## Limits and remaining stages

This establishes the exact total bounded Nat lookup equation, including its
experimental namespace comparison and physical first-match behavior. It does not
establish global root/handle provenance, owned runtime lookup, arbitrary payload
preservation, transactions/readers, real scheduler semantics, generated backend
correctness, host IO or performance. Independent-root constructors can still
collide under the old prototype; that full-authority gate stays open.
The other approved queries/flush/schedules and owned conditional correspondence
retain their separate proof/dependency gates. No allocator/exhaustion/foreign-command
policy, indexed layout or numerical threshold is adopted here.
