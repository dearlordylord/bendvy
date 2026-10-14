# Runtime08 retained consumer packet

This packet binds the private three-file runtime-kernel candidate to its staged
83-source closure, the v4 independent full-output oracle, one complete JS
consumer, and the conditional Native consumer. It retains the source-check
boundary, raw streams, guards, generated artifacts, and exact collector plans
and receipts.

`OWNED-PATHS.json` is the exact compact master-import selection: the three
candidate ECS source files, this result summary, and six delivery files. The
portable archive contains the complete runtime plans, source stage, raw logs,
guards, generated JS/C/native artifacts, source-check outputs, and independent
oracle. The historical 142-path producer commit also contains loose copies of
these raw objects; integrators should import only the paths in
`OWNED-PATHS.json`.

From this directory, run `python3 verify.py`. The verifier checks the portable
archive and exact source, plan, receipt, guard, output, telemetry, and
archive-only source joins. It does not rerun a backend.

The copied `src/ecs/owner-handoff.bend` stage source is preserved byte-for-byte
in `PORTABLE.zip`; its source-map row and `DELIVERY.json` map the archive member
to the canonical and staged SHA-256. Its loose copy has trailing blank lines, so
it is excluded from the compact master-import path list. Extract the archived
member when reconstructing the complete staged closure. The source and frozen
plans remain unchanged.

The observation is finite N=1 semantic development evidence. Telemetry covers
API invocation through typed-result handoff only; it does not qualify complete
lazy-result normalization or comparative performance. The separate protected
#28 gate is applicable to these changes because its accepted ordinary-workload
23-source recursive closure reaches none of the three changed modules. That
reuse does not qualify this feature's performance or close #55.
