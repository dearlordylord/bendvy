# Existing GCC feasibility: incompatible emitted host musttail syntax

The exact generated C `/tmp/bendvy-live-first-native-static/batch.c` was compiled unchanged using installed `/usr/bin/gcc` (Debian 12.2.0-14+deb12u1), CPU9, compiler cap120:

```
/usr/bin/gcc -O3 /tmp/bendvy-live-first-native-static/batch.c -o /tmp/bendvy-native-gcc-o3/batch-native -lm -pthread
```

Compilation exited 1 and produced no binary. GCC rejects the statement form `__attribute__((musttail)) return ...`: first at `WL_JMP` line123, likewise `WL_DYN` line124 and the host `WL_AGAIN` definition line33701. The source guards preserve_none/preserve_most attributes with `__has_attribute`, but unconditionally emits the musttail statement form for host control flow. This is a compatibility failure, not a compiler timeout or runtime correctness failure.

No source/C/compiler/kernel/reference edit, attribute removal/emulation, DEVICE-path override, new dependency or toolchain installation was attempted. `-mcpu`/architecture tuning cannot resolve this parser incompatibility. Existing GCC PGO requires a compilable instrumented program, so profile generation/training/recompile, fresh-TS full65 equality and adjacent Clang/GCC comparison are **unexecuted**, with no performance or correctness pass inferred. A compatible toolchain would be a separate approval/probe; this task stops at the observed failure.

Reproduce with `python3 experiments/s-prep/native-compiler-profile/build.py --c INPUT_C --output FRESH_BUILD`. The recipe uses existing GCC and the unchanged C, captures its version and diagnostics, hashes input before/after, and keeps the 120-second cap. Optional profile flags are present but were never exercised and confer no PGO feasibility result. It uses the root-owned supervisor and changes no shared runner.

Evidence freezes the exact C, complete original build receipt and compiler diagnostics as deterministic gzip archives, plus a small summary and uncompressed hashes. Source SHA256 is `b4b12ec1b61887b909e870454616cd46f542145f7dc43319a11b74d5e0e543b3`. This is bounded feasibility inside the user-authorized diagnostic window, not a canonical cap reset, cohort, keep, adoption or qualification.
