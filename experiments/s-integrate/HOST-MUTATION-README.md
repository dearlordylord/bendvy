# Joined semantic mutation gate

`python3 experiments/s-integrate/host-mutations.py --optimization O0 --cpu 2`
executes fresh TS plus the complete actual E0–E10 Host on Native/JS and compares
all ten public channels in four lanes. Temporary immutable import snapshots keep
the sweep independent of subsequent concurrent source edits.

The original matches every channel. Twelve compiling mutations are detected on
both backends: query order, suppressed setter, reversed inverse journal, failed
reader advancement, other-reader routing, skip/change cursor, reset capture,
reversed command FIFO, implicit flush, failed publication leakage, failed changed
stamp, and reissued failed reservation. Each records the actual public difference;
the last is rejected by the decoder's reserved-handle reissue check and records
actual q/r observations sharing a handle in all four lanes. Namespace/preflight
and large holder/capacity/registration mutations have their separate actual gates.

Native uses `-O0` for this correctness-only mutation sweep; JS uses normal code
generation. The original Native `-O3` main is separately verified. An initial
checker timeout, a draft mutation's missing Data quantity annotation and an `-O3`
mutant compilation timeout are retained in separate records. None is counted as
semantic detection. Checker/runtime remain five seconds; codegen30/clang120.
No mutation timing or product-performance acceptance is claimed.

`host-mutation-evidence.json` pins source `de73116` by every import hash, the
reference, decoder and runner. It contains all twelve backend witnesses. These
finite tests do not approve new universal laws, allocator reuse, constructor
confinement or general destructive recovery. Independent review remains separate.

The refreshed `host-mutation-source-current-evidence.json` pins the unchanged
actual runtime import closure at `d2f0295`. Both checked schema entrypoints
execute all four lanes, avoiding the combined translation unit's codegen limit.
All ten channels match fresh TS, and all twelve compiling mutations are detected
on Native and JS. The failed-publication witness specifically observes E3 Fast
messages: the expected empty list becomes actual Ping `{code: 9}`.
`host-publication-mutation-evidence.json` retains the earlier focused replay;
older records remain historical evidence rather than being overwritten.
