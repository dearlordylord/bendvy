import Base
import recipe-app.bend as Observe
import runtime-context.bend as X
import runtime-combat.bend as Combat
import runtime-core.bend as Core
import combat-feature.bend as CFeature
import core-feature.bend as KFeature
import feature.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/schedule.bend as Sch
import ../../src/ecs/schedule-provision.bend as P
import ../../src/ecs/schema-fragments.bend as SF
def restore_combat(owner:CFeature.Owner,tail:F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>,result:Sys.RunResult<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,Combat.runner>) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}: (F.Pack{Combat.Built{owner,Some{registry}},tail},outcome)
    case Sys.RegistrationRejected{registry,world,Unit{}}: (F.Pack{Combat.Built{owner,Some{registry}},tail},Sys.Failed{world,"registry-rejected"})
def restore_core(head:Combat.Built,owner:KFeature.Owner,tail:F.Pack<EmptyExtra,Unit>,result:Sys.RunResult<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,Core.runner>) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}: (F.Pack{head,F.Pack{Core.Built{owner,Some{registry}},tail}},outcome)
    case Sys.RegistrationRejected{registry,world,Unit{}}: (F.Pack{head,F.Pack{Core.Built{owner,Some{registry}},tail}},Sys.Failed{world,"registry-rejected"})
def core_selected(matched:Bool,head:Combat.Built,owner:KFeature.Owner,registry:Sys.Registry<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,Core.runner>,tail:F.Pack<EmptyExtra,Unit>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  match matched:
    case False{}: (F.Pack{head,F.Pack{Core.Built{owner,Some{registry}},tail}},Sys.Failed{world,"unknown-system"})
    case True{}: restore_core(head,owner,tail,Sys.run(~X.Schema,~X.Declarations,~X.Trace,~U32,~Unit,~String,~Unit,~Core.runner,registry,world,Unit{}))
def dispatch_core(owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,requested:U32) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  match owners:
    case F.Pack{head,F.Pack{Core.Built{owner,Some{Sys.Registry{ns,+id,name,access,cursor}}},tail}}: core_selected(U32.is_eq(requested,id),head,owner,Sys.Registry{ns,id,name,access,cursor},tail,world)
    case owners: (owners,Sys.Failed{world,"unregistered-core"})
def combat_selected(matched:Bool,owner:CFeature.Owner,registry:Sys.Registry<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,Combat.runner>,tail:F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,requested:U32) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  match matched:
    case False{}: dispatch_core(F.Pack{Combat.Built{owner,Some{registry}},tail},world,requested)
    case True{}: restore_combat(owner,tail,Sys.run(~X.Schema,~X.Declarations,~X.Trace,~U32,~Unit,~String,~Unit,~Combat.runner,registry,world,Unit{}))
def dispatch_owned(owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,+requested:U32) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  match owners:
    case F.Pack{Combat.Built{owner,Some{Sys.Registry{ns,+id,name,access,cursor}}},tail}: combat_selected(U32.is_eq(requested,id),owner,Sys.Registry{ns,id,name,access,cursor},tail,world,requested)
    case owners: (owners,Sys.Failed{world,"unregistered-combat"})
def dispatch(owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,requested:U32) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & Sys.Outcome<W.World<X.Schema,X.Declarations,X.Trace,U32>,String,Unit>:
  dispatch_owned(owners,world,requested)
def condition(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,slot:U32) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & Bool:
  (world,U32.is_eq(slot,0))
def catalog(owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>) -> F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & List<&2,U32>:
  match owners:
    case F.Pack{Combat.Built{co,Some{Sys.Registry{cn,+ci,cname,ca,cc}}},F.Pack{Core.Built{ko,Some{Sys.Registry{kn,+ki,kname,ka,kc}}},tail}}: (F.Pack{Combat.Built{co,Some{Sys.Registry{cn,ci,cname,ca,cc}}},F.Pack{Core.Built{ko,Some{Sys.Registry{kn,ki,kname,ka,kc}}},tail}},[ci,ki])
    case owners: (owners,[])
type EmptyExtra is Data:
  EmptyExtra{label:String}
def empty_build(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,owner:Unit) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & F.Output<X.Schema,EmptyExtra>:
  (world,F.Output{EmptyExtra{"empty"},P.Empty{},P.Empty{}})
def empty_feature() -> F.Feature<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,Unit,EmptyExtra>:
  F.FeatureOwner{F.Definition{"Empty",[],F.Empty{}},Unit{},empty_build}
def recipe(head:F.Definition<X.Schema>,tail:F.Definition<X.Schema>) -> F.Recipe<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>:
  F.prepend(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~CFeature.Owner,~F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>,~Combat.Built,~F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>,Combat.provided(head,CFeature.Owner{ANode{ALeaf{31},ALeaf{32}},ANode{ALeaf{41},ALeaf{42}},[ANode{ALeaf{51},ALeaf{52}}]}),F.prepend(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~KFeature.Owner,~F.Pack<Unit,Unit>,~Core.Built,~F.Pack<EmptyExtra,Unit>,Core.provided(tail,KFeature.Owner{ANode{ALeaf{11},ALeaf{12}},KFeature.Tag{}}),F.prepend(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~Unit,~Unit,~EmptyExtra,~Unit,empty_feature(),F.recipe_empty(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>))))
def identity(text:String) -> String:
  text
def registry_meta(meta:W.RegistrationMeta) -> String:
  match meta:
    case W.RegistrationMeta{id,name,access}: U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,identity,access)
