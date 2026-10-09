import Base
import ./carrier.bend as Hold
def opened(held:Hold.Owner<Unit>) -> Unit:
  Hold.Owner{value,_} = held
  value
def main() -> Unit:
  opened(Hold.hold(~Unit,Unit{}))
