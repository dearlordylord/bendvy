# Combined candidate private scope proposal

Pure read-only audit of combined source `a65021a392b1c693914e61515ff529473699cad7` against baseline `56b72f6` preserves every baseline import, complete type and function header. Storage SHA256 is `27f6b8aa69966eb6e349e7337b0947e50179dbc26cdcc363c1e857bb79cc4130`; query is `c54c276843ac606d96a560b5324a9d4c2c04c8ba3782c1a8fea3d98c9929d775`.

`combined-private-declarations.json` lists exactly five storage helpers, eight query helpers and one internal `StructIdxState` declaration. These literal signatures/types are proposed review input, not an accepted manifest or approval of privacy, semantics, performance, budget or Native factor. No prefixes/wildcards or other declarations are admitted. Existing public headers/types remain pinned while explicitly reviewed new internal state is separately enumerated.

`combined-scope-receipt.json` records exact source/proposal/audit/signature-implementation hashes and actual controls: a temporary baseline public U32-to-U64 signature mutant is rejected; an unlisted private helper is rejected; a candidate outside the explicitly declared repository is rejected. Candidate paths must equal declared repo plus logical filename and pass symlink/traversal confinement. Original candidate files were read only. The structural signature audit does not replace Bend checking, owner/access controls or independent review. No compiler, benchmark, session, tool installation or Astra call occurred.

Replay with explicit read-only paths:

```sh
python3 experiments/s-prep/parity/scope-audit.py --repo /workspace/formal-proofs/bendvy-worktrees/twohour-fusion-review --proposal /workspace/formal-proofs/bendvy-worktrees/twohour-parity/experiments/s-prep/parity/combined-private-declarations.json --candidate experiments/s-perf/candidate/storage.bend=/workspace/formal-proofs/bendvy-worktrees/twohour-fusion-review/experiments/s-perf/candidate/storage.bend --candidate experiments/s-perf/candidate/query.bend=/workspace/formal-proofs/bendvy-worktrees/twohour-fusion-review/experiments/s-perf/candidate/query.bend
```
