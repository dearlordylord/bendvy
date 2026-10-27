# Historical runtime fixture replay

The ordinary transactional/failure-prefix runtime was removed under #94 after its
current application consumers migrated. These historical fixtures retain the
original API, rollback policy, World layouts and source bytes. Do not adapt their
imports to the replacement core or treat missing historical imports as a failed
replacement law. Do not transfer their old qualification to current applications.

The final complete source snapshot before runtime removal is
[`8a686de33ddc12eeeaf0f98d0ff5ddcffa397a42`](https://github.com/dearlordylord/bendvy/tree/8a686de33ddc12eeeaf0f98d0ff5ddcffa397a42).
It includes the original library and fixture paths together. This is an exact
reconstruction binding, **not a new qualification or proof receipt**. Original
receipts retain their own subject commits, compiler pins and approval scope; use
those commits when reproducing a particular recorded result. In particular the
historical examples qualified at `1037bab017fcc8037c518fa5d89dfa0c28e9ee30`
are distinct from fixture cohorts modified later.

```sh
git worktree add --detach /tmp/bendvy-historical-fixtures 8a686de33ddc12eeeaf0f98d0ff5ddcffa397a42
cd /tmp/bendvy-historical-fixtures
```

Run a cohort's original instructions and tool pins there. The original
`query-controls.py` runner and deferred `benchmarks/parity-features` consumers
belong with that checkout. Running them against current replacement sources would
change their source contract. No replay or new performance campaign is claimed.

| Historical cohort | References to removed modules in the retained snapshot of fixture files |
| --- | ---: |
| connected-performance | 603 |
| ordinary-app | 16 |
| public-clock-events | 4 |
| public-clock-system | 4 |
| public-inspect | 28 |
| public-save-pending | 3 |
| public-schedule-readers | 10 |
| public-schedules | 28 |
| public-scopes | 20 |
| query-composition | 8 |
| query-pair-v1 | 2 |
| Total | 726 |

These are import statements, not numbers of tests or failed proofs. The
public-nested-provision and public-schema-fragments benchmark cohorts also retain
their original contract even where their direct imports still exist. The
lifecycle migration explicitly froze connected-performance, the Inspector timing
cohort and ordinary scope fixtures; their bytes remain unchanged.

Current replacement `execution-*` law/control fixture imports are present. This
inventory does not establish successful compilation or execution. The current
application examples remain ordinary CI targets, including their actual Native
and machine limitations. No current product check is retired by this archive.
