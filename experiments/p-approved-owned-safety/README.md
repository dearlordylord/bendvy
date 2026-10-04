# Contextual independent-to-model safety transport

`transport.from_independent(steps,limit,world,safe)` proves
`True == safety.ModelSafe(steps,limit,world)` from the exact original
`True == S.run_safe(steps,limit,world)`. ModelSafe retains S.admissible and
S.step_safe and follows actual M.step prefixes. This is supporting proof for the
approved owned-runtime endpoint, not that endpoint or an unapproved catalogue law.

The stronger `related_safe` list induction relates distinct physical row layouts
with shared metadata and Slots(limit). It retains model admissibility, extracts
oracle admissibility and step safety from the original guard, and consumes the
original tail guard at the exact S.step successor. Existing checked model
successor invariants and Slots successor facts handle all four operations.
`step_safe` proves equality for arbitrary Bump targets: inside-next lookup uses
enumeration adequacy; outside-next lookup uses both exact physical validity
premises to prove absence. Affine Slots proofs are split structurally, without
claiming they are Data. Related/Covered alone do not imply physical admissibility;
a checked duplicate-row counterexample records why that extra premise matters.

Run `python3 experiments/p-approved-owned-safety/run.py`. Fresh checker and kernel
pass for the universal toolkit/transport and mixed Bump/Reserve/Publish/Barrier
control. The original one-Bump ModelSafe witness passes kernel; a compiling local
mutation negates its step-safety predicate and rejects that unchanged witness and
universal transport at head_safe. An invalid original run_safe premise is rejected.
Forcing BENDTT=false rejects the originally accepted transport at the kernel gate.
Mutant and invalid-premise failures are checker failures, not kernel verdicts.
Every invocation uses the existing five-second limit, without added dependencies.

Evidence freezes original subjects, installed compiler/Base, approval and imported
contextual proofs against baseline bb2be06742ba387fc42bd69cf50bedf4ac37a7c1.
Actual affine runtime correspondence remains a separate dependency; this package does not establish integration/performance.


`member-safety.from_step` also proves the guard for every matching physical row
from exact row validity and S.step_safe. `BumpSafe(Overflow{},rows,target)` guards
all EQ-key rows with the exact independent no-overflow predicate, and recurses
through distinct rows. The generic Data Bound descriptor keeps comparison opaque
until specialization; its Below(Nat) branch supports a small duplicate-row
negative witness without unary MAX expansion. Unique matching heads establish
zero target count in the tail; distinct heads transfer the first-hit guard to a
valid tail. No assumption about target bounds is added. Actual-member and
outside-target controls pass kernel. A compiling mutant removes the matching-row
guard: the unchanged universal head_case proof and complete duplicate-is-unsafe
predicate witness fail. This supplies runtime row induction with member guards;
actual Array mutation/ownership remains the owned worker's separate proof.
