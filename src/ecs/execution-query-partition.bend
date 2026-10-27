import Base
import ./execution-query-store.bend as Store
import ./execution-query-schema.bend as Schema
import ./execution-query-preparation.bend as Preparation
import ./execution-query-admission.bend as Admit
import ./execution-query-recipe.bend as Recipe
import ./execution-builder.bend as Build
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick

type Join<-S:Data,-full:L.Layout> is Type:
  Join{rest:Store.retained(~S,full),repack:Store.stores(~S,full) -> Store.stores(~S,full) -> Store.retained(~S,full) -> Schema.families(~S,full),namespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>}
type Split<-S:Data,-full:L.Layout> is Type:
  Split{left:State.Scope<S,Store.Storage<S,full>,Unit>,right:State.Scope<S,Store.Storage<S,full>,Unit>,join:Join<S,full>}
  SplitRefused{scope:State.Scope<S,L.columns(~S,full),Unit>}
  SplitInventoryRefused{families:Schema.families(~S,full),handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>}
def separated(~S:Data,~full:L.Layout,+namespace:U32,+handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,leftGrants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,rightGrants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,+info:List<&2,Schema.Info>,result:Store.Separation<S,full>) -> Split<S,full>:
  match result:
    case Store.SeparationRefused{families}:SplitInventoryRefused{families,handles,tick,prior,view}
    case Store.Separated{left,right,rest,repack}:Split{State.Scope{Store.Storage{namespace,left,leftGrants,info},Unit{},handles,tick,prior,view},State.Scope{Store.Storage{namespace,right,rightGrants,info},Unit{},handles,tick,prior,view},Join{rest,repack,namespace,handles,tick,prior,view}}
def cut(~S:Data,~full:L.Layout,namespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,leftGrants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,rightGrants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,result:Schema.Partition<S,full>) -> Split<S,full>:
  match result:
    case Schema.Refused{columns}:SplitRefused{State.Scope{columns,Unit{},handles,tick,prior,view}}
    case Schema.PartitionedInventory{families}:separated(~S,~full,namespace,handles,tick,prior,view,leftGrants,rightGrants,info,Store.separate(~S,full,families))
def split_checked(~S:Data,~full:L.Layout,scope:State.Scope<S,L.columns(~S,full),Unit>,namespace:U32,leftGrants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,rightGrants:List<&2,Admit.Granted<S,L.columns(~S,full)>>,info:List<&2,Schema.Info>,left:Schema.Book<S,full>,right:Schema.Book<S,full>,valid:Bool) -> Split<S,full>:
  match scope valid:
    case scope False{}:SplitRefused{scope}
    case State.Scope{columns,Unit{},handles,tick,prior,+view} True{}:cut(~S,~full,namespace,handles,tick,prior,view,leftGrants,rightGrants,info,Schema.cut(~S,~full,left,right,columns))
def described(~S:Data,~full:L.Layout,~LeftOps:Data -> Type -> Type,~RightOps:Data -> Type -> Type,~leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,full),~Store.Storage<S,full>,~Unit,~LeftOps),~rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,full),~Store.Storage<S,full>,~Unit,~RightOps),+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,+view:Notice.View<S>,left:Preparation.Evidence<S,full,Store.Storage<S,full>,Unit,LeftOps,leftProgram>,right:Preparation.Evidence<S,full,Store.Storage<S,full>,Unit,RightOps,rightProgram>,result:Schema.Description<S,full>) -> Split<S,full>:
  match left right result:
    case Preparation.Evidence{+ln,+lh,_,+li,lg,lb} Preparation.Evidence{rn,+rh,_,+ri,rg,rb} Schema.Description{columns,+info,valid}:split_checked(~S,~full,State.Scope{columns,Unit{},handles,tick,prior,view},ln,lg,rg,info,lb,rb,Bool.and(valid,Bool.and(U32.is_eq(ln,rn),Bool.and(U32.is_eq(ln,Preparation.view_namespace(~S,view)),Bool.and(Preparation.same_handles(~S,handles,lh),Bool.and(Preparation.same_handles(~S,handles,rh),Bool.and(Preparation.same_info(info,li),Preparation.same_info(info,ri))))))))
