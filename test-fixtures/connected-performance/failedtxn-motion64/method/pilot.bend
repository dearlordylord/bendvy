import Base
import ../../../../benchmarks/connected-clock/clock.bend as Clock
import json.bend as J
import method.bend as M
import codec.bend as Codec
import ../consumer/motion-driver.bend as Driver
import ../consumer/motion-program.bend as Program
import ../consumer/motion-scenario.bend as Scenario
import ../consumer/motion-stream.bend as Stream
import ../consumer/report-doc.bend as Doc
import ../../../../src/ecs/world-io.bend as WI

type Completed is Type:
  Completed{prefix:Doc.Doc,state:Program.State,tuple:List<&2,U32>,actors:J.Value,nanoseconds:Nat}
def force(start:Nat,prefix:Doc.Doc,state:Program.State,+tuple:List<&2,U32>,actors:J.Value) -> IO(Completed):
  do IO<Completed>:
    IO.print("FORCE:" ++ U32.show(Codec.fold(tuple,0)))
    end:Nat <- Clock.end()
    IO.pure(Completed,Completed{prefix,state,tuple,actors,Nat.sub(end,start)})
def checked(valid:Bool,start:Nat,prefix:Doc.Doc,state:Program.State,+method:M.State) -> IO(Completed):
  match valid:
    case True{}:force(start,prefix,state,Codec.encode(method),M.raw_map(method))
    case False{}:IO.die(Completed,4,"duplicate actor identity")
def captured(start:Nat,prefix:Doc.Doc,value:Program.State & M.State) -> IO(Completed):
  match value:
    case (state,+method):checked(M.valid(method),start,prefix,state,method)
def timed(iterations:U32,value:Scenario.Prepared) -> IO(Completed):
  match value:
    case Scenario.Prepared{prefix,state}:
      do IO<Completed>:
        start:Nat <- Clock.begin()
        captured(start,prefix,Program.method_final(Program.loops(U32.to_nat(iterations),0,state)))
    case Scenario.PreparationFailed{_}:IO.die(Completed,3,"preparation refused")
def clock_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(code,message)}):IO.bind(Unit,Unit,File.close(file),_ => IO.die(Unit,code,message))
def clock_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),clock_written)
    case Fail{(code,message)}:IO.die(Unit,code,message)
def clock(path:String,value:Nat) -> IO(Unit):IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),result => clock_opened(Nat.show(value) ++ "\n",result))
def write(label:String,path:String,result:Completed) -> IO(Unit):
  match result:
    case Completed{prefix,state,tuple,actors,nanoseconds}:
      do IO<Unit>:
        clock(path,nanoseconds)
        Codec.write("TUPLE:",tuple)
        IO.print("ACTORS:" ++ J.render(actors))
        IO.print("CANONICAL-BEGIN")
        Stream.write(Doc.wrap(label ++ "={",Stream.final(prefix,state),"}\n"))
        IO.print("CANONICAL-END")
def created(label:String,count:U32,+iterations:U32,path:String,result:Driver.Creation()) -> IO(Unit):
  match result:
    case WI.Created{world}:
      do IO<Unit>:
        completed:Completed <- timed(iterations,Scenario.prepare(count,iterations,world))
        write(label,path,completed)
    case WI.Refused{_}:IO.die(Unit,3,"world creation refused")
def one(label:String,count:U32,iterations:U32,path:String) -> IO(Unit):IO.bind(Driver.Creation(),Unit,Driver.make(),created(label,count,iterations,path))
def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>,warmup:String,sample:String) -> IO(Unit):
  match count iterations:
    case Some{+count} Some{+iterations}:
      do IO<Unit>:
        IO.print("WARMUP")
        one("warmup",count,iterations,warmup)
        IO.print("SAMPLE")
        one("measured",count,iterations,sample)
    case _ _:IO.die(Unit,2,"count iterations must be U32")
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> count <> iterations <> warmup <> sample <> _:parsed(U32.read(count),U32.read(iterations),warmup,sample)
    case _:IO.die(Unit,2,"count iterations warmup-clock sample-clock required")
def main() -> IO(Unit):
  do IO<Unit>:
    values:List<String> <- IO.args()
    args(values)
