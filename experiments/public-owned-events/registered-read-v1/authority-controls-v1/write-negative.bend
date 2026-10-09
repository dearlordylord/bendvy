import Base
import ../log.bend as Log
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def write(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & U32:
  (Cap.value_set(~H,~U32,~U32,~read,owner,99),0)
def reached(log:Log.Log<P.Payload>) -> Log.Reading<P.Payload,U32>:
  Log.read(~P.Payload,~U32,~P.at,~write,log,1)
