# Example checks — 2026-10-08

- Installed Bend 2.0.35: development type/ownership check passed within the
  existing five-second checker wrapper; `.mjs` emission succeeded separately.
- `node test.mjs`: actual emitted Bend controls passed for deferred bootstrap,
  movement, pickup collection, damage/cooldown, game-over, bounds, deterministic
  replay and fresh-game reset.
- `node host-smoke.mjs`: actual browser module plus emitted Bend passed in a
  lightweight DOM/canvas harness, including keyboard movement, draw calls,
  pause/resume, blur, hidden tab and button/key restart.
- Real Chromium smoke: **blocked before page loading** by missing
  `libatk-1.0.so.0`. No browser packages or system libraries were installed.
  `browser-smoke.mjs` remains available for an environment with Chromium's
  runtime dependencies. No real-browser screenshot or rendering pass is claimed.
- No new approved laws, mathematical proofs, native execution or performance
  results are claimed by this example. The build compatibility fix below only
  renames internal ECS constructors.

Authored inputs checked:

- `game.bend`: `09d00be92ce6d7cdef0114fefb24e3111d9c01675def31314c323dd2c5f93e76`
- `browser.mjs`: `e138df519c4ce0ef26bc4030cc74ad5b7be6355b38e5949ec48cc59fe61fcb63`
- `test.mjs`: `8762b230999bdcf5fd8e20bf5e07aac1d3179c1a8afe474c398c979ecf31e2c0`
- `host-smoke.mjs`: `e1f9dc7c6d3a82b6571b670a224c9b51fe38f81ab5f093c4050b97381309cb7b`
- `browser-smoke.mjs`: `dba4c620d8e3edae1ac195171ccbe0c427faeec66cbd0dd532203aabab03e2c2`

## Constructor-name compatibility fix

The reported build rejected the generic `Ready` constructor in `world.bend`.
Renamed that scan phase's constructors to `WorldTailScanReady` and
`WorldTailScanRead`, including every construction and match. Scan behavior,
ordering, fields and fuel remain identical.

Re-ran the exact `examples/arena/build.sh` command, followed by both Node
checks above: all passed with the installed Bend 2.0.35. The reporting user's
compiler version has been requested; compatibility with that exact version
has not yet been reproduced locally.
