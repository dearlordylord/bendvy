import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
# Selector values and requirements retain their actual nominal Data types.
# No caller metadata, rendering adapter, or state-universe inference.
type RegistryView is Data:
  RegistryView{ordinal:U32,namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type EntryView<S:Data,K:Data,V:Data,Q:Data> is Data:
  EntryView{selector:B.Selector<S,K,V>,requirements:List<&2,Q>,registry:RegistryView}
type BundleView<S:Data,K:Data,V:Data,Q:Data> is Data:
  BundleView{namespace:U32,entries:List<&2,EntryView<S,K,V,Q>>}
def registry(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,entry:H.Entry<S,C,R,E,V,runner>) -> H.Entry<S,C,R,E,V,runner> & RegistryView:
  match entry:
    case H.Entry{+ordinal,Sys.Registry{+ns,+id,+name,+access,+cursor}}:(H.Entry{ordinal,Sys.Registry{ns,id,name,access,cursor}},RegistryView{ordinal,ns,id,name,access,cursor})
def one_seen(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,+selector:B.Selector<S,K,V>,+needs:List<&2,Q>,got:H.Entry<S,C,R,E,V,runner> & RegistryView) -> B.Scheduled<S,K,V,Q,C,R,E,runner> & EntryView<S,K,V,Q>:
  match got:
    case (entry,view):(B.Scheduled{selector,needs,entry},EntryView{selector,needs,view})
def one(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,scheduled:B.Scheduled<S,K,V,Q,C,R,E,runner>) -> B.Scheduled<S,K,V,Q,C,R,E,runner> & EntryView<S,K,V,Q>:
  match scheduled:
    case B.Scheduled{selector,needs,entry}:one_seen(~S,~K,~V,~Q,~C,~R,~E,~runner,selector,needs,registry(~S,~K,~V,~Q,~C,~R,~E,~runner,entry))
def joined(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,head:B.Scheduled<S,K,V,Q,C,R,E,runner>,view:EntryView<S,K,V,Q>,tail:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>) -> List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>:
  match tail:
    case (rest,views):(head <> rest,view <> views)
def headed(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,head:B.Scheduled<S,K,V,Q,C,R,E,runner> & EntryView<S,K,V,Q>,tail:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>) -> List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>:
  match head:
    case (owner,view):joined(~S,~K,~V,~Q,~C,~R,~E,~runner,owner,view,tail)
def entries(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,items:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>) -> List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>:
  match items:
    case []:([],[])
    case first <> rest:headed(~S,~K,~V,~Q,~C,~R,~E,~runner,one(~S,~K,~V,~Q,~C,~R,~E,~runner,first),entries(~S,~K,~V,~Q,~C,~R,~E,~runner,rest))
def bundled(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,+ns:U32,got:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>) -> B.Bundle<S,K,V,Q,C,R,E,runner> & BundleView<S,K,V,Q>:
  match got:
    case (owners,views):(B.Bundle{ns,owners},BundleView{ns,views})
def inspect(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>) -> B.Bundle<S,K,V,Q,C,R,E,runner> & BundleView<S,K,V,Q>:
  match bundle:
    case B.Bundle{ns,owners}:bundled(~S,~K,~V,~Q,~C,~R,~E,~runner,ns,entries(~S,~K,~V,~Q,~C,~R,~E,~runner,owners))
type OwnersView is Data:
  OwnersView{exit:List<&2,RegistryView>,transition:List<&2,RegistryView>,enter:List<&2,RegistryView>}
type RecoveryView<S:Data,K:Data,V:Data,Q:Data> is Data:
  RecoveryView{entries:List<&2,EntryView<S,K,V,Q>>,positions:List<&2,B.Position<S,K,V,Q>>,kept:List<&2,RegistryView>,owners:OwnersView}
def registries_join(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,owner:H.Entry<S,C,R,E,V,runner>,view:RegistryView,got:List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>) -> List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>:
  match got:
    case (rest,views):(owner <> rest,view <> views)
def registries_head(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,head:H.Entry<S,C,R,E,V,runner> & RegistryView,tail:List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>) -> List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>:
  match head:
    case (owner,view):registries_join(~S,~K,~V,~Q,~C,~R,~E,~runner,owner,view,tail)
def registries(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,items:List<&1,H.Entry<S,C,R,E,V,runner>>) -> List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>:
  match items:
    case []:([],[])
    case head <> rest:registries_head(~S,~K,~V,~Q,~C,~R,~E,~runner,registry(~S,~K,~V,~Q,~C,~R,~E,~runner,head),registries(~S,~K,~V,~Q,~C,~R,~E,~runner,rest))
def owners_enter(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,exit:List<&1,H.Entry<S,C,R,E,V,runner>>,exitView:List<&2,RegistryView>,transition:List<&1,H.Entry<S,C,R,E,V,runner>>,transitionView:List<&2,RegistryView>,got:List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>) -> H.Owners<S,C,R,E,V,runner> & OwnersView:
  match got:
    case (enter,enterView):(H.Owners{exit,transition,enter},OwnersView{exitView,transitionView,enterView})
def owners_transition(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,exit:List<&1,H.Entry<S,C,R,E,V,runner>>,exitView:List<&2,RegistryView>,enter:List<&1,H.Entry<S,C,R,E,V,runner>>,got:List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>) -> H.Owners<S,C,R,E,V,runner> & OwnersView:
  match got:
    case (transition,view):owners_enter(~S,~K,~V,~Q,~C,~R,~E,~runner,exit,exitView,transition,view,registries(~S,~K,~V,~Q,~C,~R,~E,~runner,enter))
def owners_exit(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,transition:List<&1,H.Entry<S,C,R,E,V,runner>>,enter:List<&1,H.Entry<S,C,R,E,V,runner>>,got:List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>) -> H.Owners<S,C,R,E,V,runner> & OwnersView:
  match got:
    case (exit,view):owners_transition(~S,~K,~V,~Q,~C,~R,~E,~runner,exit,view,enter,registries(~S,~K,~V,~Q,~C,~R,~E,~runner,transition))
def owners(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,owner:H.Owners<S,C,R,E,V,runner>) -> H.Owners<S,C,R,E,V,runner> & OwnersView:
  match owner:
    case H.Owners{exit,transition,enter}:owners_exit(~S,~K,~V,~Q,~C,~R,~E,~runner,transition,enter,registries(~S,~K,~V,~Q,~C,~R,~E,~runner,exit))
def recovery_owners(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,items:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>,views:List<&2,EntryView<S,K,V,Q>>,+positions:List<&2,B.Position<S,K,V,Q>>,kept:List<&1,H.Entry<S,C,R,E,V,runner>>,keptView:List<&2,RegistryView>,got:H.Owners<S,C,R,E,V,runner> & OwnersView) -> B.Recovery<S,K,V,Q,C,R,E,runner> & RecoveryView<S,K,V,Q>:
  match got:
    case (owner,view):(B.Recovery{items,positions,kept,owner},RecoveryView{views,positions,keptView,view})
def recovery_kept(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,items:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>,views:List<&2,EntryView<S,K,V,Q>>,positions:List<&2,B.Position<S,K,V,Q>>,owner:H.Owners<S,C,R,E,V,runner>,got:List<&1,H.Entry<S,C,R,E,V,runner>> & List<&2,RegistryView>) -> B.Recovery<S,K,V,Q,C,R,E,runner> & RecoveryView<S,K,V,Q>:
  match got:
    case (kept,view):recovery_owners(~S,~K,~V,~Q,~C,~R,~E,~runner,items,views,positions,kept,view,owners(~S,~K,~V,~Q,~C,~R,~E,~runner,owner))
def recovery_entries(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,positions:List<&2,B.Position<S,K,V,Q>>,kept:List<&1,H.Entry<S,C,R,E,V,runner>>,owner:H.Owners<S,C,R,E,V,runner>,got:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>) -> B.Recovery<S,K,V,Q,C,R,E,runner> & RecoveryView<S,K,V,Q>:
  match got:
    case (items,views):recovery_kept(~S,~K,~V,~Q,~C,~R,~E,~runner,items,views,positions,owner,registries(~S,~K,~V,~Q,~C,~R,~E,~runner,kept))
def recovery(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,owner:B.Recovery<S,K,V,Q,C,R,E,runner>) -> B.Recovery<S,K,V,Q,C,R,E,runner> & RecoveryView<S,K,V,Q>:
  match owner:
    case B.Recovery{items,positions,kept,owner}:recovery_entries(~S,~K,~V,~Q,~C,~R,~E,~runner,positions,kept,owner,entries(~S,~K,~V,~Q,~C,~R,~E,~runner,items))
