# #47 production-readiness contract and promotion plan

Existing requirements are source-backed: Descriptor.State validates finite literal
values; invalid raw writes return DecodeError(path, expected, actual), preserve the
old component and do not stamp a change. The graph restricts typed transition pairs;
runtime checks current==expected. There is no implicit default. These behaviors
need implementation and replay, not another user choice.

The earlier detail-free RawRejected is insufficient. `set_raw_result` preserves the
caller's exact Error value and returns the supplied Raw independently on refusal.
The finite String/U32 consumer decoders use #46's existing D.Error/D.Raw algebra;
they validate actual input before producing an enum. No duplicate error algebra,
unchecked JS unknown or claimed execution of #46 generic D.Codec is introduced.

Actual unresolved contracts are production module placement/composition with #46,
not whether to discard error detail; exact host serialization of typed diagnostics
and general unknown-input decoding remain #46 obligations. Consumer equality,
endpoints and decoder correctness are trusted declaration boundaries pending
specific law approval. No law or production policy is approved by this plan.

Next replay extends the actual registered application callback to invoke the generic
error-preserving setter. Compare complete state/Array owners, both changed filters,
returned raw values and exact path/expected/actual on success, invalid string and
invalid number. Re-run intended access/raw-kind/schema/owner negatives and a reached
error-omission mutant on JS/Native. Freeze #46's imported error module and our complete
reachable closure after coordination; do not reuse the preceding receipt as coverage.

Once this experiment passes and root coordinates #37 gates, promote reusable generic
operations to `src/ecs/state.bend` under #47 ownership. Keep application enums/graphs
consumer-authored. Adapt the same source-bound fixture to import that public module,
run the unchanged #28 gate, and collect equivalent full TS/JS/Native feature timings
when contention is absent. Parent owns independent reviews and delivery. Do not edit
frozen core or infer production approval from the experiment.

The checked raw-write boundary is also source-backed. Public `Cap.Write.set`
returns only the affine owner, while Compose stores actual write rejection in
`Frame.error`; inferring raw success from that owner alone is incorrect. The
adapter therefore requires a caller-provided `Cap.Request` returning typed local
write status. Original raw input accompanies either decoder or write refusal;
exact caller errors remain separate. Closed provider/transaction controls retain
legal absent-family upserts and foreign refusal. The legacy detail-free Maybe
setter is historical convenience and must not be promoted as the raw API.

Production promotion candidate now exists at src/ecs/state.bend and is used by the
public fixtures. All compare/transition success paths use read + checked Request,
not an attempted Cap.set result. Generic Value/Move/Raw/decoderError/writeError
remain consumer parameters. A clock-exhaustion control and reached movement-status
mutant address successful-read/rejected-write behavior. Independent source-current
review, final replay, root regression and feature measurement remain delivery gates;
none is inferred from the preceding 68-command experiment.
