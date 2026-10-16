# Retirement-loss source-derived counter oracle

This complete two-schema counter trace models the isolated mutation frozen at
`events53-family-reader-authority` commit `66150ce05`. The mutation changes only
the `False` arm of `src/ecs/owned-event-log.bend:partitioned`: instead of
accumulating the retiring row into the returned receipt, it returns the prior
retired accumulator. The retained log and subsequent stream/journal/world state
are unchanged. The two frame receipt observations therefore become empty; the
shutdown receipt remains real because shutdown uses `drain`, not `partition`.

The counter uses the corrected source-derived family-reader state model from
`oracle-successor-v2` and pins the complete normal and mutant source closures.
It was derived from the operation and observer sources only. No backend was
executed and no runtime output was consulted for this counter. The older
`oracle-successor-v2` baseline remains unchanged.

Run `python3 derive.py --selftest` to validate all source hashes, the exact
single-expression source mutation, state/receipt differential controls, and
raw/gzip golden bytes.
