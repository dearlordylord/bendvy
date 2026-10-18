import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/meter.bend as Meter
import Base
import health-stream.bend as Stream
import ../dense-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import health-scenario.bend as Scenario
import health-observe.bend as O
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world-io.bend as WI

def Creation() -> Type:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>
def make() -> IO(Creation()):WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources())
def refused(label:String,resource:F.Resources()) -> IO(Unit):IO.print(label ++ "Refused{resource={" ++ Scenario.text(~F.Resources(),O.resources(resource)) ++ "}}")
def output(label:String,result:List<&2,String> & List<&2,Meter.Sample>) -> IO(List<&2,Meter.Sample>):
  match result:
    case (wire,metrics):IO.bind(Unit,List<&2,Meter.Sample>,Stream.write(Stream.append([label ++ "={"],Stream.append(wire,["}\n"]))),_=>IO.pure(List<&2,Meter.Sample>,metrics))
def created(label:String,count:U32,iterations:U32,result:Creation()) -> IO(List<&2,Meter.Sample>):
  match result:
    case WI.Created{world}:output(label,Scenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.bind(Unit,List<&2,Meter.Sample>,refused(label,resource),_=>IO.pure(List<&2,Meter.Sample>,[]))
def metrics_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(_,text)}):IO.bind(Unit,Unit,File.close(file),_=>IO.die(Unit,3,text))
def metrics_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),metrics_written)
    case Fail{(_,error)}:IO.die(Unit,3,error)
def metrics(path:String,count:U32,iterations:U32,warm:List<&2,Meter.Sample>,measured:List<&2,Meter.Sample>) -> IO(Unit):IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),metrics_opened("{\"scope\":\"ordinary-workload-tx-boundaries\",\"workload\":\"FailedTxn\",\"schema\":\"Health\",\"workloadCount\":" ++ U32.show(count) ++ ",\"iterations\":" ++ U32.show(iterations) ++ ",\"worlds\":[{\"run\":\"warmup\",\"reports\":" ++ Meter.samples_render(warm) ++ "},{\"run\":\"measured\",\"reports\":" ++ Meter.samples_render(measured) ++ "}]}\n"))
def run(+count:U32,+iterations:U32,path:String) -> IO(Unit):
  do IO<Unit>:
    first:Creation() <- make()
    warm:List<&2,Meter.Sample> <- created("warmup",count,iterations,first)
    second:Creation() <- make()
    measured:List<&2,Meter.Sample> <- created("measured",count,iterations,second)
    metrics(path,count,iterations,warm,measured)
