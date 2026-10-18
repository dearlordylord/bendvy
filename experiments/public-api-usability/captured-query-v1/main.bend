import Base
import ./schema.bend as S
import ./scenario.bend as Scenario
import ../../../src/ecs/world-io.bend as WI
def created(~Schema:Data,label:String,value:WI.Creation<Schema,S.Store(~Schema),Unit,Unit>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.print(label ++ "\n" ++ Scenario.start(~Schema,world))
    case _:IO.die(Unit,1,"World creation failed")
def run(~Schema:Data,label:String) -> IO(Unit):IO.bind(WI.Creation<Schema,S.Store(~Schema),Unit,Unit>,Unit,WI.create(~Schema,~S.Store(~Schema),~Unit,~Unit,~S.empty(~Schema),Unit{}),created(~Schema,label))
def garden(allowed:Bool) -> IO(Unit):
  match allowed:
    case True{}:run(~S.Garden,"Garden")
    case False{}:IO.die(Unit,2,"Expected workshop or garden")
def workshop(allowed:Bool,mode:String) -> IO(Unit):
  match allowed:
    case True{}:run(~S.Workshop,"Workshop")
    case False{}:garden(String.eq(mode,"garden"))
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> +mode <> []:workshop(String.eq(mode,"workshop"),mode)
    case _:IO.die(Unit,2,"Expected workshop or garden")
def main() -> IO(Unit):
  do IO<Unit>:
    values:List<String> <- IO.args()
    args(values)
