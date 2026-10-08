import Base
import ../fixture.bend as F
import ../export.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import ./gate.bend as Gate
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as GD
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Declaration

def projected_second(first:U32,observed:Array<U32> & U32) -> F.Payload & GD.Raw:
  match observed:
    case (values,second):(F.Payload{values},GD.Array{[GD.Number{first},GD.Number{second}]})
def projected_first(observed:Array<U32> & U32) -> F.Payload & GD.Raw:
  match observed:
    case (values,first):projected_second(first,Array.get(U32,values,1))
def project(owner:F.Payload) -> F.Payload & GD.Raw:
  match owner:
    case F.Payload{values}:projected_first(Array.get(U32,values,0))
def settings(~S:Data) -> Declaration.Declaration<S,F.Payload>:
  Declaration.component(~S,~F.Payload,"Settings")
def saved(~S:Data,owner:F.Payload) -> F.Payload & Gate.Field:
  Gate.export_owner(~S,~F.Payload,~F.declaration(~S),Gate.persisted(~S,~F.Payload,~F.declaration(~S),GD.ArrayValue{GD.Integer{}},project),owner)
def omitted(~S:Data,owner:F.Payload) -> F.Payload & Gate.Field:
  Gate.export_owner(~S,~F.Payload,~F.declaration(~S),Gate.transient(~S,~F.Payload,~F.declaration(~S)),owner)
def fields(field:Gate.Field) -> List<&2,D.Field>:
  match field:
    case Gate.Omitted{_}:[]
    case Gate.Saved{name,value}:[D.Field{name,value}]
def row_field(~S:Data,id:U32,observed:Col.Column<S,F.Payload> & Maybe<&2,Gate.Field>) -> Col.Column<S,F.Payload> & Export.Entity:
  match observed:
    case (column,None{}):(column,Export.Entity{id,[]})
    case (column,Some{field}):(column,Export.Entity{id,fields(field)})
def prepend(~S:Data,entity:Export.Entity,observed:Col.Column<S,F.Payload> & List<&2,Export.Entity>) -> Col.Column<S,F.Payload> & List<&2,Export.Entity>:
  match observed:
    case (column,entities):(column,entity <> entities)
def stepped(~S:Data,next:Col.Column<S,F.Payload> -> Col.Column<S,F.Payload> & List<&2,Export.Entity>,observed:Col.Column<S,F.Payload> & Export.Entity) -> Col.Column<S,F.Payload> & List<&2,Export.Entity>:
  match observed:
    case (column,entity):prepend(~S,entity,next(column))
def column_rows(~S:Data,~exporter:F.Payload -> F.Payload & Gate.Field,handles:List<&2,W.Handle<S>>,column:Col.Column<S,F.Payload>) -> Col.Column<S,F.Payload> & List<&2,Export.Entity>:
  match handles:
    case []:(column,[])
    case W.Handle{_,+id} <> rest:stepped(~S,next => column_rows(~S,~exporter,rest,next),row_field(~S,id,Col.view(~S,~F.Payload,~Gate.Field,~exporter,column,id)))
def rows_done(~S:Data,transient:Col.Column<S,F.Payload>,codec:D.Codec,observed:Col.Column<S,F.Payload> & List<&2,Export.Entity>) -> F.Store<S> & List<&2,Export.Entity>:
  match observed:
    case (saved,entities):(F.Store{saved,transient,codec},entities)
def rows_transient(~S:Data,handles:List<&2,W.Handle<S>>,savedColumn:Col.Column<S,F.Payload>,codec:D.Codec,observed:Col.Column<S,F.Payload> & List<&2,Export.Entity>) -> F.Store<S> & List<&2,Export.Entity>:
  match observed:
    case (transient,_):rows_done(~S,transient,codec,column_rows(~S,~saved(~S),handles,savedColumn))
def rows(~S:Data,+handles:List<&2,W.Handle<S>>,store:F.Store<S>) -> F.Store<S> & List<&2,Export.Entity>:
  match store:
    case F.Store{saved,transient,codec}:rows_transient(~S,handles,saved,codec,column_rows(~S,~omitted(~S),handles,transient))
def public_rows(~S:Data,handles:List<&2,W.Handle<S>>,store:F.Store<S>) -> F.Store<S> & List<&2,Export.Entity>:
  rows(~S,handles,store)
def resources_done(transient:F.Payload,codec:D.Codec,observed:F.Payload & Gate.Field) -> F.Resources & List<&2,D.Field>:
  match observed:
    case (saved,field):(F.Resources{saved,transient,codec},fields(field))
def transient_resource(~S:Data,saved:F.Payload,codec:D.Codec,observed:F.Payload & Gate.Field) -> F.Resources & List<&2,D.Field>:
  match observed:
    case (transient,_):resources_done(transient,codec,Gate.export_owner(~S,~F.Payload,~settings(~S),Gate.persisted(~S,~F.Payload,~settings(~S),GD.ArrayValue{GD.Integer{}},project),saved))
def resources(~S:Data,owner:F.Resources) -> F.Resources & List<&2,D.Field>:
  match owner:
    case F.Resources{saved,transient,codec}:transient_resource(~S,saved,codec,Gate.export_owner(~S,~F.Payload,~settings(~S),Gate.transient(~S,~F.Payload,~settings(~S)),transient))
# Existing BasicWorld boundary and existing Gate static eligibility contract.
# Schema-authored Gate factories are rebuilt per observation, never duplicated.
def save(~S:Data,world:W.World<S,F.Store<S>,F.Resources,Unit>) -> W.World<S,F.Store<S>,F.Resources,Unit> & Export.Snapshot:
  Export.basic(~S,~F.Store<S>,~F.Resources,~Unit,~public_rows(~S),~resources(~S),world)
