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
def foreign(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Events:Type,~eventFold:Events -> Events & List<&2,Access.Entry>,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,~components:C -> U32 -> C & List<&2,Maybe<&2,String>>,~resources:R -> R & List<&2,Maybe<&2,String>>,~Other:Data,presentation:Presentation.Recipe<S,C,R,count,components,resources>,component:Filter.Component<Other>,app:App.Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold>) -> App.Application<S,C,R,E,H,Rows,observe,fold,Events,eventFold> & Maybe<&2,Dump.Dump<S>>:
  App.dump(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Events,~eventFold,~count,~components,~resources,presentation,Filter.Filter{None{},[component],None{}},app)
def main() -> Unit:Unit{}
