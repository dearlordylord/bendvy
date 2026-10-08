# Installed loader inventory candidate

Research only, **not a closed or admitted collector inventory**. No backend,
compiler build, performance test, or failed collector retry was executed.

Local raw metadata and command receipts are retained in
`/tmp/bendvy-loader-inventory-metadata/`. Every diagnostic used the central
`task_runner`, CPU5, cap5, raw split streams, and an explicit sanitized environment.
The initial readelf observations, loader `--list`, loader `--help`, package version,
and Clang `-###` diagnostics all exited0 without supervision failure. The latter
printed commands only; its output executable was not created. These diagnostics
are source research, not complete installed-tool qualification.

| Retained artifact | SHA256 |
| --- | --- |
| `receipts.json` | `57cdec1c77ab7fc20747084f0a5ec5c7c810e06877633e641267a27bd6caf78a` |
| `transitive.json` | `4465b8d2ba6755ce1f62f7727ee0665e8df7994578118b89219752e4f87c0eae` |
| `loader.json` | `1138a1f1ed901638f78bf8e3dd3d084c7ccdfd142bea08d110736a150303a0ec` |
| `clang-driver.json` | `e0679f10d52d485e660941e22bd072d263e9b1f3f22f7a23302bf1162427e6ae` |
| `candidate.json` | `a7a160b85b21389d38529c3cb3587005d9a732f3b835fb8e71979e8665a04a67` |

## Candidate search scope

Installed libc package reports `2.36-9+deb12u13`. Loader help reports default roots
`/lib/aarch64-linux-gnu`, `/usr/lib/aarch64-linux-gnu`, `/lib`, `/usr/lib`; no
built-in glibc-hwcaps subdirectories; legacy `aarch64`, `tls`, `atomics` searched.
The existing config files additionally name `/usr/local/lib/aarch64-linux-gnu`
(currently absent) and `/usr/local/lib`. `/etc/ld.so.preload` is absent;
`/etc/ld.so.cache` exists. Declare the config include directory's exact membership
and bytes, cache, preload absence, interpreter and all relevant link chains.

The [glibc2.36 capability construction](https://raw.githubusercontent.com/bminor/glibc/glibc-2.36/elf/dl-hwcaps.c)
constructs a power set, with selected capability names followed by platform and
TLS, emitted in reverse component order. The [AArch64 default mask](https://raw.githubusercontent.com/bminor/glibc/glibc-2.36/sysdeps/unix/sysv/linux/aarch64/dl-procinfo.h)
selects atomics, and [the tunable default](https://raw.githubusercontent.com/bminor/glibc/glibc-2.36/elf/dl-tunables.list)
uses that mask. Combined with observed platform `aarch64`, the candidate suffixes
are `tls/aarch64/atomics`, `tls/aarch64`, `tls/atomics`, `tls`,
`aarch64/atomics`, `aarch64`, `atomics`, and empty. This inference is conditional
on admitted absent mask/tunable overrides and unchanged loader/platform; upstream
source is not an independently reconstructed Debian-patched build.

Add the approved private LD_LIBRARY_PATH roots:

- `/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu`
- `/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/lib`
- `/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu`

Reached Clang, libLLVM19 and libclang-cpp19 have RUNPATH `$ORIGIN/../lib`; other
reached objects have none. Conservatively add
`/tmp/bendvy-clang19-diagnostic/root/usr/lib/lib` (currently absent), retaining
literal loaded aliases and their actual origin joins. Apply the eight suffixes
to each of these ten roots:80 declared paths,8 currently existing directories.
The candidate JSON lists47 explicit resolver inputs,33 reached ELF objects,
no slash-containing DT_NEEDED, and no broken immediate links observed.
All immediate filenames count. Two external immediate file targets are explicit:
LLVM14 `libclang-cpp.so.14` and `/usr/bin/aarch64-linux-gnu-cpp-12`.
No parent namespace is trusted; nested directory aliases remain metadata-only.
Full candidate-byte hashing and admitted-helper chain validation were not run.

## Tool and environment boundaries still to admit

Node `/24/bin/node` resolves to `/24.20.0/bin/node`; retain both paths and the
alias chain. The private Clang wrapper uses `/bin/sh`→`/usr/bin/dash` and
`/usr/bin/env`, sets its explicit private library path, and selects resource-dir19
plus `--gcc-toolchain=/usr`. The driver diagnostic selects `/usr/bin/ld`→
`aarch64-linux-gnu-ld.bfd`, GCC12 CRT objects, compiler headers and linker search
roots. Native delivery must retain actual header, linker-script and search-file
closure alongside the existing compiler resource guards. ELF loader pins alone
cannot guard those build inputs. Generated C and executable metadata were not
available in this new cohort; their eventual source/runtime closure remains due.

The unadmitted #63 draft inherits `dict(os.environ)` before replacing its private
Clang fields; no full actual cohort environment has been frozen. A values-free
presence/digest audit found inherited `NODE_OPTIONS`, whose only observed flag
name is `--max-old-space-size`; audited LD_* and GLIBC_TUNABLES names were absent.
Do not dump inherited values or infer universal absence from this sample. Freeze
an explicit complete execution environment, or separately admit inherited
contents and affected inputs, before calling the candidate closed.

Next admission needs exact environment binding, cache/config membership and
bytes, complete immediate symlink chains/file bytes, installed loader/source and
platform joins, and the ordinary Native compiler inputs above. Keep initial and
terminal discovery and all semantic/backend receipts. This note authorizes no
collector use and introduces no gate waiver.

## Concrete configuration preparation

[installed-config.py](../../experiments/public-simulation/delivery-v1/installed-config.py)
now supplies a complete explicit environment for every future cohort role, the
three existing approved resource roots, eight ELF discovery tools, and25 literal
bindings (24 resolved files). It selects actual Node24.20.0, preserves the24 alias
join, and retains the wrapper, shell, env helper, linker, CRT, libgcc and libc
script/archive inputs. Ordinary full snapshot/verify remains selected; wrapper
and ldd scripts are input pins rather than invalid ELF discovery subjects.

The same environment mapping reaches compilers, runtimes and discovery. It uses
the approved private Clang settings, fixed HOME/PATH, C locale, UTC and telemetry
off, with no inherited Node options, loader overrides or compiler include flags.
This is a future semantic cohort configuration, not a performance-baseline change.

Local prepared candidate `/tmp/bendvy-loader-inventory-metadata/installed-config-candidate.json`
has mode0600 and SHA256
`1e975ccce5edc8ed9fb2304529076279ee16d07c5c8f4af024824be6a84fad70`;
environment digest is
`f32a7cf7ee3ec5cbcb2d0c546c3bf86649ac29bf3b85f543d88cb83fd0afe14e`.
Preparation resolved every named file, joined the Node alias, checked discovery
subjects and retained exactly the three existing resource roots. Injected
inherited NODE_OPTIONS/LD_PRELOAD/CPATH sentinels did not affect its environment.
No child tools or recursive resource scans were executed during preparation.

Use existing `task_runner.Inputs(files=candidate['inputFiles'])` and the existing
recursive `owned-tool-pins` resource guards, then bind the actual source/oracle,
helper bytes, complete raw observations and all launch/terminal checks in the
runner. Those guards were prepared as scopes, not executed or admitted here.
The module records observed header/link search paths and unresolved compiler
selection explicitly: generated C consumed headers, search membership/absence,
GCC version selection, default linker script and generated executable closure
still need review. This candidate therefore cannot authorize Native execution
or substitute a closed PinnedTools inventory.
