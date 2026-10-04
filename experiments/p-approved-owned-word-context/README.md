# Contextual Word links for the approved owned schedule

**PASS: universal contextual helper package**, serving the revised owned endpoint
under [#18](https://github.com/dearlordylord/bendvy/issues/18) and its
[delegated approval](../../docs/reviews/delegated-owned-law-approval.md).
Baseline `6c4c36a`; [PLAN.md](PLAN.md) was persisted before tests.
No catalogue law is declared/filled here or assumed under an alias. Imported
approved increment is filled by its own unchanged proof package.

```sh
python3 experiments/p-approved-owned-word-context/verify.py
```

## Interfaces

All U32 binders are reusable Data; every premise is explicit, live equality
proof evidence. [helpers.bend](helpers.bend) exposes:

| Helper | Exact purpose/interface |
| --- | --- |
| `equality(left,right)` | `{U32.is_eq(left,right) == Nat.is_eq(U32.to_nat(left),U32.to_nat(right)) : Bool}` for every pair. |
| `reserve_below_max(next,limit,h)` | `h:{True{} == U32.is_lt(next,limit) : Bool}` implies `{True{} == U32.is_lt(next,4294967295) : Bool}` for arbitrary U32 limit. |
| `bump_below_max(value,h)` | `h:{True{} == Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) : Bool}` implies `{True{} == U32.is_lt(value,4294967295) : Bool}`. |
| `bump_increment(value,h)` | The same Bump premise yields `{U32.to_nat(U32.add(value,1)) == 1n+U32.to_nat(value) : Nat}` by invoking approved increment. |

The caller must supply the actual connected prefix/lookup premise; these helpers
do not invent it. In particular, the owned schedule lane still must connect a
found row and its projected array observation to `S.step_safe`, preserve the
prefix domain and demonstrate actual primitive-owner correspondence.

## Derivation and supporting inventory

`equality` maps the committed full Word/Nat comparator equality through
`Cmp.is_eq`. It does not prove another ECS lookup policy.

For Reserve, `max_bound(width,word)` structurally proves comparison with the
all-ones word cannot be GT. `max_finish`, `max_equal_head` and `clear_lt` handle
comparison tags and low bits; `lift_lt` preserves a tail LT under either low bit.
`reserve_word` is structural width induction returning a conditional proof of
below-all-ones from comparison with any same-width right word. `reserve_finish`
and `reserve_equal` distinguish a tail LT from equal tails with low-bit ordering.
The U32 wrapper specializes to width32 and eliminates that conditional with the
caller's genuine True premise. No bound on `limit` beyond its actual U32 type and
no unary MAX Nat arithmetic is assumed.

`not_ge_lt` checks the three comparison tags. `not_ge_agrees(left,right)` transports
that fact through the committed generic comparator. Specialization gives the
exact Bump guard; transitivity produces its True U32 bound. Finally `require`
eliminates the approved increment conditional. Local `impossible` discharges
contradictory Bool constructors; it introduces no assumption or unsafe evidence.
These introduction/elimination functions are ordinary proof terms, not filled
catalogue encoder equations.

A first direct MAX-specialized comparator transport hit a bounded machine-stack
error while converting the literal. Moving that transport to arbitrary left/right
U32 parameters before specialization passes without changing any interface,
original subject, numeric domain or checker limit. The final package contains no
MAX Nat normalization fixture. The high Reserve control remains structural U32.

## Evidence and scope

Bend2.0.34 version/guide and installed Base were read. Existing comparison,
approved increment and its ADC toolkit were inspected; no project vendor mathlib
was available or installed. [subjects.json](subjects.json) pins canonical laws,
spec/bridge, approval, imported proof dependencies, installed compiler and Base.
[verify.py](verify.py) refuses changed pins and records fresh commands/results in
[evidence.json](evidence.json).

Both general helper checker/kernel pass. Complete positive controls cover equal
and distinct small words, low/carry/high-word Reserve premises, exact independent
zero Bump guard, Bump successor and excluded MAX U32 guard. A false Reserve
premise is rejected exactly at `invalid_reserve_premise`; an incorrect successor
claim is rejected exactly at `invalid_bump_result`. These are negative proof
controls, **not compiling runtime semantic mutants**. A separate false kernel
backend invocation confirms verdict acceptance is required. Every checker/kernel
uses the repository five-second wrapper; supervisor cleanup targets only its own
process. No timeout, source/reference/dependency or runtime edit was made.

No residual remains for the requested interfaces. This is contextual arithmetic
support, not completion of the owned theorem or a production allocator/root,
physical-owner/full-payload, transaction, layout or performance guarantee.
