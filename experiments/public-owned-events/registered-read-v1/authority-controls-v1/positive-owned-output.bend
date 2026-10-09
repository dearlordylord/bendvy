import Base
import ../log.bend as Log
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def reached(log:Log.Log<P.Payload>) -> Log.Reading<P.Payload,Array<U32>>:
  Log.read(~P.Payload,~Array<U32>,~P.at,~P.owned_reader,log,1)
def main() -> Log.Reading<P.Payload,Array<U32>>:
  reached(Log.Log{[1],[F.packet(1,11)]})
