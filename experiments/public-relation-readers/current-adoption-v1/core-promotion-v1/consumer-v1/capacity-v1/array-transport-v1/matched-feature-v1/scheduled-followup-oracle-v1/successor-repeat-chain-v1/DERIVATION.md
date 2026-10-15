# Reached repeat-chain source applicability successor

Producer `a520d5306`; entry SHA-256 `79d13bf20744157fa3a19f94887592f068d5898333bcfa182901f47cd7ea73b4`. Frozen selected 65-source closure: `/tmp/bendvy43-scheduled-followup-oracle-source03`. All 64 core bodies remain identical. The 77 selected source/reference pins additionally retain both rejected entrypoints used as finite negative controls. No accepted golden is changed.

## Actual source cause and corrected chain

The previous setup-growth binding ae169415d still incorrectly treated the intended nine-schedule model as applicable. I had not reduced the entire final continuation chain. In cf72e7a07, follow_after_slow_read executes slow_read, then follow_after_fast_repeat executes slow_repeat, then follow_after_slow_repeat immediately renders the final state. Thus only one repeat runs: slow at clock10. It is not a duplicated execution of slow_repeat. The function name follow_after_fast_repeat does not itself imply that a fast repeat occurred.

The unexecuted intermediate dd5ccdb18 replaces that one invocation with fast_repeat. It therefore runs only fast at clock10 and omits the final slow repeat. This intermediate was rejected during source review before backend execution and is not an accepted binding.

The final a520d5306 separates rendering into follow_finish. Its actual bodies are:

```
follow_after_slow_read(state) = follow_after_fast_repeat(follow_slow_read(state))
follow_after_fast_repeat(state) = follow_after_slow_repeat(follow_fast_repeat(state))
follow_after_slow_repeat(state) = follow_finish(follow_slow_repeat(state))
follow_finish(state) = final context observation and serialization
```

Inner invocation results feed outer continuations. The selftest checks the entire selected entry equals the predecessor with exactly this tail rewrite; it also reduces the actual function bodies, rather than assigning operations by continuation names.

## Complete main-path reduction

The finite source-body audit checks main calls followup_start(setup()), the successful Ready branch passes all three actual handles through writer/fast/slow registration continuations, run_followup creates WriteArgs from those values, and follow_initial evaluates warm_readers before its continuation. It then expands every nested state/continuation application until the actual final-render expression. Actual leaf schedule bodies supply their Sch.System IDs/slots and Barrier steps.

The resulting schedule sequence is exactly:

1. warm: System2 then System3;
2. link writer: System1 then Barrier;
3. self/existing/missing writer: System1 then Barrier;
4. fast callback failure: System4, actual Sch.Failed with Ran4;
5. separate active skip: System2 with false condition slot2, Skipped2;
6. separate fast retry: System2;
7. slow independent read: System3;
8. fast repeat: System2;
9. slow repeat: System3, then final rendering.

Sch.System dispatch key4 selects the existing fast provider, whose actual World registry ID is2. It is a supplied schedule dispatch key, not a fourth registered system. World retains exactly writer1/fast2/slow3 and nextSystemId4; Sch.build validates the supplied dispatch catalog [1,2,3,4].

The model executes this extracted finite plan using the existing source-derived operation/state helpers, stops immediately at a failed dispatch within its schedule, and records the real outcome before the next separately built schedule. Warm activation, failure cursor preservation, full active-skip identity, retry equality, independent slow view, both empty repeats, graph/stamp/allocator/shared-history observations and all terminal effects remain checked. Final query cursors are writer5/fast10/slow11 and final World clock11; there are 21 trace rows and nine schedule outcomes. The original setup failure is separately rejected: a one-slot column's raw target swap2 fails, whereas the selected source's ensure makes it fit.

## Finite negative controls and complete wire

Both rejected repeat entrypoints are reduced by the same actual-body algorithm and operation model; no candidate stdout is copied or used to construct them:

| Source | Reached final repeat | Clock | Query writer/fast/slow | Bytes | SHA-256 |
| --- | --- | --- | --- | --- | --- |
| cf72e7a07 | slow only | 10 | 5/8/10 | 24765 | `26d7d8d8c488439fde3fcfc407eb269905af380e32f7d0c70ae91a717f3d0509` |
| dd5ccdb18 | fast only | 10 | 5/10/9 | 24765 | `a9da828292064af1c1b9786809214ef2b3548ce671deb141d6fa32f178ef6c22` |

Their full source-predicted wires are retained as rejected-omitted-fast.stdout and rejected-omitted-slow.stdout. Both have eight schedule executions and 19 rows and explicitly fail the nine-schedule applicability assertion. These are model controls for historical source errors, not new runtime scenarios or accepted expected output. The original setup-failed source also fails applicability independently of its continuation chain. Original c8a3/ae169 and actual01/actual02 remain preserved as source-inapplicable intended-model history.

The selected corrected source independently derives the original full expected wire: **26,254 bytes**, SHA-256 `fd4316f0b089ccdd0bec3c06faba92b9096c08e3fd4c4d1d7054e24e505de926`. Reuse the parent expected.stdout unchanged. Complete fragment reconstruction still produces seven ordered chunks and exactly one LF, with structural fuel10671 and8379 loop visits. No fields, arrays, outcomes or whitespace are dropped or normalized.

Run `python3 verify.py` for all pins, exact whole-entry diff, actual main/continuation reduction, primitive setup capacity control, nine-schedule state derivation, full intended-wire equality, complete negative predictions and terminal IO reconstruction. `--write` regenerates only the rejected model controls and derivation-result.json. Python source checks pass. No Bend backend, generated artifact or actual output was read or run by this successor derivation. Candidate mismatch reports located the old branch; source reduction supplies the correction. Backend acceptance remains pending the unchanged collector rerun.
