import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-access.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema-dump.bend as Presentation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-population.bend as Population
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~Owner:Type,result:Owner & U32) -> App.Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,App.RuntimeView<E>>:
  match result:
    case (owner,_):App.runtime_view(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,owner)
def read(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~Owner:Type,grant:Cap.ValueRead<Owner,U32>,owner:Owner) -> App.Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,App.RuntimeView<E>>:
  observed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~Owner,Cap.value_read_field(~Owner,~U32,grant)(owner))
def main() -> Unit:Unit{}
