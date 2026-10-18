import Base
import motion-stream-scenario.bend as StreamScenario
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-observe.bend as O
import motion-scenario.bend as Scenario
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world-io.bend as WI

def created(path:String,count:U32,iterations:U32,result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>) -> IO(Unit):
  match result:
    case WI.Created{world}:StreamScenario.write(path,StreamScenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.print(Scenario.refused(O.resources(resource)))
def run(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources()),created(path,count,iterations))
