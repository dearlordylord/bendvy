# Indexed query CPS transport — negative source probe

Outcome: finite Motion observations agree, but source constructor executions increase.
Do not adopt this CPS candidate as a construction-reduction optimization. No exact
heap-byte or speed regression is claimed, and no full22/capability gate is passed.

The motivating allocation sampler aggregates all four struct_idx_metadata stack
nodes to81,799,256 selfSize bytes, out of406,382,408 total. Sampling/inlining attribution
is not exact materialized allocation for one source constructor. Profile and
aggregation are archived; no single-node estimate is substituted for the aggregate.

Private helper copies pass all seven affine column/list fields to a continuation,
eliminating StructColsState per ID. Original public helpers and types remain;
only read_rows chooses the private loop. Guards, live/flag selection, Main/Aux swap
and restoration, callbacks, stamps, full views and ascending logical order/reversal
are unchanged. Each branch retains all fields; Main/Aux and metadata arrays remain
Type, with no Data-only copying. Original aligned-depth/malformed-shape limits remain.
Final Rows/MetadataColumns rebuild directly, eliminating boundary intermediates.

```sh
python3 experiments/s-prep/js-query-loop/materialize.py \
  --input /tmp/bendvy-direct-raw-swap-worker --output /tmp/fresh-query-loop
python3 experiments/s-prep/js-query-loop/sparse-run.py \
  --original /tmp/bendvy-direct-raw-swap-worker --candidate /tmp/fresh-query-loop \
  --output /tmp/fresh-query-sparse --cpu 9
```

Fail-closed recipe requires absent output, exact query revision, all29 actual pins,
coherent complete source/cache closures and original public headers. Only query
changes. Motion256 batch checker15s and JS codegen30s pass on CPU9. Uninstrumented
and counted profiles each match every field of nine full worlds against fresh
pinned TS (warmup +8 fresh worlds,64ticks), each process under5s. No failed Bend
checker/codegen/runtime attempt occurred in this probe.

Actual emitted continuation has seven curried run_clo stages. Each creates its
own arrow plus the runtime wrapper arrow, giving14 closures per visited ID. The
runtime additionally constructs one JMP object and one argument array per ID.
This replaces one StructColsState with a larger source-construction workload:

| Counter kind | Change versus direct-raw baseline |
| --- | ---: |
| ArrowFunctionExpression | +1,835,008 |
| JMP object | +131,072 |
| Argument array literal | +131,072 |
| StructColsState | −131,584 |
| StructIdxState | −512 |
| Total | +1,965,056 |

Total rises from9,955,904 to11,920,960, or90.94970703125/callback. Counters measure
executed source expressions; instrumentation perturbs escape analysis and is not
allocation bytes or timing. Original per-ID record removal is real but does not
produce a net source-construction reduction. Broader two-schema query controllers
and Native benchmarking were not pursued after this negative result.

Initial stack concern is resolved for the tested high-water case: emitted helpers
use run_tail/run_loop trampoline, not unbounded host recursion. The original loop
uses a direct for-loop; candidate propagates JMP requests through run_clo wrappers.
A tiny aligned all-dead Motion fixture, high65538/capacity131072/depth17, preserves
empty output and exact bounds on both original and candidate under Node's default
stack and runtime5s. No V8 stack override is used. This finite observation and
emitter inspection are not a universal stack proof or authority/refinement claim.

Primary source constraints were respected: one parameter-headed match perdef,
ordered helpers before callers, structurally decreasing remaining, affine resume
ownership. Version2.0.35/guide and Bend LDD language reference were read. No unsafe
recursion, law/proof/dependency/compiler/reference changes or cap reset. Live query
mutants would need prototype_loop_* anchors; old unused helper mutations cannot
establish this private path. Additional selection, authority/affinity, fallback,
rollback and two-schema gates remain unexecuted; acceptance is not inferred.

Follow-up: avoid ordinary seven-argument curried CPS for this seam. Returning a
seven-field tuple/record merely substitutes a transport wrapper. Any source-level
alternative must preserve affine ownership, the existing query domain/trampoline,
all observations and callbacks, and demonstrate actual emitted cost before full
gates. Compiler record reuse remains separately scoped work, not this probe.
