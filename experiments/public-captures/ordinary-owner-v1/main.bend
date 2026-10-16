import Base
import ./scenario.bend as S
import ./format.bend as F
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
def empty(unit:Unit) -> Unit:
  Unit{}
def second(~Schema:Data,world:W.World<Schema,Unit,U32,Unit>,created:WI.Creation<Schema,Unit,U32,Unit>) -> IO(String):
  match created:
    case WI.Created{foreign}:IO.pure(String,F.trace(S.start(~Schema,world,foreign)))
    case _:IO.die(String,1,"foreign world creation failed")
def first(~Schema:Data,created:WI.Creation<Schema,Unit,U32,Unit>) -> IO(String):
  match created:
    case WI.Created{world}:IO.bind(WI.Creation<Schema,Unit,U32,Unit>,String,WI.create(~Schema,~Unit,~U32,~Unit,~empty,900),other => second(~Schema,world,other))
    case _:IO.die(String,1,"world creation failed")
def run(~Schema:Data) -> IO(String):
  IO.bind(WI.Creation<Schema,Unit,U32,Unit>,String,WI.create(~Schema,~Unit,~U32,~Unit,~empty,10),first(~Schema))
def printed(a:String,b:String) -> IO(Unit):
  IO.print("Workshop\n" ++ a ++ "Garden\n" ++ b)
def workshop(a:String) -> IO(Unit):
  IO.bind(String,Unit,run(~Garden),b => printed(a,b))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~Workshop),workshop)
