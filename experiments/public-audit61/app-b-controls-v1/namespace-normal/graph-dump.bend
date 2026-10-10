import Base
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
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
