import Base
import ../../fixture-output.bend as Output
import ../../fixture-driver.bend as Driver
import ../../fixture-schema.bend as D

def rendered(result:Driver.Delivery<D.Garden> & String) -> String:
  (_,value)=result
  value
def main() -> IO(Unit):
  IO.print(rendered(Output.garden()))
