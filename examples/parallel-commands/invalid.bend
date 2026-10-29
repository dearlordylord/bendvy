import Base
import ./visibility.bend as V
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-plan.bend as Plan

def main() -> IO(Unit):
  IO.bind(String,Unit,V.run(Settings.Settings{True{},True{},[],[Settings.Explicit{99,None{}}]},True{},True{}),unknown => IO.bind(String,Unit,V.run(Settings.Settings{True{},True{},[],[Settings.Explicit{2,None{}},Settings.Explicit{2,None{}}]},True{},True{}),duplicate => IO.bind(String,Unit,V.run(Settings.Settings{True{},True{},[],[Settings.Explicit{2,Some{4}}]},True{},True{}),conditioned => IO.bind(String,Unit,V.run(Settings.Settings{True{},True{},[Plan.Edge{1,99}],[]},True{},True{}),ignored => IO.print("unknown-explicit=" ++ unknown ++ "\nduplicate-explicit=" ++ duplicate ++ "\nconditioned-explicit=" ++ conditioned ++ "\nunknown-ignored=" ++ ignored)))))
