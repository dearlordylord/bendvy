import Base
import ./types.bend as T
import ./schema.bend as Schema
import ./app.bend as App
import ./observe.bend as Observe
import ../app.bend as Core
import ../../../../../../../../../src/ecs/ordinary-schema.bend as Ordinary
import ../../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../../src/ecs/relation-types.bend as Rel
import ../../../../../../../../../src/ecs/machine.bend as M
import ../../../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../../../src/ecs/schedule.bend as Sch
import ../../../../../../../../../src/ecs/schedule-provision.bend as SP

type Report is Data:
  Report{factoryNext:U32,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,relationError:Maybe<&2,Rel.Error>,snapshots:List<&2,Observe.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<T.Tag>>>}
type Delivered is Type:
  Delivered{factory:W.Factory,world:W.World<T.Tag,Unit,T.Resources,Unit>,app:App.Application<T.Tag,Unit,T.Resources,Unit,Unit>,report:Report}
  Failed{factory:W.Factory,world:W.World<T.Tag,Unit,T.Resources,Unit>,owners:Unit}
  CreateFailed{factory:W.Factory,resources:T.Resources}
def next(factory:W.Factory) -> U32:
  match factory:
    case W.Factory{next}:next
def delivered(factory:W.Factory,app:App.Application<T.Tag,Unit,T.Resources,Unit,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,snapshots:List<&2,Observe.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<T.Tag>>>,world:W.World<T.Tag,Unit,T.Resources,Unit>,last:Observe.Snapshot) -> Delivered:
  match factory:
    case W.Factory{+actualNext}:Delivered{W.Factory{actualNext},world,app,Report{actualNext,reservations,activations,queueOutcome,error,List.append(&2,Observe.Snapshot,snapshots,[last]),descriptions}}
def final(factory:W.Factory,app:App.Application<T.Tag,Unit,T.Resources,Unit,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,snapshots:List<&2,Observe.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<T.Tag>>>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,last):delivered(factory,app,reservations,activations,queueOutcome,error,snapshots,descriptions,world,last)
def after_seen(factory:W.Factory,app:App.Application<T.Tag,Unit,T.Resources,Unit,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,before:Observe.Snapshot,descriptions:List<&2,Maybe<&2,App.Description<T.Tag>>>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,after):final(factory,app,reservations,activations,queueOutcome,error,[before,after],descriptions,Observe.snapshot(W.barrier(~T.Tag,~Unit,~T.Resources,~Unit,world)))
def disabled(factory:W.Factory,world:W.World<T.Tag,Unit,T.Resources,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,before:Observe.Snapshot,descriptions:List<&2,Maybe<&2,App.Description<T.Tag>>>,got:App.Application<T.Tag,Unit,T.Resources,Unit,Unit> & Maybe<&2,App.Description<T.Tag>>) -> Delivered:
  match got:
    case (app,last):after_seen(factory,app,reservations,activations,queueOutcome,error,before,List.append(&2,Maybe<&2,App.Description<T.Tag>>,descriptions,[last]),Observe.snapshot(world))
def second(factory:W.Factory,world:W.World<T.Tag,Unit,T.Resources,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,before:Observe.Snapshot,first:Maybe<&2,App.Description<T.Tag>>,got:App.Application<T.Tag,Unit,T.Resources,Unit,Unit> & Maybe<&2,App.Description<T.Tag>>) -> Delivered:
  match got:
    case (app,last):disabled(factory,world,reservations,activations,queueOutcome,error,before,[first,last],App.describe(~T.Tag,~Unit,~T.Resources,~Unit,~Unit,App.disable(~T.Tag,~Unit,~T.Resources,~Unit,~Unit,app)))
def first(factory:W.Factory,world:W.World<T.Tag,Unit,T.Resources,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,before:Observe.Snapshot,got:App.Application<T.Tag,Unit,T.Resources,Unit,Unit> & Maybe<&2,App.Description<T.Tag>>) -> Delivered:
  match got:
    case (app,description):second(factory,world,reservations,activations,queueOutcome,error,before,description,App.describe(~T.Tag,~Unit,~T.Resources,~Unit,~Unit,app))
def observed(factory:W.Factory,app:App.Application<T.Tag,Unit,T.Resources,Unit,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,before):first(factory,world,reservations,activations,queueOutcome,error,before,App.describe(~T.Tag,~Unit,~T.Resources,~Unit,~Unit,app))
def built(factory:W.Factory,world:W.World<T.Tag,Unit,T.Resources,Unit>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,error:Maybe<&2,Rel.Error>,result:App.Built<T.Tag,Unit,T.Resources,Unit,Unit>) -> Delivered:
  match result:
    case App.Rejected{owners,relations,machines}:Failed{factory,world,owners}
    case App.Built{app}:observed(factory,app,reservations,activations,queueOutcome,error,Observe.snapshot(world))
