import Base
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-query-store.bend as QueryStore
import ./execution-resource-store.bend as ResourceStore
import ./execution-query-sparse-cut.bend as Query
import ./execution-resource-sparse-cut.bend as Resource
import ./execution-resource-query-footprint.bend as Footprint
import ./execution-query-schema.bend as Schema
import ./execution-query-admission.bend as Grants
import ./execution-query-preparation.bend as Checks
import ./execution-resource-recipe.bend as Recipe
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick
import ./execution-owner-continuation.bend as Continuation

# A sparse parent is partitioned directly. Its canonical complement stays
# affine in the enclosing join; no sparse/full storage equality is assumed.
type Join<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  Join{queryMemo:Query.memos(~S,components),resourceMemo:Resource.memos(resources),namespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,grants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,info:List<&2,Schema.Info>,recipes:List<&2,Recipe.Entry>,left:Footprint.Footprint<S,components,resources>,right:Footprint.Footprint<S,components,resources>}
type Partition<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  Split{left:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,right:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,join:Join<S,components,resources>}
  CutRefused{scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>}
type Joined<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  Joined{scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>}
  JoinRefused{left:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,right:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,join:Join<S,components,resources>}
def same_recipes(left:List<&2,Recipe.Entry>,right:List<&2,Recipe.Entry>) -> Bool:
  match left right:
    case [], []:True{}
    case Recipe.Entry{lr,lk,lp} <> ls, Recipe.Entry{rr,rk,rp} <> rs:Bool.and(Schema.same_route(lr,rr),Bool.and(String.eq(lk,rk),Bool.and(Recipe.same(lp,rp),same_recipes(ls,rs))))
    case _ _:False{}
def scattered(~S:Data,~components:L.Layout,~resources:L.Layout,+namespace:U32,+handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,grants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,+info:List<&2,Schema.Info>,recipes:List<&2,Recipe.Entry>,+left:Footprint.Footprint<S,components,resources>,+right:Footprint.Footprint<S,components,resources>,query:Query.Pieces<S,components>,resource:Resource.Pieces<S,resources>) -> Partition<S,components,resources>:
  match left right query resource:
    case Footprint.Footprint{_,_,_,_,lg,_,lr} Footprint.Footprint{_,_,_,_,rg,_,rr} Query.Pieces{lc,rc,qm} Resource.Pieces{ls,rs,rm}:Split{State.Scope{QueryStore.Storage{namespace,lc,lg,info},ResourceStore.Storage{namespace,ls,lr},handles,tick,prior,view},State.Scope{QueryStore.Storage{namespace,rc,rg,info},ResourceStore.Storage{namespace,rs,rr},handles,tick,prior,view},Join{qm,rm,namespace,handles,tick,prior,view,grants,info,recipes,left,right}}
def scatter_checked(~S:Data,~components:L.Layout,~resources:L.Layout,scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,+left:Footprint.Footprint<S,components,resources>,+right:Footprint.Footprint<S,components,resources>,valid:Bool) -> Partition<S,components,resources>:
  match scope left right valid:
    case scope _ _ False{}:CutRefused{scope}
    case State.Scope{QueryStore.Storage{namespace,columns,grants,info},ResourceStore.Storage{_,owners,recipes},handles,tick,prior,view} Footprint.Footprint{_,_,_,_,_,Schema.Book{lb},lr} Footprint.Footprint{_,_,_,_,_,Schema.Book{rb},rr} True{}:scattered(~S,~components,~resources,namespace,handles,tick,prior,view,grants,info,recipes,left,right,Query.divide(~S,components,L.AtLeaf{},lb,rb,columns),Resource.divide(~S,resources,L.AtLeaf{},lr,rr,owners))
