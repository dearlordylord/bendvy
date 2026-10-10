# Repaired core seeded/provisioning source binding

The preceding private/core packets and first actual failure stay unchanged.
The new source uses explicit `Col.ensure(column,id)` before the fixture's swap.
For ID two, ensure grows the original single owner leaf to two leaves; swap's
size validation now accepts ID two. Both actual Unit cells exist. Ensure/swap
do not add lifecycle stamps or advance clock. Three core module bytes stay
unchanged.

`SOURCE-BASIS.json` binds exact repaired `SUCCESSOR-SOURCE-V2.json`, all 38-file
closures per case and the explicit fixture-repair record. The three original
independent expected byte sequences are retained exactly: seeded A/B five
observations and complete provisioning validation/Before/After observations.
They now describe the source's intended two-cell scenario. They were not
retargeted to the first run's one-cell output.

`ORACLES.json` has separate current subjects and deterministic gzip members.
Historical source receipts do not qualify this successor; producer source02
captures and future actual backend receipts remain separate. No backend or
performance qualification, added ECS policy or #70 closure is claimed here.
