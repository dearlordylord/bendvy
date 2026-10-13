import Base
import application.bend as A
import handle-application.bend as H
import application-controls.bend as O
import controls.bend as Old
import typed.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/column.bend as Col
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/lifecycle.bend as L
# Each operation observes both actual same-schema Worlds, every Array owner,
# allocator, lifecycle stamp and drained prior queue. No namespace is guessed.
def target_text(~S:Data,target:Maybe<&2,W.Handle<S>>) -> String:
  match target:
    case None{}: "null"
    case Some{W.Handle{ns,id}}: U32.show(ns) ++ ":" ++ U32.show(id)
def cells(owner:Array<U32>) -> String:
  match owner:
    case ALeaf{value}: U32.show(value) ++ ","
    case ANode{left,right}: cells(left) ++ cells(right)
def payload(~S:Data,payload:H.Payload<S>) -> String:
  match payload:
    case H.Payload{owner,name,target}: name ++ ":" ++ cells(owner) ++ ":" ++ target_text(~S,target)
def maybe(~S:Data,owner:Maybe<&1,H.Payload<S>>) -> String:
  match owner:
    case None{}: "none;"
    case Some{value}: payload(~S,value) ++ ";"
def values(~S:Data,cells:Array<Maybe<&1,H.Payload<S>>>) -> String:
  match cells:
    case ALeaf{owner}: maybe(~S,owner)
    case ANode{left,right}: values(~S,left) ++ values(~S,right)
def bools(cells:Array<Bool>) -> String:
  match cells:
    case ALeaf{True{}}: "1"
    case ALeaf{False{}}: "0"
    case ANode{left,right}: bools(left) ++ bools(right)
def stamps(entries:List<&2,L.Entry>) -> String:
  match entries:
    case []: ""
    case L.Entry{id,L.Stamp{added,changed}} <> tail: U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed) ++ ";" ++ stamps(tail)
def retired(~S:Data,owners:List<H.Payload<S>>) -> String:
  match owners:
    case []: ""
    case owner <> tail: payload(~S,owner) ++ ";" ++ retired(~S,tail)
def regs(entries:List<&2,W.RegistrationMeta>) -> String:
  match entries:
    case []: ""
    case W.RegistrationMeta{id,name,access} <> tail: U32.show(id) ++ name ++ List.show(&2,String,(x => x),access) ++ regs(tail)
def snapshot(~S:Data,world:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>) -> String:
  match world:
    case W.World{ns,next,high,live,cap,depth,Col.Column{cells,entries},H.Resources{value,rest},events,pending,registrations,system,clock}: U32.show(ns) ++ "/" ++ U32.show(next) ++ "/" ++ U32.show(high) ++ "/" ++ bools(live) ++ "/" ++ U32.show(cap) ++ "/" ++ Nat.show(depth) ++ "/" ++ values(~S,cells) ++ "/" ++ stamps(entries) ++ "/" ++ payload(~S,value) ++ "/" ++ retired(~S,rest) ++ "/" ++ List.show(&2,U32,U32.show,events) ++ "/" ++ Nat.show(List.length(&1,(W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32> -> W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>),pending)) ++ "/" ++ regs(registrations) ++ "/" ++ U32.show(system) ++ "/" ++ U32.show(clock)
    case _: "unexpected-column"
def pair_cells(a:U32,b:U32) -> Array<U32>:
  ANode{ALeaf{a},ALeaf{b}}
def incoming(~S:Data,target:Maybe<&2,W.Handle<S>>) -> H.Payload<S>:
  H.Payload{ANode{pair_cells(41,42),pair_cells(43,44)},"incoming",target}
def rendered(~S:Data,foreign:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>,cursor:U32,result:H.Outcome<S>) -> String:
  match result:
    case H.Outcome{world,refused,+checked,status}: Old.checked(checked) ++ O.canonical_keys(checked) ++ "|" ++ maybe(~S,refused) ++ "|host:" ++ O.host(status) ++ "|" ++ snapshot(~S,W.barrier(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,world)) ++ "|foreign:" ++ snapshot(~S,foreign) ++ "|factory:" ++ U32.show(cursor)
def selected(~S:Data,which:U32,+own:W.Handle<S>,foreign:W.Handle<S>) -> Maybe<&2,W.Handle<S>>:
  match which:
    case 0: Some{foreign}
    case 1: Some{foreign}
    case 2: Some{foreign}
    case 3: match own:
      case W.Handle{ns,_}: Some{W.Handle{ns,0}}
    case 4: match own:
      case W.Handle{ns,_}: Some{W.Handle{ns,0}}
    case 5: match own:
      case W.Handle{ns,_}: Some{W.Handle{ns,0}}
    case 10: None{}
    case _: Some{own}
