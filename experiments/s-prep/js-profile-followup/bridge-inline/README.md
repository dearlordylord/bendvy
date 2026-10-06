# Reached swap bridge: manual-inline hypothesis closed

Read-only AST inspection found one value reference to `__fold_state_reuse_3__swap_split_0`, a direct ReturnStatement call from `__fold_state_reuse_2`. Both schemas pass twenty initialized identifier arguments to twenty plain parameters; the receiver has no nested functions, `this`, `arguments`, eval, catch, await or yield. Motion receiver/caller sizes are 2,902/1,807 bytes with fourteen unique const locals; Health sizes are 2,659/1,344 bytes with seventeen. Hygienic inlining is structurally plausible, but its predicted construction delta is zero.

The actual bounded V8 traces explicitly record that this exact receiver **is inlined into `__fold_state_reuse_2` in both schemas**. Both exact frozen static64 programs pass all 65 fresh TypeScript worlds during these trace runs. Therefore this experiment does not implement a manual-inline rewrite or infer that this bridge is an unresolved call-transport bottleneck. Observed inlining does not prove every dynamic execution stays optimized.

`run.py` validates exact frozen recipe/catalog/parent joins, actual 29-source hashes, generated program, Native C/binary and build receipt. Each command is supervised under five seconds on CPU7. Raw `trace.txt`, selected trace and evidence are retained. Native is pinned for provenance and is not executed by this diagnosis. There are no comparative clock observations.

Two infrastructure failures remain evidence: the first Motion attempt guessed `batch.native` whereas the authoritative build uses `batch-native`, and the first Health trace delivered only 64 intact JSON lines because trace and buffered stdout output collided. The corrected Health context adds a SHA-bound preload setting stdout blocking; it leaves the generated program unchanged and passes all 65 records. Motion's corrected binary-pin attempt already passed without that preload. Neither failed attempt is a source semantic failure or an accepted validation.

Exact receipt paths and hashes are in `status.json`. This diagnostic does not modify source/compiler/kernel, approve a law, claim universal refinement, reset canonical limits or select a performance candidate.
