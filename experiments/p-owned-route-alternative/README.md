# Original erased-world proof: bounded alternative routes

**No inhabitant of the original arbitrary-world theorem was found.** This tranche
tests four concrete alternatives to the previously rejected direct erased-owner
match/call. It does not prove impossibility, amend the binder, prove the proposed
live-owner theorem, or fill either pending U32 catalogue bridge.

The original seventh law and all six subjects remain unchanged at the hashes in
[subjects.json](subjects.json). The original law retains `for -world: R.World`.
Only this new directory was changed. [PLAN.md](PLAN.md) records the test inventory
before implementation; Bend 2.0.34/version/guide and the Bend skills were read.

Run `python3 experiments/p-owned-route-alternative/run.py`. Exit 0 means the
expected diagnostic matrix was reproduced, **not** that any ECS law is proved.
[evidence.json](evidence.json) records exact commands, outputs, elapsed times,
subject/helper/source hashes and source provenance. Every checker/kernel invocation
uses the existing five-second wrapper; the outer six-second watchdog detects
wrapper failure. No dependency was installed.

| Concrete route | Positive result | Quantified erased-input result |
|---|---|---|
| Closed template specialization | Both literal Bool branches construct the actual `S.When` result and pass the kernel | `~guard` is rejected because a def variable is not a closed template argument |
| Delay behind a once-only closure | A closure over a live Bool constructs the conditional when called | Capturing the erased Bool for that later call still gives `expected: -guard / observed: guard` |
| Synthesize a live guard/equality witness | A live Bool constructs the dependent pair `actual, actual == guard` | An erased Bool cannot supply its live first field; same quantity rejection |
| Uniform result branches | An erased index can appear in an actually constant result Type, with a checked inhabitant | An unresolved Bool match is not definitionally Unit, even when both branches return Unit |

All accepted infrastructure definitions pass the ordinary checker and actual
kernel. The four route negatives and elementary false-conditional control fail
in initial checking; their `--verdict` runs do **not** reach independent kernel
rejection. A separate forced failing kernel confirms the positive path invokes
it. No returned Type, delayed uncalled term or false-domain Unit is counted as
an inhabitant of the owned theorem.

## Connection to the unchanged endpoint

The original guard is `S.run_safe(O.steps(steps), U32.to_nat(limit),
O.snapshot(world))`. The actual independent snapshot consumes an affine world;
`R.project` separately returns an owner plus observation. Neither interface
supplies an additional live guard witness in the approved theorem signature.
The existing `p-owned-route/guard-witness.bend` demonstrates legal transport **if**
such a witness and the entire equation are supplied. The existential probe here
shows that merely repackaging the erased index does not synthesize that missing
live witness. Templates likewise work for closed specializations but cannot
turn the universally quantified erased owner into compile-time constant syntax.
Delaying a call does not change which captured variables it uses live.

The constant-result positive is deliberately narrower: it shows erased binders
are not universally unusable in proofs. The unresolved same-branch negative
shows that a uniform-looking result does not, by itself, make the match reduce.
The actual `S.When` branches are even different Types (Unit versus the endpoint
equality), so this experiment provides no uniform constructor for them. This
is evidence about the tested conversion route, not a semantic nonexistence proof.

Source inspection matches these observations. Pinned checker
`bend2/bend.ts:3740` checks template inputs against an empty local context;
`def_check` checks definition bodies live, and `check-mat` rejects erased live
scrutinees. Installed `bendtt.lean` checks lambda binder liveness and pair-field
quantity, and `Term.uses` counts captured uses inside lambdas and live first pair
fields. Installed Base's equality transport requires live evidence. The installed
kernel/Base were hashed separately; the pinned source checkout is **not** claimed
to be the exact source revision of the installed 2.0.34 executable.

## Consequence and limit

The tested alternatives add no lawful construction path for the original
arbitrary-world conditional. Stop this bounded search here. The exact pending
binder and arithmetic decisions remain pending; none receives implicit approval
from these diagnostics. Further proof work should require either a concrete new
original-signature construction principle, an explicitly approved statement
revision, or a clearly labeled narrower specialization whose guard/evidence can
actually be constructed. Existing separately authorized trace preparation remains
independent of this theorem gate. No broader ECS or performance acceptance follows.
