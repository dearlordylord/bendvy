# P-OBS #18 query lane — partial proof progress

**None of the three approved complete query endpoints is proved.** This package
preserves their exact statements and provides checked contextual machinery plus
a small reproducible diagnostic for the remaining general bridge. It changes no
subject implementation, approved domain, dependency, allocator policy or runtime.

## Exact subject and gates

`LAWS.bend` is the byte-for-byte three-law block extracted from the approved
`experiments/t11-replacement/LAWS.bend`, SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
Only import paths change to import the original `types`, `model` and independent
`spec`. The source 31-law file remains untouched. The three IDs are
`query_any_complete_ordered`, `query_present_complete_ordered` and
`query_absent_complete_ordered`. All remain open in this separate package;
`attempt.bend` is failing research, deliberately not named `PROOF.bend`.

Read the installed guide and skill, inspected Base comparison/list/equality
facts and searched the installed Bend directory/repository for `PUBLIC_API.lock`.
No existing mathlib index or sorting/enumeration theorem was found there. This is
an inventory of those locations, not a claim that no such library exists.
No dependency was installed. The pinned reference commits match the manifest.
`evidence.json` freezes compiler/Base, source, proof helper and runner hashes.

## Contextual helpers and their purpose

The following proof-local toolkit is narrower than the approved endpoints and
neither fills nor assumes any of the other 24 catalogue contracts:

- `when_known`: introduce `S.When` from an actual claim inhabitant; it is not
  either conditional-encoder equality law.
- `enumerate_empty`: independent enumeration of empty physical rows is empty for
  arbitrary fuel, starting slot and selection. This is universal over that
  specialization, not over nonempty worlds.
- `cmp_reflexive`, `cmp_zero_right`: Nat key comparison steps for count/bound
  reasoning, with structural induction/cases.
- `FalseCase`, `false_true_absurd`, `and_left`, `and_right`: contradiction and
  conjunction extraction from an existing invariant equality witness.
- `ZeroCase`, `zero_succ_absurd`, `at_zero_head`, `at_count_zero`: zero count
  implies the actual independent `S.at` returns missing, including all Cmp
  decisions and arbitrary lists.
- `count_self`, `predecessor`, `unique_head_tail_zero`: count at a row's own key
  exposes its tail contribution; a unique head implies no occurrence in its tail.
- `guarded_from_rows`: checked implication-shaped endpoint decomposition. Its
  bridge is an explicit required proof argument, not an axiom or a supplied
  inhabitant. It extracts exactly `S.rows_valid(rows,rows,next)` from the true
  `S.admissible` branch and retains the original false-domain Unit branch.
- `empty_world`: checked conditional query equality for arbitrary namespace,
  frontier, pending list and selection with empty physical rows only.

`helpers.bend`, `contextual.bend` and `controls.bend` pass both checker and
kernel, under the existing five-second wrapper. The controls explicitly check
an active admissibility premise and Any/Present/Absent empty-world instances.
Three compiling decision-path mutants fail unchanged contextual proofs:
nonmatching independent lookup emitting a row (`at_zero_head`) and empty model
query emitting a ghost (`empty_world`), and incorrect Present eligibility (`eligibility`). These validate contextual dependencies;
**they do not pass the mutation gate for any complete endpoint**.

## Remaining exact bridge

The attempted general theorem is:

```text
True == S.rows_valid(rows, rows, next)
  => M.query_rows(selection, rows)
       == S.enumerate_rows(next, 0, rows, selection)
```

The checker accepts its empty-row branch. In the nonempty branch the exact
residual is:

```text
M.include(M.accepts(selection, tag), Row{id,value,tag},
          M.query_rows(selection, tail))
  == S.enumerate_rows(next, 0, Row{id,value,tag} :: tail, selection)
```

The context contains the independent count-one, `id < next` and remaining-row
validity predicates over the **original whole row list**. The remaining proof
must connect these premises to insertion order, bounded independent enumeration
and tail validity; it cannot reuse tail validity as though the `all` argument
had already changed. The attempt preserves the endpoint guard and original
functions. Both invocations exit 1 in the first checker before the kernel can accept the complete attempt; no
five-second timeout was hit. This is a missing mathematical derivation in this
bounded attempt, not a compiler limitation or a finding that the theorem is
false/impossible. No proof-completion or native/JS performance claim follows.

## Bounded continuation

1. Derive tail validity under the count-based whole-list predicate. Use the
   checked own-key/tail-zero steps and derive contextual count removal for other
   row keys; do not assume `admissibility_independent` or preservation.
2. Generalize enumeration to an arbitrary interval. Prove the contextual
   insertion equation for one absent key inside/outside that interval, including
   the actual eligible/accepts decisions, unique keys and unchanged row values.
