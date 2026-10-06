# Source token reuse diagnostic

This exact29 source overlay changes only `prototype-static-client.bend`: reusable `Data` Position/Vitals and Ledger tokens are threaded through private helpers so each read/write pair shares one token value. Every original public definition/type header is retained; old read/ledger helper bodies remain byte-identical. Public `motion_body`/`health_body` routing bodies are newly authored source. This is not original-callback pin acceptance.

Arbitrary components and callback owners remain affine `Type`. Reads, writes, ledger sequence, values, fields, namespace/access checks and opaque owner/provider function types are unchanged. No owner is copied, boxed, inspected through a new authority, or exposed to callbacks. No compiler/kernel/reference/dependency/law/proof edits or canonical cohort/keep/cap reset.

## Evidence

- `bend version`:2.0.35; `bend guide` read before source work. CPU8, checker15/codegen30/runtime5 bounds.
- Candidate static Motion entry passes `--check-only`; JS code generation succeeds. This is a typechecker result, not an approved ECS proof.
- Quiet uninstrumented candidate profile, counted candidate profile and identically counted pinned baseline each compare nine full Motion256 worlds (warmup plus eight measured worlds,64ticks) with fresh pinned TS using the unchanged full-field validator.
- Paired counted constructor expressions:10,086,976 →9,824,832; delta−262,144=two tokens ×131,072 callback invocations (2.60%). PositionToken and MotionLedgerToken each fall262,144 →131,072. Every other normalized kind, including closures and owner transport, is equal. These are executed construction expressions, not guaranteed materialized heap allocations/bytes or qualified performance.
- Fresh archived provider controls on the explicitly new source pass two positive/six intended negative cases: cross-schema callback/setter, affine owner inspection, public setter on abstract owner, undeclared ledger authority and writes through read. Archived control bytes, expected diagnostics and oracle are unchanged; the private adapter verifies actual29 pins and avoids claiming the obsolete callback-byte identity guard passed.
- Initial source check rejected unannotated local token constructors; v2 adds explicit token type annotations. Initial GC-tracing runtime completed but JSON parsing failed because GC text interrupted a large JSON record. Both failures remain archived; quiet profiling resolves output transport without changing observed fields or oracle.

[Paired delta](evidence/paired-delta.json), [baseline counts](evidence/baseline-count-summary.json), [candidate counts](evidence/candidate-count-summary.json), and [archive index](evidence/archive-index.json) retain exact inputs/outputs/source pins. Compressed profile/count receipts include full raw observations and CPU profiles. Final candidate client SHA256: `9c602f1b2a0379fd7b45de090ce880a663f2cb34aa5ef9e98baee356cb3cdfac`.

## Reproduction

```sh
python3 prepare.py --baseline /tmp/bendvy-live-first-native --output /tmp/fresh-token-overlay
# Derive pinned static entry/measurement imports from archived files to this overlay.
taskset -c 8 timeout 15 bend /tmp/fresh-static/batch.bend --check-only
taskset -c 8 timeout 30 bend /tmp/fresh-static/batch.bend -o /tmp/fresh-static/batch.js
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py --no-gc --generated-js /tmp/fresh-static/batch.js --output /tmp/fresh-profile --cpu 8
node --expose-internals /workspace/formal-proofs/bendvy/experiments/s-prep/js-allocation-map/instrument.cjs /tmp/fresh-static/batch.js /tmp/fresh-static/counted.js
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-profile/run.py --no-gc --generated-js /tmp/fresh-static/counted.js --output /tmp/fresh-count-profile --cpu 8
python3 /workspace/formal-proofs/bendvy/experiments/s-prep/js-allocation-map/summarize.py --sites /tmp/fresh-static/counted.js.sites.json --profile /tmp/fresh-count-profile
python3 access-controls.py --overlay /tmp/fresh-token-overlay --output /tmp/fresh-access
```

The recipe verifies29 input hashes before copying, records baseline/output hashes, and preserves every original header. [Candidate client](candidate-client.bend) is reviewable source; `/tmp/bendvy-token-reuse-native-v2` is the materialized exact29 overlay supplied to the integrator.

Native/Health full-field runtime, same/foreign-world fallback/ledger-absence/rollback/lifecycle cases, full22 gates and mandatory performance are not accepted by this diagnostic. The integrator owns fresh source-bound Native/Health/comparison work. A broader per-frame token cache could reduce more constructions but changes the callback environment and is a separate hypothesis; this slice only shares existing same-schema `Data` tokens within one callback.
