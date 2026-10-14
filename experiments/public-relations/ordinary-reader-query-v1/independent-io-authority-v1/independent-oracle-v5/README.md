# Independent oracle-v5

Run the deterministic source model with:

```text
python3 model.py write
python3 model.py check
```

`write` regenerates `expected.stdout` and deterministic `expected.stdout.gz`
after verifying all pinned source hashes. `check` verifies the same source pins
and exact raw/gzip bytes. `SOURCE-BASIS.json` records the derivation and source
identities; `MODEL-NOTES.md` records the finite state interpretation and the
source-visible canonical receiver binding. This successor preserves v1 through
v4 as source-only history and carries the current same-world positive suffix:
the canonical receiver's second reserved handle is related, queried, cleared,
and queried again through the existing writer/inverse capabilities.

v4 corrected two renderer/state-composition details found by source audit. The
outer component-slot `tree` applies its `leaf` wrapper to each `show_slot`
result, so slot text is `L(absent)` or `L(P(...))`. A successful tracked query
also replaces the inverse registry cursor with the observed world clock; the
positive snapshots therefore carry inverse cursors 10 and 13 after the two
queries. v5 adds the failure-reader domain that
`relation-failure-runtime.bend` activates on the successful delivery path. It
is retained with an empty queue, `readers=[3]`, and no published values from
the delivery checkpoint through the final positive checkpoint. No runtime
output is used by this derivation.
