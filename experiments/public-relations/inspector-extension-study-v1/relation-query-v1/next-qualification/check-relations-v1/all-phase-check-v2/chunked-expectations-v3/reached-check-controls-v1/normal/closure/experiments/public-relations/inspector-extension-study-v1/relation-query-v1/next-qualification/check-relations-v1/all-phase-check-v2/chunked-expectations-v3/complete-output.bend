import Base
import complete-driver.bend as Driver
import complete-format.bend as F
import ../../../../fixture-schema.bend as D

def last(result:Driver.Delivery<D.Garden> & String,first:String) -> String:
  (_,second)=result
  "{\"schemas\":[" ++ first ++ "," ++ second ++ "]}"
def first(result:Driver.Delivery<D.Workshop> & String) -> String:
  (_,value)=result
  last(F.render(~D.Garden,"Garden",Driver.garden()),value)
# Affine delivery owners are dropped only after complete detached output renders.
def output() -> String:
  first(F.render(~D.Workshop,"Workshop",Driver.workshop()))
