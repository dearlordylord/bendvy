# Independent flat-journal v4 source review

Read-only review of worker commit `ebaa83e`; no candidate, compiler, oracle or reference edits and no new runtime executions. The exact 29-source closure is `bdba8a91c1b56f4961217454139b79dc5c1614ab2301f4dae766a0cd70934bb3`, derived from join `49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38`.

No concrete semantic regression was found in the inspected source. This finding is bounded to the implementation and receipts listed below; it is not universal refinement, production API approval, proof or performance acceptance.

## Source findings

- Recursive inverse and mark constructors retain namespace/id and scalar old values. They do not turn World, component owners or commands into Data. Main/Aux/Ledger remain arbitrary affine Type slots. Legacy conversion preserves head-to-tail order and inverse replay applies each head before its tail, matching original LIFO rollback ([transaction.bend](/tmp/bendvy-flat-journal-v4/experiments/s-integrate/transaction.bend:141)).
- Generic fallback materializes the complete legacy transaction, invokes the original callback/provider route and repacks every returned field. It does not assume returned-owner identity. Successful writes prepend true-old inverse/mark entries; failed writes preserve the original journal.
- Success reverses commands and pings exactly as before; publication reverses commands again before the unchanged publisher. Failure drops commands/pings/marks and unwinds inverses. The two reversals must remain: pending observation order is reverse chronological ([finish and unwind](/tmp/bendvy-flat-journal-v4/experiments/s-integrate/transaction.bend:165), [publication](/tmp/bendvy-flat-journal-v4/experiments/s-integrate/transaction.bend:187)).
- Direct flat mark publication retains namespace, positive-id, capacity, high-water and live guards. Repeated marks write the same tick; foreign/dead/out-of-range marks remain ineffective ([mark loop](/tmp/bendvy-flat-journal-v4/experiments/s-integrate/transaction.bend:178)).
- Source verification retains original transaction/Held prefixes, public headers, authored callback bodies and all measurement definitions except the two concrete invoke redirects. Only transaction, held-adapter and measurement source bytes change ([verifier](/tmp/bendvy-threehour-native-attribution/experiments/s-prep/source-flat-journal/verify-source.py:12)).

## Evidence and corrections

Worker receipts were inspected, not rerun or claimed as this review's newly executed gates.

- Protected Tx point fixtures explicitly use private finish/failure/publication, including incoming legacy inverse/marks, commands and pings. Pre-observation materializes and repacks journals; this is distinct from the fully flat dense path ([adapter](/tmp/bendvy-threehour-native-attribution/experiments/s-prep/source-flat-journal/local-provider-controls.py:116)).
- Direct no-materialization marks cover both schemas/backends: 32 complete observations, foreign-only stamps `[4,6]`, mixed/repeated valid stamps `[9]`, `[9]`, `[9,9]`, literal pings and pending order ([receipt](/tmp/bendvy-flat-journal-direct-marks-v4-pending-order/evidence.json)). The initial FIFO display expectation failed and was corrected to the original route's `[Despawn2,RemoveFlag1]`; the failed receipt remains retained. This is a fixture expectation correction, not a demonstrated candidate semantic failure.
- New private boundaries report four positives and twelve intended negatives; arbitrary array-owning Main/Aux/Ledger row/fold examples and clone-kind negatives pass ([boundary receipt](/tmp/bendvy-flat-journal-boundary-v4/evidence.json), [owned receipt](/tmp/bendvy-flat-journal-owned-v4/evidence.json)).
- Worker package records fresh v4 full65 in all four schema/backend lanes, protected Tx576, and compiling omitted-mark/omitted-inverse detection. The CLI `inverse-order` label here denotes omission, not an order mutation; no order-mutation gate should be inferred ([worker report](/tmp/bendvy-threehour-native-attribution/experiments/s-prep/source-flat-journal/README.md)).
- Review identified an initial recipe provenance gap: input closure/cache maps were not fully guarded. The final verifier now pins baseline closure and source membership and requires embedded/standalone cache maps to equal current sources. Candidate Bend bytes remain unchanged ([guards](/tmp/bendvy-threehour-native-attribution/experiments/s-prep/source-flat-journal/verify-source.py:8)).

## Remaining limits

Private helper names are importable; naming is not a language-level privacy barrier. Finite boundary/owned examples support this concrete registration and do not establish universal authority or alias safety. Scalar journals specialize the existing concrete U32 inverse contract, not arbitrary generic inverse payloads. The general original API remains present.

No new defect was identified, but universal rollback/refinement, full22/law/proof acceptance and product performance remain open. No timing conclusion follows from source shape or constructor counts. The minor query transport experiment in this folder is separate and is not combined with v4.

## Join readiness checklist (before a ledger/journal join exists)

The standalone Owned witnesses have a narrower meaning than a returned-owner control. `generic_read` reconstructs the same private row owner; the fold witness only constructs/destructs its private state ([row witness](/tmp/bendvy-flat-journal-owned-v4/generic-owner/generic-owner.bend:9), [fold witness](/tmp/bendvy-flat-journal-owned-v4/generic-fold/generic-fold.bend:23)). Neither establishes a nonidentity returned-owner round trip through the reached private fallback.

For a new ledger/journal owner route, run these fresh source-bound gates rather than transfer standalone receipts:

- A reached fallback with an abstract rank2 callback using supplied get/set/ledger/setledger providers, including a mutation and subsequent observation of the returned owner. Callback opacity must remain intact. Assert repacked World, selected handle, inverse/mark tails, commands, pings and full immutable cached views; success/failure finalization must use that returned state. Arbitrary affine owner storage remains a separate positive/clone-negative check.
- Original callback/body/header/kind pins and actual measured registration checks on the joined source; provider positives and live provider mutants, plus factory semantic comparisons. Original-prefix preservation and the private boundary negatives do not replace these runtime gates.
- Actual joined cached/raw protected Tx, suppression, live omitted-inverse/mark detection, direct recursive mixed-mark publication, and both-schema/backend full65 observations. Record which route each fixture reaches; a point wrapper that materializes legacy state does not establish the fully flat dense path by itself.
- Exact joined source/cache closure, fail-closed recipe input pins and deterministic materialization. Joining two passing recipes is not itself an independently passing source closure.

No joined source or gate is yet claimed by this checklist. No additional runtime was executed by this reviewer.
