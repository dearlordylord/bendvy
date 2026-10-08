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
  reset; chain has triple the logarithmic bounce budget (21 at 100 enemies, 27 at
  512), fires on a fixed 60-tick interval, performs distinct impacts, and expires when unique targets run out. Live
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

- `game.bend`: `d53f351e3b8b53df5d84489458a087de228eee505a276285b450711dab0762b8`
- `fixtures.bend`: `df402cf5e60701f728c9198d19467d56750eb35fa9025ad6aae7d68532a3b452`
- `browser.mjs`: `2507f9331506a6f6aeb39d0069da985870a2e0cfb74d871de2a94a6c0330f502`
- `index.html`: `fcc16edceb99ed7a400644ed91081eb0b87fbb88b367b6a39dc618d69030f125`
- `test.mjs`: `ce7afb731504af68701d87d389790a091a993cfd99d5dfe0548fba4ffe66e176`
- `host-smoke.mjs`: `c4beb9a636052f480316d34d60726b504fd7a9223ed4764c7b6114fb56285932`
- `build.sh`: `69f849b63d91b92f9fd9c36d8fb86a764ae87a94d3b78fcb67b141ae72399a39`
- `check.sh`: `d8e31ee99cdf9b8d32a85498af63f8d29b525ecd9e77cad92fe0b0d9401eba4a`

## Generated artifacts checked (ignored, regenerate locally)

- `dist/game.mjs`: `f00aae0622a30ab261066dcc94c408ae08338f2c9f51bbde74fc1dca4309c947`
- `dist/fixtures.mjs`: `bea5d0156f5c94b9565b37e823cbc98b63cccdb6943ce267f81efee06e389177`
