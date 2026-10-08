# Public bundle authoring review — source only

The qualified68 scenarios import production APIs but still use demo A/K/Existing schema helpers. No independently authored core-only schema recipe was checked. Historical core-consumer-v1 remains byte-exact421cb25d, unexecuted/unselected; its definitions lacked concrete source specializations. This is an example/type-feasibility gap, not an identified runtime failure or a new contract decision.

| Role | Required existing API work | Cause |
|---|---|---|
| Schema author | Typed Store columns, nominal family tokens, take/put/project lenses | Bend affine ownership and typed family authority; existed before request optimization. |
| Recipe author | Raw/Cooked Pack shape, staged constructors with authored inverse, Packet pack/unpack | Heterogeneous Type ownership and recoverable construction; not a fixed arity API. |
| Installation author | Compose component installers and retain Installed/Pending/Quarantined receipts | Exact ownership/inverse handling. Default recovery/cancellation policies are not selected here. |
| Provider author | Owner/Resource aliases and request template, optional declared provisioning, Batch.finish attempt/recover hooks | Resource and recovery destination belong to schema; demo Mail is one implementation. |
| Gameplay | Input/Output aliases; generic H + core OwnedRequest, owned_request call | Opaque authority boundary. Store/lenses/Mail do not enter the gameplay body. |

consumer.bend imports Base and production core modules only. It declares two distinct token/payload/lens families (affine Array<U32> and scalar U32), identity constructor receipts, typed Packet/inverse, recursive installer composition and generic request/provider body. Resource remains arbitrary Type. It accepts an existing transaction/world; no IO creation or demo helper is copied. Optional component owners use the existing Entry/replace domain; no new decoding or recovery rule is introduced.

Closed source entries now specialize installer and actual request/provider at Resource=Unit with array/scalar literal cells. closed_adoption also invokes Batch.finish using explicit trusted-author attempt/recover templates, without providing default callbacks. There is no application bootstrap or main, and no runtime observation is claimed. The recipe installer returns all typed Attempt/recovery/undo owners. The example leaves Batch.finish callbacks and recovery storage to the schema author; it does not fabricate a default Mail, discard affine recovery, or choose #38/#46 policy. Existing complete production runtime cohorts cover the actual authored attempt/recovery path. This new example aims only to establish that independently defined family/recipe types can use the public production interface.

Proposed qualification is one source5 check against exact69 source files (production68 plus this consumer), root26 bytes and ordinary source/config/tool/env guards. Expected positive safe-report stdout is the preserved58-byte CLI report, not mathematical validity; unexpected diagnostics stop and remain unaccepted. No source checker, proof or backend has run for this example. Interface/source review and frozen actual source plan precede the check. No implementation/performance gate changes or new law.

Before any optional runtime: the independent literal oracle for a caller-provided valid target/empty families is array projection [7,9], scalar11, constructor positions [None,None]. This follows from the authored cells/identity constructors; it is not extracted from Bend output. Existing safe source check does not establish these observations or finish callback behavior. Optional runtime requires a complete concrete caller/recovery policy fixture and separately reviewed guarded plan.

V2 actual source check failed before typing at the adjacent tuple multi-pattern (line 41). V3 adds only the comma separator consumed by pinned compiler parse_terms (bend.ts:2371–2380); schema, callbacks and literal oracle remain unchanged. V2 source/plan/raw/receipt stay immutable. V3 has not executed.

V3 actual source check parsed the comma correction and failed at def body @- binders. V4 replaces only these two prefixes with leading template ~, matching qualified canonical composition.bend:21 and pinned parse_tele:2396. All schema, callbacks and literal oracle are unchanged; prior V2/V3 raw failures remain preserved. V4 has not executed.
