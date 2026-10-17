import Base
import fixture.bend as P
import ../fixture.bend as F
import ../observe.bend as O
import ../owner-observer.bend as D
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/entity-key.bend as K
import ../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-commands.bend as A

def kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"ordinary"
    case G.Hierarchy{}:"hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverse,value}:U32.show(key) ++ ":" ++ name ++ ":" ++ inverse ++ ":" ++ kind(value)
def edge(~S:Data,value:G.Edge<S>) -> String:
  match value:
    case G.Edge{value,source,target}:descriptor(~S,value) ++ ":" ++ F.key_text(source) ++ ">" ++ F.key_text(target)
def inverse(~S:Data,value:G.Inverse<S>) -> String:
  match value:
    case G.Inverse{value,target,sources}:descriptor(~S,value) ++ ":" ++ F.key_text(target) ++ ":" ++ List.show(&2,K.Key,F.key_text,sources)
def graph_text(~S:Data,value:G.Graph<S>) -> String:
  match value:
    case G.Graph{edges,inverses}:List.show(&2,G.Edge<S>,edge(~S),edges) ++ "/" ++ List.show(&2,G.Inverse<S>,inverse(~S),inverses)
def frame(~S:Data,value:G.CleanupFrame<S>) -> String:
  match value:
    case G.CleanupEnter{id}:"Enter:" ++ F.key_text(id)
    case G.CleanupFinish{id}:"Finish:" ++ F.key_text(id)
    case G.CleanupDescriptors{id,remaining}:"Descriptors:" ++ F.key_text(id) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining)
    case G.CleanupChildren{id,value,remaining,children}:"Children:" ++ F.key_text(id) ++ ":" ++ descriptor(~S,value) ++ ":" ++ List.show(&2,G.Descriptor<S>,descriptor(~S),remaining) ++ ":" ++ List.show(&2,K.Key,F.key_text,children)
def frames(~S:Data,values:List<&2,G.CleanupFrame<S>>) -> String:List.show(&2,G.CleanupFrame<S>,frame(~S),values)
def relation_error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{source}:"MissingEntity:" ++ F.key_text(source)
    case G.MissingTargetEntity{source,target,name}:"MissingTarget:" ++ F.key_text(source) ++ ":" ++ F.key_text(target) ++ ":" ++ name
    case G.SelfRelationNotAllowed{source,name}:"SelfRelation:" ++ F.key_text(source) ++ ":" ++ name
    case G.HierarchyCycle{source,target,name}:"HierarchyCycle:" ++ F.key_text(source) ++ ":" ++ F.key_text(target) ++ ":" ++ name
    case G.MissingChildEntity{source,child,name}:"MissingChild:" ++ F.key_text(source) ++ ":" ++ F.key_text(child) ++ ":" ++ name
    case G.DuplicateChild{source,child,name}:"DuplicateChild:" ++ F.key_text(source) ++ ":" ++ F.key_text(child) ++ ":" ++ name
    case G.ChildNotRelatedToParent{source,child,name}:"ChildNotRelated:" ++ F.key_text(source) ++ ":" ++ F.key_text(child) ++ ":" ++ name
    case G.ChildSetMismatch{source,name}:"ChildSetMismatch:" ++ F.key_text(source) ++ ":" ++ name
def operation(value:G.Operation) -> String:
  match value:
    case G.Relate{}:"Relate"
    case G.ReorderChildren{}:"ReorderChildren"
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{value,op,source,target,error}:descriptor(~S,value) ++ ":" ++ operation(op) ++ ":" ++ F.key_text(source) ++ ":" ++ F.key_text(target) ++ ":" ++ relation_error(error)
def notice(~S:Data,value:P.Notice(~S)) -> String:
  match value:
    case A.Original{value}:"Original(" ++ O.notice(~S,value) ++ ")"
    case A.ComponentRemoved{id}:"ComponentRemoved(" ++ F.key_text(id) ++ ")"
    case A.RelationFailed{value}:"RelationFailed(" ++ failure(~S,value) ++ ")"
    case A.CleanupPaused{values}:"CleanupPaused(" ++ frames(~S,values) ++ ")"
def world_join(~S:Data,+ns:U32,+graph:G.Graph<S>,+events:List<&2,P.Notice(~S)>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,allocator:Alloc.Allocator & String,components:F.Store<S> & String,resource:Array<U32> & String,pending:List<(P.World(~S) -> P.World(~S))> & Nat) -> P.World(~S) & String:
  (allocator,at)=allocator
  (components,ct)=components
  (resource,rt)=resource
  (pending,pt)=pending
  (W.World{ns,allocator,A.Store{components,graph},resource,events,pending,regs,sid,clock},"ns=" ++ U32.show(ns) ++ ";allocator={" ++ at ++ "};components={" ++ ct ++ "};graph=" ++ graph_text(~S,graph) ++ ";resource=" ++ rt ++ ";events=" ++ List.show(&2,P.Notice(~S),notice(~S),events) ++ ";pending=" ++ Nat.show(pt) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,D.registration,regs) ++ ";nextSystem=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock))
def world(~S:Data,value:P.World(~S)) -> P.World(~S) & String:
  match value:
    case W.World{ns,allocator,A.Store{components,graph},resource,events,pending,regs,sid,clock}:world_join(~S,ns,graph,events,regs,sid,clock,O.allocator(allocator),O.store(~S,components),D.u32_array(resource),D.callbacks(~P.World(~S),~P.World(~S),pending))
