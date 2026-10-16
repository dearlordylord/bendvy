import Base
import ./witness-mutant.bend as Witness
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D

type Tree<T:Data> is Data:
  Leaf{value:T}
  Node{left:Tree<T>,right:Tree<T>}
def joined(~T:Data,left:Array<T> & Tree<T>,right:Array<T> & Tree<T>) -> Array<T> & Tree<T>:
  (a,x)=left
  (b,y)=right
  (ANode{a,b},Node{x,y})
def array_tree(~T:Data,array:Array<T>) -> Array<T> & Tree<T>:
  match array:
    case ALeaf{+value}: (ALeaf{value},Leaf{value})
    case ANode{left,right}: joined(~T,array_tree(~T,left),array_tree(~T,right))
type Observation is Data:
  Accepted{context:Tree<U32>,payload:Tree<Bool>,checked:D.Checked}
  Refused{context:Tree<U32>,original:D.Raw,error:D.Error,sentinel:Tree<U32>}
def accepted_trees(checked:D.Checked,context:Array<U32> & Tree<U32>,payload:Array<Bool> & Tree<Bool>) -> Observation:
  (_,contextTree)=context
  (_,payloadTree)=payload
  Accepted{contextTree,payloadTree,checked}
def refused_trees(original:D.Raw,error:D.Error,context:Array<U32> & Tree<U32>,sentinel:Array<U32> & Tree<U32>) -> Observation:
  (_,contextTree)=context
  (_,sentinelTree)=sentinel
  Refused{contextTree,original,error,sentinelTree}
def observe(observed:Witness.Observed) -> Observation:
  match observed:
    case Witness.Accepted{Witness.Context{context},D.Receipt{Witness.Payload{payload},checked}}: accepted_trees(checked,array_tree(~U32,context),array_tree(~Bool,payload))
    case Witness.Refused{Witness.Context{context},original,Witness.Issues{error,sentinel}}: refused_trees(original,error,array_tree(~U32,context),array_tree(~U32,sentinel))
type Report is Data:
  Report{accepted:Observation,refused:Observation}
def main() -> Report:
  Report{observe(Witness.accepted_control()),observe(Witness.refused_control())}
