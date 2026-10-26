import Base
import ../parallel-query/commands-core.bend as Application
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/execution-deferred-settings.bend as Settings

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First/added-native=" ++ Application.run_mode(~First,~Query.ParallelWhere{Life.Added{}},Settings.defaults(),True{}) ++ "\nFirst/changed-native=" ++ Application.run_mode(~First,~Query.ParallelWhere{Life.Changed{}},Settings.defaults(),True{}) ++ "\nFirst/changed-retained=" ++ Application.run_mode(~First,~Query.ParallelWhere{Life.Changed{}},Settings.Settings{True{},False{},[],[]},True{}) ++ "\nSecond/added-serial=" ++ Application.run_mode(~Second,~Query.SerialWhere{Life.Added{}},Settings.defaults(),False{}) ++ "\nSecond/changed-serial=" ++ Application.run_mode(~Second,~Query.SerialWhere{Life.Changed{}},Settings.defaults(),False{}) ++ "\nSecond/changed-retained=" ++ Application.run_mode(~Second,~Query.SerialWhere{Life.Changed{}},Settings.Settings{True{},False{},[],[]},True{}))
