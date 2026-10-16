# Ordinary checked schedules over retained reader families

`ordinary-app-checked-family-schedule` carries an existing ordinary Family App
through the existing checked scheduler. The same World, reader owners, opaque
Family and tick are retained. Its derived fold delegates to the actual reader
owner fold; attach/snapshot/run reuse existing schedule and binding semantics.
Every Finished/Failed/Rejected/Missing result returns its owned App. Invalid
attachment returns the original Family App and actual condition bindings.

The ordinary two-schema WorldIO consumer registers fast/slow typed readers through
Reader.install, with generated selection, metadata fold and recipe. Independent
Check guards give them different histories: false/repeated false, lazy missing
skip, reached required-Threshold refusal, fast-only read, false after activation,
slow catch-up and repeated empty reads. Actual displaced Threshold owners are
restored. A false dispatch still reaches the existing barrier and drains one
preexisting clock command. Gameplay receives Ev.Input or confined Check grants;
only the existing trusted admin dispatcher handles World/runtime transport.

Three complete stock JS/Native pairs PASS with empty stderr:

- Normal: 59,015 bytes, SHA256 `41822144adcdf1d033883d698704d8163a694189297112c1c9e2364913ba3dc8`.
- Reached snapshot-tick mutant: 59,039 bytes, SHA256 `57e3a782d818de65bf3ecde9f96e7d547385bd9bf6a0a0bcb4145052f258187c`; both reject the complete normal oracle.
- Attachment refusals: 32,103 bytes, SHA256 `bcf2b86bd43987aa911b623686e93898137f6c26d7c33238942a4d768bd064bb`; unsupported Plan, missing membership and duplicate bindings each preserve actual returned owners across repeated attempts.

Four new positive and six intended type/affine authority controls pass. Seven
unchanged read-grant controls retain exact source-current applicability. Complete
previous machine/query/resource, relation and all-eight-mode compatibility closures
remain exact and do not import this sole additive module. Unchanged #28 protected23
and combined220 evidence is reused through root’s exact source applicability joins;
this prefix claims no redundant compatibility/regression execution.

Rust reference `ad678262ce53b5d142fe49ee5e08caff6f00ab60`, executor
single_threaded.rs:106–145, skips before actual system/read execution. Bend false
preserves reader state; it does not call Reader.skip/discard. Pinned TS registered
false instead discards unread by advancing streamLastRun. TS-APPLICABILITY.md binds
retained actual evidence; neveractivated false is source-only. No equivalent whole
TS/Bend false-reader result is claimed, and no fresh TS run was required.

The full observer retains physical World/resources, stream fields, actual
Reader/Registry identities/cursors, opaque Family/tick, all affine completion
arrays, plan/binding owners and actual debug snapshots. This finite Family is
Product<Stream,Held>, not FamilyRuntime.State: no journal synchronization or failed
callback/retry claim is made. Run Rejected/Missing are source-equivalent mappings,
not executed new cases. The final unused snapshot tail is unprinted; preceding
returned snapshots are observed at the next checkpoint. Pure checks PASS; IO main
has five expected foreign refusals. All three retained packets and independent
Spec/Standards review PASS; integrated `77beba95a`, CI38914934433 PASS.
This bounded delivery does not close full #61 or add a reader policy.
