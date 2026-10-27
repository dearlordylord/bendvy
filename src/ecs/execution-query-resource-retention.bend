import Base
import ./execution-query-partition.bend as Partition
import ./execution-query-store.bend as Store
import ./execution-query-schema.bend as Schema
import ./execution-query-preparation.bend as Preparation
import ./execution-builder.bend as Build
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick

# Query-only peer bodies receive Unit resources. The actual arbitrary World
# resource product stays in this unique affine join carrier throughout execution.
# This adapter grants no resource access and cannot stand in for resource splitting.
type Join<-S:Data,-full:L.Layout,-R:Type> is Type:
  Join{resources:R,columns:Partition.Join<S,full>}
type Split<-S:Data,-full:L.Layout,-R:Type> is Type:
  Split{left:State.Scope<S,Store.Storage<S,full>,Unit>,right:State.Scope<S,Store.Storage<S,full>,Unit>,join:Join<S,full,R>}
  SplitRefused{scope:State.Scope<S,L.columns(~S,full),R>}
  SplitInventoryRefused{families:Schema.families(~S,full),resources:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>}
def retained_split(~S:Data,~full:L.Layout,~R:Type,resources:R,result:Partition.Split<S,full>) -> Split<S,full,R>:
  match result:
    case Partition.Split{left,right,join}:Split{left,right,Join{resources,join}}
    case Partition.SplitRefused{State.Scope{columns,Unit{},handles,tick,prior,view}}:SplitRefused{State.Scope{columns,resources,handles,tick,prior,view}}
    case Partition.SplitInventoryRefused{families,handles,tick,prior,view}:SplitInventoryRefused{families,resources,handles,tick,prior,view}
def split(~S:Data,~full:L.Layout,~R:Type,~LeftOps:Type -> Type,~RightOps:Type -> Type,~leftProgram:Build.Program(~S,~L.columns(~S,full),~Store.Storage<S,full>,~Unit,~LeftOps),~rightProgram:Build.Program(~S,~L.columns(~S,full),~Store.Storage<S,full>,~Unit,~RightOps),scope:State.Scope<S,L.columns(~S,full),R>,left:Preparation.Evidence<S,full,Store.Storage<S,full>,Unit,LeftOps,leftProgram>,right:Preparation.Evidence<S,full,Store.Storage<S,full>,Unit,RightOps,rightProgram>) -> Split<S,full,R>:
  match scope:
    case State.Scope{columns,resources,handles,tick,prior,view}:retained_split(~S,~full,~R,resources,Partition.split(~S,~full,~LeftOps,~RightOps,~leftProgram,~rightProgram,State.Scope{columns,Unit{},handles,tick,prior,view},left,right))
type Joined<-S:Data,-full:L.Layout,-R:Type> is Type:
  Joined{scope:State.Scope<S,L.columns(~S,full),R>,displaced:Schema.displacements(~S,full)}
  JoinScopeRefused{left:State.Scope<S,Store.Storage<S,full>,Unit>,right:State.Scope<S,Store.Storage<S,full>,Unit>,join:Join<S,full,R>}
  JoinInventoryRefused{inventory:Schema.recoveries(~S,full),resources:R,namespace:U32,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>}
def retained_join(~S:Data,~full:L.Layout,~R:Type,resources:R,result:Partition.Joined<S,full>) -> Joined<S,full,R>:
  match result:
    case Partition.Joined{State.Scope{columns,Unit{},handles,tick,prior,view},displaced}:Joined{State.Scope{columns,resources,handles,tick,prior,view},displaced}
    case Partition.JoinScopeRefused{left,right,join}:JoinScopeRefused{left,right,Join{resources,join}}
    case Partition.JoinInventoryRefused{inventory,namespace,handles,tick,prior,view}:JoinInventoryRefused{inventory,resources,namespace,handles,tick,prior,view}
def join(~S:Data,~full:L.Layout,~R:Type,left:State.Scope<S,Store.Storage<S,full>,Unit>,right:State.Scope<S,Store.Storage<S,full>,Unit>,join:Join<S,full,R>) -> Joined<S,full,R>:
  match join:
    case Join{resources,columns}:retained_join(~S,~full,~R,resources,Partition.join(~S,~full,left,right,columns))
