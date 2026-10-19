import Base
import ../../../../../../benchmarks/connected-clock/clock.bend as Clock
import ../../../method/json.bend as J
import ../../comparative-v1/method/method.bend as M
import ../../../method/codec.bend as Codec
import ../../comparative-v1/method/driver.bend as Driver
import ../../comparative-v1/consumer/motion-program.bend as P
import ../../comparative-v1/consumer/motion-domain.bend as D
import ../../../consumer/dense-runtime-v1/motion.bend as F
import ../../../consumer/dense-runtime-v1/types.bend as T
import ../../../../../../src/ecs/world-io.bend as WI

import walk.bend as Walk

type Completed is Type:
  Completed{state:P.State,carriers:M.Carriers,nanoseconds:Nat}
def forced(start:Nat,state:P.State,carriers:M.Carriers,common:Walk.Outcome,foreign:Walk.Outcome,public:Walk.Outcome) -> IO(Completed):
  match common foreign public:
    case Walk.Complete{common} Walk.Complete{foreign} Walk.Complete{public}:
      do IO<Completed>:
        IO.print("FORCE:" ++ U32.show(common))
        IO.print("FOREIGN-FORCE:" ++ U32.show(foreign))
        IO.print("PUBLIC-FORCE:" ++ U32.show(public))
        end:Nat <- Clock.end()
        IO.pure(Completed,Completed{state,carriers,Nat.sub(end,start)})
    case _ _ _:IO.die(Completed,5,"typed observation fuel exhausted")
def captured(start:Nat,result:P.State & M.Carriers) -> IO(Completed):
  match result:
    case (state,M.Carriers{+common,+foreign,+actors,+public,True{}}):forced(start,state,M.Carriers{common,foreign,actors,public,True{}},Walk.force(common),Walk.force(foreign),Walk.force([public]))
    case _:IO.die(Completed,4,"duplicate actor identity")
def setup_done(iterations:U32,result:P.State & M.Setup) -> IO(Completed):
  match result:
    case (state,setup):
      do IO<Completed>:
        start:Nat <- Clock.begin()
        captured(start,M.collect(setup,P.loops(U32.to_nat(iterations),state)))
def timed(value:Driver.Prepared) -> IO(Completed):
  match value:
    case Driver.Ready{iterations,state,seed}:setup_done(iterations,M.setup(seed,state))
    case Driver.Stopped{}:IO.die(Completed,3,"preparation refused")
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
    case Completed{state,M.Carriers{common,foreign,actors,public,_},nanoseconds}:
      do IO<Unit>:
        clock(path,nanoseconds)
        Codec.write("TUPLE:",Codec.encode(common))
        Codec.write("FOREIGN-TUPLE:",Codec.encode(foreign))
        Codec.write("PUBLIC-TUPLE:",Codec.encode([public]))
        IO.print("ACTORS:" ++ J.render(actors))

def foreign_created(count:U32,iterations:U32,path:String,world:D.World(),result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> IO(Unit):
  match result:
    case WI.Created{foreign}:
      do IO<Unit>:
        completed:Completed <- timed(Driver.program(count,iterations,world,foreign))
        write(path,completed)
    case WI.Refused{_}:IO.die(Unit,3,"foreign world creation refused")
def primary_created(count:U32,iterations:U32,path:String,result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> IO(Unit):
  match result:
    case WI.Created{world}:IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources()),created=>foreign_created(count,iterations,path,world,created))
    case WI.Refused{_}:IO.die(Unit,3,"primary world creation refused")
def one(count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>,Unit,WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources()),primary_created(count,iterations,path))
def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>,warmup:String,sample:String) -> IO(Unit):
  match count iterations:
    case Some{+count} Some{+iterations}:
      do IO<Unit>:
        IO.print("PROTOTYPE:typed-observation-v1")
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
