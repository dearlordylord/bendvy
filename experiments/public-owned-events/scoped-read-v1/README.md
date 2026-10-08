# Threaded scoped read authority — #53 development candidate

`read.bend` uses existing canonical `Cap.Request<H,U32,U32>` and the existing
rank-polymorphic authority pattern. A trusted schema author supplies read-at over
its arbitrary affine Owner. A reader is universal in abstract H; its Observation
Type is fixed **before** H. The provider returns the original owner together with
that independent result. The callback receives indexed read operations, never a
write operation or the concrete owner's representation.

Observation may be arbitrary Type: `owned_reader` constructs its own Array from
one observed cell. No mandatory whole-payload Data snapshot is imposed. The two
independent full fixture readers explicitly choose List<Data> observations and
sequentially access all four cells11,12,13,14 of the SAME threaded Payload owner.
Payload also owns a sentinel Array111,222 untouched by the read lens. Each
Array.get returns its original Array owner; no Type clone is used. This is
sequential threaded scoped access, not Rust's simultaneous borrowed references,
and it does not select fan-out, cursor, retention or World policy.

Final source4 checks the generic provider, full two-reader path and owned-output
path. Current-source negatives2 refuse:

- Duplication of abstract H at the provider callback boundary: owner consumed twice.
- Writing through the received capability: Request does not supply ValueWrite.
- Returning the scoped capability: Request<H> cannot become the result's fixed
  Request<Payload> under universal H, even though arbitrary Type results are allowed.

Earlier raw attempts are preserved: source1 rejected computed destructuring;
source2 exposed runtime/template cap parameter mismatch; source3 checked a more
restrictive Data-only result. That restriction was removed; escape-negative1's
Data/Type error is historical, not final confinement evidence. Final source4 and
all negatives2 are source-current and have raw output in evidence. Guide/source
commands used cap5 and telemetry off; source checks used the shared heavy lock.
No backend, universal proof, law/dependency, public ECS API or #53 closure.
Schema-author honesty and closed read lens are trusted, as with existing R-A
capability declarations; source-level constructor/module secrecy is not claimed.
