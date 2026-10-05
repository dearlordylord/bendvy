# Proposed assertions (unapproved)

These are finite executable prototype assertions, not approved ECS laws or proofs.

- Repeated successful Ledger writes read immediately as their latest value, while rollback restores the transaction's first original Ledger value.
- Interleaving Ledger writes with Main writes preserves every full untouched payload field and Main rollback result.
- Absent Ledger writes retain absence and do not set first-write state.
- Success retains the original Main marks and command/ping publication; failure restores owners and discards all pending marks/commands/pings.
- One first-write state bit changes only private journal representation, not public callback capability or component ownership.

The last statement remains a design intent requiring connected access/ownership and full transaction gates before production adoption. No universal proof is written.
