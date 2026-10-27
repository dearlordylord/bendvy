> Verification policy override (2026-10-27): semantic verification uses Bend laws only. The new non-law models, reference tests, golden outputs and check scripts have been retired at the user's direction. References below to those checks describe historical work, not current acceptance. Historical receipts remain outside the source tree; the five approved Bend helper laws do not prove the whole ECS.

# Compose declaration-bound features

This ordinary App consumer combines two independently authored feature modules.
[Motion](feature-motion.bend) owns affine numeric Position and Counter payloads;
[Labels](feature-labels.bend) owns affine text Label and Host payloads. Their bodies
receive abstract scope capabilities, local owners and actual entity handles.

[Schema](schema.bend) declares the actual physical layout. Position is plain;
Label has a constructed literal validator; Host is transient; the optional
resource owns `Maybe<&1,Array<String>>`. The same layout supplies physical slot
types, nominal keys, canonical reusable Data views and registration requirements.
The complete slot type retains the refresh function and persistence policy.
Changing either cannot satisfy the ordinary grant's physical-type equality.

[Declarations](declarations.bend) acquire closed component/resource grants through
`Build.Program`. Both host invocation and its required-service guards select the
same `Schema.host_route`. Guards also read the optional resource through its
ordinary declaration; an absent optional owner is permitted. An absent required
host produces `missing-service:host`, suppresses its affected body and returns
all actual owners. The handler continues unrelated work. Host callbacks are
owned operations; this example adds no external IO rollback or finalization.

[Application](application.bend) supplies actual system/guard owners and their
closed selections to `execution-composer-app.build`. The entry derives schema,
requirements and registration from these declarations. Nested dependency paths
index the selection tree, independently of resource layout routes. Local edges
are validated before flattening: scope[0] cannot depend on the other feature's
system even when that system exists in the final application.

The application explicitly wires required-service guards and bindings. A
`ResourceWrite` grant permits ownership operations on its slot; it does not
intrinsically require presence or install a guard. Calling the service slot while
Missing returns Unavailable. The selected guard policy supplies the explicit
missing-service diagnostic before either affected labels body runs.

Composed, dependency Application and World record constructors are trusted
administrative boundaries. Ordinary build derives and checks its inputs; run
expects the retained carrier from that construction. Deliberately reconstructing
a carrier, clearing its validation result, or replacing its plan/bindings bypasses
that construction contract. These records have no hostile-constructor secrecy or
integrity guarantee. Gameplay scope/grant authority remains declaration-bound.

`run` returns the same composed owner with a report. `CompositionRejected`
retains the application and provisions before invocation. Otherwise the report
uses the ordinary dependency executor's success/error/refusal observations.
Errors retain performed writes. Reuse the returned owner on the next run.

[Main](main.bend) observes eight finite scenarios: missing required service,
provision and successful execution, repeated execution with errors after actual
host calls, invalid nesting, an absent optional owner, constructed validation,
schema collision and namespace exhaustion. The public closed-route `provide`
operation installs HOST-901. Refusing a second provision returns HOST-902, which
remains in the actual provision receipt. Collision/namespace refusal preserve
actual incoming resource owners and their original cached values.

[Observation](observation.bend) consumes the final application at one seam. It
prints every column slot/stamp, actual payload and cache, allocator, clock,
registration, system/guard local owner and cursor, handler history, actual
provisions, schema, plan and binding. [The oracle](oracle.py) derives those values
from the declared transitions, without reading emitted code or actual output.
See [its contract](ORACLE.md). These finite observations do not establish a
universal correctness or ownership theorem, or native concurrency for this serial
consumer.

`Schema.create` uses library-empty columns and initializes resource views after
successful admission. `trusted_create_seeded` is an explicit setup boundary: its
closed seed receives Unit, creates no gameplay adapter, and must initialize each
occupied row through `Layout.initialize`. It cannot capture runtime affine
inputs. This example validates the constructed initial Label through the same
retained declaration before inserting it. This does not validate arbitrary seeds
or invent a Raw-to-affine-owner inverse.

Normal CI discovers [check.sh](check.sh) through the existing example runner.
The wrapper requires independent launch review before its first execution.
Use the existing qualified compiler/resources and common-runner limits described
in [CHECK_PLAN.md](CHECK_PLAN.md). No performance or GPU campaign is included.
