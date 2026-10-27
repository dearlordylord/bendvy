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
import ./execution-owner-continuation.bend as Continuation

# This physical framework carrier contains both actual complements. Neither
# sparse local owner is equated with the canonical full World product.
type Join<-S:Data,-components:L.Layout,-fullResources:L.Layout> is Type:
  Join{query:Query.Join<S,components>,rest:Split.remainder(~S,fullResources),repack:Store.slots(~S,fullResources) -> Store.slots(~S,fullResources) -> Split.remainder(~S,fullResources) -> Resource.families(~S,fullResources),resource:Resource.JoinOwner<S,fullResources>}
type Partition<-S:Data,-components:L.Layout,-fullResources:L.Layout> is Type:
  Parallel{left:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,right:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,join:Join<S,components,fullResources>}
  Serial{scope:State.Scope<S,L.columns(~S,components),L.resources(~S,fullResources)>}
  Refused{scope:State.Scope<S,L.columns(~S,components),L.resources(~S,fullResources)>}
  ComponentRefused{components:Query.Split<S,components>,resources:L.resources(~S,fullResources)}
  ResourceRefused{left:State.Scope<S,QueryStore.Storage<S,components>,Unit>,right:State.Scope<S,QueryStore.Storage<S,components>,Unit>,query:Query.Join<S,components>,resources:L.resources(~S,fullResources)}
def separated(~S:Data,~components:L.Layout,~fullResources:L.Layout,left:State.Scope<S,QueryStore.Storage<S,components>,Unit>,right:State.Scope<S,QueryStore.Storage<S,components>,Unit>,query:Query.Join<S,components>,+namespace:U32,leftRecipes:List<&2,Recipe.Entry>,rightRecipes:List<&2,Recipe.Entry>,resource:Resource.JoinOwner<S,fullResources>,result:Split.Separated<S,fullResources>) -> Partition<S,components,fullResources>:
  match left right result:
    case State.Scope{lc,Unit{},lh,lt,lp,lv} State.Scope{rc,Unit{},rh,rt,rp,rv} Split.Separated{ls,rs,rest,repack}:Parallel{State.Scope{lc,Store.Storage{namespace,ls,leftRecipes},lh,lt,lp,lv},State.Scope{rc,Store.Storage{namespace,rs,rightRecipes},rh,rt,rp,rv},Join{query,rest,repack,resource}}
def resource_cut(~S:Data,~components:L.Layout,~fullResources:L.Layout,left:State.Scope<S,QueryStore.Storage<S,components>,Unit>,right:State.Scope<S,QueryStore.Storage<S,components>,Unit>,query:Query.Join<S,components>,namespace:U32,leftRecipes:List<&2,Recipe.Entry>,rightRecipes:List<&2,Recipe.Entry>,result:Resource.Cut<S,fullResources>) -> Partition<S,components,fullResources>:
  match result:
    case Resource.Refused{resources}:ResourceRefused{left,right,query,resources}
    case Resource.Partitioned{families,resource}:separated(~S,~components,~fullResources,left,right,query,namespace,leftRecipes,rightRecipes,resource,Split.separate(~S,fullResources,families))
type ResourceCutHeader<-S:Data,-components:L.Layout> is Type:
  ResourceCutHeader{left:State.Scope<S,QueryStore.Storage<S,components>,Unit>,right:State.Scope<S,QueryStore.Storage<S,components>,Unit>,query:Query.Join<S,components>,namespace:U32,leftRecipes:List<&2,Recipe.Entry>,rightRecipes:List<&2,Recipe.Entry>}
def resource_cut_header(~S:Data,~components:L.Layout,~resources:L.Layout,header:ResourceCutHeader<S,components>,result:Resource.Cut<S,resources>) -> Partition<S,components,resources>:
  match header:
    case ResourceCutHeader{lc,rc,query,namespace,left,right}:resource_cut(~S,~components,~resources,lc,rc,query,namespace,left,right,result)
