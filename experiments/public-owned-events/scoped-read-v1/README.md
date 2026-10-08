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

## Executed consuming observations

`main.bend` consumes the full owner after both independent readers and the
owned-output reader. The complete oracle, authored before backend execution,
requires both readers11,12,13,14, returned payload11,12,13,14, returned
sentinel111,222 and independently allocated output13. Actual first JS and first
Native runs each match every byte; stdout89bytes SHA256
`3d421ad3232fd522586620ab7b6ca104cbd1c4de2dadd764dfe657847338cae0`;
runtime stderr empty. No oracle repair or backend retry was needed.

Main source5PASS; CPU5 emit30/Node5 and emit30/approved private Clang19build120/
Native5 threads1 GPUoff finished exit0. `development-run.py` narrowly reuses the
existing detached development runner and installed explicit environment. Initial,
post-child-lock and terminal source/helper/tool/resource/environment/oracle/raw/
generated checks remain unchanged. Canonical root Cap and its import closure
are inventoried; a retained Cap snapshot binds SHA256
`bc25cd83326709700de1f8ecc1fa53623883a4c3e423db67aa64eaffc3f1d6fe`.
No generic collector or new dependency is introduced. Historical absolute-path
plans/receipts and raw are committed; generated binaries/private environment
files stay local. This does not qualify portable resolver/clean-checkout delivery.

Run `python3 experiments/public-owned-events/scoped-read-v1/verify.py` for no-child
complete byte/source/canonical-Cap/oracle joins. These finite observed controls
show the threaded read seam and returned owners, not universal read-lens
immutability, Rust simultaneous borrows or public World event readers. Type
fan-out/retention/cursors, failed/skipped readers, World integration, semantic
mutations and performance/regression/full #53 delivery gates remain due.
