import Base
type Package is Type:
  Package{predicate:Unit -> Bool}
def opened(package:Package) -> Bool:
  match package:
    case Package{predicate}:predicate(Unit{})
def truth(unit:Unit) -> Bool:True{}
def factory(unit:Unit) -> Package:Package{truth}
def evaluate(~factory:Unit -> Package,unit:Unit) -> Bool:opened(factory(unit))
def main() -> Bool:evaluate(~factory,Unit{})
