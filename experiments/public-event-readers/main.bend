import Base
import fixture.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sy
import ../../src/ecs/event-runtime.bend as Ev

def execute(count: Maybe<&2,U32>) -> IO(Unit):
  match count:
    case None{}: IO.die(Unit,2,"invalid count")
    case Some{count}: IO.print("{\"format\":1,\"checkpoints\":" ++ F.array(F.setup(~F.scenario,count,W.create(~F.Schema,~Unit,~Unit,~U32,~F.empty,W.factory(),Unit{}))) ++ "}")
def args(args: List<String>) -> IO(Unit):
  match args:
    case _ <> count <> _: execute(U32.read(count))
    case _: IO.die(Unit,2,"count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
