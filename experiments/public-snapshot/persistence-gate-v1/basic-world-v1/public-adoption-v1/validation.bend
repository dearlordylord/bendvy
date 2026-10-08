import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Declaration
import ./game.bend as Game
import ./leaf.bend as Leaf
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-product.bend as Product
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/decode.bend as Complete
import ../public-gate-v1/gate.bend as Gate
import ../fixture.bend as F
import ../export.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D

type CheckedField is Data:
  CheckedField{name:String,result:D.Checked}
type CheckedEntity is Data:
  CheckedEntity{id:U32,fields:List<&2,CheckedField>}
type Validation is Data:
  Validation{entities:List<&2,CheckedEntity>,resources:List<&2,CheckedField>}
# Internal diagnostic consumes the actual factory witness, not a parallel codec.
def gate_codec(~S:Data,~declaration:Declaration.Declaration<S,F.Payload>,gate:Gate.Gate<S,F.Payload,declaration>) -> D.Codec:
  match gate:
    case Gate.Persisted{codec,_}:codec
    case Gate.Transient{}:D.LiteralValues{[]}
def retained_store_codec(~S:Data,store:Game.Store(~S)) -> Game.Store(~S) & D.Codec:
  match store:
    case Product.Owner{Product.Owner{Leaf.Component{saved,+declaration},transient},units}:(Product.Owner{Product.Owner{Leaf.Component{saved,declaration},transient},units},gate_codec(~S,~F.declaration(~S),Leaf.factory(~S,~F.Payload,~F.declaration(~S),~F.project,declaration)))
def retained_resource_codec(~S:Data,resource:Game.ResourceStore(~S)) -> Game.ResourceStore(~S) & D.Codec:
  match resource:
    case Product.Owner{units,Product.Owner{Leaf.Resource{saved,+declaration},transient}}:(Product.Owner{units,Product.Owner{Leaf.Resource{saved,declaration},transient}},gate_codec(~S,~Game.settings(~S),Leaf.factory(~S,~F.Payload,~Game.settings(~S),~F.project,declaration)))
def projected_owned(+value:D.Raw) -> D.Raw & D.Raw:
  (value,value)
def projected(value:D.Raw) -> D.Raw & D.Raw:
  projected_owned(value)
def checked(receipt:D.Receipt<D.Raw>) -> D.Checked:
  match receipt:
    case D.Receipt{_,result}:result
def checked_fields(+codec:D.Codec,fields:List<&2,D.Field>) -> List<&2,CheckedField>:
  match fields:
    case []:[]
    case D.Field{name,value} <> rest:CheckedField{name,checked(Complete.decode_owner(~D.Raw,~projected,codec,value))} <> checked_fields(codec,rest)
def checked_entities(+codec:D.Codec,entities:List<&2,Export.Entity>) -> List<&2,CheckedEntity>:
  match entities:
    case []:[]
    case Export.Entity{id,fields} <> rest:CheckedEntity{id,checked_fields(codec,fields)} <> checked_entities(codec,rest)
def finished_values(~S:Data,entities:List<&2,Export.Entity>,resources:List<&2,D.Field>,componentCodec:D.Codec,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & D.Codec) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Validation:
  match observed:
    case (world,resourceCodec):(world,Validation{checked_entities(componentCodec,entities),checked_fields(resourceCodec,resources)})
def finished(~S:Data,snapshot:Export.Snapshot,componentCodec:D.Codec,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & D.Codec) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Validation:
  match snapshot:
    case Export.Snapshot{_,_,entities,resources}:finished_values(~S,entities,resources,componentCodec,observed)
def component_codec(~S:Data,snapshot:Export.Snapshot,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & D.Codec) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Validation:
  match observed:
    case (world,codec):finished(~S,snapshot,codec,W.observe_resource(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~D.Codec,~retained_resource_codec(~S),world))
# Internal diagnostic only: validates detached Data using actual retained codecs.
# Does not turn rejection into a public save refusal or manufacture payloads.
def validate(~S:Data,snapshot:Export.Snapshot,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Validation:
  component_codec(~S,snapshot,W.with_store(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~D.Codec,retained_store_codec(~S),world))
