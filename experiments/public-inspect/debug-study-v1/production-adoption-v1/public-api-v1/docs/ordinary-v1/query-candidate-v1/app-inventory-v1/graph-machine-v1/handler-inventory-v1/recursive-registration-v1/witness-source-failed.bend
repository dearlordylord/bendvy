import Base
import ./carrier.bend as Hold
def main() -> Unit:
  Hold.Owner{value,_} = Hold.hold(~Unit,Unit{})
  value
