Independent full source-only oracle for producer `f7e221791`, with helper prerequisite `931cb3b86`, in recovery52-owned-operations. Frozen main SHA256 is `d0c3a20afe322fbda24baf138c37a1dc301142a7432d93798580fd8979819991`; SOURCE-FREEZE SHA256 is `a775efca3f5b9be9bb1954fd117b2b77a4887fe6566501fb2f40f66da2b58129`. oracle.py checks all37 actual Bend bodies, both namespace sidecars, that inventory, Base and both print effects (43 direct pins). Imports of the first resource fixture/observer supply helpers only; its main/scenario are not executed by this entry.

The model was written independently from the component/capture operations and final reached scenario before backend output existed. It uses nested tuples to track entire Type owners, optional component values with distinct lifecycle stamps, a separate mutable World clock, registry success cursor and opt-in captured owner. There is no runtime/generated artifact input. Run `python3 oracle.py` to verify full raw/gzip reproduction and substantive state/recovery invariants; --write regenerates both output encodings.

Each nominal schema creates two genuine Worlds via WI.create and allocates/activates two actual handles in each. First cells receive10..13 and900..903, with stamps1:1 and clocks1. Second cells are live but component-absent. Both registrations have real ID1 and derived Payload access; namespace differs. Captures begin1000..1003 and9000..9003. Full observer output retains every cell0..3, actual complete liveness tree, allocator/high-water/capacity/depth, resourceUnit, events, pending count, registrations/nextSystemId/clock, both registry cursors and full captures. No authored payload is hidden in an unobserved slot.

Actual callback operations are: replace selected component with first; replace capture with captureFirst; exchange its element1; replace selected component with second; replace capture with captureSecond; refuse replacement on the actual foreign handle. That refusal returns the original Some(rejected) owner with MissingEntity and changes neither World nor clock. Completed outputs retain it completely, even when the selected transaction later fails.

Accepted component replacements each increment World.clock and preserve prior added tick when already present. Failure applies canonical inverses newest first, restoring the exact old optional payload and stamp while keeping World.clock monotonic. Each returned component record contains its actual handle and displaced payload's pre-undo stamp. Recovery sinks prepend records, so component and capture rows each return in their original operation order. Captures participate in this explicit opt-in journal: failed calls restore the old capture and return every replacement, unlike the default persistent capture semantics qualified by #50.

Reached sequence and independent checkpoints are:

| Completed action | World clock | Registry cursor | Component1 | Capture |
| --- | --- | --- | --- | --- |
| registration |1|0|10..13 @1:1|1000..1003|
| commit100 |3|3|120..123 @1:3|160..163|
| failed200 |5|3|120..123 @1:3|160..163|
| retry-failed300 |7|3|120..123 @1:3|160..163|
| retry-success400 |9|9|420..423 @1:9|460..463|
| absent-failed600 |11|9|420..423 @1:9|460..463|

Absent-failed targets actual live handle2: two temporary writes have stamps10:10 and10:11; rollback restores None with stamp0:0. Returned recovery records retain both full temporary values and those stamps. All successful original owners and failed replacement owners are serialized. Finally the primary registry is actually run against the foreign World: namespace validation refuses before callback and returns all seed500 arguments intact. Both Worlds, captures and metadata remain unchanged. Foreign World clock1 and cursor0 remain constant through the full scenario.

Workshop uses real namespaces1/2; Garden uses3/4, sequenced by IO.bind. Complete output is13009 bytes SHA256 `ab564a5aa035405d06c9bc8c55ebb6bb6159ec3291b079a32d8aa9b884d29c56`. Full tree node parentheses, Maybe markers, recovery order, list terminators, all argument owners, exact errors and labels follow the frozen observer. The trace already endsLF; Base.IO.print appends anotherLF, so raw output ends with a blank line. No clock normalization, checksum-only state comparison or dropped field is used.

This establishes a finite ordinary component-plus-opt-in-capture slice only after actual execution. It is not full #52 closure, irreversible-operation rejection, external IO recovery, arbitrary caller inverse support, physical finalizer behavior or a universal proof. Pure scenario sourcecheck passes; main has only the six documented foreign-dependent IO definitions and is not mathematically safe merely from that check. TS shared functional replacement references remain separate from affine owner-return qualification.
