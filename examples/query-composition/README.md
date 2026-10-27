# Historical Workshop query composition

Workshop belongs to the superseded transactional executor. Its 23 frozen
checkpoints cover required and optional components, filters, complete arrays,
deferred changes, and rollback. The current replacement executor preserves
partial writes after returned errors, so the rollback checkpoints are not
current compatibility requirements.

The scenario, TS reference, expected data, verifier, and original check script
remain here. The historical Bend caller and runtime are preserved at
[`1037bab017fcc8037c518fa5d89dfa0c28e9ee30`](https://github.com/dearlordylord/bendvy/tree/1037bab017fcc8037c518fa5d89dfa0c28e9ee30/examples/query-composition).
[#75 completion](https://github.com/dearlordylord/bendvy/issues/75#issuecomment-6284507430)
binds that delivery to the epoch-aware clock implementation and
[passing CI](https://github.com/dearlordylord/bendvy/actions/runs/39377813049).
Those observations retain their original source and contract.

To inspect or replay that source, use a separate checkout with its qualified tools:

```sh
git worktree add --detach /tmp/bendvy-historical-workshop 1037bab017fcc8037c518fa5d89dfa0c28e9ee30
cd /tmp/bendvy-historical-workshop
bash examples/query-composition/check.sh
```

The historical JS verifier checks 22 reference matches and the approved
foreign-world divergence. [scenario.md](scenario.md) defines that fixed story.
The old measurement entry remains in the same immutable source. This command
does not qualify the replacement core or launch a performance campaign.

Start new applications with [Scheduled health](../scheduled-health/README.md)
and the [replacement execution API](../../docs/reference/execution-api.md).
