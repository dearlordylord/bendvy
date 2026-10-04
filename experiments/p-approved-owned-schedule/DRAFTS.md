# Unverified full owned-schedule composition drafts

These artifacts preserve unfinished work after checked checkpoints `9872b85` and
`e2bd91c`. They are **not executable checker subjects, checked proofs, or evidence
that the full endpoint is complete**. The `.bend.draft` suffix intentionally prevents
ordinary `.bend` imports from resolving them. Internal import paths record the
intended future layout; no verified module or runner imports these drafts.

| Preserved artifact | Intended path | Intended role |
| --- | --- | --- |
| `LAWS.bend.draft` | `LAWS.bend` | Exact approved live affine-world law block |
| `PROOF.bend.draft` | `PROOF.bend` | Endpoint filling wrapper |
| `advance.bend.draft` | `advance.bend` | Actual four-constructor runtime step dispatch |
| `bump-rows.bend.draft` | `bump-rows.bend` | Owned Bump traversal and member-guard extraction |
| `endpoint.bend.draft` | `endpoint.bend` | Initial capture, unchanged independent guard, final composition |
| `full-controls.bend.draft` | `full-controls.bend` | Proposed full-proof mixed and false-domain controls |
| `schedule.bend.draft` | `schedule.bend` | Dedicated owner-threaded recursive tick induction |

The immediate residual is the exact guard conversion
`G.row_safe(G.Overflow{},Row{toNat(id),toNat(value),tag}) == U32.is_lt(value,MAX)`.
The current Bump draft fails before that conversion completes: its `overflow_row`
wrapper unfolds the large maximum Nat and causes a machine-stack overflow.
Independent probes have subsequently checked descriptor/observer wrapper links,
but the remaining universal source-definition unfolding
`S.no_overflow_lookup(Found{Row{idNat,valueNat,tag}})` to
`Bool.not(Nat.is_ge(valueNat,U32.to_nat(MAX)))` still failed in the tested proof
shapes. Alternative probes produced stack overflow, stuck function equality, or
hit the unchanged five-second limit. These failures establish neither mathematical
impossibility nor a counterexample. No core, predicate, domain, or approved law
change is proposed here.

The assembled `advance`, `schedule`, `endpoint`, and full `PROOF` closure have not
passed the checker or kernel. Guard-conjunction specialization, affine recursion,
and final composition may have further errors once the immediate blocker is
resolved. The mixed fixture's independently evaluated expectations passed, but
its call through the full universal proof has not been checked.

`full-witness.bend` remains a separate **checked** preparatory artifact: its original
independent safe premises and complete equations pass; the two compiling runtime
mutations falsify their respective complete equations. As the existing README
states, those witness checks do not replace the still-missing universal endpoint
proof and its own mutation gate. The verified runner remains unchanged and excludes
all files listed above. The root endpoint TODO remains open.
