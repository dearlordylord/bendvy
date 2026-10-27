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
  IO.bind(String,Unit,Application.run_mode(~First,~Query.ParallelWhere{Life.Added{}},Settings.defaults(),True{}),added => IO.bind(String,Unit,Application.run_mode(~First,~Query.ParallelWhere{Life.Changed{}},Settings.defaults(),True{}),changed => IO.bind(String,Unit,Application.run_mode(~First,~Query.ParallelWhere{Life.Changed{}},Settings.Settings{True{},False{},[],[]},True{}),retained => IO.bind(String,Unit,Application.run_mode(~Second,~Query.SerialWhere{Life.Added{}},Settings.defaults(),False{}),serialAdded => IO.bind(String,Unit,Application.run_mode(~Second,~Query.SerialWhere{Life.Changed{}},Settings.defaults(),False{}),serialChanged => IO.bind(String,Unit,Application.run_mode(~Second,~Query.SerialWhere{Life.Changed{}},Settings.Settings{True{},False{},[],[]},True{}),serialRetained => IO.print("First/added-native=" ++ added ++ "\nFirst/changed-native=" ++ changed ++ "\nFirst/changed-retained=" ++ retained ++ "\nSecond/added-serial=" ++ serialAdded ++ "\nSecond/changed-serial=" ++ serialChanged ++ "\nSecond/changed-retained=" ++ serialRetained)))))))
