Exact direct CPU52657 /Heap67227 both terminalPASS full4,329,743B oracle63b50/30records/walk/two markers/fourguards each. Profile hashes CPU15c3c26d,Heap7c67a700;25 signed negative deltas retained. No baseline replay or fair speed claim under contention.

| CPU self frame | Samples | Bend / generated line | Region |
|---|---:|---|---|
| Anonymous continuations |2191|Mixed; generated9716/9902/8143 relation-query.scan(src/ecs/relation-query.bend107),12042 owned-world.project_cells38|Setup/operations/forcing mixed; not one function|
| V8 garbage collector |659|Runtime pseudo-frame; no Bend line|Mixed/unassigned|
| List.append |628|Generated1763; shared token expansion|Mixed ancestry; no whole-frame attribution|
| serialize-direct.walk |329|serialize-direct.bend16 /generated1382|Serialization after Complete|
| relation-query.output_join |161|src/ecs/relation-query.bend96|ECS operations/observation before Complete|

| Sampled Heap self frame | Reported bytes | Bend / generated line | Region |
|---|---:|---|---|
| Anonymous continuations |2,152,031,344|Mixed source continuations, inspect actual callframes|Operations/forcing mixed|
| List.append |471,871,776|Generated1763|Mixed token expansion|
| trace-value.tokens |148,906,536|current-qualification-v1/trace-value.bend47|Token construction shared with forcing/serialization|
| serialize-direct.walk |99,617,088|serialize-direct.bend16 /generated1382|Serialization after Complete|
| column.plain_view_taken#1 |88,089,640|src/ecs/column.bend371 /generated9944|Component observation before Complete|

Matched beforeStepNext only: archived CPU9ca8f088 /Heap4f406bbc, same Node100us/Heap1MiB include-collected samplers, depth256/span16 fulloracle and declaration-after/start-beforeCLI boundary. Direct artifactbe864 replaces7ee5; tail/collector unchanged. Source-mapped serializer carrier loop+step reported335,588,448 before; directwalk99,617,088 after. This is sampled selfSize redistribution, not total allocations or proven savings. Total sampled weights3,870,894,728 before versus3,906,528,344 after are similar; no claim of aggregate memory improvement. CPU samples7318 before versus6581 after, directwalk329 versus priorloop283+step45; counts and percentages are diagnostic, not timing ratios or causal conclusions. No further serializer optimization is justified solely by these two runs.

Concrete feature progress: direct changedsource now passes allnine fullJS and allnineNative cases, including full17,753,298B population1024 at unchanged runtime5 cap; source and old deadline evidence retained. Continue source-current last-leaf/moved-walk mutant qualification against direct consumer, retaining complete nine scope and marker/stat failure gates; then existing #42 adoption/#28/fair full-feature timing requirements. Old movedNativeemit timeout remains INCOMPLETE and cannot be promoted from complete-looking partial C. No task closure/corepromotion here.