def inspected_resources(~S:Data,~components:L.Layout,~resources:L.Layout,namespace:U32,resourceNamespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,grants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,info:List<&2,Schema.Info>,recipes:List<&2,Recipe.Entry>,left:Footprint.Footprint<S,components,resources>,right:Footprint.Footprint<S,components,resources>,query:QueryStore.stores(~S,components) & Bool,result:ResourceStore.slots(~S,resources) & Bool,metadataValid:Bool) -> Partition<S,components,resources>:
  match query result:
    case (columns,qv), (owners,rv):scatter_checked(~S,~components,~resources,State.Scope{QueryStore.Storage{namespace,columns,grants,info},ResourceStore.Storage{resourceNamespace,owners,recipes},handles,tick,prior,view},left,right,Bool.and(metadataValid,Bool.and(qv,rv)))
def inspect_query(~S:Data,~components:L.Layout,left:List<&2,Schema.Entry>,right:List<&2,Schema.Entry>,columns:QueryStore.stores(~S,components),rest:Bool) -> QueryStore.stores(~S,components) & Bool:
  match rest:
    case False{}:Query.inspect(~S,components,L.AtLeaf{},left,right,columns)
    case True{}:Query.inspect_rest(~S,components,L.AtLeaf{},left,right,columns)
def inspect_resources(~S:Data,~resources:L.Layout,left:List<&2,Recipe.Entry>,right:List<&2,Recipe.Entry>,owners:ResourceStore.slots(~S,resources),rest:Bool) -> ResourceStore.slots(~S,resources) & Bool:
  match rest:
    case False{}:Resource.inspect(~S,resources,L.AtLeaf{},left,right,owners)
    case True{}:Resource.inspect_rest(~S,resources,L.AtLeaf{},left,right,owners)
def cut_mode(~S:Data,~components:L.Layout,~resources:L.Layout,scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,+left:Footprint.Footprint<S,components,resources>,+right:Footprint.Footprint<S,components,resources>,+rest:Bool) -> Partition<S,components,resources>:
  match scope left right:
    case State.Scope{QueryStore.Storage{+namespace,columns,grants,+info},ResourceStore.Storage{+resourceNamespace,owners,recipes},+handles,tick,prior,+view} Footprint.Footprint{+ln,+lh,+li,_,_,Schema.Book{lb},lr} Footprint.Footprint{rn,+rh,+ri,_,_,Schema.Book{rb},rr}:inspected_resources(~S,~components,~resources,namespace,resourceNamespace,handles,tick,prior,view,grants,info,recipes,left,right,inspect_query(~S,~components,lb,rb,columns,rest),inspect_resources(~S,~resources,lr,rr,owners,rest),Bool.and(U32.is_eq(namespace,resourceNamespace),Bool.and(U32.is_eq(namespace,ln),Bool.and(U32.is_eq(namespace,rn),Bool.and(U32.is_eq(namespace,Checks.view_namespace(~S,view)),Bool.and(Checks.same_handles(~S,handles,lh),Bool.and(Checks.same_handles(~S,handles,rh),Bool.and(Checks.same_info(info,li),Checks.same_info(info,ri)))))))))
def cut(~S:Data,~components:L.Layout,~resources:L.Layout,scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,+left:Footprint.Footprint<S,components,resources>,+right:Footprint.Footprint<S,components,resources>) -> Partition<S,components,resources>:
  cut_mode(~S,~components,~resources,scope,left,right,False{})
def cut_remainder(~S:Data,~components:L.Layout,~resources:L.Layout,scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,+left:Footprint.Footprint<S,components,resources>,+right:Footprint.Footprint<S,components,resources>) -> Partition<S,components,resources>:
  cut_mode(~S,~components,~resources,scope,left,right,True{})
type Metadata<-S:Data,-components:L.Layout> is Data:
  Metadata{namespace:U32,resourceNamespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,grants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,info:List<&2,Schema.Info>,recipes:List<&2,Recipe.Entry>}
def scope(~S:Data,~components:L.Layout,~resources:L.Layout,metadata:Metadata<S,components>,columns:QueryStore.stores(~S,components),owners:ResourceStore.slots(~S,resources)) -> State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>:
  match metadata:
    case Metadata{namespace,rn,handles,tick,prior,view,grants,info,recipes}:State.Scope{QueryStore.Storage{namespace,columns,grants,info},ResourceStore.Storage{rn,owners,recipes},handles,tick,prior,view}
