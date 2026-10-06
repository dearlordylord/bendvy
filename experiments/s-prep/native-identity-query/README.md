# Identity-handle query Native first stage

Fresh65 full-world TS equality passes for candidate Motion and exact joined8cb parent. Candidate original C SHA412df1718cd1627a40db53f78d7132225541e9423c407bc6b93f4b0eafe0257d; source29 /tmp/bendvy-identity-handle-query-v1. This is a mechanism regression, not a speed measurement or qualification.

| Native diagnostic total | Parent | Candidate | Delta |
|---|---:|---:|---:|
| Allocator requests |22,414,279|43,385,799|+20,971,520|
| RFC redirects |10,576,190|8,479,038|−2,097,152|
| Requested words |56,187,919|2,182,700,047|+2,126,512,128|

Main and MainView constructors halve to1,048,576 each; Cache falls to1,073,152. The intended restoration-triplet elimination is real. It is outweighed by Array/Buffer requests:26,214,400 total. Exact executed sites include blk_node8,388,608, blk_half16,777,216 and blk_new1,048,576 (8/16/1 perupdate). These are allocator requests/word-class sums, not physical malloc or retained heap.

Source query.bend:248–270 manually recurses through generic Array ANode/ALeaf, restoring the same Maybe<M> without extracting Main into the query owner. Generated blk_half and blk_node allocate blocks and copy their spans through blk_fill; the source tree split/rejoin is not emitted as intrinsic point-in-place array access. This explains the directly observed construction tradeoff; no elapsed or cache/memory-bandwidth inference is required. Further expansion should wait for a compiler-supported array access route that avoids rebuilding the tree.

Executed recipe is ../native-main-transport/count.py SHA96a5f9b41d3ec65acfea7c5857caae66d9c3c3c8aada39f36369e3dc07ff6b0e. Actual checker/emission/Clang command-array receipts, all29 source pins, source/entry/C/native hashes are archived and were reconciled by its optional provenance path. CPU8, approved unchanged privateClang19 O3 compile120, runtime/reference5, one worker GPUoff. Original C before/after agrees; all phase markers and counters reconcile. No compiler/runtime/reference/source changes, new dependency, proof, expanded affine/authority gate or Health result claimed. Analysis static caller labels are not dynamic call stacks.
