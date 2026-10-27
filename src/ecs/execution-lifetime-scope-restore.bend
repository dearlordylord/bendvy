import Base
import ./execution-lifetime-scope-store.bend as Store
import ./lifetime-scope.bend as Scope
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./lifecycle.bend as Life
import ./change-tick.bend as Tick

# Trusted restore publication after full source admission and fresh-handle
# remapping. Scope names/full keys are detached metadata; namespace authority
# always remains with the actual receiver. Bevy ad678262 state_scoped.rs covers
# state-exit despawns; this owner-preservation boundary is Bend-specific.
def replace(-S:Data,store:Store.Store<S>,members:List<&2,Scope.Member>) -> Store.Store<S> & List<&2,Scope.Member>:
  match store:
    case Store.Store{namespace,previous}:(Store.Store{namespace,members},previous)
type Admission<-Source:Type> is Type:
  LifetimeScopeReady{members:List<&2,Scope.Member>,source:Source}
  Refused{source:Source}
type Publication<-S:Data,-key:String,-origin:Layout.Layout,-Source:Type> is Type:
  Installed{slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin>,source:Source,previous:List<&2,Scope.Member>}
  Rejected{slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin>,source:Source}
def project(-S:Data,store:Store.Store<S>) -> Store.Store<S> & Store.View<S>:
  match store:
    case Store.Store{+namespace,+members}:(Store.Store{namespace,members},Store.View{namespace,members})
def projected(-S:Data,-key:String,-origin:Layout.Layout,-Source:Type,source:Source,previous:List<&2,Scope.Member>,stamp:Life.Stamp,result:Store.Store<S> & Store.View<S>) -> Publication<S,key,origin,Source>:
  match result:
    case (store,view):Installed{Layout.ResourceSlot{Layout.Viewed{store,view},stamp},source,previous}
def replaced(-S:Data,-key:String,-origin:Layout.Layout,-Source:Type,source:Source,stamp:Life.Stamp,result:Store.Store<S> & List<&2,Scope.Member>) -> Publication<S,key,origin,Source>:
  match result:
    case (store,previous):projected(S,key,origin,Source,source,previous,stamp,project(S,store))
def publish(~S:Data,~key:String,~origin:Layout.Layout,~protected:{Layout.policy(origin,Layout.AtLeaf{}) == Policy.ProtectedLifetimeScope{S} : Policy.Policy},~Source:Type,slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S>,Store.View<S>>,key,origin>,tick:Tick.Tick,admission:Admission<Source>) -> Publication<S,key,origin,Source>:
  match slot admission:
    case slot Refused{source}:Rejected{slot,source}
    case Layout.ResourceSlot{Layout.Viewed{store,_},stamp} LifetimeScopeReady{members,source}:replaced(S,key,origin,Source,source,Life.after_write(True{},True{},stamp,tick),replace(S,store,members))
