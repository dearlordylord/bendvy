# Independent oracle-v3

Run the deterministic source model with:

```text
python3 model.py write
python3 model.py check
```

`write` regenerates `expected.stdout` and deterministic `expected.stdout.gz`
after verifying all pinned source hashes. `check` verifies the same source pins
and exact raw/gzip bytes. `SOURCE-BASIS.json` records the derivation and source
identities; `MODEL-NOTES.md` records the finite state interpretation and the
source-visible canonical receiver binding. This successor preserves v1 and v2
as source-only history and adds the current same-world positive suffix: the
canonical receiver's second reserved handle is related, queried, cleared, and
queried again through the existing writer/inverse capabilities.
