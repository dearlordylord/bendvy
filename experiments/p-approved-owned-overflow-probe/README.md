# Exact Overflow wrapper probe — partial

**PARTIAL:** universal neutral wrapper links pass checker/kernel; the exact
Overflow row-to-Word guard remains unresolved. This package assists approved
owned #18 proof development without changing its predicate, domain or owner.
Baseline dc273b8, isolated probe only; schedule-worker sources were read-only.
[PLAN.md](PLAN.md) was persisted before tests.

```sh
python3 experiments/p-approved-owned-overflow-probe/verify.py
```

[bridge.bend](bridge.bend) verifies:

- `describe_any(id,value,tag)`: actual Any/Some Row describes as Found Row.
- `describe_observed(observe,id,value,tag)`: apply an arbitrary erased Lookup→Bool
  observer to that equality. This preserves the caller's exact observer.
- `source_fun`/`source_row`: neutral Row function equality and application
  congruence expose `G.row_safe(Overflow,row)` as exact
  `S.no_overflow_lookup(S.describe(Any,Some(row)))`.
- `overflow_found`: with the exact source wrappers separated, specialize the
  generic observer to actual `S.no_overflow_lookup`, relating describe and Found.

These are contextual wrapper facts, not new catalogue fills, scalar safety
claims, runtime implementation or arbitrary Type observation/ownership proofs.
The facts touch only Data rows; no affine owner is consumed or reconstructed.
Zero-value source/observer controls pass kernel; an incorrect Missing result is
rejected exactly at `wrong_describe_result`. A false kernel backend is separately
rejected. [evidence.json](evidence.json) pins source/approval/compiler/Base hashes
and records every command under the repository five-second checker wrapper.
Supervisor cleanup targets only its own process group.

## Exact residual and failed routes

The remaining desired interface, unchanged from the schedule worker, is:

```text
for id,value: U32; tag: Bool:
{G.row_safe(G.Overflow{}, T.Row{U32.to_nat(id),U32.to_nat(value),tag})
 == U32.is_lt(value,4294967295) : Bool}
```

[declaration.bend](declaration.bend) checks formation with exactly one TODO,
not a type/quantity failure. It is deliberately open and is not a proof.
[found-neutral.bend](found-neutral.bend) retains a smaller failing conversion:

```text
{S.no_overflow_lookup(T.Found{T.Row{id,value,tag}})
 == Bool.not(Nat.is_ge(value,U32.to_nat(4294967295))) : Bool}
```

Its reflexivity attempt triggers the compiler machine-stack diagnostic in well
under five seconds. This is a compiler/proof-shape obstruction, not a falsified
mathematical statement or proof of impossibility.

Other bounded attempts: direct tag splits with existing bump_guard_agrees;
generic erased observer specialization while retaining the row_safe wrapper;
reflexive Overflow-to-Found equality; neutral-U32 function equality removing
Found; and an explicit U32-bound lookup observer. The first four still stack-
overflowed. The generic bound observer itself checks, but equating its specialized
function to the actual source function is not definitionally accepted; no
extensionality or assumption was introduced. Separating neutral source function
congruence from exact describe observer congruence produced the verified facts
above, but not the final scalar-wrapper conversion.

A parent-proposed inequality-by-contradiction route and a complementary generic
Cmp-observer route are untested follow-ups owned by the other proof lanes; they
are not counted as passes here. No standalone full row_guard, Bump traversal,
owned schedule or #18 completion claim follows. Installed Bend2.0.34/Base and
version/guide were inspected; no unsafe definition, unary-MAX normalization,
canonical/reference edit, dependency, timeout change or approval was added.
