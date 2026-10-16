# Query/resource and owned-event composition

Source checked; awaiting independent whole-output oracle and stock JS/Native
execution. The preceding one-family fixture remains immutable.

`ordinary-owned-event-query` accepts an ordinary query declaration and an owned-event
domain. The authored rank-2 body receives opaque query H with its existing grants,
and opaque publication J with an emit grant. The library threads a private affine
stage through the existing capture-query traversal, outside the ECS undo journal.
Canonical `Cmd.tx_finish` completes before successful FIFO publication or the abort
receipt. No payload required by ECS restoration is also exposed as recovered data.

`ordinary-owned-event-resource.write` derives the canonical user-resource lens and
query metadata; replacing the user resource preserves the separately owned event
log. Its inverse is the existing resource-field inverse, not a caller callback.
The query registration cursor advances only on semantic success. Underlying query
selection, failure output suppression, component stamp restoration and monotonic
World clock follow the existing ordinary query implementation.

The actual two-schema consumer seeds two components plus an absent third entity,
commits one invocation, fails on the second row of the following invocation, then
retries and attempts a genuine foreign-world call. Each entered row writes both
its component and Counter, then stages an owned Array. Full snapshots retain every
component slot and stamp, resource, log payload tree and publication ID, cursor,
registration, live state and World metadata. Returned abort payloads are completely
rendered before caller release. Pending work is empty throughout and observed by
count; this trace does not claim to execute a deferred command.

This remains the one-family composition bridge. Name-only domain metadata does not
establish isolation between multiple families: canonical family path/routing
bindings and their ordinary adapters are the remaining #53 integration. No whole
#53 completion, new ownership policy, universal proof or new timing result is claimed.
