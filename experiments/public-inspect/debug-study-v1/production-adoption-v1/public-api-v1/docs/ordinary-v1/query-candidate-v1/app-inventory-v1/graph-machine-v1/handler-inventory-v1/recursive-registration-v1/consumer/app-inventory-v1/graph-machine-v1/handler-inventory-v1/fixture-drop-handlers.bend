import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/handler-inventory-v1/app-drop-handlers.bend as HandlerApp
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/fixture.bend as Previous
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/observe.bend as Observe
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/types.bend as T
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/app.bend as Core
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/app.bend as Debug
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
type Delivered is Type:
  Delivered{factory:W.Factory,previous:Previous.Report,before:Observe.Snapshot,afterDescription:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,result:B.BundleResult<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,runner>,core:Core.Application<T.Tag,Unit,T.Resources,Unit,Unit>,family:M.Family<T.Tag,T.Key,T.State,T.Resources,T.take,T.put>}
  RegistrationFailed{factory:W.Factory,previous:Previous.Report,world:W.World<T.Tag,Unit,T.Resources,Unit>,core:Core.Application<T.Tag,Unit,T.Resources,Unit,Unit>,registered:List<&1,Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>>}
  PreviousFailed{previous:Previous.Delivered}
def runner(world:W.World<T.Tag,Unit,T.Resources,Unit>,invocation:H.Invocation<T.State>) -> Sys.Outcome<W.World<T.Tag,Unit,T.Resources,Unit>,String,Unit>:
  Sys.Succeeded{Previous.publish(world),Unit{}}
def same(a:T.State,b:T.State) -> Bool:
  match a b:
    case T.Boot{} T.Boot{}:True{}
    case T.Play{} T.Play{}:True{}
    case _ _:False{}
def has(world:W.World<T.Tag,Unit,T.Resources,Unit>,requirement:SP.Requirement<T.Tag>) -> W.World<T.Tag,Unit,T.Resources,Unit> & Bool:
  match requirement:
    case SP.Resource{id}:(world,U32.is_eq(id,9))
    case _:(world,False{})
def frame(world:W.World<T.Tag,Unit,T.Resources,Unit>) -> W.World<T.Tag,Unit,T.Resources,Unit>:
  world
def publish(world:W.World<T.Tag,Unit,T.Resources,Unit>,transition:M.Transition<T.State>) -> W.World<T.Tag,Unit,T.Resources,Unit>:
  Previous.publish(world)
def ran(factory:W.Factory,previous:Previous.Report,before:Observe.Snapshot,after:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,got:B.BundleResult<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,runner> & (Core.Application<T.Tag,Unit,T.Resources,Unit,Unit> & M.Family<T.Tag,T.Key,T.State,T.Resources,T.take,T.put>)) -> Delivered:
  match got:
    case (result,(core,family)):Delivered{factory,previous,before,after,descriptions,result,core,family}
def after_seen(factory:W.Factory,previous:Previous.Report,before:Observe.Snapshot,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,app:HandlerApp.Application<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Unit,runner,T.take,T.put>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,after):ran(factory,previous,before,after,descriptions,HandlerApp.run(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~runner,~Unit,~T.take,~T.put,~publish,~same,~SP.same(~T.Tag),~has,~frame,app,world))
def disabled(factory:W.Factory,previous:Previous.Report,before:Observe.Snapshot,world:W.World<T.Tag,Unit,T.Resources,Unit>,descriptions:List<&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>>,got:HandlerApp.Application<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Unit,runner,T.take,T.put> & Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>) -> Delivered:
  match got:
    case (app,last):after_seen(factory,previous,before,List.append(&2,Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>,descriptions,[last]),app,Observe.snapshot(world))
def second(factory:W.Factory,previous:Previous.Report,before:Observe.Snapshot,world:W.World<T.Tag,Unit,T.Resources,Unit>,first:Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>,got:HandlerApp.Application<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Unit,runner,T.take,T.put> & Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>) -> Delivered:
  match got:
    case (app,last):disabled(factory,previous,before,world,[first,last],HandlerApp.describe(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~runner,~Unit,~T.take,~T.put,HandlerApp.debug(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~runner,~Unit,~T.take,~T.put,Debug.Disabled{},app)))
