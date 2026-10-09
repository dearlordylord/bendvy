import Base
import ../log.bend as Log
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev

type OtherSchema is Data: OtherSchema{}
def reached(runtime:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32>,reader:Ev.Reader<OtherSchema>) -> Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32> & Ev.Reader<F.Schema>:
  Ev.skip(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,reader)
