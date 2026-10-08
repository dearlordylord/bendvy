import Base
import fixture-state.bend as State
import root-source/world.bend as W
import root-source/machine.bend as M
import root-source/machine-stream.bend as St
import root-source/event-runtime.bend as Ev

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
def pending(value:M.Pending<U32>) -> String:
  match value:
    case M.NoPending{}:"none"
    case M.Queued{value,skip}:"next(" ++ U32.show(value) ++ "," ++ Bool.show(skip) ++ ")"
def previous(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:U32.show(value)
def slot(~S:Data,~K:Data,value:M.Slot<S,K,U32>) -> String:
  match value:
    case M.Missing{}:"missing"
    case M.Present{current,next,old,changed}:"slot(" ++ U32.show(current) ++ "," ++ pending(next) ++ "," ++ previous(old) ++ "," ++ Bool.show(changed) ++ ")"
def transition(value:M.Transition<U32>) -> String:
  match value:
    case M.Transition{a,b}:U32.show(a) ++ ">" ++ U32.show(b)
def batch(value:Ev.Batch<M.Transition<U32>>) -> String:
  match value:
    case Ev.Batch{tick,items}:Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<U32>,transition,items)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def stream(value:St.Stream<U32>) -> String:
  match value:
    case St.Stream{batches,positions,dropped,start}:"stream(" ++ List.show(&2,Ev.Batch<M.Transition<U32>>,batch,batches) ++ "," ++ List.show(&2,Ev.Position,position,positions) ++ "," ++ Nat.show(dropped) ++ "," ++ Nat.show(start) ++ ")"
def resource_done(~S:Data,+flow:M.Slot<S,State.FlowToken,U32>,+level:M.Slot<S,State.LevelToken,U32>,+ran:U32,+flowStream:St.Stream<U32>,+levelStream:St.Stream<U32>,result:Array<U32> & String) -> State.Resources<S> & String:
  match result:
    case (owned,text):(State.Resources{owned,flow,level,ran,flowStream,levelStream},text ++ ";" ++ slot(~S,~State.FlowToken,flow) ++ ";" ++ slot(~S,~State.LevelToken,level) ++ ";ran=" ++ U32.show(ran) ++ ";" ++ stream(flowStream) ++ ";" ++ stream(levelStream))
def resources(~S:Data,resources:State.Resources<S>) -> State.Resources<S> & String:
  match resources:
    case State.Resources{owned,flow,level,ran,flowStream,levelStream}:resource_done(~S,flow,level,ran,flowStream,levelStream,tree(~U32,~u32,owned))
def store_done(~S:Data,result:Array<U32> & String) -> State.Store<S> & String:
  (cells,text)=result
  (State.Store{cells},text)
def store(~S:Data,value:State.Store<S>) -> State.Store<S> & String:
  match value:
    case State.Store{cells}:store_done(~S,tree(~U32,~u32,cells))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def finished(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,store:State.Store<S>,resources:State.Resources<S>,+events:List<&2,U32>,commands:List<(W.World<S,State.Store<S>,State.Resources<S>,U32> -> W.World<S,State.Store<S>,State.Resources<S>,U32>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,pendingCount:U32,resourceText:String,storeText:String,result:Array<Bool> & String) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & String:
  (live,text)=result
  (W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock},"world(" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ text ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ "," ++ storeText ++ "," ++ resourceText ++ ",events=" ++ List.show(&2,U32,U32.show,events) ++ ",pending=" ++ U32.show(pendingCount) ++ ",regs=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ",nextSystem=" ++ U32.show(nextSystem) ++ ",clock=" ++ U32.show(clock) ++ ")")
def live(~S:Data,pendingCount:U32,resourceText:String,storeText:String,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:finished(~S,ns,next,high,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock,pendingCount,resourceText,storeText,tree(~Bool,~boolean,live))
def stored(~S:Data,pendingCount:U32,resourceText:String,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & String:
  (world,storeText)=result
  live(~S,pendingCount,resourceText,storeText,world)
def resourced(~S:Data,pendingCount:U32,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & String:
  (world,text)=result
  stored(~S,pendingCount,text,W.with_store(~S,~State.Store<S>,~State.Resources<S>,~U32,~String,store(~S),world))
def counted(~S:Data,result:W.World<S,State.Store<S>,State.Resources<S>,U32> & U32) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & String:
  (world,count)=result
  resourced(~S,count,W.observe_resource(~S,~State.Store<S>,~State.Resources<S>,~U32,~String,~resources(~S),world))
def world(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & String:
  counted(~S,W.pending_count(~S,~State.Store<S>,~State.Resources<S>,~U32,world))
