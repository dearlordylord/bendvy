import Base
import ./state.bend as St
import ./scenario.bend as S
import ./fixture.bend as F
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
def second(~Schema:Data,world:W.World<Schema,Col.Column<Schema,U32>,St.Resources<Schema>,Unit>,created:WI.Creation<Schema,Col.Column<Schema,U32>,St.Resources<Schema>,Unit>) -> IO(String):
  match created:
    case WI.Created{foreign}:IO.pure(String,S.start(~Schema,world,foreign))
    case _:IO.die(String,1,"foreign world creation failed")
def first(~Schema:Data,created:WI.Creation<Schema,Col.Column<Schema,U32>,St.Resources<Schema>,Unit>) -> IO(String):
  match created:
    case WI.Created{world}:IO.bind(WI.Creation<Schema,Col.Column<Schema,U32>,St.Resources<Schema>,Unit>,String,WI.create(~Schema,~Col.Column<Schema,U32>,~St.Resources<Schema>,~Unit,~F.empty(~Schema),St.empty(~Schema)),other => second(~Schema,world,other))
    case _:IO.die(String,1,"world creation failed")
def run(~Schema:Data) -> IO(String):
  IO.bind(WI.Creation<Schema,Col.Column<Schema,U32>,St.Resources<Schema>,Unit>,String,WI.create(~Schema,~Col.Column<Schema,U32>,~St.Resources<Schema>,~Unit,~F.empty(~Schema),St.empty(~Schema)),first(~Schema))
def printed(a:String,b:String) -> IO(Unit):
  IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):
  IO.bind(String,Unit,run(~Garden),b => printed(a,b))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~Workshop),workshop)
