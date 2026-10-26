import Base
import ./commands-core.bend as Commands
import ../../src/ecs/execution-deferred-settings.bend as Settings

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First/native-final=" ++ Commands.run(~First,Settings.defaults(),True{}) ++ "\nFirst/native-retained=" ++ Commands.run(~First,Settings.Settings{True{},False{},[],[]},True{}) ++ "\nFirst/serial-final=" ++ Commands.run(~First,Settings.defaults(),False{}) ++ "\nSecond/native-final=" ++ Commands.run(~Second,Settings.defaults(),True{}) ++ "\nSecond/native-retained=" ++ Commands.run(~Second,Settings.Settings{True{},False{},[],[]},True{}) ++ "\nSecond/serial-final=" ++ Commands.run(~Second,Settings.defaults(),False{}))