def publish(world:W.World<T.Tag,Unit,T.Resources,Unit>) -> W.World<T.Tag,Unit,T.Resources,Unit>:
  W.event_publish(~T.Tag,~Unit,~T.Resources,~Unit,world,[Unit{}])
def related(factory:W.Factory,schema:Schema.Declaration<T.Tag,Unit,T.Resources>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Maybe<&2,Rel.Error>) -> Delivered:
  match got:
    case (world,error):built(factory,W.enqueue(~T.Tag,~Unit,~T.Resources,~Unit,publish(world),publish),reservations,activations,queueOutcome,error,App.empty_build(~T.Tag,~Unit,~T.Resources,~Unit,1,Core.Enabled{},"Update",SP.Entry{Sch.Phase{"Update"},[]},schema))
def active2(factory:W.Factory,schema:Schema.Declaration<T.Tag,Unit,T.Resources>,reservations:List<&2,W.Reservation<T.Tag>>,activations:List<&2,W.Status>,queueOutcome:Tx.Outcome<Unit>,got:W.World<T.Tag,Unit,T.Resources,Unit> & W.Status) -> Delivered:
  match got:
    case (world,last):related(factory,schema,reservations,List.append(&2,W.Status,activations,[last]),queueOutcome,W.observe_resource(~T.Tag,~Unit,~T.Resources,~Unit,~Maybe<&2,Rel.Error>,~T.relate,world))
def active1(factory:W.Factory,schema:Schema.Declaration<T.Tag,Unit,T.Resources>,reservations:List<&2,W.Reservation<T.Tag>>,queueOutcome:Tx.Outcome<Unit>,got:W.World<T.Tag,Unit,T.Resources,Unit> & W.Status) -> Delivered:
  match got:
    case (world,first):active2(factory,schema,reservations,[first],queueOutcome,W.activate(~T.Tag,~Unit,~T.Resources,~Unit,world,W.Handle{1,2}))
def reserved2(factory:W.Factory,schema:Schema.Declaration<T.Tag,Unit,T.Resources>,first:W.Reservation<T.Tag>,queueOutcome:Tx.Outcome<Unit>,got:W.World<T.Tag,Unit,T.Resources,Unit> & W.Reservation<T.Tag>) -> Delivered:
  match got:
    case (world,last):active1(factory,schema,[first,last],queueOutcome,W.activate(~T.Tag,~Unit,~T.Resources,~Unit,world,W.Handle{1,1}))
def reserved1(factory:W.Factory,schema:Schema.Declaration<T.Tag,Unit,T.Resources>,queueOutcome:Tx.Outcome<Unit>,got:W.World<T.Tag,Unit,T.Resources,Unit> & W.Reservation<T.Tag>) -> Delivered:
  match got:
    case (world,first):reserved2(factory,schema,first,queueOutcome,W.reserve_id(~T.Tag,~Unit,~T.Resources,~Unit,world))
def created(schema:Schema.Declaration<T.Tag,Unit,T.Resources>,queueOutcome:Tx.Outcome<Unit>,result:W.Creation<T.Tag,Unit,T.Resources,Unit>) -> Delivered:
  match result:
    case W.CreateRejected{factory,resource}:CreateFailed{factory,resource}
    case W.Created{factory,world}:reserved1(factory,schema,queueOutcome,W.reserve_id(~T.Tag,~Unit,~T.Resources,~Unit,world))
def queued(schema:Schema.Declaration<T.Tag,Unit,T.Resources>,got:Tx.Returned<T.Resources,Unit>) -> Delivered:
  match got:
    case Tx.Returned{resources,outcome}:created(schema,outcome,W.create(~T.Tag,~Unit,~T.Resources,~Unit,~(unit => unit),W.factory(),resources))
def machine_declared(descriptor:Rel.Descriptor<T.Tag>,got:Schema.Declaration<T.Tag,Unit,T.Resources> & M.Family<T.Tag,T.Key,T.State,T.Resources,T.take,T.put>) -> Delivered:
  match got:
    case (schema,family):queued(schema,T.queued(family,T.Resources{Array.new(U32,1n,23),M.Present{T.Boot{},M.NoPending{},None{},False{}},Rel.Graph{[],[]},descriptor}))
def relation_declared(got:Schema.Declaration<T.Tag,Unit,T.Resources> & Rel.Descriptor<T.Tag>) -> Delivered:
  match got:
    case (schema,descriptor):machine_declared(descriptor,Schema.machine_named(~T.Tag,~Unit,~T.Resources,~T.Key,~T.State,~T.take,~T.put,schema,T.family()))
def main() -> Delivered:
  relation_declared(Schema.relation(~T.Tag,~Unit,~T.Resources,Schema.ordinary(~T.Tag,~Unit,~T.Resources,Ordinary.resource_schema(~T.Tag,~T.Resources,Ordinary.resource(~T.Tag,~T.Resources,"Gameplay"))),T.descriptor()))