def entry_text(entry:SF.Entry<X.Schema>) -> String:
  match entry:
    case SF.Entry{kind,key,name}: key ++ ":" ++ name
def boolean_cells(owner:Array<Bool>) -> List<&2,Bool>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,Bool,boolean_cells(left),boolean_cells(right))
def count(~T:Type,items:List<T>) -> U32:
  match items:
    case []: 0
    case head <> rest: U32.add(1,count(~T,rest))
def world_text(world:W.World<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  match world:
    case W.World{ns,next,high,live,cap,depth,X.Declarations{core,combat},X.Trace{calls,trace},events,commands,regs,system,clock}: "trace=" ++ List.show(&2,String,identity,trace) ++ "|calls=" ++ Observe.array_text(calls) ++ "|core=" ++ Maybe.show(&2,SF.Entry<X.Schema>,entry_text,core) ++ "|combat=" ++ Maybe.show(&2,SF.Entry<X.Schema>,entry_text,combat) ++ "|ns=" ++ U32.show(ns) ++ "|next=" ++ U32.show(next) ++ "|high=" ++ U32.show(high) ++ "|live=" ++ List.show(&2,Bool,Bool.show,boolean_cells(live)) ++ "|capacity=" ++ U32.show(cap) ++ "|clock=" ++ U32.show(clock) ++ "|events=" ++ List.show(&2,U32,U32.show,events) ++ "|pending=" ++ U32.show(count(~(W.World<X.Schema,X.Declarations,X.Trace,U32> -> W.World<X.Schema,X.Declarations,X.Trace,U32>),commands)) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registry_meta,regs) ++ "|next-system=" ++ U32.show(system)
def world_complete(+ns:U32,+next:U32,+high:U32,+cap:U32,+depth:Nat,+core:Maybe<&2,SF.Entry<X.Schema>>,+combat:Maybe<&2,SF.Entry<X.Schema>>,+trace:List<&2,String>,+events:List<&2,U32>,+regs:List<&2,W.RegistrationMeta>,+system:U32,+clock:U32,observed:(Array<Bool> & List<&2,Bool>) & ((Array<U32> & List<&2,U32>) & (List<(W.World<X.Schema,X.Declarations,X.Trace,U32> -> W.World<X.Schema,X.Declarations,X.Trace,U32>)> & U32))) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & String:
  match observed:
    case ((live,lv),((calls,cv),(commands,pending))): (W.World{ns,next,high,live,cap,depth,X.Declarations{core,combat},X.Trace{calls,trace},events,commands,regs,system,clock},"trace=" ++ List.show(&2,String,identity,trace) ++ "|calls=" ++ List.show(&2,U32,U32.show,cv) ++ "|core=" ++ Maybe.show(&2,SF.Entry<X.Schema>,entry_text,core) ++ "|combat=" ++ Maybe.show(&2,SF.Entry<X.Schema>,entry_text,combat) ++ "|ns=" ++ U32.show(ns) ++ "|next=" ++ U32.show(next) ++ "|high=" ++ U32.show(high) ++ "|live=" ++ List.show(&2,Bool,Bool.show,lv) ++ "|capacity=" ++ U32.show(cap) ++ "|clock=" ++ U32.show(clock) ++ "|events=" ++ List.show(&2,U32,U32.show,events) ++ "|pending=" ++ U32.show(pending) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registry_meta,regs) ++ "|next-system=" ++ U32.show(system))
