# Captured execution window

Each admitted system receives its previous execution cursor and its current
execution tick in its owned `State.Scope`. The cursor is `Maybe<Tick>` because
`None` means never executed and tick zero is a valid timestamp.

`Sys.run` takes the previous cursor from the actual system owner before entering
the run. The scheduled parallel path takes it from that owner's `Task.Meta` when
invoking the body. Conditions are system owners too and therefore receive their
own previous cursor. Neither path reads a cursor from another body or condition.
The owner advances to the captured current tick after every normal body return,
including a returned error. Admission refusal leaves its cursor unchanged.

Access adapters and query adapters preserve both values while moving affine
storage. Root partitions duplicate only these reusable timestamps and entity
selection data. Each selected system replaces the temporary partition window
with its own admitted window before executing; it never shares an owned mutable
clock with another task. Query partitions already receive the single captured
write tick for that invocation.

This checkpoint adds the execution window and migrates its transport. It does
not yet expose Added/Changed filters or removal/despawn reader capabilities.
GH85 also requires ordinary two-schema observations, retained-error and refusal
cases, zero/wrap/dormant cases, intended authority controls, JS/native execution,
reached parallel metadata paths, normal checks and independent review. No new
law or universal affine-owner preservation claim is introduced here.

## Query filters

`Query.SerialWhere{Life.Added{}}` and `Query.ParallelWhere{Life.Changed{}}`
select rows by the written family of the closed query pair. Both filters use the
actual system cursor and captured execution tick. The filter runs against the
row's stamp before its callback writes; refused rows keep their payload, cached
view, stamps and output channel. This adds no raw lens, metadata callback or
caller-supplied cursor to gameplay. Read-family and compound filters are not
provided by this entry.

The eligibility check runs in the same physical leaf traversal that owns the
component payload and stamp arrays. The coarse query branch splits both owners
and its affine output channel, then merges them through the existing path.
Existing unfiltered query declarations keep their signatures and behavior.

`examples/parallel-lifecycle/filters.bend` uses the ordinary public QueryApp
entry, two nominal schemas and actual affine Array payloads. Its four cases run
three times with serial/parallel Added/Changed filters, preserve legitimate
zero seed ticks, then refuse an owner against a genuine second World. Its
independent full-state oracle is frozen before backend capture. Backend results,
error/wrap/dormant scenarios and actual worker diagnostics remain pending.
