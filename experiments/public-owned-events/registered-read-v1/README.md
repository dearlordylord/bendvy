# Registered owned-reader candidate (#53)

Experimental integration, not a public API or issue completion.

The canonical `src/ecs/event-runtime.bend` owns Data row keys and supplies registration, lazy activation, run, skip, cursor, lag, window and whole-batch capacity behavior. Its World resource owns one `Log<Payload:Type>`; payload owners are never copied into the runtime's Data batches. Publication rejects reused keys and returns the incoming owner. Reading rejects missing or duplicate matching rows while retaining the complete log.

`Log.read` uses the existing opaque scoped-read capability, threads the same payload owner back, and permits a fixed `Observation:Type`. The fixture chooses full Data observations; `direct-controls.bend` also returns an independently owned Array observation. This is sequential owner threading, not simultaneous Rust references or a mandatory snapshot API.

After canonical frame retention, reconciliation returns removed FIFO rows in a typed retirement receipt. No finalizer, disposal, automatic reinsertion or public retention policy is selected. The private seen-key ledger prevents key reuse within this fixture's single runtime/log namespace. Raw trusted World construction and schema-owned lenses remain experimental boundaries; this does not establish a public constructor or module secrecy.

`main.bend` consumes complete fast/slow/failure/retry/skip/window/capacity/foreign-reader traces. Snapshots include the full payload cells and sentinels, returned retirement/refusal owners, key ledger, runtime batches/positions/statuses/cursors, registrations and world event keys. Direct controls cover missing keys, malformed duplicate rows, duplicate publication and owned output. The two fixture capacities are inputs, not performance thresholds.

Retained source checks in `evidence/` use the existing five-second source cap and shared child lock. Earlier parser/shadowing failures remain unchanged; `main-source-2` passes. No new semantic law or proof is declared. The ordinary source-check response is not a mathematical validity verdict.

No backend has run. An independent whole-observation oracle must be frozen before execution. Public World reader integration, authority/error negatives, reached mutations, agreed retirement ownership policy, backend qualification and applicable regression checks remain #53 gates. No arbitrary transactional component/resource extraction is introduced.
