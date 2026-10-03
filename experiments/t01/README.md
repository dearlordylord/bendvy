# T01 infrastructure canary

Scope: [issue #2](https://github.com/dearlordylord/bendvy/issues/2), parent
[#1](https://github.com/dearlordylord/bendvy/issues/1), [SPEC](../../docs/SPEC.md).
Both GitHub issue bodies and the tracked specification were read on 2026-10-03.
This is a passed infrastructure smoke gate only. It establishes neither ECS
correctness nor performance, universal runtime refinement, ownership/access
contracts, or product acceptance. No ECS laws or new dependencies were added.

Run from the repository root:

```sh
./experiments/t01/run.sh
```

The runner reads `bend guide`, checks Bend version and Base digest, builds the
same `main.bend` for native and JS, compares exact output bytes to `42\n`, and
checks both ordinary checking and `--verdict`. It fails on a timeout, unexpected
exit code, missing verdict, or wrong diagnostic. Generated artifacts are kept
in an ignored temporary directory beside the runner and removed on exit.
Every checker invocation, including compilation, uses `bend-check`: GNU
`timeout --signal=KILL 5 bend ...` (or `gtimeout`). The direct process is killed
at five seconds; timeout/signal exits are never accepted as rejection evidence.
Runtime invocations also use a five-second limit. `timeout`, `rg`, `sha256sum`,
`cut`, `cmp`, `mktemp`, a POSIX shell, Bend, clang and Node must already exist.
The script installs nothing. `BEND_BASE` may identify the installed Base when
Bend is installed outside the usual `$HOME/.bend` layout; it must be the Base
actually used by that compiler, not an unrelated matching file.

## Recorded environment

Measured here on Linux aarch64, glibc Debian 2.36-9+deb12u13, coreutils 9.1:

| Item | Pin / configuration |
| --- | --- |
| Bend | 2.0.34, `/home/node/.bend/bin/bend` |
| Bend binary SHA-256 | `d4821d04932218216c9dc906223ed0e23dd86726d4357a567fb76ee6c976db4e` |
| Base SHA-256 | `c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661` |
| Installed `bend2/bendtt.lean` SHA-256 | `61e0d2d9f4ddd7dd8bb1497fa612fb49a7274fcac647bf70702ba22321d7c292` |
| Native compiler | Debian clang 14.0.6, aarch64-unknown-linux-gnu; Bend default build flags |
| clang path | `/home/node/.local/opt/dnd-clang14/usr/lib/llvm-14/bin/clang` |
| JS runtime | Node v24.20.0 |
| Native workers | `--threads 1 --gpu off` |
| JS workers | one event loop, no Worker threads |
| Guide | `bend guide` for installed 2.0.34, read before writing Bend |

The binary digest is an artifact identity, not a claim that this binary was
built from the reference commit. Installed Base matches the reference Base.
Reference HEADs were checked against the tracked manifest in
[docs/bend2-ecs-port.md](../../docs/bend2-ecs-port.md):

- `/workspace/formal-proofs/bendvy/.references/bend2`: `a950fd683c0d76f09794078e6174fe98a1492876`
- `/workspace/formal-proofs/bendvy/.references/bevy-ts`: `3040a3b2a3f28fa8554d856f9ccb6bf5433fa334`
- `/workspace/formal-proofs/bendvy/.references/bevy`: `ad678262ce53b5d142fe49ee5e08caff6f00ab60`

These read-only references are not required to execute the canary. To reproduce
exactly, provision the recorded compiler/Base, clang and Node versions first;
this task does not authorize installing or updating them. The runner reports
clang/Node versions; only Bend/Base mismatches are actively refused.

## Evidence from this task

`./experiments/t01/run.sh` exited 0 on 2026-10-03. Commands inside it:

```sh
./bend-check true.bend --check-only
./bend-check false.bend --check-only
./bend-check true.bend --verdict
./bend-check false.bend --verdict
./bend-check main.bend -o "$build/native"
./bend-check main.bend -o "$build/main.js"
timeout --signal=KILL 5 "$build/native" --threads 1 --gpu off
timeout --signal=KILL 5 node "$build/main.js"
```

Both true runs exited 0 with `ALL PROOFS CHECK`. Both false runs exited 1 with
`SOME PROOFS FAIL`, `expected : 2n`, `observed : 3n`, `Location: canary`.
The true claim is `Nat.add(2n, 0n) == 2n`; the planted false mutation changes
only its RHS to `3n`, keeping `{==}` as the attempted evidence. Rejection is
therefore a type mismatch at the claim, not a syntax error or tool failure.
The false file is rejected by the first checker before kernel rechecking;
this does not claim an independent false-file kernel rejection. The positive
`--verdict` path succeeds. Native and JS both produce exactly `42\n` from the
same pure `Core.answer(6)` computation, using IO only to print. This is one
finite runtime comparison and a closed elementary fact, not a universal proof
of `answer` or either backend.

## Tool compatibility and remaining gates

No `vendor/bendlib`, lawcheck or bend-falsify tool exists in this checkout;
Bun is unavailable (`bun --version`: command not found). External tool
compatibility with Bend 2.0.34 is **unverified**, not passed or skipped-success.
The installed bend-ldd skill explicitly records lawcheck incompatibility with
2.0.32; that statement does not establish compatibility or incompatibility
with 2.0.34. The local planted false control is reproducible without those
tools, but is not equivalent to automatic law falsification/mutation coverage.

Follow-up: before candidate ECS laws/proofs, request separate approval to add
a concretely pinned bend-falsify and its required runtime (or a compatible
lawcheck release and runtime), then verify it against true/false/planted-defect
controls under five-second checker limits. Reason: tool adoption requires
compatibility evidence and SPEC dependency approval. Status: open, no dependency
request needed for this dependency-free T01 slice. Return condition: a task
requires automated ECS-law falsification/mutation. Such tooling gates remain
unpassed until verified; no dependent proof work is authorized by this report.
Specific ECS laws and numerical performance thresholds still require approval.
Undeclared access, cross-schema and writes-through-read negative controls belong
to the subsequent ECS interface probes and remain required, untested here.
There was no mandatory T01 behavior failure requiring a redesign decision.
No Dalph malfunction was observed; DALPH.md was left to the coordinator.
