import Base
import ./schema.bend as Families
import ./fixture.bend as F
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/owned-event-storage.bend as Storage
import ./scenario.bend as Scenario
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def empty(value:Unit) -> Unit:value
def foreign(~S:Data,world:W.World<S,Col.Column<S,U32>,Families.Resources(),Families.E()>,created:WI.Creation<S,Col.Column<S,U32>,Families.Resources(),Families.E()>) -> IO(String):
  match created:
    case WI.Created{other}:IO.pure(String,Scenario.start(~S,world,other))
    case _:IO.die(String,1,"foreign creation failed")
def first(~S:Data,created:WI.Creation<S,Col.Column<S,U32>,Families.Resources(),Families.E()>) -> IO(String):
  match created:
    case WI.Created{world}:IO.bind(WI.Creation<S,Col.Column<S,U32>,Families.Resources(),Families.E()>,String,WI.create(~S,~Col.Column<S,U32>,~Families.Resources(),~Families.E(),~F.empty(~S),Families.resources()),value => foreign(~S,world,value))
    case _:IO.die(String,1,"creation failed")
def run(~S:Data) -> IO(String):
  IO.bind(WI.Creation<S,Col.Column<S,U32>,Families.Resources(),Families.E()>,String,WI.create(~S,~Col.Column<S,U32>,~Families.Resources(),~Families.E(),~F.empty(~S),Families.resources()),first(~S))
def printed(a:String,b:String) -> IO(Unit):IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):IO.bind(String,Unit,run(~Garden),b => printed(a,b))
def main() -> IO(Unit):IO.bind(String,Unit,run(~Workshop),workshop)