def split(~S:Data,~full:L.Layout,~LeftOps:Data -> Type -> Type,~RightOps:Data -> Type -> Type,~leftProgram:Build.FrameworkProgram(~S,~L.columns(~S,full),~Store.Storage<S,full>,~Unit,~LeftOps),~rightProgram:Build.FrameworkProgram(~S,~L.columns(~S,full),~Store.Storage<S,full>,~Unit,~RightOps),scope:State.Scope<S,L.columns(~S,full),Unit>,left:Preparation.Evidence<S,full,Store.Storage<S,full>,Unit,LeftOps,leftProgram>,right:Preparation.Evidence<S,full,Store.Storage<S,full>,Unit,RightOps,rightProgram>) -> Split<S,full>:
  match scope:
    case State.Scope{columns,Unit{},handles,tick,prior,+view}:described(~S,~full,~LeftOps,~RightOps,~leftProgram,~rightProgram,handles,tick,prior,view,left,right,Schema.describe(~S,full,L.AtLeaf{},columns))
type Joined<-S:Data,-full:L.Layout> is Type:
  Joined{scope:State.Scope<S,L.columns(~S,full),Unit>,displaced:Schema.displacements(~S,full)}
  JoinScopeRefused{left:State.Scope<S,Store.Storage<S,full>,Unit>,right:State.Scope<S,Store.Storage<S,full>,Unit>,join:Join<S,full>}
  JoinInventoryRefused{inventory:Schema.recoveries(~S,full),namespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>}
def assembled(~S:Data,~full:L.Layout,namespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,result:Schema.Assembly<S,full>) -> Joined<S,full>:
  match result:
    case Schema.Assembled{columns,displaced}:Joined{State.Scope{columns,Unit{},handles,tick,prior,view},displaced}
    case Schema.AssemblyRefused{inventory}:JoinInventoryRefused{inventory,namespace,handles,tick,prior,view}
def join_checked(~S:Data,~full:L.Layout,left:State.Scope<S,Store.Storage<S,full>,Unit>,right:State.Scope<S,Store.Storage<S,full>,Unit>,join:Join<S,full>,valid:Bool) -> Joined<S,full>:
  match left right join valid:
    case left right join False{}:JoinScopeRefused{left,right,join}
    case State.Scope{Store.Storage{_,left,_,_},Unit{},_,_,_,_} State.Scope{Store.Storage{_,right,_,_},Unit{},_,_,_,_} Join{rest,repack,namespace,handles,tick,prior,+view} True{}:assembled(~S,~full,namespace,handles,tick,prior,view,Store.reunite(~S,~full,left,right,rest,repack))
def join(~S:Data,~full:L.Layout,left:State.Scope<S,Store.Storage<S,full>,Unit>,right:State.Scope<S,Store.Storage<S,full>,Unit>,join:Join<S,full>) -> Joined<S,full>:
  match left right join:
    case State.Scope{Store.Storage{+ln,left,lg,li},Unit{},+lh,lt,lp,+lv} State.Scope{Store.Storage{+rn,right,rg,ri},Unit{},+rh,rt,rp,+rv} Join{rest,repack,+namespace,+handles,tick,prior,+view}:join_checked(~S,~full,State.Scope{Store.Storage{ln,left,lg,li},Unit{},lh,lt,lp,lv},State.Scope{Store.Storage{rn,right,rg,ri},Unit{},rh,rt,rp,rv},Join{rest,repack,namespace,handles,tick,prior,view},Bool.and(U32.is_eq(ln,namespace),Bool.and(U32.is_eq(rn,namespace),Bool.and(Preparation.same_handles(~S,lh,handles),Bool.and(Preparation.same_handles(~S,rh,handles),Bool.and(U32.is_eq(Preparation.view_namespace(~S,lv),namespace),U32.is_eq(Preparation.view_namespace(~S,rv),namespace)))))))
