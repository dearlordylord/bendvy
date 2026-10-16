# Independent ordinary owned-event application

Author: Codex agent `/root/owned53_independent_application`, assigned by `/root`
on 2026-10-16. Git identity is the existing workspace identity; no alternate
human or agent identity is asserted. Base commit: `1bf6b8595`.

This agent owns only this directory in worktree
`/workspace/formal-proofs/bendvy-worktrees/events53-independent-app`, branch
`parity53/independent-owned-app`. The core implementation belongs to another
agent. No core implementation body, earlier event application, scenario,
observer, oracle or optimization history was consulted to author this app.

## Consulted material and reuse

- Repository routing, `docs/SPEC.md`, `docs/agent-workflow.md`, and the requested
  `docs/parity/affine-events.md`. The latter was bulk read and exposed its
  historical textual implementation-preparation summaries. This is recorded
  explicitly; this author does not claim zero architecture knowledge.
- Installed Bend and bend-ldd skills and actual `bend guide` output. No new law,
  proof, dependency or backend runner is part of this assignment.
- `.references/sources.json`: Rust Bevy
  `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, Bend
  `a950fd683c0d76f09794078e6174fe98a1492876`, and bevy-ts inventory
  `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`.
- Pinned Rust `message/message_reader.rs`, `message/message_cursor.rs`, and
  `message/messages.rs`: readers borrow values and hold independent cursor
  state; `update_drain` and `drain` transfer removed values. Rust's cursor
  advancement and update-window retention are not asserted to match Bendvy's
  selected failure/retry and retention rules.

Public API headers supplied by the core owner will be recorded here before
implementation. No existing application operations or output expectations are
reused. A separate author must derive the frozen whole-output oracle.

## Proposed application scope, not yet frozen

Cargo manifests own small `Array<U32>` buffers. A publisher commits one manifest,
then stages another and fails. The abort receipt is observed in full and the
application explicitly discards or reuses it. Two declared readers operate at
different rates; one fails and retries, demonstrating that its failure does not
advance its cursor or consume the other reader's view. Public maintenance
returns retired owners when the existing retention condition is met, followed
by shutdown draining remaining owners. Observations preserve every array slot,
reader cursor/lag, publication state, receipts and sentinel state exposed at the
public observation boundary. The final scenario and IO entry will freeze only
after stable public headers arrive and scope is agreed with the coordinator.

No backend has been launched. Source checking is deferred until dependency
source checks pass and the core owner supplies the stable public interface.

## Public API guidance received during authoring

The coordinator relayed `/tmp/owned53-public-headers.txt` from the core owner.
Additional constructor/type declarations were extracted from public module type
blocks without reading function bodies. The coordinator confirmed dependency
source PASS and allowed trusted administrative constructor-based observation.
Five owned-event source dependencies were copied without inspecting bodies.

The coordinator supplied the existing public callback calling convention:
rank-two callback implementations use template `~H`/`~grant` (or `~read`), despite
the public function type spelling erased `@-H`/`@-grant`. This resolved an actual
source diagnostic from initially using ordinary erased callback parameters. The
coordinator supplied the public `world-io.bend` Creation/create headers and the
requirement to call actual `WI.create`, with no caller-selected namespace.
`docs/design/public-event-readers.md` was subsequently consulted for the selected
cursor, lazy activation and retention description. Installed Base Array and List
public definitions were consulted for array traversal and list append syntax.

The final finite scope was agreed by the coordinator before freezing. Source
contains thirteen state snapshots (an earlier progress message said fourteen;
the source sequence is authoritative). No prior consumer source or oracle was
used, no backend was run, and this author did not derive a whole-output oracle.
