# Preserved drafts restored after candidate verification

Commit `f61e4b3` preserved seven unfinished `.bend.draft` files. They have now been
restored to their intended `.bend` paths **only after the full closure passed the
isolated checker candidate and unchanged installed kernel**. No proof/domain edits
were needed to those preserved drafts. The installed compiler still fails; restoration itself did not authorize adoption or close the root aggregate. The later [scoped decision](../../docs/reviews/owned-checker-local-use.md) now permits this task-local repair; all seven aggregate endpoints and both reviews pass.

| Restored path | Role |
| --- | --- |
| `LAWS.bend` | Exact approved live affine-world law block |
| `PROOF.bend` | Endpoint filling wrapper |
| `advance.bend` | Actual four-constructor runtime step dispatch |
| `bump-rows.bend` | Owned Bump traversal and exact member-guard extraction |
| `endpoint.bend` | Initial capture, unchanged independent guard, final composition |
| `full-controls.bend` | Full-proof mixed and false-domain controls |
| `schedule.bend` | Dedicated owner-threaded recursive tick induction |

The historical obstruction was source-definition unfolding of
`S.no_overflow_lookup(Found row)` into its scalar no-overflow predicate. The pinned
recursive-rigid checker candidate avoids needless expansion of the identical large
Nat bound; the unchanged installed kernel independently accepts the resulting
proof. `candidate-run.py` and `candidate-evidence.json` now record the full closure,
controls, two actual compiling runtime mutants with false complete-law witnesses,
and failures in the dedicated induction. See README for exact provenance and limits.

`run.py` remains the installed-tool partial suite and does not import the full
proof. The later aggregate acceptance and scoped local-use decision are documented separately; global/production compiler adoption remains outside this package.
