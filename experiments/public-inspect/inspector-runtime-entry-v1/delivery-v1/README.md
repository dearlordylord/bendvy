# Inspector runtime-entry evidence

This packet retains the candidate `src/ecs/inspector-runtime.bend` and one bounded current-source consumer for its public runtime entry. The normal trace exercises two nominal schemas and four worlds, including successful reads, explicit failures, a repeated read, and subsequent use of the same registered event reader. The reached control changes one `W.advance_clock` call to `W.clock` and is checked against an independently source-derived counter output.

The Native receipt is a complete development-consumer pass: emission, ordinary `-O3` build, consumer, full 2,205-byte v3 oracle, and all ten guards succeeded. The original JavaScript receipt remains `INCOMPLETE`: its frozen v1 oracle was 2,189 bytes and did not match. A separate retained-output record validates the saved JavaScript stdout against the later, source-derived v3 oracle. That post-hoc check is not a fresh collector pass.

The ordinary source check stopped at the expected six unsafe/foreign definitions. Treat it as a source-check refusal, not a full type or proof pass. The authority controls are five bounded source-only checks: one positive and four intended negative diagnostics. They do not establish a preservation theorem or runtime guarantee for arbitrary callbacks.

The TypeScript item is a retention-input handoff for a distinct 136-record lifecycle fixture. It is not a run of this runtime-entry consumer and does not establish cross-fixture parity. The protected Workshop records are read-only applicability audits for the prior accepted gate; the candidate module is outside that gate’s reached 23-file closure. They are not new timings or a full-feature performance claim.

Tool and resource trees are identified by the original plans’ hashes and inventories; large installed binaries and resources are not copied. `EVIDENCE.zip` is the portable record for the staged inputs, raw outputs, receipts, guards, and generated artifacts. The producer worktree may retain redundant loose copies; only the paths listed in `OWNED-PATHS.json` are selected for integration.

Run `python3 verify.py` from this directory to validate the archive, manifest, current candidate source, execution receipts, exact full-output comparisons, and bounded source-only evidence. `python3 verify.py --selftest` also exercises malformed-record rejection in memory. Neither command invokes Bend, Node, Clang, or a backend.
