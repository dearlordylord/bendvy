# Local product elision: zero eligible source sites

Bounded generated-JS diagnosis only. No Bend/compiler/kernel/reference/dependency changes, generated rewrite, adoption, universal refinement, qualification or canonical cap reset.

Input `/tmp/bendvy-cache-box-js-build/baseline.js`, matched against the existing counted site catalog and constructor receipt. Node's bundled Acorn 8.18.0 found **161 Tuple literals and zero local Tuple initializers**, including const/let/var. All 161 sites agree with the prior catalog in source text, function owner and occurrence order. Contexts: 119 direct returns, 27 call arguments, 12 object properties, two conditional-expression results, one arrow expression body. There are **zero safely eligible executed local sites; predicted constructor delta is zero**. The prior eight-world count recorded 2,502,144 Tuple executions; that is existing baseline evidence, not a new acceptance run.

The requested rule would replace only a uniquely bound local initialized by a plain Tuple object whose complete value references are fst/snd reads, evaluating both field expressions once and in order at the old allocation point. No such initializer exists here. The concrete `array_rmw` helper returns `{$:"Tuple",fst:a,snd:old}` across a function boundary. Eliminating its product would require a separately scoped interprocedural rewrite with call/escape/exception/evaluation-order analysis. Const locals initialized by function calls are excluded; they do not imply that a returned product is local or nonescaping. No alias mutation or broader optimizer was inferred.

```
node --expose-internals experiments/s-prep/js-local-product-elision/scan.cjs INPUT CATALOG COUNTS FRESH_RECEIPT
```

The scanner fails closed if any local Tuple candidate appears: ownership/reference analysis would then be required before rewriting. It checks the full prior Tuple catalog before issuing the zero-site receipt. A synthetic const/projection control triggers that refusal and writes no receipt. It is a scanner scope control, not an optimizer equivalence test. Archives freeze input, site catalog and prior counts with hashes.

No changed program exists, so no additional world run, profile/count sample, transaction/mutation gate or retained/split-field witness was executed. Source inverse/read/access helpers remain untouched; no source or generated correctness pass is claimed for a nonexistent rewrite. Parent owns any separately authorized function-boundary product experiment.
