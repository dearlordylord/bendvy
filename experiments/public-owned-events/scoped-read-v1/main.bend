import Base
import controls.bend as Controls

def cells(owner:Array<U32>) -> String:
  match owner:
    case ALeaf{value}: U32.show(value) ++ ","
    case ANode{left,right}: cells(left) ++ cells(right)
def values(items:List<&2,U32>) -> String:
  match items:
    case []: ""
    case head <> tail: U32.show(head) ++ "," ++ values(tail)
def observed(first:List<&2,U32>,second:List<&2,U32>,result:Controls.Payload & Array<U32>) -> String:
  match result:
    case (Controls.Payload{original,sentinel},owned): "first:" ++ values(first) ++ "|second:" ++ values(second) ++ "|returned:" ++ cells(original) ++ "|sentinel:" ++ cells(sentinel) ++ "|owned:" ++ cells(owned)
def finish(result:Controls.Payload & (List<&2,U32> & List<&2,U32>)) -> String:
  match result:
    case (owner,(first,second)): observed(first,second,Controls.owned_control(owner))
def main() -> IO(Unit):
  IO.print(finish(Controls.full()))
