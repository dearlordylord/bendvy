import Base
import ./scenario.bend as S
import ../fixture.bend as F
import ../../../../../src/ecs/world-io.bend as WI
import ../../../../../src/ecs/column.bend as Col
type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
def created(~Schema:Data,result:WI.Creation<Schema,Col.Column<Schema,U32>,Unit,Unit>) -> IO(String):
  match result:
    case WI.Created{world}:IO.pure(String,S.start(~Schema,world))
    case _:IO.die(String,1,"World creation failed")
def run(~Schema:Data) -> IO(String):
  IO.bind(WI.Creation<Schema,Col.Column<Schema,U32>,Unit,Unit>,String,WI.create(~Schema,~Col.Column<Schema,U32>,~Unit,~Unit,~F.empty(~Schema),Unit{}),created(~Schema))
def second(first:String,other:String) -> IO(Unit):
  IO.print("Workshop\n" ++ first ++ "Garden\n" ++ other)
def first(value:String) -> IO(Unit):
  IO.bind(String,Unit,run(~Garden),other => second(value,other))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~Workshop),first)
