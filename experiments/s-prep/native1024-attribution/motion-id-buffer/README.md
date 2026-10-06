# Split-ID Native attribution: escaped continuation and direct repair

Each newly executed Motion Dense1024 copied-C diagnostic passes all65 complete fields against freshly executed independent TS. The measured bracket contains4,194,304 updates, including all4096 ID-buffer allocations and initialization; it excludes setup, warmup and postphase observations. Source29/cache, actual upstream BUILD_PASS, driver, reference, tool and generated C are independently pinned before execution. Original source, C, binaries and runtime/compiler are unchanged. CPU10, Clang120/runtime5, one Native worker/GPUoff; upstream executable checker15 is diagnostic opt-in and default/proof5 remains unchanged.

| Counter | Concrete-v3 parent | Split-ID v12 | Direct-v1 |
|---|---:|---:|---:|
| Requests |29,758,407|101,073,863|29,762,503|
| RFC cells |12,677,438|37,851,454|12,677,438|
| Requested words |169,438,223|561,613,839|137,980,943|

V12 is an adverse executed result, retained permanently. Its regular `resume` arrow and curried lambda in held-adapter drain materialize three closure blocks (1/2/4 words), two32-word FlatFold records and two sets of Ledger/View/Cache per update. Direct-v1 replaces this transport with named saturated functions. Its actual phase has no per-row closure/FlatFold/Ledger/View/Cache construction: Ledger/View/Cache each24,576 fixed, and SplitCon/Pair/Mark/MainSlot each4,194,304. The MainSlot box remains present. A static DirectState CID is not an allocation claim; the analyzer finds no reached DirectState allocation site.

Against concrete-v3, direct-v1 saves8 carrier words/update (16→8-word concrete carrier), adds one512-word ID buffer/frame (4096 requests,2,097,152 words), and has unchanged RFC total. Net words saved31,457,280 (7.5/update). Against v12 it removes71,311,360 requests,25,174,016 RFC cells and423,632,896 requested words. This is a source helper/request diagnostic, not a speed acceptance result.

Direct and v12 both execute readBuffer37,756,928/readArray12,582,912/writeBuffer20,975,616/writeArray16,777,216. Versus concrete-v3, ID transport adds two buffer reads and two buffer writes/update. Native arrays are flattened runtime blocks, not pointer trees. Copied counters can keep otherwise optimized-away reads observable and change optimizer decisions; counts are not product assembly memory traffic, physical allocation, cache misses or elapsed causality. Constructor labels are static callsite attribution, not dynamic stacks.

Version history: original v10 was preflighted read-only but never admitted to compilation/count execution: its ID allocation trusted forged metadata depth before physical Main guarding. V12 separately repairs that guard; direct-v1 changes only held-adapter transport, preserving v12 query/preflight source. Frozen versions and failed hypothesis history remain distinct. This package does not accept Host/query authority, rollback/mutation gates, Health equivalence, universal refinement, full22 or adoption. Root/source workers own fresh separate functional/control and raw timing evidence.

`run.py --output FRESH` reproduces v12; `direct-v1/run.py --output FRESH` reproduces direct using unchanged parent transport-count/analyze methods. Each preflight validates exact source29 and coherent embedded/standalone cache maps/digests plus upstream build/artifacts. `comparison.json` binds the earlier concrete-v3 receipt explicitly; that gate is not relabeled a fresh run here. `archive.py` and `verify-evidence.py` preserve source, C, driver, reference, commands, copied instrumentation, full traces and exact counter/site analyses; native binaries are hash-pinned but excluded from archive.
