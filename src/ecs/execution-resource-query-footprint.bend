import ./execution-resource-pair-admission.bend as PairAdmission
import ./execution-query-domain.bend as Domain
import ./execution-query-matches.bend as Match
import Base
import ./execution-resource-admission.bend as Admission
import ./execution-builder.bend as Build
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-query-store.bend as QueryStore
import ./execution-query-partition.bend as Query
import ./execution-query-schema.bend as Schema
import ./execution-query-admission.bend as Grants
import ./execution-resource-store.bend as Store
import ./execution-resource-partition.bend as Resource
import ./execution-resource-split.bend as Split
import ./execution-resource-recipe.bend as Recipe
import ./execution-query-preparation.bend as Checks

import ./execution-resource-description.bend as Description
import ./execution-resource-query-partition.bend as Cut
# Passive metadata projected from the same admitted evidence retained by Leaf.
# This is not an owner and supplies no executable capability.
type Footprint<-S:Data,-components:L.Layout,-resources:L.Layout> is Data:
  Footprint{namespace:U32,handles:List<&2,W.Handle<S>>,componentInfo:List<&2,Schema.Info>,resourceInfo:List<&2,Description.Info>,grants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,queryBook:Schema.Book<S,components>,resourceRecipes:List<&2,Recipe.Entry>}
def capture(~S:Data,~components:L.Layout,~resources:L.Layout,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~Store.Storage<S,resources>,~Ops),evidence:Admission.Evidence<S,components,resources,QueryStore.Storage<S,components>,Store.Storage<S,resources>,Ops,program>) -> Footprint<S,components,resources>:
  match evidence:
    case Admission.Evidence{namespace,handles,_,resourceRecipes,componentInfo,resourceInfo,grants,queryBook,_}:Footprint{namespace,handles,componentInfo,resourceInfo,grants,queryBook,resourceRecipes}
def described(~S:Data,~components:L.Layout,~fullResources:L.Layout,resources:L.resources(~S,fullResources),+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,left:Footprint<S,components,fullResources>,right:Footprint<S,components,fullResources>,description:Schema.Description<S,components>) -> Cut.Partition<S,components,fullResources>:
  match left right description:
    case Footprint{+ln,+lh,+li,_,lg,lq,lr} Footprint{rn,+rh,+ri,_,rg,rq,rr} Schema.Description{columns,+info,valid}:Cut.split(~S,~components,~fullResources,State.Scope{columns,resources,handles,tick,prior,view},ln,lg,rg,info,lq,rq,lr,rr,Bool.and(valid,Bool.and(U32.is_eq(ln,rn),Bool.and(U32.is_eq(ln,Checks.view_namespace(~S,view)),Bool.and(Checks.same_handles(~S,handles,lh),Bool.and(Checks.same_handles(~S,handles,rh),Bool.and(Checks.same_info(info,li),Checks.same_info(info,ri))))))))
def split(~S:Data,~components:L.Layout,~resources:L.Layout,scope:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)>,left:Footprint<S,components,resources>,right:Footprint<S,components,resources>) -> Cut.Partition<S,components,resources>:
  match scope:
    case State.Scope{columns,owners,handles,tick,prior,view}:described(~S,~components,~resources,owners,handles,tick,prior,view,left,right,Schema.describe(~S,components,L.AtLeaf{},columns))
def described_single(~S:Data,~components:L.Layout,~fullResources:L.Layout,resources:L.resources(~S,fullResources),+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,evidence:Footprint<S,components,fullResources>,description:Schema.Description<S,components>) -> Cut.Partition<S,components,fullResources>:
  match evidence description:
    case Footprint{+namespace,+captured,+expected,_,grants,book,recipes} Schema.Description{columns,+info,valid}:Cut.split(~S,~components,~fullResources,State.Scope{columns,resources,handles,tick,prior,view},namespace,grants,[],info,book,Schema.Book{[]},recipes,[],Bool.and(valid,Bool.and(U32.is_eq(namespace,Checks.view_namespace(~S,view)),Bool.and(Checks.same_handles(~S,handles,captured),Checks.same_info(info,expected)))))
def split_single(~S:Data,~components:L.Layout,~resources:L.Layout,scope:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)>,footprint:Footprint<S,components,resources>) -> Cut.Partition<S,components,resources>:
  match scope:
    case State.Scope{columns,owners,handles,tick,prior,view}:described_single(~S,~components,~resources,owners,handles,tick,prior,view,footprint,Schema.describe(~S,components,L.AtLeaf{},columns))
# Composition merges metadata from the same already-admitted actual children.
# Child Evidence/Compilation owners remain in their retained nodes.
def combined_checked(~S:Data,~components:L.Layout,~resources:L.Layout,footprint:Footprint<S,components,resources>,valid:Bool) -> Maybe<&2,Footprint<S,components,resources>>:
  match valid:
    case True{}:Some{footprint}
    case False{}:None{}