3. Combine that equation with row induction and instantiate `[0,next)` to
   fill the exact three subjects. Prove completeness/ascending order via equality
   to the independent enumeration, not a smaller soundness/reversal property.
4. Only after a full endpoint checks, run isolated unchanged-proof compiling
   mutants and demand failure in that endpoint's own section. Maintain the exact
   statement and five-second limit; obtain approval for any genuinely additional
   standalone contract instead of silently adopting it.

Reproduce from the repository root:

```sh
python3 experiments/p-observe-queries/run.py
experiments/t01/bend-check experiments/p-observe-queries/attempt.bend --verdict
```

The runner exits 0 only when its contextual passes, exact subset verification,
reference/hash controls, expected blocked diagnostics and contextual mutant
controls all match. Its exit 0 means **partial-progress report verified**,
not `P-OBS #18` or a complete query theorem accepted. The second command is
expected to exit 1. No original Canonical Defense source was touched.

## Second bounded continuation: helper inventory (declared before execution)

The next attempt derives these contextual obligations, only for the approved
query proof: Nat Boolean equality reflection (including count-one); Nat equality
symmetry for key comparisons; zero-count head/tail extraction; removal of a
count contribution for a distinct key; Any/Present/Absent eligibility agreement;
tail validity when removing a unique head from the `all` list; and the remaining
interval ordering/bounds plus enumeration-insertion bridge. Each accepted helper
will be recorded separately; an unfilled bridge will remain failed research.

### Second tranche result

`invariants.bend` now passes checker **and** kernel: Boolean Nat equality
reflection, key symmetry/eligibility, zero-count decomposition, distinct-key
count removal, recursive absent-head removal and exact `valid_tail` are proved.
Universal `at_key` supplies key adequacy for rows emitted by independent lookup.
`zero_le`, `add_zero` and `le_lt_cycle` discharge the zero-fuel interval
contradiction. `rows_cons_from_insert` checks the final list-induction composition
from its explicit tail-equality and insertion-equality arguments. The nonempty,
physically unsorted tail control also passes. No new law is assumed.

The attempt now derives the tail premise and carries the original list
induction; its only open body is `insert_interval`, generalized to arbitrary
`slot`/`fuel`, inserted key in `[slot,slot+fuel)` and zero occurrences in tail.
The zero-fuel branch is discharged. Positive fuel leaves:

```text
include(accepts(selection,tag), head,
        query_at(selection, at(tail,slot), enumerate(rest,slot+1,tail)))
  == query_at(selection, pick(cmp(head.key,slot),head,at(tail,slot)),
              enumerate(rest,slot+1,head::tail))
```

This remaining bridge needs comparison cases, head exclusion after its slot,
and ordering of rows actually emitted by the independent enumerator. The runner
now expects the precise positive-fuel diagnostic at `insert_interval`; both
attempt invocations stop in the first checker there, **not** with a kernel
rejection. The full attempt remains failing research; eight contextual
checker/kernel runs and three compiling contextual mutants are current.

## Third bounded continuation: helper inventory before execution

Positive-fuel insertion will first use contextual exclusion of a row strictly
before the current enumeration slot: strict-order monotonicity to successor,
strict inequality excluding equality, actual independent head-lookup skipping,
and arbitrary-fuel head exclusion. These facts concern only enumeration for the
approved query endpoints and do not establish any standalone catalogue law.
The insertion case at the row's exact slot will combine the existing zero-count
lookup proof, eligibility agreement and exclusion from later slots.

### Third tranche result

Checker and kernel now also accept `lt_succ_right`, `lt_not_eq`, `skip_pick`,
`skip_head` and `enumerate_after`. The last theorem universally excludes a
physical head strictly before the logical interval's starting slot, for arbitrary
fuel, remaining rows, payloads and selection. The proof uses actual independent
lookup/enumeration definitions and recursively advances the slot; it assumes no
validity or ordering of the tail. This resolves future head exclusion after its
slot. Ten contextual checker/kernel invocations and four mirrored kernel
controls pass in the runner; the earlier three contextual mutant controls remain
separate from full endpoint acceptance.

The complete `insert_interval` positive-fuel body remains open with the exact
goal above. The remaining cases must derive actual emitted-row key ordering
from `at_key`, prove the exact-slot selected head inserts before all later emitted
rows, and commute ordered insertion through the before-head current-slot
`query_at` decision. Bounds must transfer to the recursive interval explicitly.
No full endpoint, no endpoint mutant gate, no performance gate has passed.
This checked exclusion toolkit is the bounded third-tranche delivery; it does
not stand in for those remaining mathematical derivations.
