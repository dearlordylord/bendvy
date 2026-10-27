import Base
import ./entity-allocator.bend as A
import ./entity-key.bend as K
import ./world.bend as W
import ./relation-types.bend as T
import ./relation-graph.bend as Graph
import ./relation-reorder-core.bend as Reorder
import ./execution-relation-operation.bend as O

# Trusted barrier seam. Namespace and allocator must come from the same actual
# Administration owner; this module does not grant gameplay graph authority.
def live_namespace(~S:Data,same:Bool,allocator:A.Allocator,handle:W.Handle<S>) -> A.Allocator & Bool:
  match same:
    case False{}:(allocator,False{})
    case True{}:A.checked(allocator,W.handle_key(~S,handle),1)
def live(~S:Data,+namespace:U32,allocator:A.Allocator,+handle:W.Handle<S>) -> A.Allocator & Bool:
  match handle:
    case W.Handle{ns,key}:live_namespace(~S,U32.is_eq(namespace,ns),allocator,W.Handle{ns,key})
def result(~S:Data,operation:O.Operation<S>,checked:T.CoreResult<S>) -> O.Outcome<S>:
  match checked:
    case T.CoreResult{graph,None{}}:O.Applied{graph,operation}
    case T.CoreResult{graph,Some{error}}:O.Refused{graph,operation,O.RelationError{error}}
def relate_target(~S:Data,graph:T.Graph<S>,descriptor:T.Descriptor<S>,+source:W.Handle<S>,+target:W.Handle<S>,sourceLive:Bool,checked:A.Allocator & Bool) -> A.Allocator & O.Outcome<S>:
  match checked:
    case (allocator,targetLive):(allocator,result(~S,O.Relate{source,target},Graph.relate(~S,graph,descriptor,W.handle_key(~S,source),W.handle_key(~S,target),sourceLive,targetLive)))
def relate_source(~S:Data,+namespace:U32,graph:T.Graph<S>,descriptor:T.Descriptor<S>,source:W.Handle<S>,+target:W.Handle<S>,checked:A.Allocator & Bool) -> A.Allocator & O.Outcome<S>:
  match checked:
    case (allocator,sourceLive):relate_target(~S,graph,descriptor,source,target,sourceLive,live(~S,namespace,allocator,target))
def unrelate_checked(~S:Data,graph:T.Graph<S>,descriptor:T.Descriptor<S>,+source:W.Handle<S>,checked:A.Allocator & Bool) -> A.Allocator & O.Outcome<S>:
  match checked:
    case (allocator,False{}):(allocator,O.Refused{graph,O.Unrelate{source},O.RelationError{T.MissingEntity{W.handle_key(~S,source)}}})
    case (allocator,True{}):(allocator,O.Applied{Graph.unrelate(~S,graph,descriptor,W.handle_key(~S,source)),O.Unrelate{source}})
def child_next(key:K.Key,reversed:List<&2,T.ChildStatus>,next:A.Allocator -> List<&2,T.ChildStatus> -> A.Allocator & List<&2,T.ChildStatus>,checked:A.Allocator & Bool) -> A.Allocator & List<&2,T.ChildStatus>:
  match checked:
    case (allocator,isLive):next(allocator,T.ChildStatus{key,isLive} <> reversed)
def children_checked(~S:Data,+namespace:U32,children:List<&2,W.Handle<S>>,allocator:A.Allocator,reversed:List<&2,T.ChildStatus>) -> A.Allocator & List<&2,T.ChildStatus>:
  match children:
    case []:(allocator,List.reverse(&2,T.ChildStatus,reversed))
    case +child <> rest:child_next(W.handle_key(~S,child),reversed,allocator => reversed => children_checked(~S,namespace,rest,allocator,reversed),live(~S,namespace,allocator,child))
def reorder_children(~S:Data,graph:T.Graph<S>,descriptor:T.Descriptor<S>,+parent:W.Handle<S>,+children:List<&2,W.Handle<S>>,parentLive:Bool,checked:A.Allocator & List<&2,T.ChildStatus>) -> A.Allocator & O.Outcome<S>:
  match checked:
    case (allocator,statuses):(allocator,result(~S,O.Reorder{parent,children},Reorder.reorder(~S,graph,descriptor,W.handle_key(~S,parent),statuses,parentLive)))
def reorder_parent(~S:Data,namespace:U32,graph:T.Graph<S>,descriptor:T.Descriptor<S>,parent:W.Handle<S>,+children:List<&2,W.Handle<S>>,checked:A.Allocator & Bool) -> A.Allocator & O.Outcome<S>:
  match checked:
    case (allocator,parentLive):reorder_children(~S,graph,descriptor,parent,children,parentLive,children_checked(~S,namespace,children,allocator,[]))
def reorder(~S:Data,+namespace:U32,allocator:A.Allocator,graph:T.Graph<S>,descriptor:T.Descriptor<S>,+parent:W.Handle<S>,children:List<&2,W.Handle<S>>) -> A.Allocator & O.Outcome<S>:
  match descriptor:
    case T.Descriptor{key,name,inverse,T.Ordinary{}}:(allocator,O.Refused{graph,O.Reorder{parent,children},O.HierarchyRequired{}})
    case T.Descriptor{key,name,inverse,T.Hierarchy{}}:reorder_parent(~S,namespace,graph,T.Descriptor{key,name,inverse,T.Hierarchy{}},parent,children,live(~S,namespace,allocator,parent))
# Bevy ad678262, relationship/mod.rs:28-36 makes the source relationship
# authoritative and maintains its target collection. Existing Bend graph/reorder
# algorithms implement that invariant; dispatch never accepts an inverse writer.
def apply(~S:Data,~descriptor:T.Descriptor<S>,+namespace:U32,allocator:A.Allocator,graph:T.Graph<S>,operation:O.Operation<S>) -> A.Allocator & O.Outcome<S>:
  match operation:
    case O.Relate{+source,target}:relate_source(~S,namespace,graph,descriptor,source,target,live(~S,namespace,allocator,source))
    case O.Unrelate{+source}:unrelate_checked(~S,graph,descriptor,source,live(~S,namespace,allocator,source))
    case O.Reorder{parent,children}:reorder(~S,namespace,allocator,graph,descriptor,parent,children)
