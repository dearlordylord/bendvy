# #46 public capability seam prototype

Base: master `5294bac7`. Ownership: this directory only. No src/ecs change,
new contract, cleanup policy, law, dependency or backend collector.

## Concrete path

`application.bend` copies the existing trusted kernel unchanged except its three
request branches now call `Public.provide`. That function goes through
`Public.invoke` → existing `Cap.invoke_owned` → universally quantified gameplay
body → `OwnedRequest` → `retained_request` → actual `Gate.request` → retained
`Decl.Constructed.validate` and the original trusted admission callback. Runtime
codec metadata travels with the affine context; it is not re-described by the
caller. `Input<S,P>` and `Output<S,P,O>` fix the nominal schema before opaque H.
P, O, application arguments and outputs remain arbitrary Type.

`invoke` also accepts an application-authored universal body with arbitrary Type
arguments/output. Gameplay cannot inspect H as World, synthesize a missing
operation or turn a read grant into this owned mutation grant. Trusted schema
provisioning still chooses the concrete admission functions and is not a sandbox.

`main.bend` preserves the original full 32-operation/two-schema and genuine
foreign-world consumer; only import routing changes. Full source-only checking
passes. A small ordinary resource consumer reaches the new route and interpreted
successfully in development, returning canonical Number7, the stored sentinel
[111,222] and previous Number9/sentinel[333]. This is scoped interpreter evidence,
not JS/Native qualification or a full-output oracle.

## Source-backed gap map

| Contract / source | Current implementation / evidence | Remaining public gap / owner |
| --- | --- | --- |
| Rust Bevy SystemParam `init_access`, Commands deferred application (`crates/bevy_ecs/src/system/system_param.rs:262`; commands/mod.rs:106,1428) | ECS authority comes from actual operations; source candidate supplies owned request only behind opaque H. | Ordinary declaration builder must derive the capability pack and registration access from the same descriptors, rather than independently supplied strings. #46 with #34/#37 assembly. |
| Bend affine Type ownership; capabilities.bend `OwnedRequest`, `invoke_owned` | Incoming owner and all refusal/output owners move once; exact Gate result is rejoined without normalization. Four intended source negatives below pass. | No universal preservation/cleanup proof is implied by affineness; exact complete before/after/queue observations and reached mutation still required. #46. |
| Ordinary `canonical-system.bend` `define/invoke` | Existing ordinary system builder supplies Inspector resource reads, with Params/entries/needs retained for scheduling. | Its body/result types and grants do not provide arbitrary Type input/refusal owners or mutable/deferred decoder requests. Extend this actual ordinary declaration seam; merely wrapping `Sys.register` rawWorld runner is insufficient. #46. |
| `src/ecs/system.bend` `register/run` | Namespace/registration check is real, but rawWorld runner and access names are trusted kernel inputs. | Registration wrapper must close trusted physical context and expose only derived Ops to user body. This prototype has no public-registration bridge yet. #46. |
| `src/ecs/bundle-requests.bend` `request`, `bundle-batch.bend` | Existing declared owned route supports validation/construction before deferred insert/spawn, preserving refusal payload through reversible typed packet. | Join retained decoder descriptor with that construction route and actual Batch owner; keep queue/refusal/rollback semantics and avoid inventing generic Raw→Type inverse. Current prototype's original Spawn is immediate. #41/#46. |
| Resource mutation and ordinary declared access | Prototype routes actual resource replacement through validation behind H. | Public resource operation must be supplied only by declared write capability, with declaration-derived schedule/debug metadata. Current trusted provider may choose any callback. #46/#56. |
| TS Descriptor constructor/decoder selection (`packages/core/src/Descriptor.ts:536`) | Existing full selector/JS/Native and Node evidence remains under adoption-v1/qualification-v1; this prototype does not replace those packets. | Rebind the existing complete 32+12-extension consuming spine to this public assembly and execute reached validator/partial-write controls at that exact callsite. No duplicate historical backend run requested. #46. |

Reference order: Rust Bevy ECS architecture first; Bend affine/runtime constraints
second; TS feature inventory third. Pins: Rust ad678262ce53b5d142fe49ee5e08caff6f00ab60;
Bend a950fd683c0d76f09794078e6174fe98a1492876;
TS 3040a3b2a3f28fa8554d856f9ccb6bf5433fa334. Reference checkouts are read-only.

## Checks and limits

`check-source.sh`: explicit preserved Bend2.0.35, CPU5, shared heavy lock,
--check-only, cap5. main/source-consumer exit0; intended negatives all exit1:
undeclared rawWorld operation expects World but sees H; read-write sees ValueRead
where OwnedRequest is required; cross-schema sees OtherSchema input at Schema
request; owner duplication reports consumed more than once. These are separate
actual gameplay/body type boundaries, not registration metadata enforcement.

Development failures are retained: closed-template use of runtime H, matching an
erased cap and the reserved Result type name. Initial commands accidentally
omitted --check-only: the full interpreter attempt reached the five-second cap
and is inconclusive; the small source-consumer interpreted successfully. Both
raw streams remain. Those preliminary attempts had no CPU affinity binding;
final explicit CPU5 checks are the authoritative source controls. No unchanged
full interpreter retry, scope-reduced full acceptance claim or backend launch.

Next integration: trusted ordinary declaration builder stores constructed
identity/codec together with operational write/deferred grant; builds the exact
Ops shape and scheduling access; registers an opaque-H body via a trusted runner.
Then source-current complete spine/whole oracles, semantic mutation and JS/Native
checks, independent review and unchanged #28 before executable shared-core delivery.
This prototype does not close #46 or the public assembly gaps.
