import Base
import ../complete-driver.bend as Driver
import ../complete-format.bend as F
import ../../../../../fixture-schema.bend as D

def rendered(result:Driver.Delivery<D.Garden> & String) -> String:
  (_,text)=result
  "{\"schemas\":[" ++ text ++ "]}"
def output() -> String:
  rendered(F.render(~D.Garden,"Garden",Driver.garden()))
def main() -> IO(Unit):
  IO.print(output())