def components_cut(~S:Data,~components:L.Layout,~fullResources:L.Layout,+namespace:U32,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,resources:L.resources(~S,fullResources),result:Query.Split<S,components>) -> Partition<S,components,fullResources>:
  match result:
    case Query.Split{lc,rc,query}:
      continuation:Continuation.Header<Resource.Cut<S,fullResources>,Partition<S,components,fullResources>> = Continuation.Header{ResourceCutHeader<S,components>,ResourceCutHeader{lc,rc,query,namespace,left,right},header => result => resource_cut_header(~S,~components,~fullResources,header,result)}
      Continuation.returned(Resource.Cut<S,fullResources>,Partition<S,components,fullResources>,continuation,Resource.cut(~S,~fullResources,namespace,Recipe.Book{left},Recipe.Book{right},resources))
    case result:ComponentRefused{result,resources}
# Both complete resource recipe sets are validated before any owner extraction.
# A genuine conflict retains the canonical owner for ordinary serial threading.
def split_checked(~S:Data,~components:L.Layout,~fullResources:L.Layout,scope:State.Scope<S,L.columns(~S,components),L.resources(~S,fullResources)>,+namespace:U32,leftGrants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,rightGrants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,info:List<&2,Schema.Info>,leftQuery:Schema.Book<S,components>,rightQuery:Schema.Book<S,components>,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,valid:Bool,compatible:Bool) -> Partition<S,components,fullResources>:
  match scope valid compatible:
    case scope False{} _:Refused{scope}
    case scope True{} False{}:Serial{scope}
    case State.Scope{columns,resources,handles,tick,prior,view} True{} True{}:components_cut(~S,~components,~fullResources,namespace,left,right,resources,Query.split_checked(~S,~components,State.Scope{columns,Unit{},handles,tick,prior,view},namespace,leftGrants,rightGrants,info,leftQuery,rightQuery,True{}))
type SplitHeader<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  SplitHeader{scope:State.Scope<S,L.columns(~S,components),L.resources(~S,resources)>,namespace:U32,leftGrants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,rightGrants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,info:List<&2,Schema.Info>,leftQuery:Schema.Book<S,components>,rightQuery:Schema.Book<S,components>,left:List<&2,Recipe.Entry>,right:List<&2,Recipe.Entry>}
def split_decided(~S:Data,~components:L.Layout,~resources:L.Layout,header:SplitHeader<S,components,resources>,flags:Bool & Bool) -> Partition<S,components,resources>:
  match header flags:
    case SplitHeader{scope,namespace,leftGrants,rightGrants,info,leftQuery,rightQuery,left,right}, (valid,compatible):split_checked(~S,~components,~resources,scope,namespace,leftGrants,rightGrants,info,leftQuery,rightQuery,left,right,valid,compatible)
def split(~S:Data,~components:L.Layout,~fullResources:L.Layout,scope:State.Scope<S,L.columns(~S,components),L.resources(~S,fullResources)>,namespace:U32,leftGrants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,rightGrants:List<&2,Grants.Granted<S,L.columns(~S,components)>>,info:List<&2,Schema.Info>,leftQuery:Schema.Book<S,components>,rightQuery:Schema.Book<S,components>,+left:List<&2,Recipe.Entry>,+right:List<&2,Recipe.Entry>,valid:Bool) -> Partition<S,components,fullResources>:
  continuation:Continuation.Header<(Bool & Bool),Partition<S,components,fullResources>> = Continuation.Header{SplitHeader<S,components,fullResources>,SplitHeader{scope,namespace,leftGrants,rightGrants,info,leftQuery,rightQuery,left,right},header => flags => split_decided(~S,~components,~fullResources,header,flags)}
  Continuation.decided(Partition<S,components,fullResources>,continuation,Bool.and(valid,Bool.and(L.unique(fullResources),Bool.and(Recipe.valid(~fullResources,left),Recipe.valid(~fullResources,right)))),Recipe.compatible(~fullResources,left,right))
type Joined<-S:Data,-components:L.Layout,-fullResources:L.Layout> is Type:
  Joined{scope:State.Scope<S,L.columns(~S,components),L.resources(~S,fullResources)>,displaced:Schema.displacements(~S,components)}
  ScopeRefused{left:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,right:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,join:Join<S,components,fullResources>}
  InventoryRefused{components:Query.Joined<S,components>,resources:Resource.Joined<S,fullResources>}
def joined(~S:Data,~components:L.Layout,~fullResources:L.Layout,query:Query.Joined<S,components>,resource:Resource.Joined<S,fullResources>) -> Joined<S,components,fullResources>:
  match query resource:
    case Query.Joined{State.Scope{columns,Unit{},handles,tick,prior,view},displaced} Resource.Joined{resources,_}:Joined{State.Scope{columns,resources,handles,tick,prior,view},displaced}
    case query resource:InventoryRefused{query,resource}
