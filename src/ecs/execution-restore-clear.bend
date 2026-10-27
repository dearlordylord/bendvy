import Base
import ./execution-composer-layout.bend as Layout
import ./execution-command-publication.bend as Publish
import ./execution-command-permission.bend as Permission
import ./execution-command-buffer.bend as Buffer
import ./execution-command-removed.bend as Removed
import ./world.bend as W
import ./change-tick.bend as Tick

type Cleared<-S:Data,-layout:Layout.Layout,-route:Layout.Route,-R:Type,-E:Data> is Type:
  Cleared{world:W.World<S,Layout.columns(~S,layout),R,E>,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>}
  Interrupted{world:W.World<S,Layout.columns(~S,layout),R,E>,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>,remaining:List<&2,W.Handle<S>>}
def returned(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~R:Type,~E:Data,handle:W.Handle<S>,rest:List<&2,W.Handle<S>>,next:W.World<S,Layout.columns(~S,layout),R,E> -> List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>> -> Cleared<S,layout,route,R,E>,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>,result:W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>) -> Cleared<S,layout,route,R,E>:
  match result:
    case (world,Buffer.Despawned{target,removed}):next(world,Buffer.Despawned{target,removed} <> receipts)
    case (world,receipt):Interrupted{world,receipt <> receipts,handle <> rest}
def rows(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~R:Type,~E:Data,handles:List<&2,W.Handle<S>>,world:W.World<S,Layout.columns(~S,layout),R,E>,+tick:Tick.Tick,receipts:List<Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>>) -> Cleared<S,layout,route,R,E>:
  match handles:
    case []:Cleared{world,List.reverse(&1,Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>,receipts)}
    case +handle <> +rest:returned(~S,~layout,~route,~R,~E,handle,rest,nextWorld => nextReceipts => rows(~S,~layout,~route,~R,~E,rest,nextWorld,tick,nextReceipts),receipts,Publish.despawn_namespace(~S,~R,~E,~layout,~route,handle,Permission.EntityStructural{},W.namespace(~S,~Layout.columns(~S,layout),~R,~E,world),tick))
# Internal restore publication: callers prepare the receiver and stage all new
# owners first. Canonical despawn retains old owners and emits real notices.
# An unexpected refusal remains an explicit partial outcome with all receipts.
def clear(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~R:Type,~E:Data,handles:List<&2,W.Handle<S>>,world:W.World<S,Layout.columns(~S,layout),R,E>,tick:Tick.Tick) -> Cleared<S,layout,route,R,E>:
  rows(~S,~layout,~route,~R,~E,handles,world,tick,[])
