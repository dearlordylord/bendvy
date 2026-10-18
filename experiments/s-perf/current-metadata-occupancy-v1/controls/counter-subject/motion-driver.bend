import Base
import motion-stream-scenario.bend as StreamScenario
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-observe.bend as O
import motion-scenario.bend as Scenario
import ../../private/src/ecs/world-io.bend as WI

def metrics_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(_,text)}):IO.bind(Unit,Unit,File.close(file),_=>IO.die(Unit,3,text))
def metrics_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),metrics_written)
    case Fail{(_,text)}:IO.die(Unit,3,text)
def metrics(value:StreamScenario.Prepared) -> String:
  match value:
    case StreamScenario.Ready{_,_,_,_,text}:text
    case _:"{}"
def prepared(path:String,+value:StreamScenario.Prepared) -> IO(Unit):
  IO.bind(Unit,Unit,StreamScenario.write(value),_=>IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),metrics_opened(metrics(value))))
def created(path:String,count:U32,iterations:U32,result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>) -> IO(Unit):
  match result:
    case WI.Created{world}:prepared(path,StreamScenario.program(count,iterations,world))
    case WI.Refused{resource}:IO.print(Scenario.refused(O.resources(resource)))
def run(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources()),created(path,count,iterations))
