# Contextual safety transport inventory

For the approved owned-runtime endpoint only: ModelSafe uses the exact independent
admissibility/step-safety predicates, but follows actual M.step prefixes. Transport
from original S.run_safe will preserve every exact oracle prefix and premise.
Dependencies: interval lookup equality using Slots and enumeration inverse;
missing lookups beyond next using both physical row-validity premises; step_safe
equality; actual model successor validity and bounded lookup relation; list
induction consuming original run_safe at each oracle successor. Related/Covered
alone are insufficient: physical uniqueness and outside-interval lookups matter.
No remaining catalogue law is assumed or proved. Five-second checker/kernel gates.
Base, guide/version (2.0.34), checkpoint, ticket and SPEC inspected; no installed
mathlib lock/dependency added. Original subject hashes and controls will be frozen.

## Next member-wise Bump bridge (inventory before execution)

Owned runtime visits every cell. BumpSafe must guard every row matching target,
not merely the first lookup. Use exact rows_valid uniqueness, count=1 reflection,
unique_head_tail_zero and absent-target tail recursion. For a matching head extract
the original no-overflow guard; its tail has zero count for that target. For a
distinct head transfer first-hit lookup safety to the valid tail and recurse.
No new public/catalogue law or changed run_safe premise.

The proof uses a Data Bound descriptor (Overflow or Below(Nat)) to keep the row predicate opaque during generic induction. Overflow applies the exact S.no_overflow_lookup/S.describe path; matching head/tail uniqueness is proved before specializing. This avoids eager unary MAX normalization; no timeout or source changes.
