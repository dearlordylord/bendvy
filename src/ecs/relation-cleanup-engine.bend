import Base
import ./relation-types.bend as G
import ./entity-key.bend as Key

type Progress<-S:Data,-State:Type> is Type:
  Complete{world:State}
  Incomplete{world:State,frames:List<&2,G.CleanupFrame<S>>}
def Step(~S:Data,~State:Type) -> Type:
  G.CleanupFrame<S> -> State -> @+namespace:U32 -> List<&2,G.Descriptor<S>> -> List<&2,G.CleanupFrame<S>> -> State & List<&2,G.CleanupFrame<S>>

def resumed(~S:Data,~State:Type,observed:State & List<&2,G.CleanupFrame<S>>,next:State -> List<&2,G.CleanupFrame<S>> -> Progress<S,State>) -> Progress<S,State>:
  (world,frames) = observed
  next(world,frames)
def drive(~S:Data,~State:Type,~step:Step(~S,~State),fuel: Nat,frames: List<&2,G.CleanupFrame<S>>,world: State,+namespace: U32,+descriptors: List<&2,G.Descriptor<S>>) -> Progress<S,State>:
  match fuel frames:
    case _ Nil{}: Complete{world}
    case 0n frames: Incomplete{world,frames}
    case 1n+rest Con{frame,frames}: resumed(~S,~State,step(frame,world,namespace,descriptors,frames),world => frames => drive(~S,~State,~step,rest,frames,world,namespace,descriptors))


# This is the existing structural inventory bound expressed as arbitrary Nat.
# Counting is eager; very large inventories can spend work in arithmetic before
# the same driver discovers completion. No narrower integer or cap is used.
def inventory_units(remaining:Nat,nodes:Nat,+edges:Nat,descriptors:Nat) -> Nat:
  Nat.mul(remaining,Nat.mul(Nat.add(edges,1n+nodes),Nat.add(3n,Nat.add(Nat.mul(2n,descriptors),Nat.mul(2n,edges)))))
def total_units(-S:Data,remaining:Nat,nodes:Nat,edges:List<&2,G.Edge<S>>,descriptors:List<&2,G.Descriptor<S>>) -> Nat:
  inventory_units(remaining,nodes,List.length(&2,G.Edge<S>,edges),List.length(&2,G.Descriptor<S>,descriptors))
def owner_blocks(~S:Data,~State:Type,~step:Step(~S,~State),remaining:Nat,result:Progress<S,State>,+nodes:Nat,+edges:List<&2,G.Edge<S>>,+namespace:U32,+descriptors:List<&2,G.Descriptor<S>>) -> Progress<S,State>:
  match remaining result:
    case 0n result:result
    case _ Complete{world}:Complete{world}
    case remaining Incomplete{world,frames}:drive(~S,~State,~step,total_units(S,remaining,nodes,edges,descriptors),frames,world,namespace,descriptors)

def automatic(~S:Data,~State:Type,~step:Step(~S,~State),state:State,+nodes:Nat,+edges:List<&2,G.Edge<S>>,+namespace:U32,key:Key.Key,+descriptors:List<&2,G.Descriptor<S>>) -> Progress<S,State>:
  owner_blocks(~S,~State,~step,nodes,drive(~S,~State,~step,1n,[G.CleanupEnter{key}],state,namespace,descriptors),nodes,edges,namespace,descriptors)
