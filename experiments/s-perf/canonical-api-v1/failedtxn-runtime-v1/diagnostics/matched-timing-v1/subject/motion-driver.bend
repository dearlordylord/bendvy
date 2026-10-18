import Base
import report-doc.bend as Doc
import motion-stream.bend as Stream
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-scenario.bend as Scenario
import motion-observe.bend as O
import /tmp/bendvy-failedtxn-matched-method/src/ecs/world-io.bend as WI

def Creation() -> Type:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>
def make() -> IO(Creation()):WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources())
def refused(label:String,resource:F.Resources()) -> IO(Unit):IO.print(label ++ "Refused{resource={" ++ Scenario.text(~F.Resources(),O.resources(resource)) ++ "}}")
def measured_created(count:U32,iterations:U32,result:Creation()) -> IO(Unit):
  match result:
    case WI.Created{world}:Stream.write(Doc.wrap("measured={",Scenario.program(count,iterations,world),"}\n"))
    case WI.Refused{resource}:refused("measured",resource)
def measured(count:U32,iterations:U32,_:Unit) -> IO(Unit):IO.bind(Creation(),Unit,make(),measured_created(count,iterations))
def warmup_created(+count:U32,+iterations:U32,result:Creation()) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.bind(Unit,Unit,Stream.write(Doc.wrap("warmup={",Scenario.program(count,iterations,world),"}\n")),measured(count,iterations))
    case WI.Refused{resource}:refused("warmup",resource)
def run(count:U32,iterations:U32) -> IO(Unit):IO.bind(Creation(),Unit,make(),warmup_created(count,iterations))