def metadata_valid(~S:Data,~components:L.Layout,~resources:L.Layout,metadata:Metadata<S,components>,expected:Footprint.Footprint<S,components,resources>) -> Bool:
  match metadata expected:
    case Metadata{+ns,rns,+handles,_,_,view,grants,info,recipes} Footprint.Footprint{en,eh,ei,_,eg,_,er}:Bool.and(U32.is_eq(ns,rns),Bool.and(U32.is_eq(ns,en),Bool.and(U32.is_eq(ns,Checks.view_namespace(~S,view)),Bool.and(Checks.same_handles(~S,handles,eh),Bool.and(Checks.same_info(info,ei),Bool.and(Checks.same_grants(~S,~L.columns(~S,components),grants,eg),same_recipes(recipes,er)))))))
type Context<-S:Data,-components:L.Layout,-resources:L.Layout> is Data:
  Context{namespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,grants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,info:List<&2,Schema.Info>,recipes:List<&2,Recipe.Entry>,left:Footprint.Footprint<S,components,resources>,right:Footprint.Footprint<S,components,resources>}
type JoinedResourceHeader<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  JoinedResourceHeader{memo:Context<S,components,resources>,resource:Resource.Pieces<S,resources>}
def joined_columns(~S:Data,~components:L.Layout,~resources:L.Layout,header:JoinedResourceHeader<S,components,resources>,columns:QueryStore.stores(~S,components)) -> Joined<S,components,resources>:
  match header:
    case JoinedResourceHeader{Context{+namespace,handles,tick,prior,view,grants,info,recipes,_,_},resource}:Joined{State.Scope{QueryStore.Storage{namespace,columns,grants,info},ResourceStore.Storage{namespace,Resource.merge(~S,resources,resource),recipes},handles,tick,prior,view}}
def joined_checked(~S:Data,~components:L.Layout,~resources:L.Layout,leftMetadata:Metadata<S,components>,rightMetadata:Metadata<S,components>,memo:Context<S,components,resources>,query:Query.Pieces<S,components>,resource:Resource.Pieces<S,resources>,valid:Bool) -> Joined<S,components,resources>:
  match memo query resource valid:
    case memo query resource True{}:
      continuation:Continuation.Header<QueryStore.stores(~S,components),Joined<S,components,resources>> = Continuation.Header{JoinedResourceHeader<S,components,resources>,JoinedResourceHeader{memo,resource},header => columns => joined_columns(~S,~components,~resources,header,columns)}
      Continuation.returned(QueryStore.stores(~S,components),Joined<S,components,resources>,continuation,Query.merge(~S,components,query))
    case Context{namespace,handles,tick,prior,view,grants,info,recipes,left,right} Query.Pieces{lc,rc,qm} Resource.Pieces{ls,rs,rm} False{}:JoinRefused{scope(~S,~components,~resources,leftMetadata,lc,ls),scope(~S,~components,~resources,rightMetadata,rc,rs),Join{qm,rm,namespace,handles,tick,prior,view,grants,info,recipes,left,right}}
def inspected_join(~S:Data,~components:L.Layout,~resources:L.Layout,leftMetadata:Metadata<S,components>,rightMetadata:Metadata<S,components>,memo:Context<S,components,resources>,query:Query.Pieces<S,components> & Bool,resource:Resource.Pieces<S,resources> & Bool,valid:Bool) -> Joined<S,components,resources>:
  match query resource:
    case (query,qv), (resource,rv):joined_checked(~S,~components,~resources,leftMetadata,rightMetadata,memo,query,resource,Bool.and(valid,Bool.and(qv,rv)))
