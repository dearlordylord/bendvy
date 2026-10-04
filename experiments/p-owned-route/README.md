# Exact owned-schedule construction routes — unresolved encoding gate

[Issue #18](https://github.com/dearlordylord/bendvy/issues/18), approved seventh
subject `owned_runtime_schedule_correspondence`, original law SHA256
`e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`.
**No general owned theorem or arbitrary-world empty-schedule specialization is
proved.** This investigation identifies a concrete additional construction
obstacle and validates a legal witness-transport operation and an exact empty-row family; the extra witnesses
are absent from the approved signature. It does not declare all imaginable
proofs impossible. Pure model proofs and bounded integration research can continue.

[PLAN.md](PLAN.md) records scoped canary purposes before checking.
[subjects.json](subjects.json) freezes the exact original seventh statement and
all six subject-file hashes. Only this new directory is changed. There is no
new dependency, production/core modification, law revision or proof of another
catalogue claim. Installed `bend version` (2.0.34) and `bend guide` were read.

## What was actually checked

Run `python3 experiments/p-owned-route/run.py`. It rechecks original hashes and
all route diagnostics through the existing five-second `bend-check` wrapper.
Its six-second outer watchdog detects wrapper failure, not a longer proof limit.
The terminal exit-0 result verifies the expected diagnostic matrix, **not the
seventh theorem**. [evidence.json](evidence.json) records exact commands, outputs,
source/Base/kernel/checker-source hashes and reference pins.

| Route / control | Installed checker and kernel result | Meaning |
|---|---|---|
| `language.bend` | Accepted | Live Bool conditional introduction, elementary live Nat induction and transport from an actual live guard equality work. |
| `owner-diagnostic.bend` | Accepted | A tiny affine owner can be consumed once to compute a dependent conditional. This is a language canary, not an ECS theorem with its binder silently changed. |
| `dead-formation.bend` | Accepted | A dead local Nat proof can occur inside a returned Type. Merely forming this Type supplies no live proof of its contents. |
| `guard-witness.bend` | Accepted | A live Bool, a proof tying it to the actual empty-step guard, and a proof of the entire endpoint equality suffice to transport into the exact original result Type. All three inputs are explicit. |
| `live-empty-constructor.bend` | Accepted | Actual R.World empty-step conditional construction with the entire equality explicitly supplied. Its signature/body differs from the rejected erased constructor only by `-world` becoming `world` (and the function name), mechanically checked. |
| `empty-family.bend` | Accepted | Actual empty-step correspondence for arbitrary limit/id/next/pending with **empty live rows**, using R.tick/R.project and independent O/S. This is a checked non-literal family, not the arbitrary-world specialization. |
| `empty-instances.bend` | Accepted | At limit 2 and empty steps, world `{id=0,next=1,rows=[],pending=[]}` has an equality inhabitant; `{id=0,next=3,rows=[],pending=[]}` has a Unit inhabitant. These finite cases show both guard branches really occur with the same other arguments. |
| `erased-guard-negative.bend` | Rejected, `expected : -guard / observed : guard` | Calling conditional introduction with an erased Bool is not permitted. |
| `live-call-negative.bend` | Rejected, `-n / n` | A live structural theorem cannot be called on an erased input to obtain evidence. |
| `dead-proof-negative.bend` | Rejected, `-proof / proof` | A proof computed in an erased let cannot be returned as live evidence. |
| `dead-rewrite-negative.bend` | Rejected, `-proof / proof` | Equality transport does not make that erased evidence live. |
| `erased-field-negative.bend` | Rejected, `-proof / proof` | Putting proof evidence in an erased field of an otherwise live package does not enable extraction. |
| `erased-owner-forward-negative.bend` | Rejected, `-owner / owner` | The successful live-owner canary cannot be applied to an erased owner. |
| `empty-conditional-negative.bend` | Rejected, `-world / world` | **Even when the full empty-step equation is supplied as live evidence**, computing its actual guard for conditional introduction consumes the erased world. This isolates the conditional-construction issue from the separate projection/observation proof. |
| `empty-exact-negative.bend` | Rejected, unresolved `S.When`, `non-inferrable term` | The exact arbitrary-erased-world empty-step reflexivity attempt still fails. Its signature is mechanically matched to the prior faithful specialization. |
| `false-negative.bend` | Rejected, `0n / 1n` | Elementary false equality cannot pass. |
| `false-transport-negative.bend` | Rejected, `True / False` | Guard transport cannot invent its required equality evidence. |

The seven accepted files reach `ALL PROOFS CHECK` under `--verdict`. Ten negative
files fail in initial checking, so their `--verdict` invocations are **not**
independent kernel rejections. A separate `BENDTT=/usr/bin/false` negative
confirms kernel invocation on the accepted language file. The unapproved `PROPOSED.bend` is separately checked to retain exactly one open TODO. No timeout occurred.

A compiling mutant changes actual runtime projection to report the successor namespace. The copied empty-family positive passes the kernel; the unchanged family then fails at `equation`. This validates its connection to the actual projection rather than only independent oracle reflexivity. It is a mutation control for this shape-restricted family, not for the original seventh law. Its active empty-world case is separately witnessed in `empty-instances.bend`.

The family proof uses only narrower command-projection and empty-enumeration inductions. It does not prove the unapproved general owned projection law. An initial parenthesis typo in that file was corrected before the successful checker/kernel run; parse rejection is not credited as route or mutation evidence.

## Why the obvious alternatives do not supply the original proof

After specializing only `steps=[]`, the original obligation is:

```text
for +limit: U32
for -world: R.World
S.When(S.admissible(U32.to_nat(limit), O.snapshot(world)),
  {M.observe(R.snapshot(R.project(world)))
    == S.observe(O.snapshot(world)) : T.Observation})
```

Its two challenges are distinct: establish the actual projection/observation
agreement and construct a result of a conditional Type whose guard depends on an
erased world. Supplying the former as an input in `empty-conditional-negative`
still leaves the latter rejected. The legal `guard-witness` transport requires a
live representation of that guard plus a tying equality; the original function
has only live `limit` and `steps`, neither of which determines admissibility for
all erased worlds. Choosing True loses excluded states; choosing False loses
admissible states. The paired finite instances demonstrate this with fixed limit
and empty steps. A guard supplied by a caller would be a changed signature.

Dead computation may appear in Types, annotations and erased arguments. It
cannot be used as a live conditional discriminant, returned evidence, rewrite
evidence or extracted field. Consequently the tested dead-region and transport
routes do not justify an actual constructor for the unchanged arbitrary-world
claim. Generic observation reflexivity from the prior feasibility package remains
valid; it neither computes a guard nor equates the distinct implementations.

Source mechanism was inspected in the installed kernel
`/home/node/.bend/bend2/bendtt.lean`: its opening explanation, `Term.check` match
rules (live scrutinee), `Term.uses`/`Term.live` (rewrite evidence stays live), and
`Eval` (dead arguments are not evaluated). Pinned checker
`/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts` requires a live
scrutinee in `check-mat`, checks rewrite evidence with the current live quantity
in `check-rwt`, and checks definition bodies with `Lone()` in `def_check`.
Installed Base `Equal.cong/sym/trans` likewise require live equality evidence.
These rules explain the observed failures; pinned source is not asserted to be
the installed 2.0.34 binary's exact source revision.

This is a concrete implementation blocker for the enumerated construction routes,
not a mechanized metatheorem that no inhabitant exists in every possible context.
In particular no new elimination principle or proof-irrelevance axiom was
assumed, no unsafe escape was introduced, and a Type-formation pass was never
counted as evidence inhabitation.

## Minimal proposed revision if no lawful route is supplied

The smallest directly motivated change is **one binder quantity**, retaining the
entire predicate and equality verbatim:

```diff
 law owned_runtime_schedule_correspondence:
   for +limit: U32
-  for -world: R.World
+  for world: R.World
   for +steps: List<&2,R.Step>
   S.When(S.run_safe(O.steps(steps),U32.to_nat(limit),O.snapshot(world)), {M.observe(R.snapshot(R.project(R.tick(steps,limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps(steps)) : T.Observation})
```

Exact proposed file: [PROPOSED.bend](PROPOSED.bend), SHA256
`8e400d78b08530ff17295fa32190d0cf93b1f4641816d2710506b64a8ae2940b`.
The runner mechanically checks that its law block differs from the original
only at that one binder and retains one open TODO.

**Unapproved proposal only.** This directory neither changes the selected law
nor proves this revision. A live affine world may be inspected once during proof
construction; its repeated occurrences in the proposition remain dead, so the
change does not license runtime owner duplication. The actual R.World constructor pair now establishes that this specific
conditional introduction becomes legal with one live affine input, while keeping
the full equation an explicit premise. The non-literal empty-row family supplies
the equation and guard itself for that restricted shape. Neither result solves
the full revised ECS theorem. Actual projection, observation adequacy, prefix invariants
and U32 arithmetic would still need checked derivations, possibly with additional
proof-local result/owner threading. Any needed additional signature change must
be presented explicitly instead of being inferred from this suggestion.

An alternative keeps the erased binder but requires a live observation/guard
witness tied to it and enough relation evidence to perform induction. That is a
larger statement/interface redesign and is not justified merely by the accepted
transport helper, which is given the whole equation as a premise. It is not
selected here.

Next decision: review the exact one-binder proposal or provide a lawful proof
construction principle for the unchanged conditional signature. Do not close #18
or claim the seventh theorem on the strength of these diagnostics. Other approved
pure proofs have no dependency on this owner-erasure question.
