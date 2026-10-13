# #46 timed-lifecycle final Spec/Standards review

Packet commit: `0cca016b044ee350f56ff3ab9e714a9a4f244351` in `decode46-native-resume-v1`.
The reviewed child is `operation-interval-v1/timed-v5`. This review was read-only; no
compiler, backend, runtime, hook, or heavy check was rerun.

## Verdict

**Bounded acceptance: PASS for one ordinary fresh 32-case lifecycle on generated Bend
JavaScript, the pinned TypeScript reference, and standard `-O3` Native.** The evidence
is source-bound and archive-integrity checks pass. It remains a bounded correctness and
timing-telemetry slice: it is not a performance/scaling result, universal refinement,
compiler-adoption result, or full #46 closure.

Two residual accounting/provenance notes are recorded, with no current-runtime blocker:

1. The producer import inventory is reported separately as exactly 283 paths (279 new
   and four byte-identical existing). The portable `ACTUAL-MANIFEST.json` instead has
   **284** rows classified `owned timing experiment child body`: timed-v1 140, timed-v2
   37, timed-v3 32, timed-v4 37, timed-v5 38. The difference from the previous v4
   manifest is the three archived v4 packaging rows (`ACTUAL-MANIFEST.json`,
   `DELIVERY.json`, and `PORTABLE.zip`); the manifest currently classifies all three as
   owned. This is an administrative classification discrepancy, not an output mismatch;
   retain the producer 283-path inventory as authoritative and avoid using the manifest
   kind count as that assertion.
2. `reference.mjs` imports `/workspace/formal-proofs/bendvy/.references/bevy-ts/`.
   The repository reference manifest and checkout agree at Bevy-TS commit
   `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334` (the imported `index.ts` hashes
   `a74d79748f5eff6e9f732b54ed6efc0a42826e4cf8ffc7ab9504d11257e6d61f`), but that
   external reference is absent from the packet's `SOURCE-BASIS.sourceInputs`,
   `TIMED-RUN-PLAN.pins`, and manifest. The workspace run is therefore bound and
   reproducible here; standalone portable replay of the TS reference still depends on
   the separately governed `.references` checkout.

## Source and generated-boundary review

`SOURCE-BASIS.json` (`24a0f4eabdd5eed70f57176dd81ecf7912a6eeaab0eceb38b14963cc8c2cac08`)
records 51 Bend imports, two foreign timer modules, and six TS imports. All 156 listed
source inputs are present and their recorded SHA-256 values match. The plan is
`TIMED-RUN-PLAN.json` SHA
`48a844e7a6581bfbacc53a50ee928dc0f539655b0b40d7f5405174ff4a3a8d6f`, with 285 source
pins, six tool pins, three resource roots, and two resolved-link bindings. The source
worktree is clean at `6fb739056e687503b3d58b3d33ae00964a48472c`, under root source
commit `45129efdf93deb00a54755d55af88974db32ac4c`.

`direct-cases.bend` enumerates 32 cases: 24 Workshop cases (eight codecs for each
of insert, spawn, and resource) and eight Garden insert cases. `main.bend` places
`Clock.begin` before `Common.main`, captures the complete String, then calls `end` and
`finish`; `timing.js`/`timing.c` buffer output and emit it only after the interval closes.
The generated barrier
`GENERATED-BARRIER.json` SHA
`1154c99f37ae0cdd646fee729a0be76c9ba1a4df258ef6919d7b6d8744d852ea` proves the emitted
JS/C continuation order, including reset -> begin -> common-main, capture -> end ->
finish, and deferred stdout. The v5 source-change is only validator EOF normalization
and oracle-directory rebinding; the emitted JS/C hashes are reused from the prior
barrier-checked emission.

The public Bend projection is substantive: `serialize.bend` traverses each
`Owner.View` raw value, original value, words, and flags, plus input, entity/resource,
pending-command, receipt-lowering, and checked-result fields. The TS `public.mjs`
requires the same owner fields (`value`, `original`, `sentinel`, `flags`) and rejects
unobserved components/relations; `reference.mjs` reaches the real schema, constructed
component/resource, query-write, resource-write, and command paths. This supports the
claimed public full-32 observation and aligned TS owner fields.

