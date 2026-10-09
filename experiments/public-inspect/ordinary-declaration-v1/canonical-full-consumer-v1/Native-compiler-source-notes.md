# Pinned Native compiler source notes

Source-only investigation of `.references/bend2` at the task-provided manifest `a950fd683c0d76f09794078e6174fe98a1492876`. No compiler/backend or diagnostic replay was launched. These are implementation facts and an unexecuted experiment proposal; they do not qualify Native execution.

## What “once” actually means

In `bend2/comp.ts:1371-1389`, reachable definition traversal counts syntactic nonintrinsic `Ref` nodes in `fl.sites`. This is not a runtime execution count and does not assert that a function is evaluated once. Only reachable definitions enter this traversal (`:1354-1368`).

At `comp.ts:2499-2503`, optional tail fusion requires exactly one reference site, an unbanged call, a nonforeign callee, and compatible boxed-return conditions. It also requires `dst === null` and that the callee differ from the segment definition. The condition is OR-ed with `flat_call`; defeating the once condition does not disable flat-call handling.

At `comp.ts:2126-2136`, fusion of a nonflat callee emits its body recursively into the current segment. There is no memoized generated-function boundary in that branch. Repeated expansion across branches and nested once callees can therefore amplify traversal and generated code; a formal asymptotic bound or attribution of the retained deadline failure cannot be established from these lines alone.

Flat calls follow a different path (`comp.ts:2138-2148`). `emit_native` memoizes generated spins by definition and erased-argument layout identifiers (`:2168-2183`). Generated spins use INLINE below 256 segment lines and FAR otherwise (`:2184`, threshold `:121`); FAR becomes host noinline (`:3349`). This host C attribute acts after Bend emission and cannot repair emission expansion already incurred.

Flatness excludes forks, bang calls, and nontail self-calls (`comp.ts:1170-1172`, `:1388-1389`), and is propagated over dependencies (`:1259-1265`). `flat_call` additionally rejects bang calls (`:805-808`). FOLD_FUEL is 8192 (`:99-102`, `:119`), described as limiting unfolding into segments, not a public switch disabling optional once fusion.

## Stock source mechanisms and CLI

No stock user noinline/outline annotation is exposed by the declaration parser inspected at `bend2/bend.ts:2431-2485` and `:2498-2510`. `@unsafe` is a declaration safety control, not an outlining control. The CLI accepts check/verdict/checkup/publish, output, and argument options, and rejects unknown options (`bend2/main.ts:238-266`); no Native outlining knob appears there.

`f!(...)` sets the reference bang flag (`bend.ts:2022-2032`) and prevents both flat-call and once fusion, but its documented parser meaning is offload. It changes execution routing, so it is not a neutral noinline annotation and is not the proposed qualification experiment.

Foreign definitions are excluded from once fusion (`comp.ts:2499-2501`; declaration imports `bend.ts:2467-2481`), but substituting foreign code would change the trusted implementation and is not proposed.

## Bounded stock-2.0.35 experiment proposal

Use the existing retained diagnosis to identify one nonflat heavy function whose optional once fusion is implicated. Prepare a copied full23 consumer with one source-only transformation: give that function two reachable syntactic call sites, preferably equivalent arms of an existing match on a live parameter. Each arm must pass exactly the original arguments and return exactly the original result; exactly one arm runs. Keep all 23 scenarios, oracle bytes, reader/normal distinction, backend version, admission process, phase deadlines, resource ceilings, and boundary guards unchanged. Do not add a second runtime evaluation or an unreachable helper: unreachable references do not increment this count.

Bind a new immutable plan and source manifest, review its admission, then perform one stock Native attempt under the existing caps. Check the complete output against the unchanged complete oracle and preserve phase outcomes, generated C, stdout/stderr, terminal receipt, and guards. A source-check pass or C emission alone is not Native completion. A timeout remains incomplete; do not enlarge caps or retry this plan.

The mechanism predicts `sites > 1` disables the optional once branch, but qualification requires empirical success. Earlier transformations or normalization may merge/remove equivalent arms; generated C and observed phase evidence must establish whether the intended function boundary survived. A flat callee is not an eligible target. If the required live discriminator cannot be introduced without changing the full consumer contract, this candidate is unsuitable. Do not mistake a copied compiler patch disabling the branch for qualification of stock 2.0.35.

## Limits

This note does not reanalyze the parent's retained copied-diagnostic results. The source predicts a stock route around optional once fusion, not that a particular full23 transformation succeeds, that all expansion disappears, or that Native output matches the oracle. No new run or source edit to the consumer/compiler occurred in this investigation.

## Provenance and required pre-emission control

The task-pinned source inspected here does not contain `count_sites_book` or `suppressedOnce`. Its site scan uses `fun_of(d).h`, derived from `term_higher(tld.e)` (`comp.ts:1182`, `:1371`). Therefore it cannot establish the exact counting order of a differently copied or installed 2.0.35 compiler. Reconcile that source provenance before adopting the proposed experiment.

For a concrete `inspect_target`/`check_target` owner-carrier candidate, the proposed discriminator is a live target-derived Bool and both arms retain the original op unpack/pack. Before any Native emission, an independently reviewed source-only control must demonstrate in the actual checked/specialized book that (1) the Bool remains live, (2) both arms retain direct references to the exact implicated specialized callee key, (3) that key has at least two reachable counted references, (4) its flatness and return-layout conditions are recorded, and (5) all scenarios and oracles remain unchanged. Raw textual duplication before specialization is insufficient evidence. No such control has been run by this investigation.

## Follow-up: actual bang syntax and cached source

The supported syntax is `f!(arguments...)`; prefix `!f` or a standalone banged function reference is not established. The parser requires a named Ref immediately before `!(` and sets `out.b = true` (`bend.ts:2022-2032`). Type inference may instantiate a template first (`:3325`) and then reconstructs `Ref(k, tm.s, tm.b)` (`:3343`), preserving this flag on the instantiated callee with its ordinary declared type. No additional ownership quantifier is imposed by that Ref inference case.

A bang call is a smaller and more direct source-level blocker of both flat-call fusion (`comp.ts:805-808`) and optional once fusion (`:2499-2503`). It is nevertheless an execution-routing change: `emit_jump` sets `seg.fork`, creates a task when `!seq`, and otherwise jumps (`:2051-2061`); bang roots affect device reachability (`:2797-2800`). At runtime the presence of BANGS disables the `!BANGS && pool_size == 1` sequential shortcut (`:5255`), and GPU-enabled execution routes marked tasks to the device (`:5264-5281`). Borrow/ownership facts are calculated during emission, so identical source typing does not prove identical runtime representation or ownership bookkeeping.

If execution routing is permitted within the consumer contract, a one-token change of the implicated actual named call to `f!(...)` is a bounded alternative stock experiment. Require a pre-emission check of the checked instantiated Ref flag and exact key, preserved declared type/affine obligations, unchanged full23 scenarios/oracles/caps, and recorded configured CPU/GPU mode. Then admit and execute one immutable Native plan. Source inspection predicts the fusion condition is false; only full retained runtime evidence establishes correctness and completion. Do not present this as a neutral noinline annotation.

The cached source supplied by the parent, `.../timing-alignment-v1/compiler-research-v1/layout-equality-v1/comp.ts` (task-provided SHA prefix `b7d3fe0f`), was read without execution. It likewise scans references inline in `file_book` (around lines 1383-1401), uses once at `:2511-2514`, and has no `count_sites_book` symbol. Thus the symbol mentioned in discussion does not designate a function in either inspected compiler source. The cached file and pinned reference differ in line positions; cite each separately.
