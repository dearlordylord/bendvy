import Base
type Report is Data:
  Report{physical:List<&2,U32>,borrowed:List<&2,U32>,size:U32,scalar:U32}
type Owner<A:Type> is Type:
  Owner{value:A}
def observe_right(left:Array<U32>,leftValues:List<&2,U32>,got:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match got:
    case (right,rightValues):(ANode{left,right},List.append(&2,U32,leftValues,rightValues))
def observe_node(rightGot:Array<U32> & List<&2,U32>,leftGot:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match leftGot:
    case (left,leftValues):observe_right(left,leftValues,rightGot)
def observe(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:observe_node(observe(right),observe(left))
def report_borrowed(values:List<&2,U32>,size:U32,scalar:U32,got:Array<U32> & List<&2,U32>) -> Report:
  match got:
    case (borrowed,borrowedValues):Report{values,borrowedValues,size,scalar}
def report_owner(borrowed:Array<U32>,size:U32,scalar:U32,got:Array<U32> & List<&2,U32>) -> Report:
  match got:
    case (owner,values):report_borrowed(values,size,scalar,observe(borrowed))
def report_size(borrowed:Array<U32>,scalar:U32,got:Array<U32> & U32) -> Report:
  match got:
    case (owner,size):report_owner(borrowed,size,scalar,observe(owner))
def report(owner:Array<U32>,borrowed:Array<U32>,scalar:U32) -> Report:
  report_size(borrowed,scalar,Array.size(U32,owner))
def plus(a:U32) -> U32:
  U32.add(a,10)
def target(owner:Array<U32>,borrowed:Array<U32>) -> Report:
  a b = plus(1) plus(2)
  report(owner,borrowed,U32.add(a,b))
def main() -> Report:
  target(ANode{ALeaf{51},ALeaf{52}},ANode{ALeaf{61},ALeaf{62}})
