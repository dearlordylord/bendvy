import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import ./export.bend as Export

# One persisted column provider. Col.view preserves the actual affine cell.
# Complete schema assembly must merge all selected fields per entity; this leaf
# does not yet implement arbitrary heterogeneous registry enumeration.
def row_field(~S:Data,~P:Type,name:String,id:U32,observed:Col.Column<S,P> & Maybe<&2,D.Raw>) -> Col.Column<S,P> & Export.Entity:
  match observed:
    case (column,None{}):(column,Export.Entity{id,[]})
    case (column,Some{value}):(column,Export.Entity{id,[D.Field{name,value}]})
def rows_prepend(~S:Data,~P:Type,entity:Export.Entity,observed:Col.Column<S,P> & List<&2,Export.Entity>) -> Col.Column<S,P> & List<&2,Export.Entity>:
  match observed:
    case (column,entities):(column,entity <> entities)
def rows_step(~S:Data,~P:Type,next:Col.Column<S,P> -> Col.Column<S,P> & List<&2,Export.Entity>,observed:Col.Column<S,P> & Export.Entity) -> Col.Column<S,P> & List<&2,Export.Entity>:
  match observed:
    case (column,entity):rows_prepend(~S,~P,entity,next(column))
def rows(~S:Data,~P:Type,~project:P -> P & D.Raw,+name:String,handles:List<&2,W.Handle<S>>,column:Col.Column<S,P>) -> Col.Column<S,P> & List<&2,Export.Entity>:
  match handles:
    case []:(column,[])
    case W.Handle{_,+id} <> rest:rows_step(~S,~P,next => rows(~S,~P,~project,name,rest,next),row_field(~S,~P,name,id,Col.view(~S,~P,~D.Raw,~project,column,id)))
