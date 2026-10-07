# Registered public event readers (#31)

Run from repository root with a fresh output directory:

```sh
python3 experiments/public-event-readers/build.py --output .artifacts/events31-replay
```

The runner freezes the current core and these fixtures, checks reference commits,
uses existing Node/Bend and the separately approved Clang19, and applies checker5 /
emit30 / Clang120 / runtime5 second limits. No package installation is needed.

- 18 complete public TS-equal checkpoints: two actual registered readers, publication
  order, slow-reader retention, failed read/retry, failed publication/retry, skip,
  cleanup, the actual TS65536 entry capacity and whole-batch overflow/lag.
- Seven additional TS-equal late-first-run checkpoints: a65537-value batch dropped
  before either reader first runs must not report reader lag; an independently
  starting reader observes the remaining backlog.
- Every retained value is compared, including65535/65537 element payload lists.
  Fresh TS inspectors read complete retained payloads; debug supplies actual
  reader unread/lag observations. Inspectors themselves advance TS ticks; the
  comparisons do not assert incidental clock encodings.
- Separate Bend lifecycle extension: dispose one exact registration, retain the
  other reader's actual10/11 backlog through frames, read it, then release it.
  Pinned TS has no public per-system disposal method.
- Same-callback registration swap rejects and returns original arguments.
- Four intended check-time controls: undeclared access, publication through read,
  cross-schema reader and duplicated affine reader. The existing ten public
  component/query controls replay against the same frozen source.
- Three source mutants compile and are reached/detected on both JS and Native:
  dropped publication, advancement after failed read, and cleanup ignoring an
  active reader. These are executable controls, not mathematical proofs.

Every actual stdout is retained losslessly with gzip. Receipt hashes bind source,
commands, diagnostics, binaries and full observations. Three observed repetitions
per ordinary backend include process startup and JSON serialization; concurrent
load is uncontrolled. This is finite feature evidence, not hot-path qualification.
The unchanged Workshop regression gate is delivered by the integrator separately.

The opt-in Runtime owns one event domain with its World. All publishers in that
domain must execute through its World bridge so successful publications are stamped
exactly once; direct out-of-band World mutation is not a supported integration.
Existing append-only consumers are unchanged. Mixed removal/event domains require
independent retention owners because skip semantics differ. Affine event fan-out,
full connected runtime qualification and the performance matrix remain with the
full core and #21/#23/#24; Data events are not a final Data-only approval.
