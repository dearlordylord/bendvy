import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/resource-control.bend as Control
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/app.bend as App
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/retained-schema.bend as Schema
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/scenario-observation.bend as Observe
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View

type Snapshot is Data:
  Snapshot{namespace:U32,nextId:U32,highWater:U32,capacity:U32,depth:Nat,liveBits:List<&2,Bool>,store:Unit,resource:View.FullCell,events:List<&2,Unit>,pendingCount:U32,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32}
type Report is Data:
  Report{factoryNext:U32,before:Snapshot,after:Snapshot,descriptions:List<&2,Maybe<&2,App.Description<Control.ResourceSchema>>>}
type Outcome is Data:
  Reported{report:Report}
  BuildRejected{factoryNext:U32,snapshot:Snapshot}
  CreateRejected{factoryNext:U32,resource:View.FullCell}
def bits_seen(resourceView:View.FullCell,pendingCount:U32,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,+store:Unit,resource:Array<U32>,+events:List<&2,Unit>,pending:List<(W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> -> W.World<Control.ResourceSchema,Unit,Array<U32>,Unit>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,got:Array<Bool> & List<&2,Bool>) -> W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & Snapshot:
  match got:
    case (live,bits):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},Snapshot{namespace,nextId,highWater,capacity,depth,bits,store,resourceView,events,pendingCount,registrations,nextSystemId,clock})
def counted(resourceView:View.FullCell,got:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & U32) -> W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & Snapshot:
  match got:
    case (W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,+store,resource,+events,pending,+registrations,+nextSystemId,+clock},pendingCount):bits_seen(resourceView,pendingCount,namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock,Observe.bits(U32.to_nat(capacity),0,live))
def projected(got:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & View.FullCell) -> W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & Snapshot:
  match got:
    case (world,resourceView):counted(resourceView,W.pending_count(~Control.ResourceSchema,~Unit,~Array<U32>,~Unit,world))
def snapshot(world:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit>) -> W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & Snapshot:
  projected(W.observe_resource(~Control.ResourceSchema,~Unit,~Array<U32>,~Unit,~View.FullCell,~View.view,world))
def factory_next(factory:W.Factory) -> U32:
  match factory:
    case W.Factory{next}:next
def finished(next:U32,before:Snapshot,app:App.Application<Control.ResourceSchema,Unit,Array<U32>,Unit,Unit>,descriptions:List<&2,Maybe<&2,App.Description<Control.ResourceSchema>>>,got:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & Snapshot) -> Outcome:
  match got:
    case (world,after):
      Reported{Report{next,before,after,descriptions}}
def disabled(factory:W.Factory,world:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit>,before:Snapshot,descriptions:List<&2,Maybe<&2,App.Description<Control.ResourceSchema>>>,got:App.Application<Control.ResourceSchema,Unit,Array<U32>,Unit,Unit> & Maybe<&2,App.Description<Control.ResourceSchema>>) -> Outcome:
  match got:
    case (app,last):finished(factory_next(factory),before,app,List.append(&2,Maybe<&2,App.Description<Control.ResourceSchema>>,descriptions,[last]),snapshot(world))
def disable(app:App.Application<Control.ResourceSchema,Unit,Array<U32>,Unit,Unit>) -> App.Application<Control.ResourceSchema,Unit,Array<U32>,Unit,Unit>:
  match app:
    case App.Application{schema,_,bindings,schedule}:App.Application{schema,App.Disabled{},bindings,schedule}
def second(factory:W.Factory,world:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit>,before:Snapshot,first:Maybe<&2,App.Description<Control.ResourceSchema>>,got:App.Application<Control.ResourceSchema,Unit,Array<U32>,Unit,Unit> & Maybe<&2,App.Description<Control.ResourceSchema>>) -> Outcome:
  match got:
    case (app,repeated):disabled(factory,world,before,[first,repeated],App.describe(~Control.ResourceSchema,~Unit,~Array<U32>,~Unit,~Unit,disable(app)))
def before_seen(factory:W.Factory,app:App.Application<Control.ResourceSchema,Unit,Array<U32>,Unit,Unit>,first:Maybe<&2,App.Description<Control.ResourceSchema>>,got:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & Snapshot) -> Outcome:
  match got:
    case (world,before):second(factory,world,before,first,App.describe(~Control.ResourceSchema,~Unit,~Array<U32>,~Unit,~Unit,app))
def build_failed(next:U32,owners:Unit,got:W.World<Control.ResourceSchema,Unit,Array<U32>,Unit> & Snapshot) -> Outcome:
  match got:
    case (world,view):
      BuildRejected{next,view}
def create_failed(next:U32,got:Array<U32> & View.FullCell) -> Outcome:
  match got:
    case (resource,view):
      CreateRejected{next,view}
def consume(delivered:Control.Delivered) -> Outcome:
  match delivered:
    case Control.Delivered{factory,world,app,description}:before_seen(factory,app,description,snapshot(world))
    case Control.BuildRejected{factory,world,owners}:build_failed(factory_next(factory),owners,snapshot(world))
    case Control.CreateRejected{factory,resource}:create_failed(factory_next(factory),View.view(resource))
def main() -> Outcome:
  consume(Control.main())
