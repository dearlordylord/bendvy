import Base
import ../../mutants/world-valid-omitted/fixture-output.bend as Output
import ../../mutants/world-valid-omitted/fixture-driver.bend as Driver
import ../../mutants/world-valid-omitted/fixture-schema.bend as D

def rendered(result:Driver.Delivery<D.Garden> & String) -> String:
  (_,value)=result
  value
def main() -> IO(Unit):
  IO.print(rendered(Output.garden()))
