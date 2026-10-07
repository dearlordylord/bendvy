# Indexed metadata probe — bounded experiment

No `src/ecs` edits, package adoption, laws, proofs or performance acceptance.

The byte-identical old generic and nominal exhaustive consumers reject added sum
constructors with an intended missing-case diagnostic. A recursive affine carrier
does not solve this source compatibility break. The consumer instantiates real
Array owners. Complete Column integration therefore needs a separately reviewed
provider boundary or an explicit client migration; constructor spellings alone
are not evidence of compatibility.

`Metadata` owns separate added/changed scalar Arrays. IDs 1..131072 index at
id-1 after domain/capacity checks. ID 0 and IDs above 131072 use only the exceptional
list; no same-ID array/list cache exists. Exceptional-only restoration retains
capacity 1 and does not allocate for U32.max. Normal restore may grow both arrays
together, retaining ticks and zero-padding. Reads/clears beyond normal capacity
do not allocate or index the wrapping Base operation.

The raw Metadata constructor assumes consistent power-of-two capacity/depth,
actual arrays of that size, and exceptional-only list entries. Factory traces
start at capacity 1 and require at most 17 growth steps. This is not a universal
refinement of forged constructors or caller-supplied exhausted growth fuel.
Normal absent and explicit zero have the same stamp observation; raw legacy
list order/duplicates are retained and observed on the unchanged legacy route,
not claimed as an indexed list round-trip.

`controls.bend` compares 15 full old/new stamp observations: dense 64, sparse and
capacity/high-ID edges, zero/nonzero ticks, exceptional duplicates, repeated
replacement and saved-stamp replay, clear and isolation. Three legacy raw-list
records check first duplicate lookup and exact set/clear ordering. A final real
Array payload projection mutates 3 to 4 and returns the actual changed owner while
threading the metadata owner. This is not a complete ECS rollback/World test.

Run `python3 experiments/public-optimized-compose/indexed-metadata-probe/run.py --output /tmp/indexed-metadata-fresh`.
The source-bound runner checks the intended affine-duplicate rejection and
unchanged-consumer missing-case diagnostics, observes both JS/Native, and detects
a compiling wrong-index mutant on both backends. Checker/runtime caps remain
five seconds; no timing or CPU/allocation profiles are run.
