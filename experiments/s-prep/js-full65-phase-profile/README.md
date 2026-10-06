# Full65 generated-JS phase profiles

Diagnostic CPU sampling on all64 measured worlds plus warmup, with actual pinned
bevy-ts and every complete field checked. Unlike eight-world constructor profiles,
this retains the original64-world generated entry. Two IO-clock sites gain bracket
markers; blocking stdout is enabled outside the phase. Node CPU sampling100µs
perturbs execution. These clocks are not acceptance measurements.

The current recipe validates exact emitted input, source29, compiler build receipt,
row transformation receipt and token transformation receipt before execution.
It never fabricates a build pass for rewritten JS. `input-pins.json` admits only
the two already validated Health source/diagnostic chains. Runtime5/CPU11, existing
Node parser/runtime, no compiler/kernel/source/reference/dependency changes.

Current flat-journal profile: GC10.78%, read19.91%, live guard14.66%, ledger callback
11.42%, query advance7.52%, step7.44% self samples. Genuine ledger composition:
GC12.53%, read15.63%, taken11.46%, ledger callback10.79%, step9.49%, query advance
9.11%. Different runs/host/JIT attribution prevent interpreting these percentages
as comparative speedups; use them to select reached mechanisms. Fold reuse may
remove its one returned-state construction/update; Native already unboxes Fold.

All current runs retain65 full worlds. The initial flat run predates the added
in-recipe provenance guard and is archived separately, never relabeled. Current
flat-v2 and joined runs execute the shipping guard and record recipe/catalog pins.
`archive.py` independently decoded98 pinned members, including CPU profiles,
phase outputs, source29/cache and complete transformation lineage. Replay uses
current catalog paths and absent output directories; temporary layout is provenance,
not authorization for changed inputs. Full22, production alias confinement,
qualification and both performance thresholds remain separate and incomplete.
