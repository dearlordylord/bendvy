import Base
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Declaration
import ./save.bend as Save
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
def retained_store_codec(~S:Data,store:F.Store<S>) -> F.Store<S> & D.Codec:
  match store:
    case F.Store{saved,transient,+codec}:(F.Store{saved,transient,codec},gate_codec(~S,~F.declaration(~S),Save.component_gate(~S,codec)))
def retained_resource_codec(~S:Data,resource:F.Resources) -> F.Resources & D.Codec:
  match resource:
    case F.Resources{saved,transient,+codec}:(F.Resources{saved,transient,codec},gate_codec(~S,~Save.settings(~S),Save.resource_gate(~S,codec)))
def checked(receipt:D.Receipt<Unit>) -> D.Checked:
  match receipt:
    case D.Receipt{_,result}:result
def checked_fields(+codec:D.Codec,fields:List<&2,D.Field>) -> List<&2,CheckedField>:
  match fields:
    case []:[]
    case D.Field{name,value} <> rest:CheckedField{name,checked(D.owned(~Unit,128n,codec,D.Owned{Unit{},value}))} <> checked_fields(codec,rest)
def checked_entities(+codec:D.Codec,entities:List<&2,Export.Entity>) -> List<&2,CheckedEntity>:
  match entities:
    case []:[]
    case Export.Entity{id,fields} <> rest:CheckedEntity{id,checked_fields(codec,fields)} <> checked_entities(codec,rest)
def finished_values(~S:Data,entities:List<&2,Export.Entity>,resources:List<&2,D.Field>,componentCodec:D.Codec,observed:W.World<S,F.Store<S>,F.Resources,Unit> & D.Codec) -> W.World<S,F.Store<S>,F.Resources,Unit> & Validation:
  match observed:
    case (world,resourceCodec):(world,Validation{checked_entities(componentCodec,entities),checked_fields(resourceCodec,resources)})
def finished(~S:Data,snapshot:Export.Snapshot,componentCodec:D.Codec,observed:W.World<S,F.Store<S>,F.Resources,Unit> & D.Codec) -> W.World<S,F.Store<S>,F.Resources,Unit> & Validation:
  match snapshot:
    case Export.Snapshot{_,_,entities,resources}:finished_values(~S,entities,resources,componentCodec,observed)
def component_codec(~S:Data,snapshot:Export.Snapshot,observed:W.World<S,F.Store<S>,F.Resources,Unit> & D.Codec) -> W.World<S,F.Store<S>,F.Resources,Unit> & Validation:
  match observed:
    case (world,codec):finished(~S,snapshot,codec,W.observe_resource(~S,~F.Store<S>,~F.Resources,~Unit,~D.Codec,~retained_resource_codec(~S),world))
# Internal diagnostic only: validates detached Data using actual retained codecs.
# Does not turn rejection into a public save refusal or manufacture payloads.
def validate(~S:Data,snapshot:Export.Snapshot,world:W.World<S,F.Store<S>,F.Resources,Unit>) -> W.World<S,F.Store<S>,F.Resources,Unit> & Validation:
  component_codec(~S,snapshot,W.with_store(~S,~F.Store<S>,~F.Resources,~Unit,~D.Codec,retained_store_codec(~S),world))
