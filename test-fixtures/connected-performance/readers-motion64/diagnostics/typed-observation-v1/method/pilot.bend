import Base
import ../../../../../../benchmarks/connected-clock/clock.bend as Clock
import ../../../method/json.bend as J
import ../../comparative-v1/method/method.bend as M
import ../../../method/codec.bend as Codec
import walk.bend as Walk
import ../../comparative-v1/method/scenario.bend as Scenario
import ../../comparative-v1/method/finish.bend as Finish
import ../../comparative-v1/consumer/motion-program.bend as P
import ../../../consumer/motion.bend as F
import ../../../consumer/types.bend as T
import ../../../consumer/events.bend as E
import ../../../../../../src/ecs/world-io.bend as WI

type Completed is Data:
  Completed{carriers:M.Carriers,public:J.Value,nanoseconds:Nat}
def force(start:Nat,carriers:M.Carriers,public:J.Value,common:Walk.Outcome,public_token:Walk.Outcome) -> IO(Completed):
  match common public_token:
    case Walk.Complete{common} Walk.Complete{public_token}:
      do IO<Completed>:
        IO.print("FORCE:" ++ U32.show(common))
        IO.print("PUBLIC-FORCE:" ++ U32.show(public_token))
        end:Nat <- Clock.end()
        IO.pure(Completed,Completed{carriers,public,Nat.sub(end,start)})
    case _ _:IO.die(Completed,5,"typed observation fuel exhausted")
def checked(start:Nat,+public:J.Value,result:M.Carriers) -> IO(Completed):
  match result:
    case M.Carriers{+records,+actors,True{}}:force(start,M.Carriers{records,actors,True{}},public,Walk.force(records),Walk.force([public]))
    case _:IO.die(Completed,4,"duplicate actor identity")
def captured(start:Nat,result:Finish.Captured) -> IO(Completed):
  match result:
    case Finish.Captured{carriers,public}:checked(start,public,carriers)
def timed(value:Scenario.Prepared) -> IO(Completed):
  match value:
    case Scenario.Ready{iterations,state,seed,seedCall}:
      do IO<Completed>:
        start:Nat <- Clock.begin()
        captured(start,Finish.run(seed,seedCall,P.drain(P.loops(U32.to_nat(iterations),state))))
    case Scenario.Stopped{}:IO.die(Completed,3,"preparation refused")
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
    case Completed{M.Carriers{records,actors,_},public,nanoseconds}:
      do IO<Unit>:
        clock(path,nanoseconds)
        IO.print("TUPLE:" ++ Codec.show(Codec.encode(records)))
        IO.print("PUBLIC-TUPLE:" ++ Codec.show(Codec.encode([public])))
        IO.print("ACTORS:" ++ J.render(actors))
def created(count:U32,iterations:U32,path:String,result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>) -> IO(Unit):
  match result:
    case WI.Created{world}:
      do IO<Unit>:
        result:Completed <- timed(Scenario.program(count,iterations,world))
        write(path,result)
    case WI.Refused{_}:IO.die(Unit,3,"world creation refused")
def one(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~F.empty,F.initial_resources()),created(count,iterations,path))
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
