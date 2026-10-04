# P-OBS #18 — three approved query proofs

**All three exact approved query endpoints pass checker, kernel and compiling
own-endpoint semantic mutant gates:** `query_any_complete_ordered`,
`query_present_complete_ordered`, `query_absent_complete_ordered`.
This completes the query lane, not the remaining #18 laws or the full ECS.

## Exact scope

`LAWS.bend` is the byte-for-byte three-law block extracted from the approved
31-law file, SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
Only import paths change; subjects import the original types, model and
independent specification. The original 31-law file and implementation remain
untouched. The exact independently defined `S.admissible` premise and false-domain
Unit branch remain intact. No remaining support catalogue law is filled/assumed.
No dependency, allocator policy, payload scope or numerical threshold changes.

## Proof decomposition and inventory

`helpers.bend` provides conditional introduction, empty enumeration,
Nat-key reflexivity, conjunction extraction, count-zero lookup and unique-head
count reduction. `invariants.bend` derives Boolean equality reflection,
distinct-key count removal and the actual changed-whole-list tail validity;
it also supplies selection agreement, emitted-row key adequacy and interval
arithmetic steps. These contextual obligations were inventoried before execution
in the preceding commits and do not fill the other catalogue contracts.

`order.bend` relates opposite key comparisons and transfers interval bounds.
`intervals.bend` proves actual independent lookup skips a distinct head and
universally excludes a head below an enumeration interval. `insertion.bend`
proves insertion precedes later emitted rows, commutes with an earlier emitted
row and agrees with selected/rejected emission at the head's own slot. These
proofs use actual `S.at` key adequacy, not an assumed sorted-output property.

`complete.bend` proves interval insertion by fuel induction: the empty interval
contradicts its bounds; a head before the slot contradicts the lower bound; the
exact-slot case uses real count-zero lookup and future exclusion; the later-key
case transfers bounds and recurses, commuting insertion with the current row.
List induction then connects physical insertion sorting to independent `[0,next)`
enumeration using the derived count-based tail premise. The true admissibility
branch extracts exactly this row invariant; the false branch returns Unit.

`PROOF.bend` applies that result separately in the three original law sections,
matching the actual public `M.query` boundary. Universal equality to independent
ascending enumeration establishes exact result completeness/order within the
approved domain; it is not merely soundness, reversal invariance or literal tests.

## Verification

Run from the repository root:

```sh
python3 experiments/p-observe-queries/run.py
experiments/t01/bend-check experiments/p-observe-queries/PROOF.bend --verdict
```

The installed Bend guide/Base were inspected; Bend is 2.0.34. The installed
Bend directory/repository contained no mathlib `PUBLIC_API.lock`; no dependency
was installed. Reference commits match the tracked manifest. `evidence.json`
records exact compiler/Base/source/proof/runner hashes, commands and diagnostics.
All checker and kernel invocations use the existing five-second wrapper.

The runner checks the complete proof with checker and kernel, repeats each
unchanged endpoint in isolation with checker/kernel controls, and plants three
compiling public selection-dispatch defects in temporary copies: Any→Present,
Present→Absent and Absent→Any. Each original active-premise instance passes the
kernel; the mutant's independent premise remains true while its result equation
fails. Each unchanged universal proof fails in its own exact `Laws.query_*`
section, rather than a shared helper. Three earlier compiling contextual-helper
mutant controls also remain recorded separately. The runner exits 0 only when
these exact gates and source/approval/hash checks pass.

## Historical partial work and limits

`attempt.bend` preserves the prior deliberately failing interval research
checkpoint; its expected diagnostic is recorded as historical evidence. It is
not imported by the accepted proof and is not claimed complete. The earlier
empty-world and invariant controls are contextual evidence; they do not replace
the accepted universal proof. Earlier partial commits preserve the declared
helper inventory and concrete blockers that the completed proof resolved.

No proof of arbitrary Type payload preservation, owned runtime correspondence,
root confinement, transaction/readers, host IO or native/JS performance follows.
Other #18 stages and the full core remain gated. Canonical Defense stays untouched.

## Next approved contextual integration inventory

For the schedule/flush public observation obligations, derive generic Any-query
enumeration lookup adequacy in the same package: actual emitted-row lookup under
a distinct target; missing lookup below the interval; exact-slot lookup and
bounded inside-interval lookup; missing lookup at/above the upper interval
boundary; and pointwise/observation enumeration stability. These obligations
use the actual `S.enumerate_rows`/`S.at`, arbitrary raw row lists and pinned
emitted-key proofs. They are contextual links needed by approved endpoints,
not a proof of an additional catalogue contract, runtime authority or full-core
performance. Materialize-specific and Bump-specific facts remain other lanes.

### Contextual integration result

`enum-lookup.bend` passes checker and kernel and supplies:

- `lookup_inside(fuel,start,rows,target,lo,hi)`: original `S.at` equals lookup in
  Any materialization for exact inside bounds.
- `lookup_below` and `lookup_above`: materialized lookup is Missing outside the
  interval; the upper boundary is excluded.
- `enumerated_slots` and `related_enumerations`: a structural interval lookup
  relation and its independent enumeration congruence, without copying an affine
  proof callback.
- `enumeration_stable(fuel,start,rows,selection)`: same-interval selection before
  Any materialization equals selection afterwards.
- `observation_stable(id,next,rows,pending)`: the independent public observation
  remains equal after `[0,next)` Any materialization.

These are universal for arbitrary raw row lists, including physical disorder,
duplicate keys and out-of-range rows; they add no product policy for malformed
worlds. `enum-controls.bend` additionally checks the first duplicate result,
below/at-upper/above interval boundaries, zero fuel, arbitrary selections and
unchanged namespace/frontier/pending observation. The current runner rechecks
these helpers, the three full query endpoints and all prior own-endpoint mutant
gates. Flush/schedule lanes may import this exact committed package; their
materialize/Bump/transition premises and endpoint gates remain their own work.
