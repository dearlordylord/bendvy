# Approved U32 increment without wrap

**PASS: general exact `u32_increment_no_wrap`**, checker and BendTT kernel.
Governing [#18](https://github.com/dearlordylord/bendvy/issues/18),
[delegated approval](../../docs/reviews/delegated-owned-law-approval.md) at
`8e149fd`; approval applies to the original arithmetic proposal SHA256
`7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937`.
The runner mechanically verifies the first law/import selection against that
unchanged original file. Its historical UNAPPROVED comment is retained verbatim;
the dated approval record is authoritative. No second arithmetic/catalogue law
is filled by this package.

```sh
python3 experiments/p-approved-u32-increment/verify.py
```

Bend 2.0.34 version and guide were read before development; [PLAN.md](PLAN.md)
was persisted before proof testing. Installed Base and the existing
[p-owned-arithmetic toolkit](../p-owned-arithmetic/structural.bend) were inspected.
No local project vendor mathlib was available or added. [subjects.json](subjects.json)
freezes original/proof dependency/approval/compiler/Base hashes; verification
refuses a changed pin. Each checker or kernel invocation uses the repository's
five-second wrapper; the six-second process supervisor only detects wrapper
malfunction and kills its own process group. No timeout increase or unsafe proof
is used. [evidence.json](evidence.json) records exact commands and diagnostics.

## Derivation and dependencies

The exact statement quantifies over every U32 value: below MAX, converting actual
`B.increment(value)` to Nat equals successor of its prior conversion. MAX itself
is excluded; no allocator, exhaustion or general overflow policy follows.

- `ones(n)` constructs the all-set-bit Word structurally; it never computes a
  unary Nat MAX.
- `conditional` introduces a local `S.When` from an unconditional equation.
- `carry_when` examines the tail comparison tag. LT carries the tail successor
  equation through the set low bit; EQ/GT produce the false-domain Unit branch.
- `guarded_word(n,w)` proves the conditional conversion for arbitrary width and
  word by structural induction on width. A clear low bit uses unconditional
  clear-bit conversion; a set low bit uses the recursively obtained conditional
  and the carry step. Width zero is outside the below-all-ones domain.
- The exact endpoint specializes to width32. Existing `runtime_add_one` proves
  actual `U32.add(value,1)` equals structural `U32.inc(value)` using ADC carry/zero
  lemmas; the endpoint transports its guarded Nat equation through that equality.
  Literal U32 MAX is definitionally the 32-bit all-ones word. No general unsigned
  comparison/Nat agreement theorem is assumed here.

These are mathematical dependencies serving the approved endpoint, not new ECS
contracts. Existing zero/carry/add-one helpers and installed `Equal.sym` are
included in the checked import closure. The complete arbitrary-word proof is
[PROOF.bend](PROOF.bend), SHA256
`13e82a4c268019237134acf0199ef103e6c9f6bdd8470938445738a1e220d593`.

## Gates and limits

- Original general theorem: checker and kernel both exit0 with ALL PROOFS CHECK.
- Original complete true-domain witness255: guard=True and exact selected
  conditional equation pass kernel. General proof instances0 and255 also pass.
- Wrapping boundary: MAX guard=False; the exact theorem specializes to Unit;
  actual increment(MAX)==0 is checked in U32. No enormous Nat equality at MAX or
  MAX−1 is normalized as a fixture.
- Fresh copied positive passes kernel before mutation. Changing only actual
  bridge increment from +1 to +2 still compiles. The unchanged general proof
  fails at `Location: L.u32_increment_no_wrap`, not in a shared helper. The
  complete255 conditional witness fails at its own section while a separate
  mutant-domain control remains True.
- A separate `BENDTT=/usr/bin/false` verdict invocation exits1, confirming the
  kernel result is required. Failures/timeouts cannot satisfy positive gates.

No residual remains for this exact endpoint. Integrating it into Reserve bounds,
prefix-safe Bump/owned schedule correspondence requires its caller premises and
other independently checked links. This theorem does not establish array payload
preservation, world identity, arbitrary Type ownership, full runtime refinement,
production capacity/layout or performance acceptance. Canonical law/core sources
and read-only references remain unchanged; only this isolated package is owned.