def query_joined_header(~S:Data,~components:L.Layout,~resources:L.Layout,query:Query.Joined<S,components>,resource:Resource.Joined<S,resources>) -> Joined<S,components,resources>:
  joined(~S,~components,~resources,query,resource)
type ResourceJoinHeader<-S:Data,-resources:L.Layout> is Type:
  ResourceJoinHeader{left:Store.slots(~S,resources),right:Store.slots(~S,resources),rest:Split.remainder(~S,resources),repack:Store.slots(~S,resources) -> Store.slots(~S,resources) -> Split.remainder(~S,resources) -> Resource.families(~S,resources),resource:Resource.JoinOwner<S,resources>}
def resource_join_header(~S:Data,~components:L.Layout,~resources:L.Layout,header:ResourceJoinHeader<S,resources>,query:Query.Joined<S,components>) -> Joined<S,components,resources>:
  match header:
    case ResourceJoinHeader{left,right,rest,repack,resource}:
      continuation:Continuation.Header<Resource.Joined<S,resources>,Joined<S,components,resources>> = Continuation.Header{Query.Joined<S,components>,query,header => result => query_joined_header(~S,~components,~resources,header,result)}
      Continuation.returned(Resource.Joined<S,resources>,Joined<S,components,resources>,continuation,Split.reunite(~S,~resources,left,right,rest,repack,resource))
def join_checked(~S:Data,~components:L.Layout,~fullResources:L.Layout,left:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,right:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,join:Join<S,components,fullResources>,valid:Bool) -> Joined<S,components,fullResources>:
  match left right join valid:
    case left right join False{}:ScopeRefused{left,right,join}
    case State.Scope{lc,Store.Storage{_,lr,_},lh,lt,lp,lv} State.Scope{rc,Store.Storage{_,rr,_},rh,rt,rp,rv} Join{query,rest,repack,resource} True{}:
      continuation:Continuation.Header<Query.Joined<S,components>,Joined<S,components,fullResources>> = Continuation.Header{ResourceJoinHeader<S,fullResources>,ResourceJoinHeader{lr,rr,rest,repack,resource},header => result => resource_join_header(~S,~components,~fullResources,header,result)}
      Continuation.returned(Query.Joined<S,components>,Joined<S,components,fullResources>,continuation,Query.join(~S,~components,State.Scope{lc,Unit{},lh,lt,lp,lv},State.Scope{rc,Unit{},rh,rt,rp,rv},query))
type JoinHeader<-S:Data,-components:L.Layout,-resources:L.Layout> is Type:
  JoinHeader{left:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,resources>>,right:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,resources>>,join:Join<S,components,resources>}
def join_decided(~S:Data,~components:L.Layout,~resources:L.Layout,header:JoinHeader<S,components,resources>,valid:Bool) -> Joined<S,components,resources>:
  match header:
    case JoinHeader{left,right,join}:join_checked(~S,~components,~resources,left,right,join,valid)
def join(~S:Data,~components:L.Layout,~fullResources:L.Layout,left:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,right:State.Scope<S,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>>,join:Join<S,components,fullResources>) -> Joined<S,components,fullResources>:
  match left right join:
    case State.Scope{lc,Store.Storage{+ln,lr,le},lh,lt,lp,+lv} State.Scope{rc,Store.Storage{+rn,rr,re},rh,rt,rp,+rv} Join{query,rest,repack,Resource.JoinOwner{+namespace,lq,rq}}:
      continuation:Continuation.Header<Bool,Joined<S,components,fullResources>> = Continuation.Header{JoinHeader<S,components,fullResources>,JoinHeader{State.Scope{lc,Store.Storage{ln,lr,le},lh,lt,lp,lv},State.Scope{rc,Store.Storage{rn,rr,re},rh,rt,rp,rv},Join{query,rest,repack,Resource.JoinOwner{namespace,lq,rq}}},header => valid => join_decided(~S,~components,~fullResources,header,valid)}
      Continuation.returned(Bool,Joined<S,components,fullResources>,continuation,Bool.and(U32.is_eq(ln,namespace),Bool.and(U32.is_eq(rn,namespace),Bool.and(U32.is_eq(Checks.view_namespace(~S,lv),namespace),U32.is_eq(Checks.view_namespace(~S,rv),namespace)))))
