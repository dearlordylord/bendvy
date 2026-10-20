# BendHub release 0.1.0.1

Package: `bendvy-ecs-core@0.1.0.1`. Content hash:
`0xf435da9e535b3846d643dad16580e35f`.

Source/export commit: `e5cb1e431`. Supported compiler: Bend 2.0.37;
JS uses Node, Native qualification uses Clang 19.1.7.
License remains `MIT OR Apache-2.0`.

## Compatibility change

Bend 2.0.37 adds Base constructors `Ready`, `Exit` and `Wait`. Rename
Bendvy's conflicting `Ready`/`Exit` variants to `BendvyReady`/`BendvyExit`,
including current callers and the captured-query example. Update the Native
namespace adapter to the two-argument `io_eff` registration API. ECS algorithms,
affine ownership, approved laws and runtime contracts are unchanged. No legacy
aliases or compatibility shim are supplied; Native Bend 2.0.35 is no longer
supported by this release. Examples default to `bend` on PATH; CI pins the
2.0.37 Linux x64 archive with SHA256
`84c32465a39bc9ac315eade23f470cb8db03153dc860f89564fcfec153c3e445`.

## Checks

- `examples/check.sh` with `BENDVY_EXAMPLE_NATIVE=1`: all runnable examples
  pass their existing full checks on JS and Native, including captured-query
  rollback and retained affine capture.
- Existing public-change-tick, public-clock-events, public-clock-system and
  public-save-pending controls: full JS output matches their unchanged oracles.
- External consumer imports the complete package entry and exercises actual IO
  world creation, registered scheduling, six ticks, deferred visibility and an
  excluded entity. JS and Native full outputs match the independent original
  oracle (only the version line changes).

Functional checks use CPU0; publication mining uses CPUs1–3. No benchmark or
performance qualification is claimed. Existing frozen performance campaigns and
unrelated workspace changes are excluded; their source-bound plans are not
silently migrated to this compiler.

Export again with:

```sh
python3 scripts/package-bendhub.py e5cb1e431 /tmp/bendvy-package-0101
```

Local receipts: `/tmp/bendvy-release-0101`. Credentials stay in ignored `.env`;
no credential is included in the package or receipts.

CI [39506332627](https://github.com/dearlordylord/bendvy/actions/runs/39506332627)
passes functional and runnable-example jobs on the migration commit.

## Published package verification

The normal Bend importer populated an empty isolated cache from the content
hash. All 367 downloaded files match the tested export and the independently
hashed Hub manifest, including LICENSE and both namespace host adapters. The
actual Hub package passes the complete scheduled-health consumer on JS and
Native; clock-system and pending-save pass their unchanged full JS oracles.
The named version resolves to this exact hash and its ordinary import passes
the same complete 207-byte JS consumer output.

Manifest SHA256:
`f435da9e535b3846d643dad16580e35fb9ae485317226d9d0325ad1dcaa1fdb0`.

| Output | Bytes | SHA256 |
| --- | ---: | --- |
| registry-js.stdout | 207 | `41c1b77a509172db154d0a16ae472c94d04892aa6a134d50caf3f97b5ffede49` |
| registry-native.stdout | 207 | `41c1b77a509172db154d0a16ae472c94d04892aa6a134d50caf3f97b5ffede49` |
| registry-clock-system.stdout | 1009 | `8b8fb87a5ece27ddfc53fd99b8560d9853466f04de6aa0be324a7500db171bab` |
| registry-save-pending.stdout | 500 | `807ddd87e3794201146d71290257ffa36874045a9efa2bb54460fcfad8dbdc8b` |

```bend
import bendvy-ecs-core@0.1.0.1/world_io.bend as WorldIO
import bendvy-ecs-core@0.1.0.1/ordinary_app_run.bend as AppRun
```
