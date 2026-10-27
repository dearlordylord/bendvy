import Base
import ./commands-core.bend as Commands
import ../../src/ecs/execution-deferred-settings.bend as Settings

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.bind(String,Unit,Commands.run(~First,Settings.defaults(),True{}),firstFinal =>
    IO.bind(String,Unit,Commands.run(~First,Settings.Settings{True{},False{},[],[]},True{}),firstRetained =>
      IO.bind(String,Unit,Commands.run(~First,Settings.defaults(),False{}),firstSerial =>
        IO.bind(String,Unit,Commands.run(~Second,Settings.defaults(),True{}),secondFinal =>
          IO.bind(String,Unit,Commands.run(~Second,Settings.Settings{True{},False{},[],[]},True{}),secondRetained =>
            IO.bind(String,Unit,Commands.run(~Second,Settings.defaults(),False{}),secondSerial =>
              IO.print("First/native-final=" ++ firstFinal ++ "\nFirst/native-retained=" ++ firstRetained ++ "\nFirst/serial-final=" ++ firstSerial ++ "\nSecond/native-final=" ++ secondFinal ++ "\nSecond/native-retained=" ++ secondRetained ++ "\nSecond/serial-final=" ++ secondSerial)))))))