# Ordinary lowering supplies both complete domains from its two actual admitted
# closed compilations. Live storage and captured handles are checked again before cut.
def described_admitted(~S:Data,~components:L.Layout,~fullResources:L.Layout,~LeftOps:Data -> Type -> Type,~RightOps:Data -> Type -> Type,~leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~Store.Storage<S,fullResources>,~LeftOps),~rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~Store.Storage<S,fullResources>,~RightOps),resources:L.resources(~S,fullResources),+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,left:Admission.Evidence<S,components,fullResources,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>,LeftOps,leftProgram>,right:Admission.Evidence<S,components,fullResources,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>,RightOps,rightProgram>,description:Schema.Description<S,components>) -> Partition<S,components,fullResources>:
  match left right description:
    case Admission.Evidence{+ln,+lh,_,lr,+li,_,lg,lq,_} Admission.Evidence{rn,+rh,_,rr,+ri,_,rg,rq,_} Schema.Description{columns,+info,valid}:split(~S,~components,~fullResources,State.Scope{columns,resources,handles,tick,prior,view},ln,lg,rg,info,lq,rq,lr,rr,Bool.and(valid,Bool.and(U32.is_eq(ln,rn),Bool.and(U32.is_eq(ln,Checks.view_namespace(~S,view)),Bool.and(Checks.same_handles(~S,handles,lh),Bool.and(Checks.same_handles(~S,handles,rh),Bool.and(Checks.same_info(info,li),Checks.same_info(info,ri))))))))
def split_admitted(~S:Data,~components:L.Layout,~fullResources:L.Layout,~LeftOps:Data -> Type -> Type,~RightOps:Data -> Type -> Type,~leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~Store.Storage<S,fullResources>,~LeftOps),~rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~Store.Storage<S,fullResources>,~RightOps),scope:State.Scope<S,L.columns(~S,components),L.resources(~S,fullResources)>,left:Admission.Evidence<S,components,fullResources,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>,LeftOps,leftProgram>,right:Admission.Evidence<S,components,fullResources,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>,RightOps,rightProgram>) -> Partition<S,components,fullResources>:
  match scope:
    case State.Scope{columns,resources,handles,tick,prior,view}:described_admitted(~S,~components,~fullResources,~LeftOps,~RightOps,~leftProgram,~rightProgram,resources,handles,tick,prior,view,left,right,Schema.describe(~S,components,L.AtLeaf{},columns))
# Serial execution cuts the complete active invocation domain against an unused
# framework peer. No declared grant is removed and the peer body is not invoked.
def described_single(~S:Data,~components:L.Layout,~fullResources:L.Layout,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~Store.Storage<S,fullResources>,~Ops),resources:L.resources(~S,fullResources),+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,evidence:Admission.Evidence<S,components,fullResources,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>,Ops,program>,description:Schema.Description<S,components>) -> Partition<S,components,fullResources>:
  match evidence description:
    case Admission.Evidence{+namespace,+captured,_,recipes,+expected,_,grants,book,_} Schema.Description{columns,+info,valid}:split(~S,~components,~fullResources,State.Scope{columns,resources,handles,tick,prior,view},namespace,grants,[],info,book,Schema.Book{[]},recipes,[],Bool.and(valid,Bool.and(U32.is_eq(namespace,Checks.view_namespace(~S,view)),Bool.and(Checks.same_handles(~S,handles,captured),Checks.same_info(info,expected)))))
def split_single_admitted(~S:Data,~components:L.Layout,~fullResources:L.Layout,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,components),~QueryStore.Storage<S,components>,~Store.Storage<S,fullResources>,~Ops),scope:State.Scope<S,L.columns(~S,components),L.resources(~S,fullResources)>,evidence:Admission.Evidence<S,components,fullResources,QueryStore.Storage<S,components>,Store.Storage<S,fullResources>,Ops,program>) -> Partition<S,components,fullResources>:
  match scope:
    case State.Scope{columns,resources,handles,tick,prior,view}:described_single(~S,~components,~fullResources,~Ops,~program,resources,handles,tick,prior,view,evidence,Schema.describe(~S,components,L.AtLeaf{},columns))
