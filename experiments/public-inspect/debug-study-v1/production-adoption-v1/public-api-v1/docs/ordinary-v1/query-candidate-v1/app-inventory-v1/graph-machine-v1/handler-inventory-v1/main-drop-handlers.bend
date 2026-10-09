import Base
import ./fixture-drop-handlers.bend as Fixture
import ../fixture.bend as GraphFixture
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import ./handlers.bend as Inspect
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import ./app-drop-handlers.bend as HandlerApp
import ../types.bend as T
import ../observe.bend as Observe
import ../main.bend as Previous
import ../../main.bend as Inventory
import ../../resource-main.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
type OwnerView is Data:
  Returned{bundle:Inspect.BundleView<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>}
  InternalRemainder{namespace:U32,recovery:Inspect.RecoveryView<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>}
type Report is Data:
  Report{factoryNext:U32,snapshots:List<&2,Observe.Snapshot>,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,status:B.Status<SP.Requirement<T.Tag>>,owners:OwnerView}
type Complete is Data:
  Complete{previous:Previous.Complete,handlers:Report}
type Delivered is Type:
  DeliveredBundle{world:W.World<T.Tag,Unit,T.Resources,Unit>,bundle:B.Bundle<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner>,report:Report}
  DeliveredRecovery{world:W.World<T.Tag,Unit,T.Resources,Unit>,recovery:B.Recovery<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner>,report:Report}
def final_bundle(+next:U32,before:Observe.Snapshot,afterDescription:Observe.Snapshot,marker:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,status:B.Status<SP.Requirement<T.Tag>>,bundle:B.Bundle<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner>,view:Inspect.BundleView<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,barrier ):DeliveredBundle{world,bundle,Report{next,[before,afterDescription,marker,barrier],descriptions,status,Returned{view}}}
def marker_bundle(next:U32,before:Observe.Snapshot,afterDescription:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,status:B.Status<SP.Requirement<T.Tag>>,bundle:B.Bundle<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner>,view:Inspect.BundleView<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,marker):final_bundle(next,before,afterDescription,marker,descriptions,status,bundle,view,Observe.snapshot(W.barrier(~T.Tag,~Unit,~T.Resources,~Unit,world)))
def inspected(next:U32,before:Observe.Snapshot,afterDescription:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,status:B.Status<SP.Requirement<T.Tag>>,world:W.World<T.Tag,Unit,T.Resources,Unit>,got:B.Bundle<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner> & Inspect.BundleView<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>) -> Delivered:
  match got:
    case (bundle,view):marker_bundle(next,before,afterDescription,descriptions,status,bundle,view,Observe.snapshot(world))
def remainder_observed(next:U32,before:Observe.Snapshot,afterDescription:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,status:B.Status<SP.Requirement<T.Tag>>,namespace:U32,recovery:B.Recovery<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner>,view:Inspect.RecoveryView<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,marker ):DeliveredRecovery{world,recovery,Report{next,[before,afterDescription,marker],descriptions,status,InternalRemainder{namespace,view}}}
def remainder(next:U32,before:Observe.Snapshot,afterDescription:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,status:B.Status<SP.Requirement<T.Tag>>,namespace:U32,world:W.World<T.Tag,Unit,T.Resources,Unit>,got:B.Recovery<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner> & Inspect.RecoveryView<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>) -> Delivered:
  match got:
    case (recovery,view):remainder_observed(next,before,afterDescription,descriptions,status,namespace,recovery,view,Observe.snapshot(world))
def result(next:U32,before:Observe.Snapshot,afterDescription:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,got:B.BundleResult<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner>) -> Delivered:
  match got:
    case B.Returned{bundle,world,status}:inspected(next,before,afterDescription,descriptions,status,world,Inspect.inspect(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~Fixture.runner,bundle))
    case B.InternalOwnerRemainder{namespace,recovery,world,status}:remainder(next,before,afterDescription,descriptions,status,namespace,world,Inspect.recovery(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~Fixture.runner,recovery))
def with_factory(factory:W.Factory,before:Observe.Snapshot,afterDescription:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,got:B.BundleResult<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Fixture.runner>) -> Delivered:
  match factory:
    case W.Factory{next}:result(next,before,afterDescription,descriptions,got)
type Outcome is Data:
  Reported{report:Complete}
  SetupFailed{factoryNext:U32,previous:GraphFixture.Report,snapshot:Observe.Snapshot,registrations:List<&2,RegistrationView>}
  PreviousFailed{previous:Previous.Outcome}
type RegistrationView is Data:
  RegistrationView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
def report(previous:Previous.Complete,delivered:Delivered) -> Outcome:
  match delivered:
    case DeliveredBundle{world,bundle,report}:Reported{Complete{previous,report}}
    case DeliveredRecovery{world,recovery,report}:Reported{Complete{previous,report}}
def registration_views(items:List<&1,Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,Fixture.runner>>) -> List<&2,RegistrationView>:
  match items:
    case []:[]
    case Sys.Registry{namespace,id,name,access,cursor} <> rest:RegistrationView{namespace,id,name,access,cursor} <> registration_views(rest)
def setup_factory(factory:W.Factory,previous:GraphFixture.Report,snapshot:Observe.Snapshot,registrations:List<&2,RegistrationView>) -> Outcome:
  match factory:
    case W.Factory{next}:SetupFailed{next,previous,snapshot,registrations}
def setup_observed(factory:W.Factory,previous:GraphFixture.Report,registrations:List<&2,RegistrationView>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Outcome:
  match got:
    case (world,snapshot):setup_factory(factory,previous,snapshot,registrations)
def consume(delivered:Fixture.Delivered) -> Outcome:
  match delivered:
    case Fixture.Delivered{factory,previous,before,afterDescription,descriptions,result,core,family}:report(Previous.Complete{Inventory.main(),Resource.main(),Previous.Reported{previous}},with_factory(factory,before,afterDescription,descriptions,result))
    case Fixture.RegistrationFailed{factory,previous,world,core,registered}:setup_observed(factory,previous,registration_views(registered),Observe.snapshot(world))
    case Fixture.PreviousFailed{previous}:PreviousFailed{Previous.consume(previous)}
def main() -> Outcome:
  consume(Fixture.main())
