import Base
import tx-metrics.bend as Metrics
import metric-output.bend as MetricOut
import report-doc.bend as Doc
import motion-stream.bend as Stream
import ../../../../dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-scenario.bend as Scenario
import motion-observe.bend as O
import ../../../../../../../src/ecs/world-io.bend as WI

def Creation() -> Type:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>
def make() -> IO(Creation()):WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources())
def refused(label:String,resource:F.Resources()) -> IO(Unit):IO.print(label ++ "Refused{resource={" ++ Scenario.text(~F.Resources(),O.resources(resource)) ++ "}}")
def measured_prepared(path:String,warmup:Metrics.Sample,value:Scenario.Prepared) -> IO(Unit):
  match value:
    case Scenario.Prepared{wire,sample}:IO.bind(Unit,Unit,Stream.write(Doc.wrap("measured={",wire,"}\n")),_=>MetricOut.write(path,[warmup,MetricOut.label("measured-seed",sample)]))
def measured_created(path:String,warmup:Metrics.Sample,count:U32,iterations:U32,result:Creation()) -> IO(Unit):
  match result:
    case WI.Created{world}:measured_prepared(path,warmup,Scenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.bind(Unit,Unit,refused("measured",resource),_=>MetricOut.write(path,[warmup,Metrics.NoTx{"measured-creation-refused"}]))
def measured(path:String,warmup:Metrics.Sample,count:U32,iterations:U32,_:Unit) -> IO(Unit):IO.bind(Creation(),Unit,make(),measured_created(path,warmup,count,iterations))
def warmup_prepared(path:String,count:U32,iterations:U32,value:Scenario.Prepared) -> IO(Unit):
  match value:
    case Scenario.Prepared{wire,sample}:IO.bind(Unit,Unit,Stream.write(Doc.wrap("warmup={",wire,"}\n")),measured(path,MetricOut.label("warmup-seed",sample),count,iterations))
def warmup_created(path:String,+count:U32,+iterations:U32,result:Creation()) -> IO(Unit):
  match result:
    case WI.Created{world}:warmup_prepared(path,count,iterations,Scenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.bind(Unit,Unit,refused("warmup",resource),_=>MetricOut.write(path,[Metrics.NoTx{"warmup-creation-refused"}]))
def run(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(Creation(),Unit,make(),warmup_created(path,count,iterations))
