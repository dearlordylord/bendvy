import Base
import ../main.bend as Inventory
import ../resource-main.bend as Resource
import ./fixture.bend as Fixture
import ./observe.bend as Observe
import ./types.bend as T
import ./app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

type Outcome is Data:
  Reported{report:Fixture.Report}
  BuildFailed{factoryNext:U32,snapshot:Observe.Snapshot}
  CreateFailed{factoryNext:U32,resource:T.ResourceView}
type Complete is Data:
  Complete{inventory:Inventory.Complete,resource:Resource.Outcome,graphMachine:Outcome}
def failed_factory(factory:W.Factory,world:W.World<T.Tag,Unit,T.Resources,Unit>,owners:Unit,snapshot:Observe.Snapshot) -> Outcome:
  match factory:
    case W.Factory{next}:BuildFailed{next,snapshot}
def failed(factory:W.Factory,owners:Unit,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Outcome:
  match got:
    case (world,snapshot):failed_factory(factory,world,owners,snapshot)
def create_factory(factory:W.Factory,resource:T.Resources,view:T.ResourceView) -> Outcome:
  match factory:
    case W.Factory{next}:CreateFailed{next,view}
def create_failed(factory:W.Factory,got:T.Resources & T.ResourceView) -> Outcome:
  match got:
    case (resource,view):create_factory(factory,resource,view)
def consume(delivered:Fixture.Delivered) -> Outcome:
  match delivered:
    case Fixture.Delivered{factory,world,app,report}:Reported{report}
    case Fixture.Failed{factory,world,owners}:failed(factory,owners,Observe.snapshot(world))
    case Fixture.CreateFailed{factory,resources}:create_failed(factory,T.view(resources))
def main() -> Complete:
  Complete{Inventory.main(),Resource.main(),consume(Fixture.main())}
