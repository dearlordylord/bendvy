import Base
import health-stream.bend as Stream
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-scenario.bend as Scenario
import health-observe.bend as O
import ../../../../src/ecs/world-io.bend as WI

def Creation() -> Type:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>
def make() -> IO(Creation()):WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources())
def refused(label:String,resource:F.Resources()) -> IO(Unit):IO.print(label ++ "Refused{resource={" ++ Scenario.text(~F.Resources(),O.resources(resource)) ++ "}}")
def measured_created(count:U32,iterations:U32,result:Creation()) -> IO(Unit):
  match result:
    case WI.Created{world}:Stream.write(Stream.append(["measured={"],Stream.append(Scenario.program(count,iterations,world),["}\n"])))
    case WI.Refused{resource}:refused("measured",resource)
def measured(count:U32,iterations:U32,_:Unit) -> IO(Unit):IO.bind(Creation(),Unit,make(),measured_created(count,iterations))
def warmup_created(+count:U32,+iterations:U32,result:Creation()) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.bind(Unit,Unit,Stream.write(Stream.append(["warmup={"],Stream.append(Scenario.program(count,iterations,world),["}\n"]))),measured(count,iterations))
    case WI.Refused{resource}:refused("warmup",resource)
def run(count:U32,iterations:U32) -> IO(Unit):IO.bind(Creation(),Unit,make(),warmup_created(count,iterations))
