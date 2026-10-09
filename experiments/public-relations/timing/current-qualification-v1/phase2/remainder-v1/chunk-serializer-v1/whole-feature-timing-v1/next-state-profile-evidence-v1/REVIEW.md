Both exact Inspector02 runs passed the complete 4,329,743-byte depth256/span16 oracle, 30 records, walk and two markers. CPU original session58883; Heap6265. Eight input guards unchanged. CPU7318 samples,31 signed negative deltas retained; sampled Heap selfSize sum3,870,894,728. These weights are neither total allocations nor RSS. No timing ratio or causal conclusion under contention.

| CPU self frame | Samples | Source / generated line | Region |
|---|---:|---|---|
| Anonymous continuations |2601|Mixed; largest sampled sites cpu.cjs9923/7055/9737 map to src/ecs/relation-query.bend107;12063 to owned-world.bend38|Setup/operations/observation; mixed, not a single function|
| V8 garbage collector |909|Runtime pseudo-frame, no Bend line|Cannot isolate region|
| List.append |549|cpu.cjs1768; Base List.append, shared token expansion and force callers|Mixed; ancestry required|
| serialize-next-state.loop |283|serialize-next-state.bend24 /cpu.cjs1710|Serialization after Complete|
| relation-query.output_join |163|src/ecs/relation-query.bend96 /cpu.cjs5930|ECS operations/observation before Complete|

| Sampled Heap self frame | Reported bytes | Source / generated line | Region |
|---|---:|---|---|
| Anonymous continuations |2,091,200,960|largest sites3543/3615 src/ecs/relation-graph.bend27;12063 owned-world.bend38;821 phase2/force.bend39;4164 src/ecs/relation-graph.bend38|Mixed operations and forcing before Complete|
| List.append |404,762,256|cpu.cjs1768|Mixed token traversal|
| serialize-next-state.loop |306,227,016|serialize-next-state.bend24 /cpu.cjs1710|Serialization after Complete|
| column.plain_view_taken#1 |102,769,712|src/ecs/column.bend371 /cpu.cjs9965|Component observation before Complete|
| column.plain_view_checked#0 |70,260,768|src/ecs/column.bend375 /cpu.cjs9257|Component observation before Complete|

Before comparison reuses archived CPU9122d783 /Heapd8f633de profiles only: same Node24.20.0 identity, depth256/span16 full oracle, declaration-after start boundary,100us CPU sampler and1MiB collected-object Heap sampler. No baseline rerun. The earlier callback serializer's anonymous continuation weight is distributed among generic frames; after explicit state, a named loop appears. Actual before6391 versus current7318 samples; counts differ, so do not read raw counts as time. Reported sampled Heap sum before5,055,972,240 versus current3,870,894,728 is one sampled observation, not proven savings or total allocation. Portable old private environment is excluded as already documented.

Minimal next source proposal: replace private EncodeStep/step/loop state carrier with direct tail recursion over (fuel,pending,chunks), matching fuel and pending parameters together. The emitted loop currently receives StepNext from step each token (cpu.cjs2194), and loop306,227,016 sampled bytes is a named serialization hotspot. Preserve zero-fuel empty completion, Visit expansion, one decrement per token, reverse chunks and every exact byte. This removes an intermediate carrier without changing observed work; improvement remains a hypothesis until full fuel/oracle checks and matched profiles. No patch implemented here, no new collector needed.
