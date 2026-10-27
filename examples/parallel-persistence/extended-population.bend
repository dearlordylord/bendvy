import Base
import ./extended-declarations.bend as Schema
import ./declarations.bend as O
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-reservation-materialization.bend as Materialize
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

type Seed is Data:Seed{name:String,energy:U32}
def Previous(~S:Data) -> Type:List<Bundle.Payload(Schema.components(~S))>
type Population<-S:Data> is Type:
  Populated{world:Schema.World(~S),handles:List<&2,W.Handle<S>>,previous:Previous(~S)}
  ReservationRefused{world:Schema.World(~S),handles:List<&2,W.Handle<S>>,previous:Previous(~S)}
  PublicationRefused{result:Bundle.Publication<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit,Schema.components(~S)>,handles:List<&2,W.Handle<S>>,previous:Previous(~S)}
def published(~S:Data,next:Schema.World(~S) -> List<&2,W.Handle<S>> -> Previous(~S) -> Population<S>,handles:List<&2,W.Handle<S>>,previous:Previous(~S),result:Bundle.Publication<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit,Schema.components(~S)>) -> Population<S>:
  match result:
    case Bundle.Materialized{world,handle,removed}:next(world,List.append(&2,W.Handle<S>,handles,[handle]),removed <> previous)
    case other:PublicationRefused{other,handles,previous}
def clocked(~S:Data,next:Schema.World(~S) -> List<&2,W.Handle<S>> -> Previous(~S) -> Population<S>,name:String,energy:U32,handle:W.Handle<S>,handles:List<&2,W.Handle<S>>,previous:Previous(~S),result:Schema.World(~S) & Tick.Tick) -> Population<S>:
  match result:
    case (world,tick):published(~S,next,handles,previous,Materialize.apply_at(~S,~Schema.Resources(~S),~Unit,~Schema.components(~S),Permission.EntityStructural{},world,handle,Product.Owner{Some{O.Actor{name,ALeaf{energy}}},None{}},tick))
def reserved(~S:Data,next:Schema.World(~S) -> List<&2,W.Handle<S>> -> Previous(~S) -> Population<S>,name:String,energy:U32,handles:List<&2,W.Handle<S>>,previous:Previous(~S),result:Schema.World(~S) & W.Reservation<S>) -> Population<S>:
  match result:
    case (world,W.Reserved{+handle}):clocked(~S,next,name,energy,handle,handles,previous,W.write_clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,W.mark_pending(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world,handle)))
    case (world,W.ReservationRejected{_}):ReservationRefused{world,handles,previous}
def populate(~S:Data,values:List<&2,Seed>,world:Schema.World(~S),handles:List<&2,W.Handle<S>>,previous:Previous(~S)) -> Population<S>:
  match values:
    case []:Populated{world,handles,previous}
    case Seed{name,energy} <> rest:reserved(~S,world => handles => previous => populate(~S,rest,world,handles,previous),name,energy,handles,previous,W.reserve_id(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world))
def source(~S:Data,world:Schema.World(~S)) -> Population<S>:populate(~S,[Seed{"parent",41},Seed{"child",52}],world,[],[])
