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
