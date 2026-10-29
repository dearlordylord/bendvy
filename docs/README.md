# Documentation

Start with the document that answers the current question. Historical plans and
measurements do not grant execution budgets or qualify the current source.

| Question | Source |
| --- | --- |
| What are we building, and which decisions need approval? | [Specification](SPEC.md) |
| What should be worked on next? | [Task navigation](next-core-checkpoint.md), then the governing GitHub issue |
| Which core capabilities and gaps are tracked? | [Parity index](parity/README.md) and [remaining-core specification](parity/remaining-core-spec.md) |
| Which API starts a replacement application? | [Replacement execution API](reference/execution-api.md) and [examples](../examples/README.md) |
| How is implementation and evidence collected? | [Workflow](agent-workflow.md) and [check policy](check-policy.md) |
| What are the current execution limits, and why did they change? | [Limits and change history](limits.md) |
| Where are architecture choices and useful design findings? | [Design index](design/README.md) |
| What intentionally remains for later? | [Follow-ups](follow-ups.md) |
| What was verified for a particular delivery? | [Evidence reports](reports/README.md); read the source/receipt scope before using a result |
| What happened during earlier planning and optimization? | [Historical archive](archive/README.md) |

[Reference catalogue](reference/core-map.md), [research](research/),
[law drafts](laws/), and [local ticket copies](tickets/) retain their distinct
roles. A draft law is not an approved law. A ticket copy is not live issue status;
see the [issue tracker](agents/issue-tracker.md).

## Search by question

Run these commands from the repository root. Start with the source or contract
that owns the question, then widen the search when needed.

```sh
# Implementation and runnable examples.
rg -n 'PATTERN' src examples

# Decisions, public contracts and capability requirements.
rg -n 'PATTERN' docs/SPEC.md docs/reference docs/parity docs/design

# Law statements, proofs and subject bindings in this checkout.
rg -n 'PATTERN' src test-fixtures docs/laws -g '*.bend' -g 'SUBJECTS.*'

# Compiler findings and earlier design investigations.
rg -n 'PATTERN' docs/research

# Historical plans, local ticket copies and delivery reports.
rg -n 'PATTERN' docs/archive docs/tickets docs/reports
```

Replace `PATTERN` with a symbol or phrase. Add `-F` for a literal symbol and `-i`
for case-insensitive prose search. Use `rg --files src test-fixtures` to find a
filename before searching its contents. A law filename or match does not establish
approval or proof completion; read its subject binding and governing approval.

For work routing, read [task navigation](next-core-checkpoint.md). For API lookup,
start with the [core map](reference/core-map.md) and follow its source links.
For prior investigation findings, use the [research index](research/README.md).
Search all `docs` only when the narrower sources do not answer the question.
