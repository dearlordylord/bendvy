import Base
import ../../../../benchmarks/connected-clock/clock.bend as Clock
import json.bend as J
import method.bend as M
import codec.bend as Codec
import driver.bend as Driver
import ../consumer/lifecycle-runtime-v1/motion-program.bend as P
import ../consumer/lifecycle-runtime-v1/motion-report-rope.bend as Rope
import ../consumer/lifecycle-runtime-v1/motion-buffer-stream.bend as Stream
import ../consumer/lifecycle-runtime-v1/motion-domain.bend as D
import ../consumer/dense-runtime-v1/motion.bend as F
import ../consumer/dense-runtime-v1/types.bend as T
import ../../../../src/ecs/world-io.bend as WI

type Completed is Type:
  Completed{prefix:Rope.Rope,state:P.State,tuple:List<&2,U32>,foreign:List<&2,U32>,actors:J.Value,nanoseconds:Nat}
def force(start:Nat,prefix:Rope.Rope,state:P.State,+tuple:List<&2,U32>,+foreign:List<&2,U32>,actors:J.Value) -> IO(Completed):
  do IO<Completed>:
    IO.print("FORCE:" ++ U32.show(Codec.fold(tuple,0)))
    IO.print("FOREIGN-FORCE:" ++ U32.show(Codec.fold(foreign,0)))
    end:Nat <- Clock.end()
    IO.pure(Completed,Completed{prefix,state,tuple,foreign,actors,Nat.sub(end,start)})
def captured(start:Nat,prefix:Rope.Rope,result:P.State & M.Carriers) -> IO(Completed):
  match result:
    case (state,M.Carriers{common,foreign,actors,True{}}):force(start,prefix,state,Codec.encode(common),Codec.encode(foreign),actors)
    case _:IO.die(Completed,4,"duplicate actor identity")
def setup_done(iterations:U32,prefix:Rope.Rope,result:P.State & M.Setup) -> IO(Completed):
  match result:
    case (state,setup):
      do IO<Completed>:
        start:Nat <- Clock.begin()
        captured(start,prefix,M.collect(setup,P.loops(U32.to_nat(iterations),state)))
def timed(value:Driver.Prepared) -> IO(Completed):
  match value:
    case Driver.Ready{prefix,iterations,state,seed}:setup_done(iterations,prefix,M.setup(seed,state))
    case Driver.Stopped{_}:IO.die(Completed,3,"preparation refused")
def clock_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(code,message)}):IO.bind(Unit,Unit,File.close(file),_ => IO.die(Unit,code,message))
def clock_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),clock_written)
    case Fail{(code,message)}:IO.die(Unit,code,message)
def clock(path:String,value:Nat) -> IO(Unit):IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),result => clock_opened(Nat.show(value) ++ "\n",result))
def formatted(value:P.State & Stream.StateView) -> IO(Unit):
  match value:
    case (state,view):IO.bind(Unit,Unit,Stream.write_body(view),_=>IO.write("!\n"))
def canonical(prefix:Rope.Rope,state:P.State) -> IO(Unit):
  do IO<Unit>:
    Rope.write(prefix)
    IO.write("T")
    formatted(Stream.state(state))
def write(path:String,result:Completed) -> IO(Unit):
  match result:
    case Completed{prefix,state,tuple,foreign,actors,nanoseconds}:
      do IO<Unit>:
        clock(path,nanoseconds)
        IO.print("TUPLE:" ++ Codec.show(tuple))
        IO.print("FOREIGN-TUPLE:" ++ Codec.show(foreign))
        IO.print("ACTORS:" ++ J.render(actors))
        IO.print("CANONICAL-BEGIN")
        canonical(prefix,state)
        IO.print("CANONICAL-END")
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