A scope boundary remains: `public.bend` defines a separate `Whole<S>` carrying
`{public: View, native: App.Report}`, but the timed-v5 entry reaches `Public.view` and
`Serialize.view`, not `Public.whole`. Therefore the evidence qualifies the public view
and its embedded physical owner fields; it does not independently serialize the
standalone native `App.Report` supplement. If “separate qualified physical” requires
that standalone supplement, this is a remaining gate; otherwise it should remain an
explicit limitation.

## Oracle and execution evidence

`oracle-v1/derive.py` SHA
`60cae561b61c6044d91820ea3cfbf28819d4ffa552a381dddac3a1abadcaab2c` derives the timed
expectation without current JS/TS/Native output input. It binds the canonical accepted
wire gzip (8,371 bytes, SHA
`a7b1e9d98061cd4ed89a01d6daf8bc9f4be56ce630c3781587301dbf36c95d4b`) to a 624,328-byte
wire (SHA `ac4be8d768a1b64def3fe8ea2608830a45d5565bd4f18cf742605576b92f5221`), decodes
the complete 501,885-byte UTF-8 public String, and appends the timer's one LF. The
result is 501,886 raw bytes, SHA
`d5c1e6d70d03842985a7fb6ebc6b41614a82a74f24a50e6833ac7207be8fe96d`, FNV-1a32
`909256459`, 32 records; the derived gzip is SHA
`7813d65b2bb2804eb3e432040437816bc72f526aa69d83b175bb1a5a89a69c45` and metadata is
`ORACLE.json` SHA `8f393a8cd70d13c654b38b4de2049c2aeac13aac1a771737a3f57572eb389363`.

`RUNTIME-RECEIPT.json` SHA
`5cb45eb20a5e244e81eb9c3f8f33ddc034871db1c354c69c189383e7c703353a` records four
ordered commands: JS, TS, Native `-O3` build, and Native consumer. All exit zero. Each
consumer validates 32 rows, 501,886 raw bytes, the same raw SHA/FNV, and one interval.
The Native binary is 3,210,752 bytes, SHA
`71edf62f0cda91c8ad971d4efc09f3ec301d9267d41633c608b898ff22cb9ef6`; the build uses
pinned Clang 19 with `-O3`, `-pthread`, and `-lm`. Recorded elapsed values are
206,686,255 ns (JS), 35,387,078 ns (TS), and 40,284,700 ns (Native), and are explicitly
telemetry only. No timing threshold or ratio is applied.

## Archive and historical evidence

`DELIVERY.json` SHA
`4917c87cdafa7d3d744cb44701611ce6c6e50716a5a8caed341593e3ad5c92bc` binds
`CURRENT-RESULT.json` SHA
`62a4f3c0ce63cc6b8c7c1e0afe014f05925f31c372ad67715c338bf88b167094`, the manifest
SHA `cf8700a6b1bbbf31fd6d2c95c30ff3b06d7d4b51083648bb6ffa77e791a6920f`, and
`PORTABLE.zip` (10,086,214 bytes) SHA
`486f12e93eca1be0fb331ab3f6aa33b3fbfbf0cae8dee98242a5b487edfe9fa8`. The manifest
has 341 rows and 188 unique content-addressed objects; the zip has 189 members
(manifest plus 188 objects). Every local row hash matches and every archived object
name, byte length, and SHA matches its manifest row.

The four historical attempts remain represented with statuses STOPPED, STOPPED,
INCOMPLETE, and COMPLETE. The four historical whitespace validators remain byte
preserved in the archive (v1-v3 SHA `008724613c5b4b0c0c1fdc819b140221a76c6cc233fd9606f54df6e08e9cfd6a`,
v4 SHA `a12e808169994957e186bc0557d2b7d304b85fa78cc89327b522a2fa1eca6302`); the
current v5 validator SHA `e52f29e93cf233860fc5034d771c64878c201193f40eaf5a89119887e4e4f97c`
has the single final LF. The configured producer hook history records source/admission
success and the expected historical `git diff --check` refusal; no bypass or rewrite
of those archived files is claimed.

The bounded Bend `--check-only` refusal is correctly recorded as expected FFI/unsafe
IO refusal, not proof. No core/compiler source, API contract, law, acceptance threshold,
performance claim, or cross-host Native claim is introduced. No Bevy Rust execution or
universal parity claim is made; the TS side is the pinned Bevy-TS-backed reference
subject described above.
