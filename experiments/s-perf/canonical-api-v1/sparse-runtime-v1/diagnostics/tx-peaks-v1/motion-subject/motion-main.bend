import Base
import tx-metrics.bend as Metrics
import types.bend as T
import motion.bend as F
import motion-driver.bend as Driver
import motion-observe.bend as Observe
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/world-io.bend as WI
import ../../../../../../../src/ecs/ordinary-system.bend as Ordinary

import motion-scenario.bend as Scenario

def created(+count:U32,+iterations:U32,result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> Scenario.Prepared:
  match result:
    case WI.Created{world}:Scenario.seeded(count,iterations,F.seed(count,world))
    case WI.Refused{resource}:Scenario.Prepared{Scenario.refused(Observe.resources(resource)),[Metrics.NoTx{"world-creation-refused"}]}

def metrics_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(_,text)}):IO.bind(Unit,Unit,File.close(file),_=>IO.die(Unit,3,text))
def metrics_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),metrics_written)
    case Fail{(_,error)}:IO.die(Unit,3,error)
def write(metricsPath:String,value:Scenario.Prepared) -> IO(Unit):
  match value:
    case Scenario.Prepared{wire,samples}:IO.bind(Unit,Unit,IO.print(wire),_=>IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(metricsPath,"w"),metrics_opened(Metrics.report(samples))))
def run(+count:U32,+iterations:U32,metricsPath:String) -> IO(Unit):
  do IO<Unit>:
    result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat> <- WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources())
    write(metricsPath,created(count,iterations,result))
def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>,metricsPath:String) -> IO(Unit):
  match count iterations:
    case Some{count} Some{iterations}:run(count,iterations,metricsPath)
    case _ _:IO.die(Unit,2,"count iterations must be U32")
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> count <> iterations <> metricsPath <> _:parsed(U32.read(count),U32.read(iterations),metricsPath)
    case _:IO.die(Unit,2,"count iterations and unique metrics path required")
def main() -> IO(Unit):
  do IO<Unit>:
    values:List<String> <- IO.args()
    args(values)
