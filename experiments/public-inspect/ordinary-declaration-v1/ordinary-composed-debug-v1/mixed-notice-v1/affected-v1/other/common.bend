import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import ./state.bend as F
import ./event-setup.bend as Events
import ./runtime.bend as Mixed
import ./application.bend as Adapter
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Recipe
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route

def Rows() -> Data:Relation.ObservedRows(~F.S,~Unit)
def observe() -> F.World() -> F.World() & DTO.Observation<Rows()>:Recipe.observe_pair(~F.World(),~Unit,~Relation.View<F.S>,~Build.empty_observe(~F.World()),~Relation.observe(~F.S,~Array<U32>,~F.Resources(),~F.Publications(),~F.parent(),~Relation.builtin_row(~F.S)))
def Application() -> Type:App.Application<F.S,F.Store(),F.Resources(),F.Events(),Events.State(),Unit,Rows(),observe(),Records.empty(~F.S)>
def from_registered(state:Events.State(),tick:Nat,value:Relation.Application(~F.S,~Array<U32>,~F.Resources(),~F.Publications(),~F.parent(),~Unit,~Unit,~Build.empty_observe(~F.World()),~Records.empty(~F.S))) -> Application():
  match value:
    case Build.Registered{world,owners,recipe,debug}:App.Application{Schema.Schema{[]},Route.Runtime{world,state,tick},owners,recipe,debug}
def attach(runtime:Events.Runtime()) -> Application():
  match runtime:
    case Route.Runtime{world,state,tick}:from_registered(state,tick,Relation.install(~F.S,~Array<U32>,~F.Resources(),~F.Publications(),~F.parent(),~Unit,~Unit,~Build.empty_observe(~F.World()),~Records.empty(~F.S),Build.empty(~F.S,~F.World(),world)))
def detach(value:Application()) -> Events.Runtime():
  match value:
    case App.Application{_,runtime,_,_,_}:runtime
def enabled(value:Application(),flag:Bool) -> Application():App.enabled(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Events.State(),~Unit,~Rows(),~observe(),~Records.empty(~F.S),value,flag)
def snapshot(value:Application()) -> Application() & Maybe<&2,SchemaApp.Description<F.S,Rows()>>:App.snapshot(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Events.State(),~Unit,~Rows(),~observe(),~Records.empty(~F.S),value)
def inventory(value:Application()) -> Application() & Maybe<&2,List<&2,String>>:Adapter.inventory(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.inventory(),~Unit,~Rows(),~observe(),~Records.empty(~F.S),value)
