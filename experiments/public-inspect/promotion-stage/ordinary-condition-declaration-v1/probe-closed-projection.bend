import Base
type Package is Type:
  Package{predicate:Unit -> Bool}
def projected(package:Package) -> Unit -> Bool:
  match package:
    case Package{predicate}:predicate
def invoke(~predicate:Unit -> Bool,unit:Unit) -> Bool:predicate(unit)
def opened(~package:Package,unit:Unit) -> Bool:invoke(~projected(package),unit)
def truth(unit:Unit) -> Bool:True{}
def main() -> Bool:opened(~Package{truth},Unit{})
