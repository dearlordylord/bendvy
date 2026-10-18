import Base
import json.bend as J
import method.bend as M
import codec.bend as Codec
import scenario.bend as Scenario
import finish.bend as Finish
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health-program.bend as P
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health.bend as F
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/types.bend as T
import /tmp/bendvy-readers-health-matched-method/experiments/s-perf/canonical-api-v1/readers-runtime-v1/health-events.bend as E
import /tmp/bendvy-readers-health-matched-method/src/ecs/world-io.bend as WI

type Completed is Data:
  Completed{captured:Finish.Captured,tuple:List<&2,U32>,actors:J.Value,milliseconds:Nat}
def force(start:Nat,captured:Finish.Captured,+tuple:List<&2,U32>,actors:J.Value) -> IO(Completed):
  do IO<Completed>:
    IO.print("FORCE:" ++ U32.show(Codec.fold(tuple,0)))
    end:Nat <- IO.now()
    IO.pure(Completed,Completed{captured,tuple,actors,Nat.sub(end,start)})
def checked(start:Nat,prefix:Finish.Captured,result:M.Carriers) -> IO(Completed):
  match result:
    case M.Carriers{records,actors,True{}}:force(start,prefix,Codec.encode(records),actors)
    case _:IO.die(Completed,4,"duplicate actor identity")
def captured(start:Nat,result:Finish.Captured) -> IO(Completed):
  match result:
    case Finish.Captured{prefix,view,logical,after,+carriers}:checked(start,Finish.Captured{prefix,view,logical,after,carriers},carriers)
def timed(value:Scenario.Prepared) -> IO(Completed):
  match value:
    case Scenario.Ready{prefix,iterations,state,seed}:
      do IO<Completed>:
        start:Nat <- IO.now()
        captured(start,Finish.run(seed,prefix,P.drain(P.loops(U32.to_nat(iterations),state))))
    case Scenario.Stopped{_}:IO.die(Completed,3,"preparation refused")
def clock_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(code,message)}):IO.bind(Unit,Unit,File.close(file),_ => IO.die(Unit,code,message))
def clock_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),clock_written)
    case Fail{(code,message)}:IO.die(Unit,code,message)
def clock(path:String,value:Nat) -> IO(Unit):IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),result => clock_opened(Nat.show(value) ++ "\n",result))
def write(path:String,result:Completed) -> IO(Unit):
  match result:
    case Completed{captured,tuple,actors,milliseconds}:
      do IO<Unit>:
        clock(path,milliseconds)
        IO.print("TUPLE:" ++ Codec.show(tuple))
        IO.print("ACTORS:" ++ J.render(actors))
        IO.print("CANONICAL-BEGIN")
        Finish.write(captured)
        IO.print("CANONICAL-END")
def created(count:U32,iterations:U32,path:String,result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>) -> IO(Unit):
  match result:
    case WI.Created{world}:
      do IO<Unit>:
        result:Completed <- timed(Scenario.program(count,iterations,world))
        write(path,result)
    case WI.Refused{_}:IO.die(Unit,3,"world creation refused")
def one(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>,Unit,WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources()),created(count,iterations,path))
def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>,warmup:String,sample:String) -> IO(Unit):
  match count iterations:
    case Some{+count} Some{+iterations}:
      do IO<Unit>:
        IO.print("WARMUP")
        one(count,iterations,warmup)
        IO.print("SAMPLE")
        one(count,iterations,sample)
    case _ _:IO.die(Unit,2,"count iterations must be U32")
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> count <> iterations <> warmup <> sample <> _:parsed(U32.read(count),U32.read(iterations),warmup,sample)
    case _:IO.die(Unit,2,"count iterations warmup-clock sample-clock required")
def main() -> IO(Unit):
  do IO<Unit>:
    values:List<String> <- IO.args()
    args(values)
