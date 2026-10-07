import Base
import fixture.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sy
import ../../src/ecs/event-runtime.bend as Ev

def probe(host: F.Host,+count: U32) -> List<&2,String>:
  F.steps([
    F.Step{"before-readers",[F.Publish{F.PublishRequest{7,(count+2 : U32),None{},False{}}}]},
    F.Step{"dropped-before-first-run",[]},
    F.Step{"first-fast-after-drop",[F.Read{True{},False{}}]},
    F.Step{"before-slow-first-run",[F.Publish{F.PublishRequest{10,1,Some{11},False{}}}]},
    F.Step{"first-slow-backlog",[F.Read{False{},False{}}]},
    F.Step{"fast-backlog",[F.Read{True{},False{}}]},
    F.Step{"late-cleanup",[]}
  ],host,[])

def execute(count: Maybe<&2,U32>) -> IO(Unit):
  match count:
    case None{}: IO.die(Unit,2,"invalid count")
    case Some{count}: IO.print("{\"format\":1,\"checkpoints\":" ++ F.array(F.setup(~probe,count,W.create(~F.Schema,~Unit,~Unit,~U32,~F.empty,W.factory(),Unit{}))) ++ "}")
def args(args: List<String>) -> IO(Unit):
  match args:
    case _ <> count <> _: execute(U32.read(count))
    case _: IO.die(Unit,2,"count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
