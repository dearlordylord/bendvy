import Base
import ../../../../benchmarks/connected-clock/clock.bend as Clock
import common.bend as C
import codec.bend as Codec
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion.bend as F
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-driver.bend as Driver
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-observe.bend as Observe
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-main.bend as Canonical
import ../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/ordinary-system.bend as Ordinary

type Prepared is Type:
  Prepared{state:Driver.State,prefix:String}
type Completed is Type:
  Completed{state:Driver.State,prefix:String,tuple:List<&2,U32>,nanoseconds:Nat}
def registered(prefix:String,observed:Driver.State & String) -> Prepared:
  match observed:
    case (state,text):Prepared{state,prefix ++ "registered=" ++ text ++ "\n"}
def defined(prefix:String,result:Driver.Defined) -> IO(Prepared):
  match result:
    case Driver.Defined{state}:IO.pure(Prepared,registered(prefix,Observe.state(state)))
    case Driver.Refused{_}:IO.die(Prepared,3,"registration refused")
def applied(prefix:String,observed:F.World() & String) -> IO(Prepared):
  match observed:
    case (world,text):defined(prefix ++ "seedApplied=" ++ text ++ "\n",Driver.define(world))
def pending(prefix:String,observed:F.World() & String) -> IO(Prepared):
  match observed:
    case (world,text):applied(prefix ++ "seedPending=" ++ text ++ "\n",Observe.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,world)))
def seeded(+count:U32,+iterations:U32,result:F.Seeded) -> IO(Prepared):
  match result:
    case F.Seeded{world,reservations,outcome}:pending("SparseRuntime Motion\ncount=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ "\nseedOutcome=" ++ Observe.outcome(outcome) ++ "|reservations=" ++ List.show(&2,W.Reservation<T.MotionSchema>,Observe.reservation,reservations) ++ "\n",Observe.world(world))
def created(+count:U32,iterations:U32,result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> IO(Prepared):
  match result:
    case WI.Created{world}:seeded(count,iterations,F.seed(count,world))
    case WI.Refused{_}:IO.die(Prepared,3,"world creation refused")
def prepare(+count:U32,+iterations:U32) -> IO(Prepared):
  do IO<Prepared>:
    result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat> <- WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources())
    created(count,iterations,result)
def force(start:Nat,prefix:String,state:Driver.State,+tuple:List<&2,U32>) -> IO(Completed):
  do IO<Completed>:
    IO.print("FORCE:" ++ U32.show(Codec.fold(tuple,0)))
    end:Nat <- Clock.end()
    IO.pure(Completed,Completed{state,prefix,tuple,Nat.sub(end,start)})
def captured(start:Nat,prefix:String,observed:Driver.State & C.Common) -> IO(Completed):
  match observed:
    case (state,common):force(start,prefix,state,Codec.encode(common))
def timed(iterations:U32,prepared:Prepared) -> IO(Completed):
  match prepared:
    case Prepared{state,prefix}:
      do IO<Completed>:
        start:Nat <- Clock.begin()
        captured(start,prefix,C.capture(Driver.loops(U32.to_nat(iterations),state)))
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
    case Completed{state,prefix,tuple,nanoseconds}:
      do IO<Unit>:
        clock(path,nanoseconds)
        Codec.write("TUPLE:",tuple)
        IO.print("CANONICAL-BEGIN")
        IO.print(Canonical.final_state(prefix,Observe.state(state)))
        IO.print("CANONICAL-END")
def one(+count:U32,+iterations:U32,path:String) -> IO(Unit):
  do IO<Unit>:
    prepared:Prepared <- prepare(count,iterations)
    completed:Completed <- timed(iterations,prepared)
    write(path,completed)
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
