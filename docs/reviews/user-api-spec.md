# S-USER-API Spec review

**Verdict: bounded #26 implementation conditions met; no unresolved Spec finding.**

Reviewed live GitHub #26, `docs/tickets/24-user-system-api.md`, `docs/SPEC.md`,
the reviewed design, and the baseline-to-final diff from
`7ea583bc8771c5243dca4495c899868a2e7dc6f9` through `54680829`.
Subsequent user implementation authorization resolves the original design-only
wording. This review inspected source and archived receipts; it did not rerun
Bend checks.

The initial review found retry registration omitted granted capabilities.
Commit `4fafd84f` declares its complete bundle, satisfying SPEC's requirement
that system capabilities are “visible in its contract.” Actual spawn-returned
handles now drive later structural operations. Registration metadata remains
trusted provisioning, not universal authority over a concrete root runner.

Ticket condition 5 requires “fresh connected gates on exact source” and a
“reviewed bounded performance regression check”; condition 6 requires a
“fresh blind consumer on the reviewed public package.” Final `suite.json`
archives passing connected controls, provider positives/intended negatives,
current-source blind consumer checker/Native/JS execution, pinned TS checkpoints
and both compiled application backends. I checked all 18 application, 17 timing
and 17 consumer source hashes against current files: no mismatch. Original
consumer impressions and initial authoring history remain archived. The ledger
now identifies the delivered gates and their limits.

The corrected retry processes both selected rows before failure. Actual authored
body counting controls record failure `[2,1,1,1]` and success `[0,1,0,0]` for
component/resource/event/spawn work on Native and JS. Both final backends match
22 complete normative checkpoints and independently satisfy the approved 23rd
foreign-world divergence. The earlier unequal-work timing cohort is explicitly
disqualified. Its replacement retains all 15 whole-process rows under the
reviewed protocol; cold startup/import/serialization dominance is disclosed.

No additional wrong behavior or scope creep identified. Independent affine
families, real Arrays, restricted gameplay grants, rollback/retry and explicit
publication/barrier boundaries satisfy this bounded slice. Query-composition
limits have explicit follow-up #27. Full core, globally unique independent
factory roots, fabricated-root protection, captured affine callbacks, event
retention/lag, production representation, universal refinement and qualified
JS/TS <= 1, Native/TS <= 0.5/full five-by-three acceptance remain open.
