import Base
import ../../mutants/outgoing-filter-negated/fixture-output.bend as Output
import ../../mutants/outgoing-filter-negated/fixture-driver.bend as Driver
import ../../mutants/outgoing-filter-negated/fixture-schema.bend as D

def rendered(result:Driver.Delivery<D.Workshop> & String) -> String:
  (_,value)=result
  value
def main() -> IO(Unit):
  IO.print(rendered(Output.workshop()))