def world_observed(world:W.World<X.Schema,X.Declarations,X.Trace,U32>) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & String:
  match world:
    case W.World{ns,next,high,live,cap,depth,X.Declarations{core,combat},X.Trace{calls,trace},events,commands,regs,system,clock}: world_complete(ns,next,high,cap,depth,core,combat,trace,events,regs,system,clock,(X.bool_view(live),(X.array_view(calls),X.count_owned(~(W.World<X.Schema,X.Declarations,X.Trace,U32> -> W.World<X.Schema,X.Declarations,X.Trace,U32>),commands))))
def combat_registry(registry:Maybe<&1,Sys.Registry<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,Combat.runner>>) -> String:
  match registry:
    case None{}: "unregistered"
    case Some{Sys.Registry{ns,id,name,access,cursor}}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,identity,access) ++ ":" ++ U32.show(cursor)
def core_registry(registry:Maybe<&1,Sys.Registry<X.Schema,X.Declarations,X.Trace,U32,Unit,String,Unit,Core.runner>>) -> String:
  match registry:
    case None{}: "unregistered"
    case Some{Sys.Registry{ns,id,name,access,cursor}}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,identity,access) ++ ":" ++ U32.show(cursor)
def owners_text(owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>) -> String:
  match owners:
    case F.Pack{Combat.Built{co,cr},F.Pack{Core.Built{ko,kr},F.Pack{EmptyExtra{label},Unit{}}}}: Observe.owner_text(F.Pack{co,F.Pack{ko,F.Pack{Unit{},Unit{}}}}) ++ "|combat-registry=" ++ combat_registry(cr) ++ "|core-registry=" ++ core_registry(kr) ++ "|empty-label=" ++ label
def original_text(owners:F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>) -> String:
  Observe.owner_text(owners)
def step_observation(obs:Sch.Observation) -> String:
  match obs:
    case Sch.Entered{name}: "entered:" ++ name
    case Sch.Ran{id}: "ran:" ++ U32.show(id)
    case Sch.Skipped{id}: "skipped:" ++ U32.show(id)
    case Sch.Applied{}: "applied"
def requirement_text(item:P.Requirement<X.Schema>) -> String:
  match item:
    case P.Component{id}: "component:" ++ U32.show(id)
    case P.Resource{id}: "resource:" ++ U32.show(id)
    case P.Service{id}: "service:" ++ U32.show(id)
def executed(result:P.ProvisionResult<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,String>) -> String:
  match result:
    case P.Executed{Sch.Finished{Sch.Schedule{ns,name,steps,owners},world,obs},needs}: "executed|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners) ++ "|observations=" ++ List.show(&2,Sch.Observation,step_observation,obs) ++ "|requirements=" ++ List.show(&2,P.Requirement<X.Schema>,requirement_text,needs)
    case P.Executed{Sch.Failed{Sch.Schedule{ns,name,steps,owners},world,error,obs},needs}: "failed=" ++ error ++ "|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners) ++ "|observations=" ++ List.show(&2,Sch.Observation,step_observation,obs)
    case P.Executed{Sch.Rejected{Sch.Schedule{ns,name,steps,owners},world},needs}: "foreign-schedule|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners)
    case P.Missing{P.Provisioned{Sch.Schedule{ns,name,steps,owners},needs},world,missing}: "missing-provision|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners) ++ "|missing=" ++ List.show(&2,P.Requirement<X.Schema>,requirement_text,missing)
