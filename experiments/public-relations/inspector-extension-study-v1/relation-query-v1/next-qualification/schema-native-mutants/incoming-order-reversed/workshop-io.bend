import Base
import ../../mutants/incoming-order-reversed/fixture-output.bend as Output
import ../../mutants/incoming-order-reversed/fixture-driver.bend as Driver
import ../../mutants/incoming-order-reversed/fixture-schema.bend as D

def rendered(result:Driver.Delivery<D.Workshop> & String) -> String:
  (_,value)=result
  value
def main() -> IO(Unit):
  IO.print(rendered(Output.workshop()))
