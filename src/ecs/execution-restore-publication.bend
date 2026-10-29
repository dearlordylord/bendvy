import Base
import ./execution-composer-layout.bend as Layout
import ./execution-reservation-bundle.bend as Bundle
import ./execution-reservation-materialization.bend as Materialize
import ./execution-command-permission.bend as Permission
import ./restore-data.bend as R
import ./entity-key.bend as Key
import ./world.bend as W
import ./change-tick.bend as Tick

type Row<-layout:Layout.Layout> is Type:Row{saved:Key.Key,bundle:Bundle.Payload(layout)}
type Receipt<-S:Data,-layout:Layout.Layout> is Type:
  Materialized{saved:Key.Key,handle:W.Handle<S>,previous:Bundle.Payload(layout)}
  AllocationRefused{saved:Key.Key,bundle:Bundle.Payload(layout)}
  PublicationRefused{saved:Key.Key,handle:W.Handle<S>,bundle:Bundle.Payload(layout),reason:Bundle.Refusal}
type Published<-S:Data,-layout:Layout.Layout,-Resource:Type,-E:Data> is Type:
  Published{world:W.World<S,Layout.columns(~S,layout),Resource,E>,mapping:List<&2,R.Binding<S>>,receipts:List<Receipt<S,layout>>,complete:Bool}
def materialized(~S:Data,~layout:Layout.Layout,~Resource:Type,~E:Data,saved:Key.Key,result:Bundle.Publication<S,Layout.columns(~S,layout),Resource,E,layout>) -> W.World<S,Layout.columns(~S,layout),Resource,E> & Receipt<S,layout>:
  match result:
    case Bundle.Materialized{world,handle,previous}:(world,Materialized{saved,handle,previous})
    case Bundle.RefusedPublication{world,handle,bundle,reason}:(world,PublicationRefused{saved,handle,bundle,reason})
def reserved(~S:Data,~layout:Layout.Layout,~Resource:Type,~E:Data,saved:Key.Key,bundle:Bundle.Payload(layout),tick:Tick.Tick,result:W.World<S,Layout.columns(~S,layout),Resource,E> & W.Reservation<S>) -> W.World<S,Layout.columns(~S,layout),Resource,E> & Receipt<S,layout>:
  match result:
    case (world,W.ReservationRejected{_}):(world,AllocationRefused{saved,bundle})
    case (world,W.Reserved{+handle}):materialized(~S,~layout,~Resource,~E,saved,Materialize.apply_at(~S,~Resource,~E,~layout,Permission.EntityStructural{},W.mark_pending(~S,~Layout.columns(~S,layout),~Resource,~E,world,handle),handle,bundle,tick))
def returned(~S:Data,~layout:Layout.Layout,~Resource:Type,~E:Data,next:W.World<S,Layout.columns(~S,layout),Resource,E> -> List<&2,R.Binding<S>> -> List<Receipt<S,layout>> -> Bool -> Published<S,layout,Resource,E>,mapping:List<&2,R.Binding<S>>,receipts:List<Receipt<S,layout>>,complete:Bool,result:W.World<S,Layout.columns(~S,layout),Resource,E> & Receipt<S,layout>) -> Published<S,layout,Resource,E>:
  match result:
    case (world,Materialized{+saved,+handle,previous}):next(world,R.Binding{saved,handle} <> mapping,Materialized{saved,handle,previous} <> receipts,complete)
    case (world,receipt):next(world,mapping,receipt <> receipts,False{})
def rows(~S:Data,~layout:Layout.Layout,~Resource:Type,~E:Data,values:List<Row<layout>>,world:W.World<S,Layout.columns(~S,layout),Resource,E>,+tick:Tick.Tick,mapping:List<&2,R.Binding<S>>,receipts:List<Receipt<S,layout>>,complete:Bool) -> Published<S,layout,Resource,E>:
  match values:
    case []:Published{world,List.reverse(&2,R.Binding<S>,mapping),List.reverse(&1,Receipt<S,layout>,receipts),complete}
    case Row{saved,bundle} <> rest:returned(~S,~layout,~Resource,~E,nextWorld => nextMapping => nextReceipts => nextComplete => rows(~S,~layout,~Resource,~E,rest,nextWorld,tick,nextMapping,nextReceipts,nextComplete),mapping,receipts,complete,reserved(~S,~layout,~Resource,~E,saved,bundle,tick,W.reserve_id(~S,~Layout.columns(~S,layout),~Resource,~E,world)))
# All incoming owners finish either in the receiver or an explicit refusal
# receipt. A failed row marks the whole result partial; later rows are retained
# and attempted once. Only canonical fresh receiver handles enter the map.
def publish(~S:Data,~layout:Layout.Layout,~Resource:Type,~E:Data,values:List<Row<layout>>,world:W.World<S,Layout.columns(~S,layout),Resource,E>,tick:Tick.Tick) -> Published<S,layout,Resource,E>:
  rows(~S,~layout,~Resource,~E,values,world,tick,[],[],True{})
