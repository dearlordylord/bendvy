# Independent AppA captured-condition oracle

Derived from frozen source 51071d490 before any backend output was consulted. Run `python3 model.py --selftest` for arithmetic/framing checks or `python3 model.py` to reproduce the complete stdout. Gzip uses mtime zero.

The actual entry first reserves and queues the bundle, then explicitly drains activation and recipe delivery. Array insertion advances the clock to 1; scalar insertion advances it to 2. One retained opaque inverse is counted and never executed. Three ordinary registrations are newest-first IDs 3/2/1. The field system resets Counter to the actual two-leaf Array [21,22] before each capture run, without changing the World clock. Its tracked cursor records the clock at that point: 2,3,3.

The component capture reads scalar 11 then 15 on its two entered runs, writes 15 then 19 and advances clock/query cursor to 3 then 4. Query capture calls 0→1→1→2 and values [30,40]→[41,51]→unchanged→[56,66]. The middle false condition preserves all query owners/cursor while the unbound resource capture still runs. The resource capture adds 1+21+22=44 to both retained leaves on every run, ending [232,332]. The actual bound target, constant owner/facts, nested plan, full owner identities/access/args/enabled flags, field cursor and all schedule observations are rendered.

Six Inspector reads use cursor zero, preserve every threaded owner, and report the real array/scalar added/changed flags and Counter values. Each full World snapshot includes live tree, all authored column payload/stamp data, resources, receipt lists/counts, events, pending callback count, registration metadata, allocator state and clock. Array tree shapes remain distinct from Inspector list projections. Opaque callbacks are retained and counted; this finite observer does not inspect their code. This workload has no provision requirements and does not establish numeric resource/service admission coverage.

The report contains sixteen complete rows ending in LF; actual Base IO.print adds one more LF on both stock backends. Source bindings retain the 93 consuming modules separately from Base/effect pins. No runtime or compiler output is an oracle input.
