# E11 C-emission blocker: static lane selection

The tested **Motion/message** subject now passes both Native and JavaScript against the original strict comparator and ten fresh full public TS reference lanes. This does **not** pass E11/full22: the remaining nine Bend subjects and semantic mutants are unexecuted by this probe.

The exact [original repaired receipt](../../experiments/s-prep/e11-codegen-probe/evidence/original-repaired-failure.json) records Motion/message `30s limit: bend`, ten passing TS references and zero Bend cases. Its checked input has 95 Bend files. Reconstructing the old subject with the unchanged schema/import slicing reproduces every slice/hash in that failed receipt exactly.

## Specific source seam and measured diagnostic

`host-retention-controls.bend` previously passes runtime `RetLane` through `motion`, `motion_created`, `motion_registered`, `frames` and `lane_name`, despite this subject's main being exactly `motion(RetMessage{})`. Reachability therefore retains unrelated lifecycle, unheld and marks frame generators. Existing schema slicing leaves 33 fixture definitions; static selected-lane resolution leaves 28, removing exactly `frames`, `lane_name`, `lifecycle_frames`, `marks_frames`, `unheld_frames`.

The probe changes only Motion registered's two pure selectors: `lane_name(RetMessage)` becomes the original literal `"message"`; `frames(RetMessage)` becomes the byte-identical original `message_frames()` call. The existing slicer then removes unreachable controls. No message frame, including empty frames, operation, field, clock, callback, invoker, renderer or oracle is simplified. The imported protected batch invoker retains the **same sliced SHA256 and all 34 definition bodies** as the failed subject. Its `D.tick` bindings remain actual `motion_presence/invoke/barrier/transition/frame`; seed formatting slice also remains byte-identical. Runtime files are whole and unchanged.

One changed-subject diagnostic on CPU 10: checker 1.13s (limit 15), C emission 6.10s (limit 30), clang 21.24s (limit 120), JS emission 2.18s (limit 30); Native 0.066s / JS 0.298s runtime (limit 5). Both strict full-field Motion/message comparisons pass. Generated C is 4,666,656 bytes with 429 native spin helpers and 1,019 work-loop cases. These are compiler graph/output observations, not performance acceptance.

Pinned compiler [fun_of](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:1174) derives reached function layouts; [emit_native](/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts:2168) emits/caches a helper per definition and erased-argument layout. Keeping unselected fixture branches expands the reached native emission graph. The tested static slice unblocks this subject under the existing cap. No compiler-internal CPU profile was collected, so this evidence does not establish which normalization/emission subroutine consumed the original 30s or exclude environment effects. Protected dynamic RetOp/BodyKind branches remain and must not be pruned merely because a lane commonly bypasses them.

## Gate-preserving integration hook

Before `slice_control_imports` in the original-subject loop (`fivehour-connected-gates/e11-run.py:200`), resolve only the selected schema's `_registered` selector calls using the exact original `frames`/`lane_name` match arms:

| Lane | Exact frame expression |
| --- | --- |
| message | `message_frames()` |
| removed | `lifecycle_frames(B.RetRemoveAll{})` |
| despawned | `lifecycle_frames(B.RetDespawnAll{})` |
| unheld | `unheld_frames()` |
| marks | `marks_frames()` |

Fail closed on selector/main/arm mismatches; record pre/post hashes and retained frame-body pins. Apply the same selected-lane staging in `mutation_build` before slicing, preserving each mutant's authoritative modified frame/invoker bytes rather than replacing them with originals. Keep all ten fresh TS lanes, twenty actual Bend original cases, original decoder/comparator, full fields, invocations and semantic mutants mandatory. Do not infer their pass from this probe. No shared runner was edited here.

[Recipe and all receipts](../../experiments/s-prep/e11-codegen-probe/) retain the original failure, full fresh TS observations, both actual outputs, exact derived sources/C/JS and source pins. An initial local Python import-path setup failure occurred before any compiler/reference run and is retained separately. No timeout increase, core/compiler/kernel/reference/dependency change, new law/proof, canonical cohort or allowance reset occurred.

## Full ten-subject attempt: blocked by fresh reference timeouts

The [extended scoped probe](../../experiments/s-prep/e11-codegen-probe/full-evidence/summary.json) resolves the exact selected frame/lane arms for both schemas and all five lanes, preserving each authoritative retained frame/invoker body and runtime pins. All ten subjects actually check and emit C/JS within diagnostic checker15/codegen30 caps; no Bend build timed out. Eight fresh TS lanes and sixteen strict actual backend comparisons pass. Fresh Motion/removed and Motion/despawned references timed out at the unchanged five-second cap with zero partial output, leaving their four backend comparisons and all required semantic mutants/type controls/oracle perturbations unexecuted. E11 remains **unaccepted**; this is not full22 or current optimized-role evidence.

These permanent failures were not retried. Adapter SHA matches the earlier successful ten-reference probe; earlier removed/despawned took 1.180/1.281 seconds, versus current termination at 5.166/5.023 seconds. Other fresh references were also slower, but no CPU accounting establishes whether execution or scheduling caused the timeout. The full command receipts expose actual checker15 supervision despite the inherited shared report's legacy checker5 metadata. No shared/default runner or proof checker was changed.
