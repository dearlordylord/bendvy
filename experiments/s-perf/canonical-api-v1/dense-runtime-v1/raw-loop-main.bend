import Base
import raw-loop-control.bend as Control
import motion.bend as F
import motion-observe.bend as O
import types.bend as Types
import ../../../../src/ecs/world-io.bend as WI

def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resource,text):"WorldCreationRefused|" ++ text

def created(~skip:Bool,name:String,empty:Bool,fail:Bool,result:WI.Creation<Types.MotionSchema,F.Store(),F.Resources(),Nat>) -> String:
  match result:
    case WI.Created{world}:Control.run(~skip,name,empty,fail,world)
    case WI.Refused{resource}:refused(O.resources(resource))

def run(~skip:Bool,name:String,empty:Bool,fail:Bool) -> IO(Unit):
  do IO<Unit>:
    result:WI.Creation<Types.MotionSchema,F.Store(),F.Resources(),Nat> <- WI.create(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources())
    IO.print(created(~skip,name,empty,fail,result))
def main() -> IO(Unit):
  do IO<Unit>:
    run(~False{},"success",False{},False{})
    run(~True{},"skip-middle",False{},False{})
    run(~False{},"empty",True{},False{})
    run(~False{},"fail-second",False{},True{})
