import Base
import ./trace-facts.bend as Facts
import ./relation-types.bend as G
import ./world.bend as W
import ./entity-key.bend as Key
import ./entity-key-render.bend as Render

def kind(value:G.RelationKind) -> Facts.RelationKind:
  match value:
    case G.Ordinary{}:Facts.OrdinaryRelation{}
    case G.Hierarchy{}:Facts.HierarchyRelation{}
def identity(~S:Data,value:G.Descriptor<S>) -> Facts.RelationIdentity:
  match value:
    case G.Descriptor{id,name,inverseName,value}:Facts.RelationIdentity{id,name,inverseName,kind(value)}
def handle(~S:Data,target:W.Handle<S>) -> Facts.HandleValue:
  match target:
    case W.Handle{namespace,+key}:Facts.HandleValue{namespace,Key.index(key),Key.generation(key)}
def error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{source}:"MissingEntity:" ++ Render.show(source)
    case G.MissingTargetEntity{source,target,name}:"MissingTargetEntity:" ++ Render.show(source) ++ ":" ++ Render.show(target) ++ ":" ++ name
    case G.SelfRelationNotAllowed{source,name}:"SelfRelationNotAllowed:" ++ Render.show(source) ++ ":" ++ name
    case G.HierarchyCycle{source,target,name}:"HierarchyCycle:" ++ Render.show(source) ++ ":" ++ Render.show(target) ++ ":" ++ name
    case G.MissingChildEntity{source,child,name}:"MissingChildEntity:" ++ Render.show(source) ++ ":" ++ Render.show(child) ++ ":" ++ name
    case G.DuplicateChild{source,child,name}:"DuplicateChild:" ++ Render.show(source) ++ ":" ++ Render.show(child) ++ ":" ++ name
    case G.ChildNotRelatedToParent{source,child,name}:"ChildNotRelatedToParent:" ++ Render.show(source) ++ ":" ++ Render.show(child) ++ ":" ++ name
    case G.ChildSetMismatch{source,name}:"ChildSetMismatch:" ++ Render.show(source) ++ ":" ++ name
def outcome(value:Maybe<&2,G.Error>) -> Facts.FactResult:
  match value:
    case None{}:Facts.Applied{}
    case Some{why}:Facts.Refused{error(why)}
def relate(~S:Data,state:Facts.State,descriptor:G.Descriptor<S>,operation:Facts.Operation,source:W.Handle<S>,target:W.Handle<S>,result:Facts.FactResult) -> Facts.State:
  match state:
    case Facts.Off{}:Facts.Off{}
    case Facts.On{facts}:Facts.On{Facts.RelationFact{identity(~S,descriptor),operation,handle(~S,source),Facts.RelateAction{handle(~S,target)},result} <> facts}
def relate_applied(~S:Data,state:Facts.State,descriptor:G.Descriptor<S>,source:W.Handle<S>,target:W.Handle<S>,error:Maybe<&2,G.Error>) -> Facts.State:
  match state:
    case Facts.Off{}:Facts.Off{}
    case state:relate(~S,state,descriptor,Facts.ApplyOperation{},source,target,outcome(error))
def unrelate(~S:Data,state:Facts.State,descriptor:G.Descriptor<S>,operation:Facts.Operation,source:W.Handle<S>,result:Facts.FactResult) -> Facts.State:
  match state:
    case Facts.Off{}:Facts.Off{}
    case Facts.On{facts}:Facts.On{Facts.RelationFact{identity(~S,descriptor),operation,handle(~S,source),Facts.UnrelateAction{},result} <> facts}
def handles(~S:Data,targets:List<&2,W.Handle<S>>) -> List<&2,Facts.HandleValue>:
  match targets:
    case []:[]
    case target <> rest:handle(~S,target) <> handles(~S,rest)
def reorder(~S:Data,state:Facts.State,descriptor:G.Descriptor<S>,operation:Facts.Operation,parent:W.Handle<S>,children:List<&2,W.Handle<S>>,result:Facts.FactResult) -> Facts.State:
  match state:
    case Facts.Off{}:Facts.Off{}
    case Facts.On{facts}:Facts.On{Facts.RelationFact{identity(~S,descriptor),operation,handle(~S,parent),Facts.ReorderAction{handles(~S,children)},result} <> facts}
def reorder_applied(~S:Data,state:Facts.State,descriptor:G.Descriptor<S>,parent:W.Handle<S>,children:List<&2,W.Handle<S>>,error:Maybe<&2,G.Error>) -> Facts.State:
  match state:
    case Facts.Off{}:Facts.Off{}
    case state:reorder(~S,state,descriptor,Facts.ApplyOperation{},parent,children,outcome(error))
