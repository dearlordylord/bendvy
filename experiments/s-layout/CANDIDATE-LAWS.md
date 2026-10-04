# S-LAYOUT candidate guarantees — unapproved

This is a bounded executable investigation, not approved general laws or proofs.
The first prototype representation was drafted before these statements were
persisted; no historical law-first claim is made. Validation/mutation starts
against the following observable guarantees.

1. A valid logical ID maps bijectively to `limit - 1 - id`, independently of query
   order. Out-of-range IDs return absent and preserve array ownership without an
   array access; an invalid capacity yields an empty limit-zero probe before entity filling.
2. Queries return exactly present IDs and values in ascending logical ID order;
   sparse holes and reversed physical slots cannot reorder observations.
3. Commands remain pending until explicit flush, then execute FIFO. Reservation
   remains monotonic without reuse; numeric exhaustion is unresolved product policy.
   Foreign world handles return MissingEntity even for a colliding local ID.
4. Updates mutate the original owned array and return it. Failure restores each
   old row in inverse order, preserves previous commits and excludes failed
   publications; retry succeeds. Owned Type payload restoration must separately
   return the original owner and cannot use a Data copy of that payload.
5. Two readers keep independent positions; message/change positions are distinct,
   failed reads preserve both, registered skips advance only messages.
6. Public constructors do not authorize replacing an arbitrary callback handle;
   schema, undeclared access, read/write and reconstruction negatives are paired
   with working positive callbacks over the actual indexed provider.

Falsification: compare exact ordered projections with actual pinned bevy-ts and
committed list code; probe bounds, pending/live/flush/foreign, owned failure/retry
and readers; compile mutations of slot mapping, ordering and restoration. No
mutation is credited merely for parse/type failure. These are finite controls,
not universal confinement or runtime refinement, and do not approve thresholds.
