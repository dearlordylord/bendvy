import Base
import ../log.bend as Log
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def escape(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & Cap.Request<H,U32,U32>:
  (owner,read)
def reached(log:Log.Log<P.Payload>) -> Log.Reading<P.Payload,Cap.Request<P.Payload,U32,U32>>:
  Log.read(~P.Payload,~Cap.Request<P.Payload,U32,U32>,~P.at,~escape,log,1)
