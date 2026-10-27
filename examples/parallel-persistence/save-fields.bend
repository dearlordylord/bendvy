import Base
import ./declarations.bend as D
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-schema.bend as Schema
import ../../src/ecs/execution-reservation-materialization.bend as Materialize
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

def Columns(~S:Data) -> Type:Layout.columns(~S,Plan.layout(D.components(~S)))
def Resources(~S:Data) -> Type:Layout.resources(~S,Plan.layout(D.resources(~S)))
def World(~S:Data) -> Type:W.World<S,Columns(~S),Resources(~S),Unit>
type SavedApplication<-S:Data> is Type:
  Exported{schema:Plan.Schema<S,D.components(~S),D.resources(~S)>,world:World(~S),outcome:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
  AllocationRefused{world:World(~S)}
  PublicationRefused{world:World(~S),handle:W.Handle<S>,bundle:Bundle.Payload(Plan.layout(D.components(~S))),reason:Bundle.Refusal}
  CreationRefused{resources:Resources(~S)}
def saved(~S:Data,result:Plan.Schema<S,D.components(~S),D.resources(~S)> & (World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> SavedApplication<S>:
  match result:
    case (schema,(world,outcome)):Exported{schema,world,outcome}
def published(~S:Data,result:Bundle.Publication<S,Columns(~S),Resources(~S),Unit,Plan.layout(D.components(~S))>) -> SavedApplication<S>:
  match result:
    case Bundle.Materialized{world,_,_}:saved(~S,Save.save(~S,~D.components(~S),~D.resources(~S),~Unit,D.schema(~S),world))
    case Bundle.RefusedPublication{world,handle,bundle,reason}:PublicationRefused{world,handle,bundle,reason}
def materialized(~S:Data,handle:W.Handle<S>,world:World(~S),tick:Tick.Tick) -> SavedApplication<S>:
  published(~S,Materialize.apply_at(~S,~Resources(~S),~Unit,~Plan.layout(D.components(~S)),Permission.EntityStructural{},world,handle,Product.Owner{Some{D.Actor{"ordinary",ALeaf{41}}},Some{D.Scratch{ALeaf{808}}}},tick))
def clocked(~S:Data,handle:W.Handle<S>,result:World(~S) & Tick.Tick) -> SavedApplication<S>:
  match result:
    case (world,tick):materialized(~S,handle,world,tick)
def allocated(~S:Data,result:World(~S) & W.Reservation<S>) -> SavedApplication<S>:
  match result:
    case (world,W.ReservationRejected{_}):AllocationRefused{world}
    case (world,W.Reserved{+handle}):clocked(~S,handle,W.clock(~S,~Columns(~S),~Resources(~S),~Unit,W.mark_pending(~S,~Columns(~S),~Resources(~S),~Unit,world,handle)))
# Trusted initial population reuses the canonical Pending materializer. Ordinary
# execution and its retained queue gate remain the application's responsibility.
def created(~S:Data,result:W.Creation<S,Columns(~S),Resources(~S),Unit>) -> SavedApplication<S>:
  match result:
    case W.Created{_,world}:allocated(~S,W.reserve_id(~S,~Columns(~S),~Resources(~S),~Unit,Schema.initialized_world(~S,~Plan.layout(D.components(~S)),~Plan.layout(D.resources(~S)),~Unit,world)))
    case W.CreateRejected{_,resources}:CreationRefused{resources}
def ordinary_alpha() -> SavedApplication<D.Alpha>:
  created(~D.Alpha,W.create(~D.Alpha,~Columns(~D.Alpha),~Resources(~D.Alpha),~Unit,~D.empty(~D.Alpha),W.factory(),D.initial_resources(~D.Alpha)))
def ordinary_beta() -> SavedApplication<D.Beta>:
  created(~D.Beta,W.create(~D.Beta,~Columns(~D.Beta),~Resources(~D.Beta),~Unit,~D.empty(~D.Beta),W.factory(),D.initial_resources(~D.Beta)))
