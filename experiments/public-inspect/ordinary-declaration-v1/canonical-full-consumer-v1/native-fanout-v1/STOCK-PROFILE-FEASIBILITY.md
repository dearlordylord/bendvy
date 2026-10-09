# Stock compiler V8 profiling feasibility

Source-only inspection. No profiler, compiler emission, backend or new experiment ran. The requested Node24 V8 tick-log route is blocked for actual stock Bend2.0.35.

`stock-native01/plan.json` invokes taskset CPU5 → `/home/node/.bend/bin/bend-2.0.35` → complete47 entry → `-o scenario.c` directly. Node is a separate consumer tool. `development-v2.py:201` passes the plan argv/environment directly to the bounded runner; `experiments/public-simulation/delivery-v1/installed-config.py:11–12` selects distinct Bend and Node tools. No Node wrapper is selected for emit.

Read-only `file` identifies the selected compiler as ARM aarch64 ELF, dynamically linked, not a script. Its pinned SHA256 is f77417474ded314ad5d1a68fa3ebbe214c2124bf04d56a59b05bc17be6b0327a. Read-only `strings` exposes Bun.main, bun build v, and vendor/WebKit/Source/JavaScriptCore runtime/JSArray.cpp, JSObject.cpp, DFG and FTL paths. These are direct evidence of a packaged Bun/JavaScriptCore runtime in the actual executable bytes.

Pinned reference `.references/bend2/bend2/main.ts:1` uses a Bun shebang. `main.ts:358–365` dispatches .c output to fs.writeFileSync(out, Comp.compile_book(book)) in-process, without a Node child. Other child launches serve different commands/builds. This corroborates the binary finding; it does not establish exact packed/reference source identity.

Plain, non-profiled introspection of pinned Node24.20 returned version v24.20.0, profAllowed=false, logfileAllowed=false using process.allowedNodeEnvironmentFlags.has('--prof') and has('--logfile'). Thus NODE_OPTIONS cannot carry these V8 flags even for Node24. Direct node --prof could profile a Node program, but cannot interpret the ELF as JavaScript. A Node wrapper spawning Bend would sample the waiting wrapper, not compiler JavaScriptCore execution. It cannot establish actual compiler phase or allocation/GC direction.

Existing experiments/s-prep/js-profile/README.md and full-consumer chunked-output-v1/js-profile-v1/README.md cover generated JS consumers under V8. Their CPU/heap/GC recipes do not profile this compiler engine. The latter also limits heap sampling to retained allocations, excluding transient collected objects. s-prep/native-phase-profile/README.md covers generated native computation, another process and phase.

No executable V8 profiling batch is proposed. Do not replay emit30 merely to obtain an absent V8 log. Preserve complete47 subject, whole5077477-byte oracle, CPU5, emit30, identities and retained failures. A next diagnostic proposal needs source-backed support for the packaged Bun/JavaScriptCore profiler with deadline-surviving artifacts, or an existing OS process-PC sampler with symbols resolving compiler JS phases. Neither is established here; native PC samples alone do not establish allocation counts or JS call phases. This is a tooling applicability blocker, not attribution of the no-C deadline to GC or a compiler phase.

Parent-directed complete normal+mutant JS remains ahead of any admitted compiler diagnostic. No cap increase, compiler/source patch, dependency installation or backend retry is proposed. Reviewer-owned review.md content remains untouched; the parent authorized preserving it with this note.

## Packaged-runtime leads, not launch admission

Read-only strings of the exact selected ELF expose BUN_OPTIONS; a diagnostic requiring JSC environment variables to use the BUN_JSC_ prefix; JSC_useSamplingProfiler, JSC_samplingProfilerPath, and samplingProfilerStackTraces. Bun help strings expose --cpu-prof, --cpu-prof-dir/name/interval and --heap-prof, with descriptions explicitly saying write profile on exit. This makes actual JSC profiling a concrete source-research lead. It does not demonstrate that this standalone executable accepts runtime flags without changing compiler argv, honors BUN_OPTIONS, or flushes a useful profile before the existing runner kills the process group at deadline. No flag/env trial was run. A bounded launch proposal needs these gaps resolved from actual packaged support or primary runtime source first. Parent is researching official support in parallel.

Read-only availability check found no perf on PATH; /proc/sys/kernel/perf_event_paranoid is 2 and kptr_restrict is 0. These settings do not positively establish perf-event access for this container. No perf syscall, sampler or install was attempted. Existing process-PC diagnostics are a possible fallback research lead, with JS phase attribution still unproven.
