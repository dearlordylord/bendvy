import Base
import health-stream-scenario.bend as StreamScenario
import health.bend as F
import types.bend as T
import health-events.bend as E
import health-observe.bend as O
import health-scenario.bend as Scenario
import ../../../../src/ecs/world-io.bend as WI

def created(count:U32,iterations:U32,result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>) -> IO(Unit):
  match result:
    case WI.Created{world}:StreamScenario.write(StreamScenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.print(Scenario.refused(O.resources(resource)))
def run(count:U32,iterations:U32) -> IO(Unit):IO.bind(WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>,Unit,WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources()),created(count,iterations))
