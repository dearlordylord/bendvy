# BendHub release 0.1.0.0

Package: `bendvy-ecs-core@0.1.0.0`. Content hash:
`0x296ca5f551e3792cd56cfc8122905b94`. Publication and immutable name resolution are verified on BendHub.

The release freezes the accepted core at `1037bab01`; packaging is pinned at
`0fe0b6921`. Clock #75 and save #76 are accepted with their final source/CI
evidence. Experimental performance work and unrelated workspace edits are excluded.

Supported consumer: matched Bend 2.0.35, Node JS and Native Clang 19.1.7.
Bend 2.0.37 rejects duplicate Ready constructors in the complete library closure;
compatibility with that compiler is not claimed. This release adds no compatibility
shim or alternate ECS contract.

The reproducible export uses:

```sh
python3 scripts/package-bendhub.py 0fe0b6921 /tmp/bendvy-package
```

BendHub rejects hyphens in file paths. Export changes filenames/import paths to
underscores without renaming the source checkout's ECS modules. The exported
closure has 367 files, including both namespace host implementations and a root
LICENSE with SPDX expression `MIT OR Apache-2.0`. Unused source files outside the
entry's import closure are not published.

The isolated local export passes a complete scheduled-health application on
JS and Native (actual WorldIO, registration, six system ticks, explicit deferred
visibility and an excluded entity). Clock-system and pending-save controls also
match their complete JS oracles. The cold Hub cache was populated by the normal Bend importer; all367 downloaded
files match the independently verified published manifest and local tested export.
The actual downloaded package passes the same scheduled-health JS/Native outputs,
clock-system and pending-save full JS controls. Name-based import independently
resolves the exact published hash and passes the scheduled-health output.
These are functional checks, not timing/whole-core performance qualification.

Resource disclosure: initial publication/testing used CPU11 from approximately
2026-10-20 20:13:58 through 20:25:25 UTC. A concurrent performance consumer was
then observed pinned to CPU11; measurements in that interval may be contended
by release work and must not be presented as uncontended. Subsequent release
checks used CPU0, and final publication mining uses CPUs0–3. Earlier timeouts,
cancelled mining attempts and server path rejection remain in the local receipt
directory; they are not credited as successful delivery evidence.

Local receipt directory: `/tmp/bendvy-release-0100-ro1xvk2v`. Credentials are
held only in ignored root `.env`, mode0600; no credential value is included here.

## Verification receipts

| Consumer | Complete bytes | SHA256 |
| --- | ---: | --- |
| registry-consumer-js.stdout | 207 | `0c8a1ecda79e9fa0af225b60b1d63068c7ea2eb20437c8b31f86bcf37af31eee` |
| registry-consumer-native.stdout | 207 | `0c8a1ecda79e9fa0af225b60b1d63068c7ea2eb20437c8b31f86bcf37af31eee` |
| registry-clock-system.stdout | 1009 | `8b8fb87a5ece27ddfc53fd99b8560d9853466f04de6aa0be324a7500db171bab` |
| registry-save-pending.stdout | 500 | `807ddd87e3794201146d71290257ffa36874045a9efa2bb54460fcfad8dbdc8b` |
| named-consumer-js.stdout | 207 | `0c8a1ecda79e9fa0af225b60b1d63068c7ea2eb20437c8b31f86bcf37af31eee` |

Hub manifest SHA256: `296ca5f551e3792cd56cfc8122905b948d31c481dea51b76bbed4fdb9c1c5b3d`.

Packaging CI [39492256499](https://github.com/dearlordylord/bendvy/actions/runs/39492256499)
passed functional and runnable-example jobs. No claim of full-matrix execution
through Hub, universal proof, Jend indexing or performance qualification is made.

```bend
import bendvy-ecs-core@0.1.0.0/world_io.bend as WorldIO
import bendvy-ecs-core@0.1.0.0/ordinary_app_run.bend as AppRun
```
