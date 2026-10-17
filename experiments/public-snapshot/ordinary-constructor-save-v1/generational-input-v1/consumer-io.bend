import Base
import ./legacy-fixture.bend as F
import ./driver.bend as Driver
import ./output.bend as Output
import ./format.bend as Format
import ./supplement.bend as Supplement

def io_workshop(result:Driver.Finished<F.Workshop>) -> IO(String):
  match result:
    case Driver.Finished{_,report}:IO.bind(Driver.Finished<F.Garden>,String,Driver.run_io(~F.Garden),garden => IO.pure(String,Output.garden(Format.report(~F.Workshop,report),garden)))
    case Driver.SetupRefused{_,_,_}:IO.pure(String,"{\"refused\":\"WorkshopSetup\"}")
    case Driver.CreationRefused{_,_}:IO.pure(String,"{\"refused\":\"WorkshopCreation\"}")
def main() -> IO(Unit):
  do IO<Unit>:
    scenario : String <- IO.bind(Driver.Finished<F.Workshop>,String,Driver.run_io(~F.Workshop),io_workshop)
    IO.print("{\"scenario\":" ++ scenario ++ ",\"ordinary\":" ++ Supplement.output() ++ "}")
