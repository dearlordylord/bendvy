import Base
import ../log.bend as Log
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def consume(~H:Type,owner:H) -> U32: 0
def duplicate(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & U32:
  (owner,consume(~H,owner))
def reached(log:Log.Log<P.Payload>) -> Log.Reading<P.Payload,U32>:
  Log.read(~P.Payload,~U32,~P.at,~duplicate,log,1)
