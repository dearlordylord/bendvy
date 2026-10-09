# Parallel source boundary repair

controls08 retained two accepted emissions and the failed parallel witness, with no Native build/runtime. No replay or witness relaxation.

Pinned `comp.ts:692` deliberately excludes builtin intrinsics from `term_spine.k`. `anf` at 2009–2010 splits a multi-let if any bound expression lacks a callable key. Therefore direct intrinsic Array.size bindings did not reach a two-child fork. The retained checked Book shows both source bindings, but actual compiler witnesses show no such fork.

The repaired source introduces exactly `measure(owner:Array<U32>) -> Array<U32> & U32: Array.size(U32,owner)`. Both parallel bindings invoke this ordinary authored function. `term_spine` can identify its source Def; it has the same consuming argument and returned owner/size. Existing two Arrays, observations, sum, Report and independent whole model remain unchanged. No primitive or compiler change.

The binding gate now records exact authored measure identities using the same checked Book template mapping algorithm. Parallel gate requires the authored target's two-binding fork with both exact measure callees and two actual measure child-task records with rem=0. Unrelated Base/observe/task/callee refusals remain. This is a prospective source-backed boundary, not an assertion it has executed. Fresh source5 exit0 retained in source5-v7; fresh backend admission remains required.
