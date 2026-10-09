Matched whole-consumer JS profiles — preparation only

Four separate five-second diagnostics reuse the qualified JS artifacts: old
leaf-lift before21672 and chunked output after20603. No emitter or source wrapper
runs. Both preserve the identical complete5,077,477-byte independent oracle and
empty runtime stderr. Node24.20, CPU5, environment and profiler settings match.
The full46-source inventory and original successful artifact/receipt/guard joins
are bound for each subject.

CPU sampling uses100µs; heap sampling uses8192bytes, following the existing #63
profile recipe. Both are whole-process diagnostics including startup, JIT,
application, serialization, printing and profiler overhead. Contention prevents
timing/speedup claims; diagnostic settings are not acceptance thresholds.

The heap CLI supplies only samplingInterval in
[Node24.20 inspector_profiler.cc](https://github.com/nodejs/node/blob/v24.20.0/src/inspector_profiler.cc#L400).
[Pinned V8 sampling defaults](https://github.com/nodejs/node/blob/v24.20.0/deps/v8/src/inspector/v8-heap-profiler-agent-impl.cc#L499)
exclude objects collected by major/minor GC. Accordingly this is sampled retained
allocation attribution at profile end, not total allocation traffic, transient
garbage, heap high-water or physical RSS. Complete raw heap profiles remain.

Separate Linux ru_maxrss is labeled the peak of the reaped subprocess subtree,
including shared runner owner and Node, in KiB. It is not Node-only, live heap or
timed-region RSS; no additional wrapper/tool/dependency is installed. Before/after
CPU/system/wall accounting is retained without interpreting it as a benchmark.

The existing guarded collector is adapted narrowly. Profile output must begin
absent; any regular partial/full profile is captured in finally before interpreting
child failure, with post/final pin guards. Deadline, missing profile, nonempty
stderr, malformed profile or any whole-output mismatch stays INCOMPLETE; no hidden
runtime extension/retry follows. Portable controls use the real full oracle and
mock executors only, including last-byte corruption, timeout partial captures,
existing/symlink refusal and Bool-versus-integer profile identities.

No profiler child is permitted before exact-plan admission and queue release.
