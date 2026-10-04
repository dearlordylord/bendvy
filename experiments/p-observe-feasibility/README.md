# Erased-owner proof feasibility

Bounded infrastructure probe for the approved `owned_runtime_schedule_correspondence` law. This directory proves no ECS correspondence theorem and changes no subject or approved statement.

Run `python3 experiments/p-observe-feasibility/run.py`. The runner uses the existing compiler, invokes every subprocess with a five-second timeout, checks expected diagnostics, and records output, elapsed time, source/compiler/Base hashes and reference commits in `evidence.json`. No dependency is added. `bend version` and `bend guide` were read before these probes.

## Results

| Probe | Observed result with `bend FILE --verdict` |
| --- | --- |
| Generic erased `R.World` observation reflexivity | `ALL PROOFS CHECK`, exit 0 |
| Match erased `R.World` inside proof body | Rejected: live scrutinee |
| Match erased projected `T.World` inside proof body | Rejected: live scrutinee |
| False elementary equality `0n == 1n` | Rejected: unequal endpoints |
| Exact seventh statement specialized to empty steps, attempted `{==}` | Rejected: non-inferrable term at unresolved `S.When` |
| Exact seventh statement specialized to one barrier, attempted `{==}` | Rejected: non-inferrable term at unresolved `S.When` |
| Prior `erasure-control.bend` | Accepted; defines a proposition and forwards a live owner |
| Prior `erasure-negative.bend` | Rejected; erased owner cannot become live result |

The first probe is stronger than merely defining a `Type`: it constructs an inhabitant of `{O.snapshot(world) == O.snapshot(world) : T.World}` for every erased affine owner. The kernel verdict also accepts it. Thus erased observations can occur in inhabited equality propositions. This establishes neither implementation/spec agreement nor any ownership-preservation contract.

Both schedule attempts preserve the approved predicate and equation and specialize only the `steps` binder. For empty steps, the checker reports:

```
S.When(S.admissible(U32.to_nat(limit), O.snapshot(world)),
  {M.observe(R.snapshot(R.project(world))) == S.observe(O.snapshot(world)) : T.Observation})
```

For a barrier the guard additionally requires step safety and admissibility of the independently flushed world. Neither guard reduces for a generic erased world. `{==}` cannot inhabit an opaque conditional proposition, and even the empty-step endpoints require a projection/observation agreement proof. Changing the guard to `True`, proving a literal world, or replacing the erased owner with a live parameter would not prove this approved specialization; none is used here.

## Checker mechanism and libraries

Pinned reference `bend2/bend2/bend.ts:3617` rejects matching an erased argument in a live region. The proof body is live; the equality endpoints are dead. The actual installed 2.0.34 checker agrees with this restriction on both owner and projected-Data probes. The reference checkout is a different revision/version and is not claimed to be the installed binary's build source.

Installed Base supplies `Equal.cong`, `Equal.sym` and `Equal.trans`. Inspection found no project `vendor/bendlib` and no `PUBLIC_API.lock`/mathlib catalogue under the project's vendor directory, installed `~/.bend`, or the installed bend-ldd skill directory. No library was installed, and no arithmetic theorem was reproved.

## Decision boundary

A straightforward live induction on `-world`, or a live case split on its erased projection, is unavailable. These failed attempts do **not** establish that every possible proof is impossible. An erased observation relation, suitable elimination principle or properly connected theorem might offer a legal route; such a route has not been demonstrated here. A proof-planning task must resolve the conditional-elimination and projection-agreement obligations before claiming that schedule correspondence is ready for routine induction.

The seven approved IDs remain the only approved public laws. No supporting catalogue law is promoted or proved. Runtime execution, payload identity, array-wide preservation, admissibility preservation, arithmetic bridges and universal ECS refinement are not validated by these canaries.
