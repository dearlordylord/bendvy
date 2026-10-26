import Base
import ./visibility.bend as V
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-plan.bend as Plan

def main() -> IO(Unit):
  IO.print("unknown-explicit=" ++ V.run(Settings.Settings{True{},True{},[],[Settings.Explicit{99,None{}}]},True{},True{}) ++ "\nduplicate-explicit=" ++ V.run(Settings.Settings{True{},True{},[],[Settings.Explicit{2,None{}},Settings.Explicit{2,None{}}]},True{},True{}) ++ "\nconditioned-explicit=" ++ V.run(Settings.Settings{True{},True{},[],[Settings.Explicit{2,Some{4}}]},True{},True{}) ++ "\nunknown-ignored=" ++ V.run(Settings.Settings{True{},True{},[Plan.Edge{1,99}],[]},True{},True{}))
