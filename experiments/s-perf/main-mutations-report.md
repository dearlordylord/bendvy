# Indexed joined-host mutation gate

**PASS: all twelve compiling mutants detected on Native O0 and JavaScript.**
The original matches a freshly executed pinned TS E0–E10 trace in all ten
channels across Motion/Health and Returned/Regenerated capture lanes. Every
mutant executes the same actual host entrypoints and has an intended-channel
witness on both backends; checker/build failures are not counted as killed mutants.

| Mutant | First intended witness |
|---|---|
| query-order | `Health/regenerated-closure.snapshots[4].optional[0].aux` |
| suppressed-setter | `Motion/regenerated-closure.ownWrites[0].main.coordinates[0]` |
| inverse-order | `Health/regenerated-closure.snapshots[6].lookups.b.main.levels[0]` |
| failed-cursor | `Health/regenerated-closure.reads[6].added` |
| other-reader-routing | `Health/regenerated-closure.reads[6].messages` |
| skip-change-cursor | `Health/regenerated-closure.reads[12].changed` |
| reset-capture | `Health/regenerated-closure.dispatches[1].counts.B[0]` |
| reversed-command-FIFO | `Health/regenerated-closure.snapshots[24].aux[0].main.levels[0]` |
| implicit-flush | `Health/regenerated-closure.snapshots[0].aux` |
| failed-publication-leak | `Health/regenerated-closure.reads[5].messages` |
| failed-change-stamp | `Health/regenerated-closure.reads[5].changed` |
| reissued-failed-reservation | `Motion/returned-owner.rawReservations` |

The failed-publication witness is the actual E3 Fast read: expected messages `[]`, observed `[{'code': 9}]`.

Three mutation patterns follow the indexed adapter: query-order removes the
new ordered traversal reversal; command FIFO bypasses the reverse before the
indexed batch; implicit flush invokes the now-effectful deferred barrier using
`IO.bind`. The remaining nine retain the original mutation subjects. The source
closure, exact replacements, fresh reference, decoder/comparator and all commands
are pinned in `main-mutations-evidence.json`. The decoder and comparator are
byte-identical to the original gate. No candidate core source is edited by this
runner; each mutant receives its own frozen source copy.

Replay:

```sh
python3 experiments/s-perf/main-mutations-run.py --overlay /tmp/indexed-overlay --output-dir /tmp/indexed-main-mutations --cpu 10
```

Checker/runtime limits remain 5s, code generation 30s and clang 120s. Native
uses O0, one worker and GPU off; these are semantic results, not timing evidence.
CPU affinity does not reserve the whole machine.

The first attempt hit the original Motion checker five-second deadline before
any mutant ran. Its exact isolated retry passed, followed by the complete fresh
replay without checker failures. The first timeout remains recorded and prevents
a claim of globally stable checking. No source or budget was changed to retry.
Full original/mutant outputs, commands, diagnostics, exact source closures and
both attempts are retained in `.artifacts/indexed-main-mutations-20261004.tar.gz`,
with its SHA256 in the evidence. Generated C/JS/binaries are pinned by hash and
remain in the local attempt folders; the archive avoids duplicating them. Future
stable-checker work should reproduce and
explain the variable original deadline under the same five-second gate.

This is finite actual-host evidence. It proves neither universal runtime
refinement nor production capability/performance acceptance. Candidate-specific
index/growth/ownership controls and the separate E11 retention replay remain
independent gates.
