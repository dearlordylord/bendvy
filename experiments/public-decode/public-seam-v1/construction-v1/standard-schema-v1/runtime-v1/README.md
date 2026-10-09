# Experimental runtime host bridge — #46

Source candidate, not runtime qualification or full Standard Schema parity.
No generated outputs have been used to author its oracle.

`cases.mjs` calls the existing Standard Schema adapter with two actual host
schemas. Their accepted output becomes explicit Raw tokens at runtime;
`main.bend` reads those tokens through `IO.args`, constructs affine input,
and reaches canonical constructor/capability providers. Input String admission
and stored Object admission remain separate. No callback enters a Bend heap.

The 28 ordered cases cover, per schema: spawn, insert, resource replacement,
custom parse/wrong-input/downstream refusals for both component and resource,
system failure, failed insert/resource, skip, and host-only validator refusal.
Component routes use ordinary registered Local and the existing delivery
barrier. Resource routes use the existing typed owned grant and transaction
completion. Resource abort restores the old owner and drops its replacement;
it does not promise returning accepted replacement input.

Every report field is serialized, including World metadata/live/physical
slots/stamps/queue, affine-owner views and Local recovery. Strings use scalar
codepoint arrays and F32 uses bits on the observation wire. The strict full
oracle must detect `$transportIncomplete`; it is not an accepted projection.

`transport-cases.mjs` separately specifies 19 positive Raw cases and six
malformed frames. `transport-main.bend` creates no World. These include every
Raw tag, max bounded Nat, F32 bit edges, Binary64, astral scalar text, explicit
UTF16 units, and nested duplicate fields in original order. They do not count
as ECS feature scenarios.

Budget comes from the actual runtime token count: `16 * count + 64`.
Generated JS `IO.args` is backed by an Array; Native uses C `int` argc. Thus the
reachable budget is at most 68,719,476,784, below pinned Nat's 48-bit maximum.
Pure helpers are not qualified for arbitrary fabricated huge Lists. Scalar
string traversal and argv/environment/stack capacity remain unqualified at
large sizes; no new accepted-size threshold is proposed.

Non-scalar host Text/field names remain an explicit representation gap;
see [UTF16-NAMES.md](UTF16-NAMES.md). The encoder's RangeError is experimental
and does not establish a new host/ECS refusal contract.

Next acceptance: frozen independent complete oracle; admitted existing-runner
JS/Native stages evaluating the Node adapter and forwarding its actual output;
reached validation mutation; full Raw transport controls; independent actual
review. Static conversion or source checks alone do not satisfy these gates.
