import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Owner:Type,result:Owner & U32) -> App.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,App.Description<S,Rows>>:
  match result:
    case (owner,_):App.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,owner)
def invalid(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Owner:Type,grant:Cap.ValueRead<Owner,U32>,owner:Owner) -> App.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,App.Description<S,Rows>>:observed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Owner,Cap.value_read_field(~Owner,~U32,grant)(owner))
def main() -> Unit:Unit{}
