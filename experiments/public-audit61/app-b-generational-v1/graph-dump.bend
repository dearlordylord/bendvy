import Base
import ../../../src/ecs/entity-key.bend as Key
import ../../public-identity/generational-reuse-v1/fixture.bend as Identity
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/machine.bend as M
import ../../../src/ecs/machine-stream.bend as St
import ../../../src/ecs/event-runtime.bend as Ev

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
    case M.Initial{value}:"initial:" ++ U32.show(value)
    case M.Transition{a,b}:U32.show(a) ++ ">" ++ U32.show(b)
def batch(value:Ev.Batch<M.Transition<U32>>) -> String:
  match value:
    case Ev.Batch{tick,items}:Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<U32>,transition,items)
def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def stream_snapshot(value:List<&2,Ev.Batch<M.Transition<U32>>> & (List<&2,Ev.Position> & (Nat & Nat))) -> String:
  match value:
    case (batches,(positions,(dropped,start))):"stream(" ++ List.show(&2,Ev.Batch<M.Transition<U32>>,batch,batches) ++ "," ++ List.show(&2,Ev.Position,position,positions) ++ "," ++ Nat.show(dropped) ++ "," ++ Nat.show(start) ++ ")"
def stream(value:St.Stream<U32>) -> String:stream_snapshot(St.snapshot(~U32,value))
def relation_kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"ordinary"
    case G.Hierarchy{}:"hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverseName,kind}:U32.show(key) ++ ":" ++ name ++ ":" ++ inverseName ++ ":" ++ relation_kind(kind)
def edge(~S:Data,value:G.Edge<S>) -> String:
  match value:
    case G.Edge{relation,source,target}:descriptor(~S,relation) ++ ":" ++ Identity.key_text(source) ++ ">" ++ Identity.key_text(target)
def inverse(~S:Data,value:G.Inverse<S>) -> String:
  match value:
    case G.Inverse{relation,target,sources}:descriptor(~S,relation) ++ ":" ++ Identity.key_text(target) ++ ":" ++ List.show(&2,Key.Key,Identity.key_text,sources)
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
    case G.MissingEntity{source}:"missingEntity:" ++ Identity.key_text(source)
    case G.MissingTargetEntity{source,target,relation}:"missingTarget:" ++ Identity.key_text(source) ++ ":" ++ Identity.key_text(target) ++ ":" ++ relation
    case G.SelfRelationNotAllowed{source,relation}:"selfRelation:" ++ Identity.key_text(source) ++ ":" ++ relation
    case G.HierarchyCycle{source,target,relation}:"hierarchyCycle:" ++ Identity.key_text(source) ++ ":" ++ Identity.key_text(target) ++ ":" ++ relation
    case G.MissingChildEntity{source,child,relation}:"missingChild:" ++ Identity.key_text(source) ++ ":" ++ Identity.key_text(child) ++ ":" ++ relation
    case G.DuplicateChild{source,child,relation}:"duplicateChild:" ++ Identity.key_text(source) ++ ":" ++ Identity.key_text(child) ++ ":" ++ relation
    case G.ChildNotRelatedToParent{source,child,relation}:"childNotRelated:" ++ Identity.key_text(source) ++ ":" ++ Identity.key_text(child) ++ ":" ++ relation
    case G.ChildSetMismatch{source,relation}:"childSetMismatch:" ++ Identity.key_text(source) ++ ":" ++ relation
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{relation,op,source,target,error}:descriptor(~S,relation) ++ ":" ++ operation(op) ++ ":" ++ Identity.key_text(source) ++ ":" ++ Identity.key_text(target) ++ ":" ++ relation_error(error)
def cleanup(~S:Data,value:G.CleanupFrame<S>) -> String:
  match value:
    case G.CleanupEnter{id}:"enter:" ++ Identity.key_text(id)
    case G.CleanupDescriptors{id,remaining}:"descriptors:" ++ Identity.key_text(id) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining)
    case G.CleanupChildren{id,relation,remaining,children}:"children:" ++ Identity.key_text(id) ++ ":" ++ descriptor(~S,relation) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ ":" ++ List.show(&2,Key.Key,Identity.key_text,children)
    case G.CleanupFinish{id}:"finish:" ++ Identity.key_text(id)
def notice(~S:Data,value:A.Notice<S,U32>) -> String:
  match value:
    case A.Original{value}:"user:" ++ U32.show(value)
    case A.RelationFailed{value}:"relationFailed:" ++ failure(~S,value)
    case A.ComponentRemoved{id}:"componentRemoved:" ++ Identity.key_text(id)
    case A.CleanupPaused{frames}:"cleanupPaused:" ++ List.show(&2,G.CleanupFrame<S>,cleanup(~S),frames)
