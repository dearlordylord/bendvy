import Base
import ../../../../../../benchmarks/connected-clock/clock.bend as Clock
import ../../../method/json.bend as J
import ../../../method/method.bend as M
import ../../../method/codec.bend as Codec
import walk.bend as Walk
import ../../comparative-v1/consumer/health-program.bend as Program
import ../../comparative-v1/consumer/health-scenario.bend as Scenario
import ../../../../../../src/ecs/world-io.bend as WI

import ../../../consumer/health.bend as F
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../consumer/health-events.bend as E
type Completed is Type:
  Completed{state:Program.State,method:M.State,public:J.Value,actors:J.Value,nanoseconds:Nat}
def records(value:M.State) -> List<&2,J.Value>:
  match value:
    case M.State{_,values}:values
def force(start:Nat,state:Program.State,method:M.State,public:J.Value,actors:J.Value,common:Walk.Outcome,public_token:Walk.Outcome) -> IO(Completed):
  match common public_token:
    case Walk.Complete{common} Walk.Complete{public_token}:
      do IO<Completed>:
        IO.print("FORCE:" ++ U32.show(common))
        IO.print("PUBLIC-FORCE:" ++ U32.show(public_token))
        end:Nat <- Clock.end()
        IO.pure(Completed,Completed{state,method,public,actors,Nat.sub(end,start)})
    case _ _:IO.die(Completed,5,"typed observation fuel exhausted")
def public_encoded(state:M.State,public:J.Value) -> List<&2,U32>:
  match state:
    case M.State{actors,_}:Codec.encode(M.State{actors,[public]})
def public_captured(start:Nat,+method:M.State,value:Program.State & J.Value) -> IO(Completed):
  match value:
    case (state,+public):force(start,state,method,public,M.raw_map(method),Walk.force(records(method)),Walk.force([public]))
def checked(valid:Bool,start:Nat,state:Program.State,method:M.State) -> IO(Completed):
  match valid:
    case True{}:public_captured(start,method,Program.public_state(state))
    case False{}:IO.die(Completed,4,"duplicate actor identity")
def captured(start:Nat,value:Program.State & M.State) -> IO(Completed):
  match value:
    case (state,+method):checked(M.valid(method),start,state,method)
def timed(iterations:U32,value:Scenario.Prepared) -> IO(Completed):
  match value:
    case Scenario.Prepared{state}:
      do IO<Completed>:
        start:Nat <- Clock.begin()
        captured(start,Program.method_final(Program.loops(U32.to_nat(iterations),0,state)))
    case Scenario.PreparationFailed{stage}:IO.die(Completed,3,"preparation refused at " ++ U32.show(stage))
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
    case Completed{state,+method,+public,actors,nanoseconds}:
      do IO<Unit>:
        clock(path,nanoseconds)
        Codec.write("TUPLE:",Codec.encode(method))
        Codec.write("PUBLIC-TUPLE:",public_encoded(method,public))
        IO.print("ACTORS:" ++ J.render(actors))
def created(count:U32,+iterations:U32,path:String,result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>) -> IO(Unit):
  match result:
    case WI.Created{world}:
      do IO<Unit>:
        completed:Completed <- timed(iterations,Scenario.prepare(count,iterations,world))
        write(path,completed)
    case WI.Refused{_}:IO.die(Unit,3,"world creation refused")
def one(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.HealthSchema,F.Store(),F.Resources(),E.event_type()>,Unit,WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources()),created(count,iterations,path))
def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>,warmup:String,sample:String) -> IO(Unit):
  match count iterations:
    case Some{+count} Some{+iterations}:
      do IO<Unit>:
        IO.print("TYPED-OBSERVATION:v1:json-fields")
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
