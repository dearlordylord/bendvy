# Swarm example checks — 2026-10-08

## Passed with Bend 2.0.36

Used the official 2.0.36 Linux arm64 release in a separate temporary installation.
The installer verified its release checksum; the main thread's toolchain was
not changed. Base 2.0.36 defines `Ready`, confirming the prior world-constructor
collision; the distinct world-scan names compile with this version.

- The exact `examples/arena/build.sh` command passed: development type/ownership
  check inside the existing five-second wrapper, then `.mjs` emission.
- `examples/arena/check.sh` passed: the game build, finite fixture type-check and
  emission, gameplay checks, and the actual browser-module host harness.
- Default gameplay: 512 enemy entities and at least 40 live projectile entities
  after 24 steps; frame counters match actual materialized bodies. Movement,
  retained birth speed, slower newborns, deterministic replay and reset pass.
- Source-current ECS fixtures: closest enemy loses exactly one of four health
  units; AoE loses two inside its radius and none outside, with the fixed 180-tick
  reset; chain performs distinct impacts and expires after its budget. Live
  handle counts confirm impact/death cleanup at the real command barrier.
- Explicit no-revisit control: a chain skips an already visited enemy even when
  that enemy remains closest and is the projectile's preferred target.
- Actual renderer/host wiring: keyboard movement, pause/resume, blur, hidden tab,
  restart, smaller sprites, green/yellow/red bars, expanding pulse and chain.
  Controlled renderer fixtures stay inside their own emitted Bend module; the
  fixture wrapper normalizes the outer Packet tag for the UI. This avoids the
  2.0.36 cross-module constructor-tag boundary while retaining real ECS gameplay.

## Limits

Real Chromium smoke remains blocked before page loading by the container's
missing `libatk-1.0.so.0`. No native-browser screenshot or pixel-rendering pass
is claimed. The optional browser runner is retained for an equipped environment.
No new ECS behavior, approved laws, mathematical proofs, native execution or
qualified performance results are claimed. Checks cover finite examples only.
The demo's documented lifetime/allocation limits are separate from live counts.

## Authored inputs checked

- `game.bend`: `8e40bf890ef03ce937aed40b9c3f7e793a5a0bc85bd79cc1a706928b995b630a`
- `fixtures.bend`: `7c01cc64b45277bd7d490b7602e8e1d45b28e06c4ca3291796903e777592b53c`
- `browser.mjs`: `44bd63cca275ffecb2519392cf2d960c83d73d0cbe68516fc6be614c97f55d51`
- `index.html`: `fcc16edceb99ed7a400644ed91081eb0b87fbb88b367b6a39dc618d69030f125`
- `test.mjs`: `8eb703a1c76de883e04db3740d960b30b81f5db8711f330ca3047ad4ac102962`
- `host-smoke.mjs`: `2a142c09e999ec1e95651c2b1798ff305671a72f350f8e313aea3712a580c016`
- `build.sh`: `69f849b63d91b92f9fd9c36d8fb86a764ae87a94d3b78fcb67b141ae72399a39`
- `check.sh`: `d8e31ee99cdf9b8d32a85498af63f8d29b525ecd9e77cad92fe0b0d9401eba4a`

## Generated artifacts checked (ignored, regenerate locally)

- `dist/game.mjs`: `ddd8c24acef18bac0d1fa38a2cc72389af22df3462c60a00b6e5d8f691659f69`
- `dist/fixtures.mjs`: `6bf1c7895276aaa2c732bc3cd85901740e4c1f16d15f70d1b82ee3a872184c4f`
