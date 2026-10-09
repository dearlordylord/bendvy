# Native debug compilation boundary candidate

Copied-compiler preparation only. Installed Bend and the reference checkout are untouched. `comp.patch` disables exactly the existing single-site tail-fusion heuristic; flat calls retain their existing route. `/usr/bin/python3.11 experiments/public-inspect/native-debug-call-boundary-v1/verify.py` checks the reverse-exact patch and retained fallback text without compiler children. `CONSUMER-JOIN.json` binds the unchanged complete71-source declaration-derived debug consumer and full independent oracle. This is not compilation, behavioral equivalence, Native qualification or a speed result.

## Why this boundary

Pinned Bend source commit a950fd683c0d76f09794078e6174fe98a1492876, `bend2/comp.ts`:

- `file_book`1357–1400 discovers source refs/flat dependencies; `flat_of`1263 propagates the safe flat class. `flat_call`807 requires this class.
- `emit_body`2498–2504 additionally fuses a non-flat tail call when there is exactly one discovered source site, no bang/foreign body, and compatible boxed return shape. This is a compile-time heuristic, not ECS metadata policy.
- `emit_fuse`2126–2138 unfolds a non-flat body into its caller. **It is not used for arbitrary non-flat calls**: those already use segments. Do not infer the count of single-site non-flat fusions from the aggregate emit_fuse counter.
- `compile_book`2765–2774 independently emits every reachable definition each fixed-point pass. The single-site optimization therefore emits the callee independently and again inside the caller; long eligible chains can expand caller bodies and type/term processing. The proposed boundary stops this optional expansion.

Existing full71 copied-reference BOX+adjacency diagnostic reached two whole emission iterations (106654 emit_body events each), facts6264→6286, then cutoff25 during the third. Its sampled self top entries include term_key3345, term_higher1437 and garbage collector2160 among19910 samples. This supports examining emission topology. It does **not** establish that the changed single-site branch is a dominant hotspot, nor attribute installed ELF behavior to the copied reference.

## Preserved route and safety review

After the changed conditional, the untouched `emit_body`2506–2514 path first adapts incompatible return layouts through a typed Let/cut; otherwise it calls `emit_args(...,true)`, flushes spare storage, and `emit_jump`. The function is already independently emitted by the complete done_defs pass.

`emit_args`2069–2110 computes owned arguments before borrowed arguments and updates lend/own facts. Existing jump-mode semantics apply in both old non-flat fused `emit_args(tail && !flat)` and fallback; recursive/layout/ownership equivalence still requires consuming controls. `emit_jump`2051–2067 records task/fork behavior, transfers parameter words, uses WL_JMP for another segment, and WL_AGAIN for self recursion. The patch adds no C native recursion or erased-argument specialization cache. Original self-call exclusion and flat route remain. Parallel tasks and facts can differ with segment boundaries, so source inspection is not a proof of execution equivalence.

## Existing controls to reuse before full consumer

Reuse the existing recursive-registration/layout-key-cache/box-before-key controls and cases (array, nested-array, IO.OP, recursive-list, recursive-owner, mutual-recursion, family-cycle, parameter-products), with complete type/layout/error controls retained. Their old exact-C equality gate cannot establish this patch: emitted C is intentionally allowed to differ. Bind existing independent complete logical observations and actual arbitrary-owner returns to both compiled subjects. Require explicit branch coverage for an acyclic non-flat single-site tail call, return-layout cut, recursive/self path, borrowed-vs-owned array arguments, parallel multi-bind and bang/task routing; existing case names alone do not prove this coverage. No new ECS contract or law is proposed.

Then use the **unchanged full71 consumer and whole oracle** in CONSUMER-JOIN, the existing diagnostic/runner recipe and caps after exact source/plan review. The debug switch must still derive structure/access/schedules from ordinary declarations; no caller-authored metadata adapters or smaller feature substitute. Application source is untouched, so no affected Bend source5 invocation is justified by this compiler-only preparation. No compiler/control/full-consumer child has been launched here. No added BOX/adjacency/cache changes are combined with this patch.

Ownership handoff: root selects the copied-compiler execution owner and admission/reviewer; #56 author remains sole owner of its worktree/runner/fixtures. This worker owns only this candidate directory in parity-54-boxed-scan. Shared src, reference and other workers' files remain unchanged. If branch controls reject the route or full71 still fails, retain failure evidence; do not replay unchanged attempts or increase caps.
