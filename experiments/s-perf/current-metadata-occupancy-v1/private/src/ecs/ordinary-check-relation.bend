import Base
import ./ordinary-check-declaration.bend as D
import ./ordinary-inspector-relation.bend as Decl
import ./ordinary-check-query.bend as CQ
import ./relation-types.bend as G
import ./relation-query.bend as RQ
import ./relation-commands.bend as A
import ./check.bend as K
import ./inspector-query.bend as Query
import ./inspector-query-projection.bend as Select

# All metadata comes from the same closed operational declaration.
def kind(value:G.RelationKind) -> D.RelationKind:
  match value:
    case G.Ordinary{}:D.Ordinary{}
    case G.Hierarchy{}:D.Hierarchy{}
def identity(~S:Data,value:G.Descriptor<S>) -> D.RelationIdentity:
  match value:
    case G.Descriptor{id,name,inverseName,relationKind}:D.RelationIdentity{id,name,inverseName,kind(relationKind)}
def category(value:D.RelationIdentity,mode:Decl.Mode) -> D.Category:
  match mode:
    case Decl.RequiredOut{key}:D.Relation{value,D.Outgoing{},D.RelationRequired{},Some{key}}
    case Decl.OptionalOut{key}:D.Relation{value,D.Outgoing{},D.RelationOptional{},Some{key}}
    case Decl.PresentOut{}:D.Relation{value,D.Outgoing{},D.RelationPresent{},None{}}
    case Decl.AbsentOut{}:D.Relation{value,D.Outgoing{},D.RelationAbsent{},None{}}
    case Decl.RequiredIn{key}:D.Relation{value,D.Incoming{},D.RelationRequired{},Some{key}}
    case Decl.OptionalIn{key}:D.Relation{value,D.Incoming{},D.RelationOptional{},Some{key}}
    case Decl.PresentIn{}:D.Relation{value,D.Incoming{},D.RelationPresent{},None{}}
    case Decl.AbsentIn{}:D.Relation{value,D.Incoming{},D.RelationAbsent{},None{}}
def use_named(value:D.RelationIdentity,mode:Decl.Mode) -> D.Use:
  match value:
    case D.RelationIdentity{id,+name,inverseName,kind}:D.Use{category(D.RelationIdentity{id,name,inverseName,kind},mode),name,D.Read{},False{}}
def use(~S:Data,value:Decl.Declaration<S>) -> D.Use:
  match value:
    case Decl.Declaration{source,mode}:use_named(identity(~S,Decl.descriptor(~S,source)),mode)
# Structural graph storage is already present in A.Store. No extra World-owned
# parameter is admitted here; required relation clauses retain row membership.
def declaration(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~component:CQ.Selection<K.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,S,V>,~relation:Decl.Declaration<S>) -> D.Declaration<S,A.Store<S,C>,R,A.Notice<S,E>,CQ.Ops(~S,~Select.Product<V,List<&2,RQ.Cell<S>>>)>:
  D.Declaration{K.Plan{D.provided(~S,~A.Store<S,C>,~R,~A.Notice<S,E>),CQ.Read{Decl.condition(~S,~C,~R,~E,~V,~CQ.selected(~K.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S,~V,component),~relation)}},List.append(&2,D.Use,CQ.uses(~K.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S,~V,component),[use(~S,relation)])}
