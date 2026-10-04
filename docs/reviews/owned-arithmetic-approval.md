# Supporting arithmetic approval request — historical proposal

**Current status:** both exact subjects are approved under explicit user-delegated
Astra review; see [decision](delegated-owned-law-approval.md). The original request
below records the pre-approval state. No general proof is complete.

Two exact infrastructure candidates from the original 31-law catalogue are needed
for the owned schedule proof's U32-to-Nat transition reasoning. They are not yet
approved or proved, and this request does not select the other 22 support candidates.

- `u32_comparison_agrees_nat`: unsigned comparison agrees with comparison of the natural-number projections.
- `u32_increment_no_wrap`: below U32 MAX, increment projects to the natural-number successor.

[Exact selected statements](../../experiments/p-observe/ARITHMETIC-PROPOSED.bend),
SHA256 `7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937`. Each law block is unchanged from
original SHA256 `e0c607d723ad250a189c096d9fa3fd6a36913f4c72efd3a3be6dacd7fadb2cbc`;
only relative imports and explanatory comments differ.

The completed #12 falsification records 4 increment instances and 16 comparison
instances on 0/1/2/255, plus two compiling own-statement mutants rejected on
true-domain witnesses. Actual compiled MAX-1/MAX guard observations are separate
from these equations; unary-Nat normalization at that boundary was not performed.
These finite results are not universal proof or high-bound equation verification.

[Checked structural Word toolkit](../../experiments/p-owned-arithmetic/README.md)
now connects the actual inline `U32.add(value,1)` to `U32.inc` and validates
carry/conversion cases. It does not assume or fill either proposed law. Generic
comparison agreement and propagation of the bounded successor are the remaining
mathematical links. The endpoint must additionally connect these to its actual
Reserve/Bump guards, owner projection and prefix safety; proving the two bridge
facts alone would not prove the owned runtime theorem.

Requested approval is specifically for these two infrastructure facts as supporting
proof subjects, with their unchanged domains. It does not approve allocator/reuse
policy, the other support laws, numerical thresholds, new dependencies or the
separate owned-binder amendment. Keep that separate decision pending.

## Decision

Both exact subjects above were approved by Astra under the user's explicit
delegation; see [dated decision](delegated-owned-law-approval.md). This request
and its frozen proposed statements remain historical evidence. Proofs, kernel
verdicts and endpoint mutation gates remain outstanding.
