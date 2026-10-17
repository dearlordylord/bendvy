# Workshop query composition

An advanced example of required/optional components, independent filters,
change filters, deferred changes and rollback. Payload observations include
complete arrays. For a new application with declaration-derived access,
registration and a schedule, start with
[Scheduled health](../scheduled-health/README.md).

`declarations.bend` demonstrates explicit query/provider assembly; `driver.bend`
uses lower-level registered runners and authored access lists. These are
specialist integration examples, not a second recommended application facade.
The scenario is also used by frozen reference/regression evidence, so an API
migration must preserve and requalify its full checkpoints.

From the repository root:

```sh
bend examples/query-composition/main.bend -o /tmp/bendvy-workshop.js
node /tmp/bendvy-workshop.js > /tmp/bendvy-workshop.json
python3 examples/query-composition/verify.py /tmp/bendvy-workshop.json
```

The verifier checks all 23 checkpoints and the approved foreign-world
`MissingEntity` divergence. [scenario.md](scenario.md) defines the fixed story.
`timing-main.bend` is a separate historical measurement entry, not a tutorial or
an automatic performance qualification command.

Current-source JS replay checked on 2026-10-17 with Bend 2.0.35 and Node
24.20.0: all 23 checkpoints pass (22 reference matches and one approved
foreign-world divergence). Native and comparative performance were not rerun
for this documentation update.