def schedule_built(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,result:P.Build<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> String:
  match result:
    case P.Built{schedule}: executed(P.run(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,~String,~dispatch,~condition,~X.provision,schedule,world))
    case P.Invalid{owners}: "invalid-schedule|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners)
def schedule_catalog(+namespace:U32,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,plan:P.Plan<X.Schema>,observed:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & List<&2,U32>) -> String:
  match observed:
    case (owners,ids): schedule_built(world,P.build(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,namespace,"features",plan,ids,owners))
def schedule_named(plan:P.Plan<X.Schema>,owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,named:W.World<X.Schema,X.Declarations,X.Trace,U32> & U32) -> String:
  match named:
    case (world,ns): schedule_catalog(ns,world,plan,catalog(owners))
# Bootstrap and update are separate public schedules. Reusing a registered
# system in two phases is legal; duplicate IDs within one schedule are not.
type PhaseResult is Type:
  PhaseRan{result:P.ProvisionResult<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,String>}
  PhaseInvalid{world:W.World<X.Schema,X.Declarations,X.Trace,U32>,owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>}
def phase_merge(+previous:List<&2,Sch.Observation>,+needs:List<&2,P.Requirement<X.Schema>>,result:P.ProvisionResult<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,String>) -> PhaseResult:
  match result:
    case P.Executed{Sch.Finished{schedule,world,observations},later}: PhaseRan{P.Executed{Sch.Finished{schedule,world,List.append(&2,Sch.Observation,previous,observations)},P.unique(~X.Schema,List.append(&2,P.Requirement<X.Schema>,needs,later))}}
    case result: PhaseRan{result}
def phase_update_built(+previous:List<&2,Sch.Observation>,+needs:List<&2,P.Requirement<X.Schema>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,built:P.Build<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> PhaseResult:
  match built:
    case P.Built{schedule}: phase_merge(previous,needs,P.run(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,~String,~dispatch,~condition,~X.provision,schedule,world))
    case P.Invalid{owners}: PhaseInvalid{world,owners}
def phase_update_catalog(+namespace:U32,plan:P.Plan<X.Schema>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,+previous:List<&2,Sch.Observation>,+needs:List<&2,P.Requirement<X.Schema>>,observed:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & List<&2,U32>) -> PhaseResult:
  match observed:
    case (owners,ids): phase_update_built(previous,needs,world,P.build(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,namespace,"update",plan,ids,owners))
def phase_bootstrap_ran(+namespace:U32,update:P.Plan<X.Schema>,result:P.ProvisionResult<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,String>) -> PhaseResult:
  match result:
    case P.Executed{Sch.Finished{Sch.Schedule{ns,name,steps,owners},world,observations},needs}: phase_update_catalog(namespace,update,world,observations,needs,catalog(owners))
    case result: PhaseRan{result}
def phase_bootstrap_built(+namespace:U32,update:P.Plan<X.Schema>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,built:P.Build<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> PhaseResult:
  match built:
    case P.Built{schedule}: phase_bootstrap_ran(namespace,update,P.run(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,~String,~dispatch,~condition,~X.provision,schedule,world))
    case P.Invalid{owners}: PhaseInvalid{world,owners}
def phases_catalog(+namespace:U32,bootstrap:P.Plan<X.Schema>,update:P.Plan<X.Schema>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,observed:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & List<&2,U32>) -> PhaseResult:
  match observed:
    case (owners,ids): phase_bootstrap_built(namespace,update,world,P.build(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,namespace,"bootstrap",bootstrap,ids,owners))
def phases(+namespace:U32,bootstrap:P.Plan<X.Schema>,update:P.Plan<X.Schema>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>) -> PhaseResult:
  phases_catalog(namespace,bootstrap,update,world,catalog(owners))
def phases_text(result:PhaseResult) -> String:
  match result:
    case PhaseRan{result}: executed(result)
    case PhaseInvalid{world,owners}: "invalid-schedule|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners)
def phases_named(bootstrap:P.Plan<X.Schema>,update:P.Plan<X.Schema>,owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,named:W.World<X.Schema,X.Declarations,X.Trace,U32> & U32) -> String:
  match named:
    case (world,ns): phases_text(phases(ns,bootstrap,update,world,owners))
def result(result:F.RecipeResult<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> String:
  match result:
    case F.Completed{world,F.Output{owners,bootstrap,update}}: phases_named(bootstrap,update,owners,W.namespace(~X.Schema,~X.Declarations,~X.Trace,~U32,world))
    case F.Refused{error,world,F.Recipe{tree,owners,build}}: "refused=" ++ Observe.error_text(error) ++ "|" ++ world_text(world) ++ "|owners=" ++ original_text(owners)
def created(head:F.Definition<X.Schema>,tail:F.Definition<X.Schema>,creation:W.Creation<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  match creation:
    case W.Created{factory,world}: result(F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world,recipe(head,tail)))
    case W.CreateRejected{factory,X.Trace{calls,trace}}: "creation-rejected|calls=" ++ Observe.array_text(calls) ++ "|trace=" ++ List.show(&2,String,identity,trace)
def run(head:F.Definition<X.Schema>,tail:F.Definition<X.Schema>) -> String:
  created(head,tail,W.create(~X.Schema,~X.Declarations,~X.Trace,~U32,~X.empty_store,W.factory(),X.resource()))
def foreign_result(target:W.World<X.Schema,X.Declarations,X.Trace,U32>,result:F.RecipeResult<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> String:
  match result:
    case F.Completed{origin,F.Output{owners,bootstrap,update}}: "origin=" ++ world_text(origin) ++ "|target=" ++ phases_text(phases(1,bootstrap,update,target,owners))
    case F.Refused{error,origin,F.Recipe{tree,owners,build}}: "UNEXPECTED_REFUSAL|origin=" ++ world_text(origin) ++ "|target=" ++ world_text(target) ++ "|owners=" ++ original_text(owners)
def second_world(origin:W.World<X.Schema,X.Declarations,X.Trace,U32>,creation:W.Creation<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  match creation:
    case W.Created{factory,target}: foreign_result(target,F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,origin,recipe(CFeature.declaration(~X.Schema),KFeature.declaration(~X.Schema))))
    case W.CreateRejected{factory,X.Trace{calls,trace}}: "second-creation-rejected|origin=" ++ world_text(origin) ++ "|calls=" ++ Observe.array_text(calls)
def first_world(creation:W.Creation<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  match creation:
    case W.Created{factory,origin}: second_world(origin,W.create(~X.Schema,~X.Declarations,~X.Trace,~U32,~X.empty_store,factory,X.resource()))
    case W.CreateRejected{factory,X.Trace{calls,trace}}: "first-creation-rejected|calls=" ++ Observe.array_text(calls)
def foreign() -> String:
  first_world(W.create(~X.Schema,~X.Declarations,~X.Trace,~U32,~X.empty_store,W.factory(),X.resource()))
def refusal_observed(error:F.Error,owners:F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,observed:W.World<X.Schema,X.Declarations,X.Trace,U32> & String) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & String:
  match observed:
    case (world,text): (world,"refused=" ++ Observe.error_text(error) ++ "|" ++ text ++ "|incoming=" ++ original_text(owners))
def unexpected_observed(owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,observed:W.World<X.Schema,X.Declarations,X.Trace,U32> & String) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & String:
  match observed:
    case (world,text): (world,"UNEXPECTED_BUILT|" ++ text ++ "|owners=" ++ owners_text(owners))
def refused(result:F.RecipeResult<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> W.World<X.Schema,X.Declarations,X.Trace,U32> & String:
  match result:
    case F.Refused{error,world,F.Recipe{tree,owners,build}}: refusal_observed(error,owners,world_observed(world))
    case F.Completed{world,F.Output{owners,bootstrap,update}}: unexpected_observed(owners,world_observed(world))
def sequence_finish(previous:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,records:List<&2,String>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  List.show(&2,String,identity,records) ++ "|final-world=" ++ world_text(world) ++ "|previous-owners=" ++ owners_text(previous)
def priority_observed(previous:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,records:List<&2,String>,observed:W.World<X.Schema,X.Declarations,X.Trace,U32> & String) -> String:
  match observed:
    case (world,text): sequence_finish(previous,List.append(&2,String,records,["priority=" ++ text]),world)
def priority_stage(previous:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,records:List<&2,String>) -> String:
  priority_observed(previous,records,refused(F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world,recipe(CFeature.declaration(~X.Schema),CFeature.declaration(~X.Schema)))))
def missing_observed(previous:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,records:List<&2,String>,observed:W.World<X.Schema,X.Declarations,X.Trace,U32> & String) -> String:
  match observed:
    case (world,text): priority_stage(previous,world,List.append(&2,String,records,["missing=" ++ text]))
def missing_stage(previous:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,records:List<&2,String>) -> String:
  missing_observed(previous,records,refused(F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world,recipe(CFeature.declaration(~X.Schema),F.Definition{"Other",[],F.Empty{}}))))
def duplicate_observed(previous:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,records:List<&2,String>,observed:W.World<X.Schema,X.Declarations,X.Trace,U32> & String) -> String:
  match observed:
    case (world,text): missing_stage(previous,world,List.append(&2,String,records,["duplicate=" ++ text]))
def duplicate_stage(previous:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world:W.World<X.Schema,X.Declarations,X.Trace,U32>,records:List<&2,String>) -> String:
  duplicate_observed(previous,records,refused(F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world,recipe(KFeature.declaration(~X.Schema),KFeature.declaration(~X.Schema)))))
def sequence_observed(owners:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,observed:W.World<X.Schema,X.Declarations,X.Trace,U32> & String) -> String:
  match observed:
    case (world,text): duplicate_stage(owners,world,["selected=" ++ text])
def sequence_executed(result:P.ProvisionResult<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,String>) -> String:
  match result:
    case P.Executed{Sch.Finished{Sch.Schedule{ns,name,steps,owners},world,obs},needs}: sequence_observed(owners,world_observed(world))
    case result: "UNEXPECTED_SEQUENCE_EXECUTION|" ++ executed(result)
def sequence_built(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,result:P.Build<X.Schema,X.Declarations,X.Trace,U32,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> String:
  match result:
    case P.Built{schedule}: sequence_executed(P.run(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,~String,~dispatch,~condition,~X.provision,schedule,world))
    case P.Invalid{owners}: "invalid-sequence|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners)
def sequence_catalog(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,plan:P.Plan<X.Schema>,observed:F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>> & List<&2,U32>) -> String:
  match observed:
    case (owners,ids): sequence_built(world,P.build(~X.Schema,~X.Declarations,~X.Trace,~U32,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,1,"features",plan,ids,owners))
def sequence_phases(result:PhaseResult) -> String:
  match result:
    case PhaseRan{result}: sequence_executed(result)
    case PhaseInvalid{world,owners}: "invalid-sequence|" ++ world_text(world) ++ "|owners=" ++ owners_text(owners)
def sequence_result(result:F.RecipeResult<X.Schema,W.World<X.Schema,X.Declarations,X.Trace,U32>,F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>>) -> String:
  match result:
    case F.Completed{world,F.Output{owners,bootstrap,update}}: sequence_phases(phases(1,bootstrap,update,world,owners))
    case F.Refused{error,world,F.Recipe{tree,owners,build}}: "unexpected-sequence-refusal|" ++ world_text(world) ++ "|owners=" ++ original_text(owners)
def sequence_created(creation:W.Creation<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  match creation:
    case W.Created{factory,world}: sequence_result(F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,world,recipe(CFeature.declaration(~X.Schema),KFeature.declaration(~X.Schema))))
    case W.CreateRejected{factory,X.Trace{calls,trace}}: "sequence-creation-rejected|calls=" ++ Observe.array_text(calls)
def sequence() -> String:
  sequence_created(W.create(~X.Schema,~X.Declarations,~X.Trace,~U32,~X.empty_store,W.factory(),X.resource()))
# Diagnostic command deliberately replaces the U32 counter array after refusal;
# its actual captured Type owner must remain deferred until the original barrier.
def replace_calls(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,calls:Array<U32>) -> W.World<X.Schema,X.Declarations,X.Trace,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,X.Trace{previous,trace},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,X.Trace{calls,List.append(&2,String,trace,["marker"])},events,commands,regs,system,clock}
def marker_observed(observed:W.World<X.Schema,X.Declarations,X.Trace,U32> & String) -> String:
  match observed:
    case (world,text): "before=" ++ text ++ "|after=" ++ world_text(W.barrier(~X.Schema,~X.Declarations,~X.Trace,~U32,world))
def marker_world(world:W.World<X.Schema,X.Declarations,X.Trace,U32>,asset:Array<U32>) -> String:
  marker_observed(refused(F.run_recipe(~X.Schema,~W.World<X.Schema,X.Declarations,X.Trace,U32>,~F.Pack<CFeature.Owner,F.Pack<KFeature.Owner,F.Pack<Unit,Unit>>>,~F.Pack<Combat.Built,F.Pack<Core.Built,F.Pack<EmptyExtra,Unit>>>,W.enqueue(~X.Schema,~X.Declarations,~X.Trace,~U32,world,w => W.event_publish(~X.Schema,~X.Declarations,~X.Trace,~U32,replace_calls(w,asset),[909])),recipe(CFeature.declaration(~X.Schema),F.Definition{"Other",[],F.Empty{}}))))
def marker_created(creation:W.Creation<X.Schema,X.Declarations,X.Trace,U32>) -> String:
  match creation:
    case W.Created{factory,world}: marker_world(world,ANode{ALeaf{901},ALeaf{902}})
    case W.CreateRejected{factory,X.Trace{calls,trace}}: "marker-creation-rejected|calls=" ++ Observe.array_text(calls)
def marker() -> String:
  marker_created(W.create(~X.Schema,~X.Declarations,~X.Trace,~U32,~X.empty_store,W.factory(),X.resource()))
def main() -> IO(Unit):
  IO.print("selected=" ++ run(CFeature.declaration(~X.Schema),KFeature.declaration(~X.Schema)) ++ "\nduplicate=" ++ run(KFeature.declaration(~X.Schema),KFeature.declaration(~X.Schema)) ++ "\nmissing=" ++ run(CFeature.declaration(~X.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\npriority=" ++ run(CFeature.declaration(~X.Schema),CFeature.declaration(~X.Schema)) ++ "\nforeign=" ++ foreign())