def route(which:U32) -> U32:
  match which:
    case 0: 0
    case 3: 0
    case 6: 0
    case 1: 1
    case 4: 1
    case 7: 1
    case 9: 1
    case _: 2
def operation_target(~S:Data,which:U32,own:W.Handle<S>,foreign:W.Handle<S>) -> W.Handle<S>:
  match which:
    case 9: foreign
    case _: own
def operation(~S:Data,+which:U32,+own:W.Handle<S>,+foreign:W.Handle<S>,first:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>,second:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>,cursor:U32) -> String:
  rendered(~S,second,cursor,H.admit(~S,route(which),operation_target(~S,which,own,foreign),first,incoming(~S,selected(~S,which,own,foreign))))
def marker(~S:Data,world:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>) -> W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>:
  W.event_publish(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,world,[77])
def pending(~S:Data,+which:U32,+own:W.Handle<S>,+foreign:W.Handle<S>,second:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>,cursor:U32,result:H.Outcome<S>) -> String:
  match result:
    case H.Outcome{first,refused,_,_}: operation(~S,which,own,foreign,W.enqueue(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,first,w => marker(~S,w)),second,cursor)
def second_reserved(~S:Data,+which:U32,+own:W.Handle<S>,first:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>,cursor:U32,result:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32> & W.Reservation<S>) -> String:
  match result:
    case (second,W.Reserved{+foreign}): pending(~S,which,own,foreign,Cmd.spawn_apply(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,~H.Payload<S>,~H.populate(~S),second,foreign,H.Payload{pair_cells(21,22),"seed",Some{foreign}}),cursor,H.admit(~S,0,own,first,H.Payload{ANode{pair_cells(31,32),pair_cells(33,34)},"queued",Some{own}}))
    case _: "second-reserve-failed"
def second_created(~S:Data,+which:U32,+own:W.Handle<S>,first:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>,result:W.Creation<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>) -> String:
  match result:
    case W.Created{W.Factory{cursor},second}: second_reserved(~S,which,own,first,cursor,W.reserve_id(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,second))
    case _: "second-create-failed"
def first_reserved(~S:Data,+which:U32,factory:W.Factory,result:W.World<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32> & W.Reservation<S>) -> String:
  match result:
    case (first,W.Reserved{+own}): second_created(~S,which,own,Cmd.spawn_apply(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,~H.Payload<S>,~H.populate(~S),first,own,H.Payload{pair_cells(11,12),"seed",Some{own}}),W.create(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,~H.empty(~S),factory,H.Resources{H.Payload{pair_cells(300,301),"foreignresource",None{}},[]}))
    case _: "first-reserve-failed"
def first_created(~S:Data,+which:U32,result:W.Creation<S,Col.Column<S,H.Payload<S>>,H.Resources<S>,U32>) -> String:
  match result:
    case W.Created{factory,first}: first_reserved(~S,which,factory,W.reserve_id(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,first))
    case _: "first-create-failed"
def run(~S:Data,which:U32) -> String:
  first_created(~S,which,W.create(~S,~Col.Column<S,H.Payload<S>>,~H.Resources<S>,~U32,~H.empty(~S),W.factory(),H.Resources{H.Payload{pair_cells(100,101),"resource",None{}},[]}))
def main() -> IO(Unit):
  IO.print(run(~A.First,0) ++ "\n" ++ run(~A.First,1) ++ "\n" ++ run(~A.First,2) ++ "\n" ++ run(~A.First,3) ++ "\n" ++ run(~A.First,4) ++ "\n" ++ run(~A.First,5) ++ "\n" ++ run(~A.First,6) ++ "\n" ++ run(~A.First,7) ++ "\n" ++ run(~A.First,8) ++ "\n" ++ run(~A.First,9) ++ "\n" ++ run(~A.First,10) ++ "\n" ++ run(~A.Second,0) ++ "\n" ++ run(~A.Second,1) ++ "\n" ++ run(~A.Second,2) ++ "\n" ++ run(~A.Second,3) ++ "\n" ++ run(~A.Second,4) ++ "\n" ++ run(~A.Second,5) ++ "\n" ++ run(~A.Second,6) ++ "\n" ++ run(~A.Second,7) ++ "\n" ++ run(~A.Second,8) ++ "\n" ++ run(~A.Second,9) ++ "\n" ++ run(~A.Second,10))
