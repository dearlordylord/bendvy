import Base
import ./state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource.bend as O
def leaf(~T:Type,result:T & String) -> Array<T> & String:
  (value,text)=result
  (ALeaf{value},"L(" ++ text ++ ")")
def tree_join(~T:Type,a:Array<T>,text:String,result:Array<T> & String) -> Array<T> & String:
  (b,other)=result
  (ANode{a,b},"N(" ++ text ++ "," ++ other ++ ")")
def tree_left(~T:Type,b:Array<T> & String,result:Array<T> & String) -> Array<T> & String:
  (a,text)=result
  tree_join(~T,a,text,b)
def tree(~T:Type,~show:T -> T & String,owner:Array<T>) -> Array<T> & String:
  match owner:
    case ALeaf{value}:leaf(~T,show(value))
    case ANode{a,b}:tree_left(~T,tree(~T,~show,b),tree(~T,~show,a))
def u32_value(+value:U32) -> U32 & String:
  (value,U32.show(value))
def boolean_value(+value:Bool) -> Bool & String:
  (value,Bool.show(value))
def u32(value:U32) -> U32 & String:
  u32_value(value)
def boolean(value:Bool) -> Bool & String:
  boolean_value(value)
def slot_present(~S:Data,result:Array<U32> & String) -> State.Slot(~S) & String:
  match result:
    case (owner,text):(O.Present{owner},"Present(" ++ text ++ ")")
def slot_view(~S:Data,value:State.Slot(~S)) -> State.Slot(~S) & String:
  match value:
    case O.Missing{}:(O.Missing{},"Missing")
    case O.Present{owner}:slot_present(~S,tree(~U32,~u32,owner))
def owners_returned(sibling:Array<U32>,previous:String,result:Array<U32> & String) -> Product.Owner<Array<U32>,Array<U32>> & String:
  match result:
    case (owners,text):(Product.Owner{sibling,owners},previous ++ ",owners=" ++ text)
def sibling_returned(owners:Array<U32>,result:Array<U32> & String) -> Product.Owner<Array<U32>,Array<U32>> & String:
  match result:
    case (sibling,text):owners_returned(sibling,"sibling=" ++ text,tree(~U32,~u32,owners))
def siblings_view(value:Product.Owner<Array<U32>,Array<U32>>) -> Product.Owner<Array<U32>,Array<U32>> & String:
  match value:
    case Product.Owner{sibling,owners}:sibling_returned(owners,tree(~U32,~u32,sibling))
def tail_returned(counter:Array<U32>,previous:String,result:Product.Owner<Array<U32>,Array<U32>> & String) -> State.Tail() & String:
  match result:
    case (siblings,text):(Product.Owner{counter,siblings},previous ++ "," ++ text)
def counter_returned(siblings:Product.Owner<Array<U32>,Array<U32>>,result:Array<U32> & String) -> State.Tail() & String:
  match result:
    case (counter,text):tail_returned(counter,"counter=" ++ text,siblings_view(siblings))
def tail_view(value:State.Tail()) -> State.Tail() & String:
  match value:
    case Product.Owner{counter,siblings}:counter_returned(siblings,tree(~U32,~u32,counter))
def resource_returned(~S:Data,slot:State.Slot(~S),previous:String,result:State.Tail() & String) -> State.Resource(~S) & String:
  match result:
    case (tail,text):(Product.Owner{slot,tail},previous ++ "," ++ text)
def slot_returned(~S:Data,tail:State.Tail(),result:State.Slot(~S) & String) -> State.Resource(~S) & String:
  match result:
    case (slot,text):resource_returned(~S,slot,"payload=" ++ text,tail_view(tail))
def resource(~S:Data,value:State.Resource(~S)) -> State.Resource(~S) & String:
  match value:
    case Product.Owner{slot,tail}:slot_returned(~S,tail,slot_view(~S,slot))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,s=>s,access)
def finished(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,store:Array<U32>,resources:State.Resource(~S),+events:List<&2,U32>,commands:List<(W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,pendingCount:U32,resourceText:String,storeText:String,result:Array<Bool> & String) -> W.World<S,Array<U32>,State.Resource(~S),U32> & String:
  match result:
    case (live,text):(W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock},"world(" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ ",live=" ++ text ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ ",store=" ++ storeText ++ "," ++ resourceText ++ ",events=" ++ List.show(&2,U32,U32.show,events) ++ ",pending=" ++ U32.show(pendingCount) ++ ",regs=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ",nextSystem=" ++ U32.show(nextSystem) ++ ",clock=" ++ U32.show(clock) ++ ")")
def live(~S:Data,pendingCount:U32,resourceText:String,storeText:String,world:W.World<S,Array<U32>,State.Resource(~S),U32>) -> W.World<S,Array<U32>,State.Resource(~S),U32> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:finished(~S,ns,next,high,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock,pendingCount,resourceText,storeText,tree(~Bool,~boolean,live))
def stored(~S:Data,pendingCount:U32,resourceText:String,result:W.World<S,Array<U32>,State.Resource(~S),U32> & String) -> W.World<S,Array<U32>,State.Resource(~S),U32> & String:
  match result:
    case (world,storeText):live(~S,pendingCount,resourceText,storeText,world)
def resourced(~S:Data,pendingCount:U32,result:W.World<S,Array<U32>,State.Resource(~S),U32> & String) -> W.World<S,Array<U32>,State.Resource(~S),U32> & String:
  match result:
    case (world,text):stored(~S,pendingCount,text,W.with_store(~S,~Array<U32>,~State.Resource(~S),~U32,~String,tree(~U32,~u32_value),world))
def counted(~S:Data,result:W.World<S,Array<U32>,State.Resource(~S),U32> & U32) -> W.World<S,Array<U32>,State.Resource(~S),U32> & String:
  match result:
    case (world,count):resourced(~S,count,W.observe_resource(~S,~Array<U32>,~State.Resource(~S),~U32,~String,~resource(~S),world))
def world(~S:Data,world:W.World<S,Array<U32>,State.Resource(~S),U32>) -> W.World<S,Array<U32>,State.Resource(~S),U32> & String:
  counted(~S,W.pending_count(~S,~Array<U32>,~State.Resource(~S),~U32,world))
