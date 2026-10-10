# Ordinary schema debug integration — private draft

Owning issue: #56; source authority Rust Bevy → Bend → TS inventory.

The public registered-record App already derives component/resource access and
value observations from the same registrations. Its `Registered` stores no
ordinary `Schema`, so schema names/order are absent from automatic snapshots.

This successor retains the actual `ordinary-schema.Schema<S,C,R>` alongside the
actual `World<S,C,R,E>` App. Enabled snapshots derive schema entries from that
same declaration; disabled snapshots neither derive entries nor invoke the
public metadata/observation folds. The physical C/R type association is retained.
No independent debug schema, classification, runtime type descriptor, or user
metadata callback is accepted.

The complete ordinary setup supplies one `Setup.Declarations` term to both
`Schema.product` and canonical operational component/resource field bindings.
Physical owners are `Owner<Column<Array<U32>>,Unit>` and
`Owner<Unit,Array<U32>>`; no bare-column/whole-resource substitution occurs.
Library setup derives product paths; the application supplies no debug lenses.

Complete source04 passed the stock five-second check (original 32773).
`SOURCE-COMPLETE.json` binds the exact entry and closure. Earlier parser/type/
quantity failures and successful predecessor checks remain in the lossless
source-history archive. Source acceptance is not runtime acceptance.

The zero/two-entity consumer runs one actual component registration and three
actual selected-field resource invocations (success, failure, retry), using
`Sys.run_tracked` through existing transport. It includes seven snapshots and
complete World, successful physical Type output and actual owner Fields.
Failure has the existing `Sys.Failed{world,error}` shape; no failed output is
invented. Pending event callback 99 remains unflushed. A test-side owner observer
runs after every action, including Disabled; production Disabled skips both
metadata and World observation. No schedule-dispatch acceptance is inferred.
Independent whole-model and first JS/Native pair remain pending.

Other #56 gaps remain: generic operational schedule/Plan integration;
relation/machine registration descriptions (#55); persistence classification
association; complete naming/lint/access-index/population formats; wider arity
and scaling qualification. `Fields` currently distinguishes only component and
resource registrations. Those gaps are not evidence of Bend impossibility.
