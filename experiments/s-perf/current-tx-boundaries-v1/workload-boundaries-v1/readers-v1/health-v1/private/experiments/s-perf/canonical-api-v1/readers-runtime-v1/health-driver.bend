import Base
import health-stream-scenario.bend as StreamScenario
import health.bend as F
import types.bend as T
import health-events.bend as E
import health-observe.bend as O
import health-scenario.bend as Scenario
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world-io.bend as WI

def created(path:String,count:U32,iterations:U32,result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>) -> IO(Unit):
  match result:
    case WI.Created{world}:StreamScenario.write(path,StreamScenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.print(Scenario.refused(O.resources(resource)))
def run(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>,Unit,WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources()),created(path,count,iterations))
