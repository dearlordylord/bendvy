import Base
import ./execution-relation-store.bend as Store
import ./execution-composer-layout.bend as Layout
import ./relation-types.bend as T
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./execution-resource-policy.bend as Policy

# Trusted restore publication, after complete source graph admission and actual
# fresh-handle remapping. No gameplay ResourceWrite or operation queue is exposed.
# Bevy ad678262ce53b5d142fe49ee5e08caff6f00ab60 scene/entity_mapper.rs
# supports remapped identities; preserving these affine failure-channel owners
# and Reader IDs is an additional Bend requirement, not a Bevy proof.
def replace(-S:Data,-descriptor:T.Descriptor<S>,store:Store.Store<S,descriptor>,graph:T.Graph<S>) -> Store.Store<S,descriptor> & T.Graph<S>:
  match store:
    case Store.Store{namespace,previous,failures,sequence,nextReader}:(Store.Store{namespace,graph,failures,sequence,nextReader},previous)
type Admission<-S:Data,-Source:Type> is Type:
  Ready{graph:T.Graph<S>,source:Source}
  Refused{source:Source}
type Publication<-S:Data,-descriptor:T.Descriptor<S>,-key:String,-origin:Layout.Layout,-Source:Type> is Type:
  Installed{slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin>,source:Source,previous:T.Graph<S>}
  Rejected{slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin>,source:Source}
def project(-S:Data,-descriptor:T.Descriptor<S>,store:Store.Store<S,descriptor>) -> Store.Store<S,descriptor> & Store.View<S,descriptor>:
  match store:
    case Store.Store{+namespace,+graph,failures,sequence,nextReader}:(Store.Store{namespace,graph,failures,sequence,nextReader},Store.View{namespace,graph})
def projected(-S:Data,-descriptor:T.Descriptor<S>,-key:String,-origin:Layout.Layout,-Source:Type,source:Source,previous:T.Graph<S>,stamp:Life.Stamp,result:Store.Store<S,descriptor> & Store.View<S,descriptor>) -> Publication<S,descriptor,key,origin,Source>:
  match result:
    case (store,view):Installed{Layout.ResourceSlot{Layout.Viewed{store,view},stamp},source,previous}
def replaced(-S:Data,-descriptor:T.Descriptor<S>,-key:String,-origin:Layout.Layout,-Source:Type,source:Source,stamp:Life.Stamp,result:Store.Store<S,descriptor> & T.Graph<S>) -> Publication<S,descriptor,key,origin,Source>:
  match result:
    case (store,previous):projected(S,descriptor,key,origin,Source,source,previous,stamp,project(S,descriptor,store))
def publish(~S:Data,~descriptor:T.Descriptor<S>,~key:String,~origin:Layout.Layout,~protected:{Layout.policy(origin,Layout.AtLeaf{}) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~Source:Type,slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin>,tick:Tick.Tick,admission:Admission<S,Source>) -> Publication<S,descriptor,key,origin,Source>:
  match slot admission:
    case slot Refused{source}:Rejected{slot,source}
    case Layout.ResourceSlot{Layout.Viewed{store,_},stamp} Ready{graph,source}:replaced(S,descriptor,key,origin,Source,source,Life.after_write(True{},True{},stamp,tick),replace(S,descriptor,store,graph))
