# Independent oracle-v1

Run the deterministic source model with:

```text
python3 model.py write
python3 model.py check
```

`write` regenerates `expected.stdout` and deterministic `expected.stdout.gz`
after verifying all pinned source hashes. `check` verifies the same source pins
and exact raw/gzip bytes. `SOURCE-BASIS.json` records the derivation and source
identities; `MODEL-NOTES.md` records the finite state interpretation and its
source-visible receiver binding.
