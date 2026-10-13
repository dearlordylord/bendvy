import Base
import handle-application.bend as H
import handle-controls.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as WorldCommands

def zero_target(~S:Data,own:W.Handle<S>) -> Maybe<&2,W.Handle<S>>:
  match own:
    case W.Handle{namespace,_}:Some{W.Handle{namespace,0}}
def target(~S:Data,which:U32,own:W.Handle<S>,foreign:W.Handle<S>) -> Maybe<&2,W.Handle<S>>:
  match which:
    case 0: Some{foreign}
    case 1: Some{foreign}
    case 2: Some{foreign}
    case 3: zero_target(~S,own)
    case 4: zero_target(~S,own)
    case 5: zero_target(~S,own)
    case 10: None{}
    case _: Some{own}
def operation_target(~S:Data,which:U32,own:W.Handle<S>,foreign:W.Handle<S>) -> W.Handle<S>:
  match which:
    case 9: foreign
    case _: own
def populate_world(~S:Data,world:H.World(~S),target:W.Handle<S>,payload:H.Payload<S>) -> H.World(~S):
  H.populate(~S,world,target,payload)
def input(~S:Data,which:U32,own:W.Handle<S>,foreign:W.Handle<S>) -> H.Payload<S>:
  H.Payload{ANode{ANode{ALeaf{41},ALeaf{42}},ANode{ALeaf{43},ALeaf{44}}},"incoming",target(~S,which,own,foreign)}
def marker(~S:Data,world:H.World(~S)) -> H.World(~S):
  W.event_publish(~S,~H.Store(~S),~H.Payload<S>,~U32,world,[77])
def run_again(~S:Data,+which:U32,+own:W.Handle<S>,+foreign:W.Handle<S>,second:H.World(~S),cursor:U32,result:H.Outcome<S>) -> String:
  match result:
    case H.Outcome{world,_,_,_}:
      O.render(~S,second,cursor,H.admit(~S,which,W.enqueue(~S,~H.Store(~S),~H.Payload<S>,~U32,world,w => marker(~S,w)),operation_target(~S,which,own,foreign),input(~S,which,own,foreign)))
def factory_cursor(factory:W.Factory) -> U32:
  match factory:
    case W.Factory{nextNamespace}: nextNamespace
def second_ready(~S:Data,+which:U32,+own:W.Handle<S>,first:H.World(~S),cursor:W.Factory,result:H.World(~S) & W.Reservation<S>) -> String:
  match result:
    case (second,W.Reserved{+foreign}):
      run_again(~S,which,own,foreign,WorldCommands.spawn_apply(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.Payload<S>,~populate_world(~S),second,foreign,H.Payload{ANode{ALeaf{21},ALeaf{22}},"seed",Some{foreign}}),factory_cursor(cursor),H.admit(~S,which,first,operation_target(~S,which,own,foreign),input(~S,which,own,foreign)))
    case _: "second-reserve-failed"
def second_created(~S:Data,which:U32,own:W.Handle<S>,first:H.World(~S),result:W.Creation<S,H.Store(~S),H.Payload<S>,U32>) -> String:
  match result:
    case W.Created{factory,second}:
      second_ready(~S,which,own,first,factory,W.reserve_id(~S,~H.Store(~S),~H.Payload<S>,~U32,second))
    case _: "second-create-failed"
def first_ready(~S:Data,which:U32,factory:W.Factory,result:H.World(~S) & W.Reservation<S>) -> String:
  match result:
    case (first,W.Reserved{+own}):
      second_created(~S,which,own,WorldCommands.spawn_apply(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.Payload<S>,~populate_world(~S),first,own,H.Payload{ANode{ALeaf{11},ALeaf{12}},"seed",Some{own}}),W.create(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.empty(~S),factory,H.Payload{ANode{ALeaf{300},ALeaf{301}},"foreignresource",None{}}))
    case _: "first-reserve-failed"
def first_created(~S:Data,which:U32,result:W.Creation<S,H.Store(~S),H.Payload<S>,U32>) -> String:
  match result:
    case W.Created{factory,first}:
      first_ready(~S,which,factory,W.reserve_id(~S,~H.Store(~S),~H.Payload<S>,~U32,first))
    case _: "first-create-failed"
def run(~S:Data,which:U32) -> String:
  first_created(~S,which,W.create(~S,~H.Store(~S),~H.Payload<S>,~U32,~H.empty(~S),W.factory(),H.Payload{ANode{ALeaf{100},ALeaf{101}},"resource",None{}}))
def main() -> IO(Unit):
  IO.print(run(~H.First,0) ++ "\n" ++ run(~H.First,1) ++ "\n" ++ run(~H.First,2) ++ "\n" ++ run(~H.First,3) ++ "\n" ++ run(~H.First,4) ++ "\n" ++ run(~H.First,5) ++ "\n" ++ run(~H.First,6) ++ "\n" ++ run(~H.First,7) ++ "\n" ++ run(~H.First,8) ++ "\n" ++ run(~H.First,9) ++ "\n" ++ run(~H.First,10) ++ "\n" ++ run(~H.Second,0) ++ "\n" ++ run(~H.Second,1) ++ "\n" ++ run(~H.Second,2) ++ "\n" ++ run(~H.Second,3) ++ "\n" ++ run(~H.Second,4) ++ "\n" ++ run(~H.Second,5) ++ "\n" ++ run(~H.Second,6) ++ "\n" ++ run(~H.Second,7) ++ "\n" ++ run(~H.Second,8) ++ "\n" ++ run(~H.Second,9) ++ "\n" ++ run(~H.Second,10) ++ "\n")