def first(factory:W.Factory,previous:Previous.Report,before:Observe.Snapshot,world:W.World<T.Tag,Unit,T.Resources,Unit>,got:HandlerApp.Application<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Unit,runner,T.take,T.put> & Maybe<&2,HandlerApp.Description<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>>>) -> Delivered:
  match got:
    case (app,description):second(factory,previous,before,world,description,HandlerApp.describe(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~runner,~Unit,~T.take,~T.put,app))
def observed(factory:W.Factory,previous:Previous.Report,app:HandlerApp.Application<T.Tag,T.Key,T.State,SP.Requirement<T.Tag>,Unit,T.Resources,Unit,Unit,runner,T.take,T.put>,got:W.World<T.Tag,Unit,T.Resources,Unit> & Observe.Snapshot) -> Delivered:
  match got:
    case (world,before):first(factory,previous,before,world,HandlerApp.describe(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~runner,~Unit,~T.take,~T.put,HandlerApp.debug(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~runner,~Unit,~T.take,~T.put,Debug.Enabled{},app)))
def built(factory:W.Factory,previous:Previous.Report,world:W.World<T.Tag,Unit,T.Resources,Unit>,core:Core.Application<T.Tag,Unit,T.Resources,Unit,Unit>,exit:Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>,transition:Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>,enter:Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>) -> Delivered:
  observed(factory,previous,HandlerApp.declare(~T.Tag,~T.Key,~T.State,~SP.Requirement<T.Tag>,~Unit,~T.Resources,~Unit,~runner,~Unit,~T.take,~T.put,core,T.family(),B.Bundle{1,[B.Scheduled{B.ExitFrom{T.Boot{}},[SP.Resource{9}],H.Entry{10,exit}},B.Scheduled{B.TransitionPair{T.Boot{},T.Play{}},[SP.Resource{9}],H.Entry{20,transition}},B.Scheduled{B.EnterTo{T.Play{}},[SP.Resource{9}],H.Entry{30,enter}}]}),Observe.snapshot(W.enqueue(~T.Tag,~Unit,~T.Resources,~Unit,world,Previous.publish)))
def entered(factory:W.Factory,previous:Previous.Report,core:Core.Application<T.Tag,Unit,T.Resources,Unit,Unit>,exit:Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>,transition:Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>,got:Sys.RegistrationResult<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>) -> Delivered:
  match got:
    case Sys.RegistrationFailed{world}:RegistrationFailed{factory,previous,world,core,[exit,transition]}
    case Sys.Registered{world,registry}:built(factory,previous,world,core,exit,transition,registry)
def transitioned(factory:W.Factory,previous:Previous.Report,core:Core.Application<T.Tag,Unit,T.Resources,Unit,Unit>,exit:Sys.Registry<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>,got:Sys.RegistrationResult<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>) -> Delivered:
  match got:
    case Sys.RegistrationFailed{world}:RegistrationFailed{factory,previous,world,core,[exit]}
    case Sys.Registered{world,registry}:entered(factory,previous,core,exit,registry,Sys.register(~T.Tag,~Unit,~T.Resources,~Unit,~H.Invocation<T.State>,~String,~Unit,~runner,world,"EnterMode",["machine:Mode:enter"]))
def exited(factory:W.Factory,previous:Previous.Report,core:Core.Application<T.Tag,Unit,T.Resources,Unit,Unit>,got:Sys.RegistrationResult<T.Tag,Unit,T.Resources,Unit,H.Invocation<T.State>,String,Unit,runner>) -> Delivered:
  match got:
    case Sys.RegistrationFailed{world}:RegistrationFailed{factory,previous,world,core,[]}
    case Sys.Registered{world,registry}:transitioned(factory,previous,core,registry,Sys.register(~T.Tag,~Unit,~T.Resources,~Unit,~H.Invocation<T.State>,~String,~Unit,~runner,world,"TransitionMode",["machine:Mode:transition"]))
def consume(previous:Previous.Delivered) -> Delivered:
  match previous:
    case Previous.Delivered{factory,world,app,report}:exited(factory,report,app,Sys.register(~T.Tag,~Unit,~T.Resources,~Unit,~H.Invocation<T.State>,~String,~Unit,~runner,world,"ExitMode",["machine:Mode:exit"]))
    case other:PreviousFailed{other}
def main() -> Delivered:
  consume(Previous.main())
