# #55 independent logical lifecycle oracle

This directory contains a source-derived oracle for the matched feature lifecycle. It models the logical `run(count)` string from the frozen Bend application and the independent TypeScript reference. It does not invoke Bend, Node, a generated backend, or a historical output.

The source basis is `SOURCE-FREEZE.json`, the freeze03 closure with 93 pinned source paths. `SOURCE-BASIS.json` records the same closure, the source-check receipt, and the derivation. `model.py` rehashes the closure before generating or checking artifacts.

Each lifecycle contains two nominal schemas, `Workshop` and `Garden`. Each schema contributes 64 category records (two relations, eight query modes, two inspect passes, and two check/noop passes) followed by four machine records: fresh Union inspection twice, a machine check/noop, and the registered stream read. The complete lifecycle therefore has 136 records. The finite artifacts cover scales 1, 2, and 4:

- `expected-scale-1.stdout`, `expected-scale-2.stdout`, and `expected-scale-4.stdout` are the canonical UTF-8 JSON plus one terminal LF.
- The matching `.json` files are byte-identical copies for consumers that require a JSON-named path.
- The matching `.stdout.gz` files are deterministic gzip archives.

Run `python3 model.py write` to regenerate the artifacts after a source-basis change, and `python3 model.py check` to verify all source hashes, record counts, raw bytes, and gzip decompression. `CHECKS.json`, `ORACLES.json`, and `SELFTEST.json` record the resulting hashes and checks.

The app's physical/report route and the TypeScript `diagnostics()` route are intentionally outside this logical byte oracle. They retain worlds, event batches, registrations, stream positions, reader cursors, and other backend-specific fields; this packet makes no physical equality, backend qualification, performance, or universal-semantics claim.
