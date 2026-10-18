import Base
import schema.bend as S
import application.bend as A
import scenario.bend as Scenario
import sampler.bend as Sampler
import ../private/src/ecs/world-io.bend as WorldIO
import ../private/src/ecs/column.bend as Column

def empty(_:Unit) -> S.Store():Column.empty(~S.Schema,~Array<U32>)
def created(label:String,fail:Bool,result:WorldIO.Creation<S.Schema,S.Store(),Array<U32>,U32>) -> Scenario.Case:
  match result:
    case WorldIO.Created{world}:Scenario.registered(label,A.register(world,fail))
    case WorldIO.Refused{_}:Scenario.Unexpected{"ERROR world creation\n"}
def create(label:String,fail:Bool) -> IO(Scenario.Case):IO.bind(WorldIO.Creation<S.Schema,S.Store(),Array<U32>,U32>,Scenario.Case,WorldIO.create(~S.Schema,~S.Store(),~Array<U32>,~U32,~empty,ALeaf{10}),result=>IO.pure(Scenario.Case,created(label,fail,result)))
def metrics_written(result:File & Result<&1,&1,U32 & String,Unit>) -> IO(Unit):
  match result:
    case (file,Done{_}):File.close(file)
    case (file,Fail{(_,text)}):IO.bind(Unit,Unit,File.close(file),_=>IO.die(Unit,3,text))
def metrics_opened(text:String,result:Result<&1,&1,U32 & String,File>) -> IO(Unit):
  match result:
    case Done{file}:IO.bind(File & Result<&1,&1,U32 & String,Unit>,Unit,File.write(file,text),metrics_written)
    case Fail{(_,error)}:IO.die(Unit,3,error)
def write(path:String,left:Scenario.Case,right:Scenario.Case) -> IO(Unit):
  match left right:
    case Scenario.Case{_,_,wire,a},Scenario.Case{_,_,other,b}:IO.bind(Unit,Unit,IO.write(wire ++ other),_=>IO.bind(Result<&1,&1,U32 & String,File>,Unit,File.open(path,"w"),metrics_opened("{\"scope\":\"ordinary-mixed-reset-control\",\"frame\":null,\"queryCursor\":0,\"cases\":[{\"case\":\"success\",\"reports\":" ++ Sampler.render_list(a) ++ "},{\"case\":\"failure\",\"reports\":" ++ Sampler.render_list(b) ++ "}]}\n")))
    case _ _:IO.die(Unit,4,"unexpected fixture refusal")
def run(path:String) -> IO(Unit):
  do IO<Unit>:
    left:Scenario.Case <- create("success",False{})
    right:Scenario.Case <- create("failure",True{})
    write(path,left,right)
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> path <> _:run(path)
    case _:IO.die(Unit,2,"unique metrics path required")
def main() -> IO(Unit):
  do IO<Unit>:
    values:List<String> <- IO.args()
    args(values)
