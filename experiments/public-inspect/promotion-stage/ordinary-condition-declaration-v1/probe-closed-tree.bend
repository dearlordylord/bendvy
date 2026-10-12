import Base
type Package is Data:
  Package{-predicate:Unit -> Bool}
def invoke(~predicate:Unit -> Bool,unit:Unit) -> Bool:predicate(unit)
def opened(~package:Package) -> Bool:
  match package:
    case Package{predicate}:invoke(~predicate,Unit{})
def truth(unit:Unit) -> Bool:True{}
def main() -> Bool:opened(~Package{truth})
