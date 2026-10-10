import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import ./state.bend as State
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev

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
def resource_done(~S:Data,result:Array<U32> & String) -> State.Resources<S> & String:
  (cells,text)=result
  (State.Resources{cells},text)
def resources(~S:Data,value:State.Resources<S>) -> State.Resources<S> & String:
  match value:
    case State.Resources{cells}:resource_done(~S,tree(~U32,~u32,cells))
def components(~S:Data,value:Unit) -> Unit & String:
  (value,"Unit")
def relation_kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"ordinary"
    case G.Hierarchy{}:"hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverseName,kind}:U32.show(key) ++ ":" ++ name ++ ":" ++ inverseName ++ ":" ++ relation_kind(kind)
def edge(~S:Data,value:G.Edge<S>) -> String:
  match value:
    case G.Edge{relation,source,target}:descriptor(~S,relation) ++ ":" ++ U32.show(source) ++ ">" ++ U32.show(target)
def inverse(~S:Data,value:G.Inverse<S>) -> String:
  match value:
    case G.Inverse{relation,target,sources}:descriptor(~S,relation) ++ ":" ++ U32.show(target) ++ ":" ++ List.show(&2,U32,U32.show,sources)
def graph(~S:Data,value:G.Graph<S>) -> String:
  match value:
    case G.Graph{edges,inverses}:List.show(&2,G.Edge<S>,edge(~S),edges) ++ ";" ++ List.show(&2,G.Inverse<S>,inverse(~S),inverses)
def store_done(~S:Data,+relations:G.Graph<S>,observed:Unit & String) -> A.Store<S,Unit> & String:
  (components,text)=observed
  (A.Store{components,relations},text ++ ";graph=" ++ graph(~S,relations))
def store(~S:Data,value:A.Store<S,Unit>) -> A.Store<S,Unit> & String:
  match value:
    case A.Store{owner,relations}:store_done(~S,relations,components(~S,owner))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def operation(value:G.Operation) -> String:
  match value:
    case G.Relate{}:"relate"
    case G.ReorderChildren{}:"reorderChildren"
def relation_error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{source}:"missingEntity:" ++ U32.show(source)
    case G.MissingTargetEntity{source,target,relation}:"missingTarget:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ relation
    case G.SelfRelationNotAllowed{source,relation}:"selfRelation:" ++ U32.show(source) ++ ":" ++ relation
    case G.HierarchyCycle{source,target,relation}:"hierarchyCycle:" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ relation
    case G.MissingChildEntity{source,child,relation}:"missingChild:" ++ U32.show(source) ++ ":" ++ U32.show(child) ++ ":" ++ relation
    case G.DuplicateChild{source,child,relation}:"duplicateChild:" ++ U32.show(source) ++ ":" ++ U32.show(child) ++ ":" ++ relation
    case G.ChildNotRelatedToParent{source,child,relation}:"childNotRelated:" ++ U32.show(source) ++ ":" ++ U32.show(child) ++ ":" ++ relation
    case G.ChildSetMismatch{source,relation}:"childSetMismatch:" ++ U32.show(source) ++ ":" ++ relation
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{relation,op,source,target,error}:descriptor(~S,relation) ++ ":" ++ operation(op) ++ ":" ++ U32.show(source) ++ ":" ++ U32.show(target) ++ ":" ++ relation_error(error)
def cleanup(~S:Data,value:G.CleanupFrame<S>) -> String:
  match value:
    case G.CleanupEnter{id}:"enter:" ++ U32.show(id)
    case G.CleanupDescriptors{id,remaining}:"descriptors:" ++ U32.show(id) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining)
    case G.CleanupChildren{id,relation,remaining,children}:"children:" ++ U32.show(id) ++ ":" ++ descriptor(~S,relation) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ ":" ++ List.show(&2,U32,U32.show,children)
    case G.CleanupFinish{id}:"finish:" ++ U32.show(id)
def notice(~S:Data,value:A.Notice<S,U32>) -> String:
  match value:
    case A.Original{value}:"user:" ++ U32.show(value)
    case A.RelationFailed{value}:"relationFailed:" ++ failure(~S,value)
    case A.ComponentRemoved{id}:"componentRemoved:" ++ U32.show(id)
    case A.CleanupPaused{frames}:"cleanupPaused:" ++ List.show(&2,G.CleanupFrame<S>,cleanup(~S),frames)
def finished(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,store:A.Store<S,Unit>,resources:State.Resources<S>,+events:List<&2,A.Notice<S,U32>>,commands:List<(W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> -> W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,pendingCount:U32,resourceText:String,storeText:String,result:Array<Bool> & String) -> W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String:
  (live,text)=result
  (W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock},"world(" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ U32.show(high) ++ "," ++ text ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ "," ++ storeText ++ "," ++ resourceText ++ ",events=" ++ List.show(&2,A.Notice<S,U32>,notice(~S),events) ++ ",pending=" ++ U32.show(pendingCount) ++ ",regs=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ",nextSystem=" ++ U32.show(nextSystem) ++ ",clock=" ++ U32.show(clock) ++ ")")
def live(~S:Data,pendingCount:U32,resourceText:String,storeText:String,world:W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:finished(~S,ns,next,high,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock,pendingCount,resourceText,storeText,tree(~Bool,~boolean,live))
def stored(~S:Data,pendingCount:U32,resourceText:String,result:W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String:
  (world,storeText)=result
  live(~S,pendingCount,resourceText,storeText,world)
def resourced(~S:Data,pendingCount:U32,result:W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String:
  (world,text)=result
  stored(~S,pendingCount,text,W.with_store(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,~String,store(~S),world))
def counted(~S:Data,result:W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & U32) -> W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String:
  (world,count)=result
  resourced(~S,count,W.observe_resource(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,~String,~resources(~S),world))
def world(~S:Data,world:W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Unit>,State.Resources<S>,A.Notice<S,U32>> & String:
  counted(~S,W.pending_count(~S,~A.Store<S,Unit>,~State.Resources<S>,~A.Notice<S,U32>,world))
