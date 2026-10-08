import Base
import ../complete-driver.bend as Driver
import ../complete-format.bend as F
import ../../../../../fixture-schema.bend as D

def rendered(result:Driver.Delivery<D.Workshop> & String) -> String:
  (_,text)=result
  "{\"schemas\":[" ++ text ++ "]}"
def output() -> String:
  rendered(F.render(~D.Workshop,"Workshop",Driver.workshop()))
def main() -> IO(Unit):
  IO.print(output())
