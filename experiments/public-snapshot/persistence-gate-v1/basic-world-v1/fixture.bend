import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import ./export.bend as Export
import ./column-provider.bend as Provider
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Definition

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Payload is Type:
  Payload{values:Array<U32>}
type Store<-S:Data> is Type:
  Store{saved:Col.Column<S,Payload>,transient:Col.Column<S,Payload>,codec:D.Codec}
type Resources is Type:
  Resources{saved:Payload,transient:Payload,codec:D.Codec}
def payload(first:U32,second:U32) -> Payload:
  Payload{Array.set(U32,Array.new(U32,1n,first),1,second)}
def projected_second(first:U32,observed:Array<U32> & U32) -> Payload & D.Raw:
  match observed:
    case (values,second):(Payload{values},D.Array{[D.Number{first},D.Number{second}]})
def projected_first(observed:Array<U32> & U32) -> Payload & D.Raw:
  match observed:
    case (values,first):projected_second(first,Array.get(U32,values,1))
def project(owner:Payload) -> Payload & D.Raw:
  match owner:
    case Payload{values}:projected_first(Array.get(U32,values,0))
def declaration(~S:Data) -> Definition.Declaration<S,Payload>:
  Definition.component(~S,~Payload,"Payload")
def saved_key(~S:Data) -> String:
  Definition.key(~S,~Payload,declaration(~S))
def empty(~S:Data,_:Unit) -> Store<S>:
  Store{Col.empty(~S,~Payload),Col.empty(~S,~Payload),D.ArrayValue{D.Integer{}}}
def rows_done(~S:Data,transient:Col.Column<S,Payload>,codec:D.Codec,observed:Col.Column<S,Payload> & List<&2,Export.Entity>) -> Store<S> & List<&2,Export.Entity>:
  match observed:
    case (saved,entities):(Store{saved,transient,codec},entities)
def rows(~S:Data,handles:List<&2,W.Handle<S>>,store:Store<S>) -> Store<S> & List<&2,Export.Entity>:
  match store:
    case Store{saved,transient,codec}:rows_done(~S,transient,codec,Provider.rows(~S,~Payload,~project,saved_key(~S),handles,saved))
def resources_done(transient:Payload,codec:D.Codec,observed:Payload & D.Raw) -> Resources & List<&2,D.Field>:
  match observed:
    case (saved,value):(Resources{saved,transient,codec},[D.Field{"Settings",value}])
def resources(owner:Resources) -> Resources & List<&2,D.Field>:
  match owner:
    case Resources{saved,transient,codec}:resources_done(transient,codec,project(saved))
def save(~S:Data,world:W.World<S,Store<S>,Resources,Unit>) -> W.World<S,Store<S>,Resources,Unit> & Export.Snapshot:
  Export.basic(~S,~Store<S>,~Resources,~Unit,~rows(~S),~resources,world)