type JoinInspectionHeader<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  JoinInspectionHeader{leftMetadata:Metadata<S,components>,rightMetadata:Metadata<S,components>,memo:Context<S,components,resources>,resource:Resource.Pieces<S,resources>}
type ResourceInspectionHeader<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  ResourceInspectionHeader{leftMetadata:Metadata<S,components>,rightMetadata:Metadata<S,components>,memo:Context<S,components,resources>,query:Query.Pieces<S,components> & Bool}
type MetadataInspectionHeader<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  MetadataInspectionHeader{inspection:ResourceInspectionHeader<S,components,resources>,resource:Resource.Pieces<S,resources> & Bool}
def joined_metadata_inspected(~S:Data,~components:L.Layout,~resources:L.Layout,pair:MetadataInspectionHeader<S,components,resources> & (Bool & Bool)) -> Joined<S,components,resources>:
  match pair:
    case (MetadataInspectionHeader{ResourceInspectionHeader{leftMetadata,rightMetadata,memo,query},resource},(leftValid,rightValid)):inspected_join(~S,~components,~resources,leftMetadata,rightMetadata,memo,query,resource,Bool.and(leftValid,rightValid))
def joined_resource_inspected(~S:Data,~components:L.Layout,~resources:L.Layout,header:ResourceInspectionHeader<S,components,resources>,resource:Resource.Pieces<S,resources> & Bool) -> Joined<S,components,resources>:
  match header:
    case ResourceInspectionHeader{+leftMetadata,+rightMetadata,Context{namespace,handles,tick,prior,view,grants,info,recipes,+left,+right},query}:
      continuation:Continuation.PairedHeader<(Bool & Bool),Joined<S,components,resources>> = Continuation.PairedHeader{MetadataInspectionHeader<S,components,resources>,MetadataInspectionHeader{ResourceInspectionHeader{leftMetadata,rightMetadata,Context{namespace,handles,tick,prior,view,grants,info,recipes,left,right},query},resource},joined_metadata_inspected(~S,~components,~resources)}
      Continuation.paired_returned(Bool & Bool,Joined<S,components,resources>,continuation,(metadata_valid(~S,~components,~resources,leftMetadata,left),metadata_valid(~S,~components,~resources,rightMetadata,right)))
def joined_query_inspected(~S:Data,~components:L.Layout,~resources:L.Layout,header:JoinInspectionHeader<S,components,resources>,query:Query.Pieces<S,components> & Bool) -> Joined<S,components,resources>:
  match header:
    case JoinInspectionHeader{leftMetadata,rightMetadata,memo,Resource.Pieces{ls,rs,rm}}:
      continuation:Continuation.Header<(Resource.Pieces<S,resources> & Bool),Joined<S,components,resources>> = Continuation.Header{ResourceInspectionHeader<S,components,resources>,ResourceInspectionHeader{leftMetadata,rightMetadata,memo,query},header => resource => joined_resource_inspected(~S,~components,~resources,header,resource)}
      Continuation.returned(Resource.Pieces<S,resources> & Bool,Joined<S,components,resources>,continuation,Resource.inspect_join(~S,resources,ls,rs,rm))
def join(~S:Data,~components:L.Layout,~resources:L.Layout,left:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,right:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,memo:Join<S,components,resources>) -> Joined<S,components,resources>:
  match left right memo:
    case State.Scope{QueryStore.Storage{ln,lc,lg,li},ResourceStore.Storage{lrn,ls,lr},lh,lt,lp,lv} State.Scope{QueryStore.Storage{rn,rc,rg,ri},ResourceStore.Storage{rrn,rs,rr},rh,rt,rp,rv} Join{qm,rm,namespace,handles,tick,prior,view,grants,info,recipes,left,right}:
      continuation:Continuation.Header<(Query.Pieces<S,components> & Bool),Joined<S,components,resources>> = Continuation.Header{JoinInspectionHeader<S,components,resources>,JoinInspectionHeader{Metadata{ln,lrn,lh,lt,lp,lv,lg,li,lr},Metadata{rn,rrn,rh,rt,rp,rv,rg,ri,rr},Context{namespace,handles,tick,prior,view,grants,info,recipes,left,right},Resource.Pieces{ls,rs,rm}},header => query => joined_query_inspected(~S,~components,~resources,header,query)}
      Continuation.returned(Query.Pieces<S,components> & Bool,Joined<S,components,resources>,continuation,Query.inspect_join(~S,components,lc,rc,qm))
