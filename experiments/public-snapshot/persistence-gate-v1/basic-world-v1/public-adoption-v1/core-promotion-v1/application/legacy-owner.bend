import Base
import ./legacy-fixture.bend as F
import ./legacy-column-provider.bend as Provider
import ../library/snapshot-data.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import ../library/decode-data.bend as D

type ColumnOwner is Data:
  ColumnOwner{rows:List<&2,Export.Entity>,first:L.Stamp,second:L.Stamp}
type StoreOwner is Data:
  StoreOwner{saved:ColumnOwner,transient:ColumnOwner,codec:D.Codec}
type ResourceOwner is Data:
  ResourceOwner{saved:D.Raw,transient:D.Raw,codec:D.Codec}
def column_second(~S:Data,rows:List<&2,Export.Entity>,first:L.Stamp,observed:Col.Column<S,F.Payload> & L.Stamp) -> Col.Column<S,F.Payload> & ColumnOwner:
  match observed:
    case (column,second):(column,ColumnOwner{rows,first,second})
def column_first(~S:Data,rows:List<&2,Export.Entity>,observed:Col.Column<S,F.Payload> & L.Stamp) -> Col.Column<S,F.Payload> & ColumnOwner:
  match observed:
    case (column,first):column_second(~S,rows,first,Col.lifecycle(~S,~F.Payload,column,2))
def column_rows(~S:Data,observed:Col.Column<S,F.Payload> & List<&2,Export.Entity>) -> Col.Column<S,F.Payload> & ColumnOwner:
  match observed:
    case (column,rows):column_first(~S,rows,Col.lifecycle(~S,~F.Payload,column,1))
def column(~S:Data,name:String,handles:List<&2,W.Handle<S>>,column:Col.Column<S,F.Payload>) -> Col.Column<S,F.Payload> & ColumnOwner:
  column_rows(~S,Provider.rows(~S,~F.Payload,~F.project,name,handles,column))
def transient_done(~S:Data,saved:Col.Column<S,F.Payload>,savedData:ColumnOwner,+codec:D.Codec,observed:Col.Column<S,F.Payload> & ColumnOwner) -> F.Store<S> & StoreOwner:
  match observed:
    case (transient,transientData):(F.Store{saved,transient,codec},StoreOwner{savedData,transientData,codec})
def saved_done(~S:Data,handles:List<&2,W.Handle<S>>,transient:Col.Column<S,F.Payload>,codec:D.Codec,observed:Col.Column<S,F.Payload> & ColumnOwner) -> F.Store<S> & StoreOwner:
  match observed:
    case (saved,savedData):transient_done(~S,saved,savedData,codec,column(~S,"Scratch",handles,transient))
def store(~S:Data,+handles:List<&2,W.Handle<S>>,owner:F.Store<S>) -> F.Store<S> & StoreOwner:
  match owner:
    case F.Store{saved,transient,+codec}:saved_done(~S,handles,transient,codec,column(~S,F.saved_key(~S),handles,saved))
def resource_transient(saved:F.Payload,savedData:D.Raw,+codec:D.Codec,observed:F.Payload & D.Raw) -> F.Resources & ResourceOwner:
  match observed:
    case (transient,transientData):(F.Resources{saved,transient,codec},ResourceOwner{savedData,transientData,codec})
def resource_saved(transient:F.Payload,codec:D.Codec,observed:F.Payload & D.Raw) -> F.Resources & ResourceOwner:
  match observed:
    case (saved,savedData):resource_transient(saved,savedData,codec,F.project(transient))
def resource(owner:F.Resources) -> F.Resources & ResourceOwner:
  match owner:
    case F.Resources{saved,transient,+codec}:resource_saved(transient,codec,F.project(saved))