def combined(~S:Data,~components:L.Layout,~resources:L.Layout,left:Footprint<S,components,resources>,right:Footprint<S,components,resources>) -> Maybe<&2,Footprint<S,components,resources>>:
  match left right:
    case Footprint{+ln,+lh,+li,ls,lg,Schema.Book{lq},lr} Footprint{rn,rh,ri,_,rg,Schema.Book{rq},rr}:combined_checked(~S,~components,~resources,Footprint{ln,lh,li,ls,List.append(&2,Grants.Granted<S,L.columns(~S,components)>,lg,rg),Schema.Book{List.append(&2,Schema.Entry,lq,rq)},List.append(&2,Recipe.Entry,lr,rr)},Bool.and(U32.is_eq(ln,rn),Bool.and(Checks.same_handles(~S,lh,rh),Checks.same_info(li,ri))))
def combine(~S:Data,~components:L.Layout,~resources:L.Layout,left:Maybe<&2,Footprint<S,components,resources>>,right:Maybe<&2,Footprint<S,components,resources>>) -> Maybe<&2,Footprint<S,components,resources>>:
  match left right:
    case Some{left} Some{right}:combined(~S,~components,~resources,left,right)
    case _ _:None{}
def compatible(~S:Data,~components:L.Layout,~resources:L.Layout,left:Footprint<S,components,resources>,right:Footprint<S,components,resources>) -> Bool:
  match left right:
    case Footprint{_,_,_,_,_,Schema.Book{+lq},lr} Footprint{_,_,_,_,_,Schema.Book{rq},rr}:Bool.and(Bool.not(PairAdmission.query_conflicts(lq,rq,lq)),Recipe.compatible(~resources,lr,rr))
def subtracted(offset:U32,selected:Bool,rest:Domain.Domain) -> Domain.Domain:
  match selected rest:
    case True{} rest:rest
    case False{} Domain.Domain{offsets}:Domain.Domain{offset <> offsets}
def subtract_offsets(+selected:Domain.Domain,offsets:List<&2,U32>) -> Domain.Domain:
  match offsets:
    case []:Domain.Domain{[]}
    case +offset <> rest:subtracted(offset,Domain.contains(selected,offset),subtract_offsets(selected,rest))
def subtract(parent:Domain.Domain,selected:Domain.Domain) -> Domain.Domain:
  match parent:
    case Domain.Domain{offsets}:subtract_offsets(selected,offsets)
def remainder_recipe(parent:Domain.Access,active:Domain.Access) -> Match.Recipe:
  match parent active:
    case Domain.Access{_,writes} Domain.Access{_,taken}:Match.Write{subtract(writes,taken)}
def query_remainder(layout:L.Layout,+route:L.Route,+parent:List<&2,Schema.Entry>,+active:List<&2,Schema.Entry>) -> List<&2,Schema.Entry>:
  match layout:
    case L.EmptyLayout{}:[]
    case L.LayoutLeaf{_,_,_,_,_}:[Schema.Entry{route,remainder_recipe(Schema.entry_access(route,parent),Schema.entry_access(route,active))}]
    case L.ClassifiedLayoutLeaf{_,_,_,_,_,_}:[Schema.Entry{route,remainder_recipe(Schema.entry_access(route,parent),Schema.entry_access(route,active))}]
    case L.LayoutPair{left,right}:List.append(&2,Schema.Entry,query_remainder(left,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),parent,active),query_remainder(right,Schema.append_route(route,L.InRight{L.AtLeaf{}}),parent,active))
def resource_remainder_permission(parent:Recipe.Permission,active:Recipe.Permission) -> Recipe.Permission:
  match parent active:
    case Recipe.Writable{} Recipe.Writable{}:Recipe.Unused{}
    case Recipe.Writable{} _:Recipe.Writable{}
    case Recipe.ReadOnly{} Recipe.Unused{}:Recipe.ReadOnly{}
    case _ _:Recipe.Unused{}
def resource_remainder(layout:L.Layout,+route:L.Route,+parent:List<&2,Recipe.Entry>,+active:List<&2,Recipe.Entry>) -> List<&2,Recipe.Entry>:
  match layout:
    case L.EmptyLayout{}:[]
    case L.LayoutLeaf{_,_,_,key,_}:[Recipe.Entry{route,key,resource_remainder_permission(Recipe.at(route,parent),Recipe.at(route,active))}]
    case L.ClassifiedLayoutLeaf{_,_,_,key,_,_}:[Recipe.Entry{route,key,resource_remainder_permission(Recipe.at(route,parent),Recipe.at(route,active))}]
    case L.LayoutPair{left,right}:List.append(&2,Recipe.Entry,resource_remainder(left,Schema.append_route(route,L.InLeft{L.AtLeaf{}}),parent,active),resource_remainder(right,Schema.append_route(route,L.InRight{L.AtLeaf{}}),parent,active))
# Only an unused framework peer holds this complement; it is never invoked.
def remainder(~S:Data,~components:L.Layout,~resources:L.Layout,parent:Footprint<S,components,resources>,active:Footprint<S,components,resources>) -> Footprint<S,components,resources>:
  match parent active:
    case Footprint{ns,handles,info,ri,_,Schema.Book{pq},pr} Footprint{_,_,_,_,_,Schema.Book{aq},ar}:Footprint{ns,handles,info,ri,[],Schema.Book{query_remainder(components,L.AtLeaf{},pq,aq)},resource_remainder(resources,L.AtLeaf{},pr,ar)}
