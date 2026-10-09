import Base
import ./carrier.bend as Hold
def wrong(value:Array<U32>) -> Hold.Owner<Unit>:
  Hold.Owner{Unit{},Some{Hold.hold(~Array<U32>,value)}}
def main() -> Unit:
  Unit{}
