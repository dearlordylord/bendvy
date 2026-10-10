import Base
import ../provider.bend as P
import ../readers.bend as R
import ../context.bend as Ctx
import ../gameplay.bend as G
import ../observe.bend as O
import ../full-observe.bend as Full
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-schedule.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as OD
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/machine-world.bend as MW
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import ../../marker-phases-v1/apply-retention-v1/consumer.bend as Tree
import checked-schedule.bend as CheckedSch
type ReaderOwners<S:Data> is Type:ReaderOwners{fast:R.Instance<S,(world => input => R.runner(~S,world,input))>,slow:R.Instance<S,(world => input => R.runner(~S,world,input))>,owned:Array<U32>,deliveries:List<&2,String>}
type ReaderApplication<S:Data> is Type:ReaderApplication{owners:ReaderOwners<S>,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>,observations:List<&2,Sch.Observation>,status:String}
type ConditionWork<-S:Data,-H:Type> is Type:ConditionWork{flow:Cap.ValueRead<H,M.CurrentView<S,P.FlowToken,P.Flow>>}
def flow_declaration(~S:Data) -> OD.Declaration<S,P.FlowToken,P.Flow,P.Resources<S>,P.flow_take_resource(~S)>:OD.Declaration{"Flow"}
def condition_view(~S:Data,view:M.CurrentView<S,P.FlowToken,P.Flow>,id:U32) -> Bool:
  match id:
    case 1:M.is_current(~S,~P.FlowToken,~P.Flow,~P.flow_same,view,P.Play{})
    case _:Bool.not(M.is_current(~S,~P.FlowToken,~P.Flow,~P.flow_same,view,P.Play{}))
def condition_read(~S:Data,~H:Type,id:U32,pair:H & M.CurrentView<S,P.FlowToken,P.Flow>) -> H & Bool:
  (owner,view)=pair
  (owner,condition_view(~S,view,id))
def condition_cap(~S:Data,~H:Type,caps:ConditionWork<S,H>) -> Cap.ValueRead<H,M.CurrentView<S,P.FlowToken,P.Flow>>:
  match caps:
    case ConditionWork{cap}:cap
def condition_body(~S:Data,~H:Type,~caps:ConditionWork<S,H>,id:U32,owner:H) -> H & Bool:condition_read(~S,~H,id,Cap.value_read(~H,~M.CurrentView<S,P.FlowToken,P.Flow>,~condition_cap(~S,~H,caps),owner))
def condition_plan(~S:Data) -> K.Plan<S,P.Store<S>,P.Resources<S>,Unit,(H => ConditionWork<S,H>)>:K.Plan{world => OD.required(~S,~P.FlowToken,~P.Flow,~P.Store<S>,~P.Resources<S>,~Unit,~P.flow_take_resource(~S),~flow_declaration(~S),world),ConditionWork{OD.condition(~S,~P.FlowToken,~P.Flow,~P.Store<S>,~P.Resources<S>,~Unit,~P.flow_take_resource(~S),~flow_declaration(~S))}}
def checked(~S:Data,result:K.Checked<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & Result<String,Bool>:
  match result:
    case K.Checked{world,Done{allowed}}:(world,Done{allowed})
    case K.Checked{world,Fail{K.MissingRuntimeRequirements{names}}}:(world,Fail{"ConditionMissing:" ++ List.show(&2,String,x => x,names)})
def condition(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>,id:U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & Result<String,Bool>:checked(~S,K.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(H => ConditionWork<S,H>),~U32,~condition_body(~S),~condition_plan(~S),id,world))
def delivery(value:R.Delivery) -> String:
  match value:
    case R.Delivery{flow,level,flowLagged,levelLagged}:"flow=" ++ List.show(&2,M.Transition<P.Flow>,v => O.transition(~P.Flow,~O.flow,v),flow) ++ "/level=" ++ List.show(&2,M.Transition<P.Level>,v => O.transition(~P.Level,~O.level,v),level) ++ "/lagged=" ++ O.bool(flowLagged) ++ "," ++ O.bool(levelLagged)
def report(value:Maybe<&2,R.Delivery>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:delivery(value)
def reader_allowed(~S:Data,allowed:Bool,status:String,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match allowed:
    case True{}:Sys.Succeeded{world,Unit{}}
    case False{}:Sys.Failed{world,status}
def reader_outcome(~S:Data,+status:String,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:reader_allowed(~S,String.eq(status,"ok"),status,world)
def reader_returned(~S:Data,other:R.Instance<S,(world => input => R.runner(~S,world,input))>,owned:Array<U32>,prior:List<&2,String>,id:U32,result:R.Returned<S,(world => input => R.runner(~S,world,input))>) -> ReaderOwners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match id result:
    case 1 R.Returned{instance,world,values,+status}:(ReaderOwners{instance,other,owned,List.append(&2,String,prior,["fast:" ++ report(values) ++ ":" ++ status])},reader_outcome(~S,status,world))
    case _ R.Returned{instance,world,values,+status}:(ReaderOwners{other,instance,owned,List.append(&2,String,prior,["slow:" ++ report(values) ++ ":" ++ status])},reader_outcome(~S,status,world))
def dispatch(~S:Data,owners:ReaderOwners<S>,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>,id:U32) -> ReaderOwners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners id:
    case ReaderOwners{fast,slow,owned,prior} 1:reader_returned(~S,slow,owned,prior,1,R.invoke(~S,~(world => input => R.runner(~S,world,input)),fast,world,False{}))
    case ReaderOwners{fast,slow,owned,prior} _:reader_returned(~S,fast,owned,prior,2,R.invoke(~S,~(world => input => R.runner(~S,world,input)),slow,world,False{}))
def skip_returned(~S:Data,other:R.Instance<S,(world => input => R.runner(~S,world,input))>,owned:Array<U32>,prior:List<&2,String>,id:U32,pair:R.Instance<S,(world => input => R.runner(~S,world,input))> & W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> ReaderOwners<S> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match id pair:
    case 1, (instance,world):(ReaderOwners{instance,other,owned,prior},world)
    case _, (instance,world):(ReaderOwners{other,instance,owned,prior},world)
def skip(~S:Data,owners:ReaderOwners<S>,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>,id:U32) -> ReaderOwners<S> & W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match owners id:
    case ReaderOwners{fast,slow,owned,prior} 1:skip_returned(~S,slow,owned,prior,1,R.skip(~S,~(world => input => R.runner(~S,world,input)),fast,world))
    case ReaderOwners{fast,slow,owned,prior} _:skip_returned(~S,fast,owned,prior,2,R.skip(~S,~(world => input => R.runner(~S,world,input)),slow,world))
def scheduled(~S:Data,result:Sch.RunResult<S,P.Store<S>,P.Resources<S>,Unit,ReaderOwners<S>,String>) -> ReaderApplication<S>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,owners},world,observations}:ReaderApplication{owners,world,observations,"finished"}
    case Sch.Failed{Sch.Schedule{_,_,_,owners},world,error,observations}:ReaderApplication{owners,world,observations,error}
    case Sch.Rejected{Sch.Schedule{_,_,_,owners},world}:ReaderApplication{owners,world,[],"rejected"}
def built(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>,result:Sch.Build<S,P.Store<S>,P.Resources<S>,Unit,ReaderOwners<S>>) -> ReaderApplication<S>:
  match result:
    case Sch.Invalid{owners}:ReaderApplication{owners,world,[],"invalid"}
    case Sch.Built{schedule}:scheduled(~S,CheckedSch.run_with_skip(~S,~P.Store<S>,~P.Resources<S>,~Unit,~ReaderOwners<S>,~String,~skip(~S),~dispatch(~S),~condition(~S),schedule,world))
def named(~S:Data,owners:ReaderOwners<S>,pair:W.World<S,P.Store<S>,P.Resources<S>,Unit> & U32) -> ReaderApplication<S>:
  (world,namespace)=pair
  built(~S,world,Sch.build(~S,~P.Store<S>,~P.Resources<S>,~Unit,~ReaderOwners<S>,namespace,"ordinary-readers",[Sch.Phase{"condition-preflight"},Sch.System{1,1},Sch.System{2,2}],[1,2],owners))
def run(~S:Data,app:ReaderApplication<S>) -> ReaderApplication<S>:
  match app:
    case ReaderApplication{owners,world,_,_}:named(~S,owners,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,P.frame(~S,world)))
def fixture_resource(~S:Data,resource:P.Resources<S>) -> P.Resources<S>:
  match resource:
    case P.Resources{owned,_,level,_,levelStream,_,_,trace}:P.Resources{owned,M.Present{P.Play{},M.Queued{P.Boot{},False{}},Some{P.Boot{}},True{}},level,St.publish(~P.Flow,St.empty(~P.Flow),1n,M.Transition{P.Boot{},P.Play{}}),levelStream,0n,1n,trace}
def slow_provisioned(~S:Data,fast:R.Instance<S,(world => input => R.runner(~S,world,input))>,result:R.Provision<S,(world => input => R.runner(~S,world,input))>) -> Maybe<&1,ReaderApplication<S>>:
  match result:
    case R.ProvisionFailed{_}:None{}
    case R.Provisioned{world,slow}:Some{ReaderApplication{ReaderOwners{fast,slow,ANode{ALeaf{43},ALeaf{59}},[]},world,[],"ready"}}
def fast_provisioned(~S:Data,result:R.Provision<S,(world => input => R.runner(~S,world,input))>) -> Maybe<&1,ReaderApplication<S>>:
  match result:
    case R.ProvisionFailed{_}:None{}
    case R.Provisioned{world,fast}:slow_provisioned(~S,fast,R.provision(~S,~(world => input => R.runner(~S,world,input)),world,"slow"))
def populated(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Maybe<&1,ReaderApplication<S>>:fast_provisioned(~S,R.provision(~S,~(world => input => R.runner(~S,world,input)),P.map_resources(~S,resource => fixture_resource(~S,resource),world),"fast"))
def seeded(~S:Data,result:Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>) -> Maybe<&1,ReaderApplication<S>>:
  match result:
    case Sys.Succeeded{world,_}:populated(~S,world)
    case Sys.Failed{_,_}:None{}
def created(~S:Data,result:W.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> Maybe<&1,ReaderApplication<S>>:
  match result:
    case W.CreateRejected{_,_}:None{}
    case W.Created{_,world}:seeded(~S,Ctx.runner(~S,world,G.Seed{}))
def create(~S:Data) -> Maybe<&1,ReaderApplication<S>>:created(~S,W.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~P.empty_store(~S),W.factory(),P.initial_resources(~S)))
def marker_applied(~S:Data,owned:Array<U32>,level:M.Slot<S,P.LevelToken,P.Level>,flowStream:St.Stream<P.Flow>,levelStream:St.Stream<P.Level>,frame:Nat,+tick:Nat,trace:List<&2,String>,applied:M.Applied<S,P.FlowToken,P.Flow>) -> P.Resources<S>:
  match applied:
    case M.Applied{slot,None{}}:P.Resources{owned,slot,level,flowStream,levelStream,frame,tick,trace}
    case M.Applied{slot,Some{event}}:P.Resources{owned,slot,level,St.publish(~P.Flow,flowStream,tick,event),levelStream,frame,tick,trace}
def marker_resource(~S:Data,resource:P.Resources<S>) -> P.Resources<S>:
  match resource:
    case P.Resources{owned,+flow,level,flowStream,levelStream,frame,tick,trace}:marker_applied(~S,owned,level,flowStream,levelStream,frame,tick,trace,M.apply_snapshot(~S,~P.FlowToken,~P.Flow,~P.flow_same,flow,M.snapshot(~S,~P.FlowToken,~P.Flow,flow)))
def apply_group(~S:Data,owners:ReaderOwners<S>,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> ReaderOwners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:(owners,Sys.Succeeded{P.map_resources(~S,resource => marker_resource(~S,resource),P.pulse(~S,world)),Unit{}})
def idle_group(~S:Data,owners:ReaderOwners<S>,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> ReaderOwners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:(owners,Sys.Succeeded{world,Unit{}})
def marker_built(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>,result:Sch.Build<S,P.Store<S>,P.Resources<S>,Unit,ReaderOwners<S>>) -> ReaderApplication<S>:
  match result:
    case Sch.Invalid{owners}:ReaderApplication{owners,world,[],"invalid-marker"}
    case Sch.Built{schedule}:scheduled(~S,I.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~ReaderOwners<S>,~String,~apply_group(~S),~idle_group(~S),~idle_group(~S),~idle_group(~S),schedule,world))
def marker_named(~S:Data,owners:ReaderOwners<S>,pair:W.World<S,P.Store<S>,P.Resources<S>,Unit> & U32) -> ReaderApplication<S>:
  (world,namespace)=pair
  marker_built(~S,world,I.install(~S,~P.Store<S>,~P.Resources<S>,~Unit,~ReaderOwners<S>,~String,I.declare(~S,"reader-transition-marker"),namespace,owners))
def marker(~S:Data,app:ReaderApplication<S>) -> ReaderApplication<S>:
  match app:
    case ReaderApplication{owners,world,_,_}:marker_named(~S,owners,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Ran{id}:"ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"skipped:" ++ U32.show(id)
    case Sch.Applied{}:"applied"
    case Sch.Entered{name}:"entered:" ++ name
def instance(~S:Data,value:R.Instance<S,(world => input => R.runner(~S,world,input))>) -> R.Instance<S,(world => input => R.runner(~S,world,input))> & String:
  match value:
    case R.Instance{Sys.Registry{+ns,+id,+name,+access,+cursor},St.Reader{+fn,+fi},St.Reader{+ln,+li}}:(R.Instance{Sys.Registry{ns,id,name,access,cursor},St.Reader{fn,fi},St.Reader{ln,li}},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access) ++ ":cursor=" ++ U32.show(cursor) ++ ":flow=" ++ U32.show(fn) ++ ":" ++ U32.show(fi) ++ ":level=" ++ U32.show(ln) ++ ":" ++ U32.show(li))
def owners_join(~S:Data,+deliveries:List<&2,String>,+observations:List<&2,Sch.Observation>,+status:String,pairFast:R.Instance<S,(world => input => R.runner(~S,world,input))> & String,pairSlow:R.Instance<S,(world => input => R.runner(~S,world,input))> & String,pairOwned:Array<U32> & String,pairWorld:W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> ReaderApplication<S> & String:
  match pairFast pairSlow pairOwned pairWorld:
    case (fast,a),(slow,b),(owned,c),(world,text):(ReaderApplication{ReaderOwners{fast,slow,owned,deliveries},world,observations,status},text ++ "/fast=" ++ a ++ "/slow=" ++ b ++ "/owners=" ++ c ++ "/deliveries=" ++ List.show(&2,String,x => x,deliveries) ++ "/observations=" ++ List.show(&2,Sch.Observation,observation,observations) ++ "/status=" ++ status)
def observe(~S:Data,app:ReaderApplication<S>) -> ReaderApplication<S> & String:
  match app:
    case ReaderApplication{ReaderOwners{fast,slow,owned,deliveries},world,observations,status}:owners_join(~S,deliveries,observations,status,instance(~S,fast),instance(~S,slow),Tree.tree(~U32,~Tree.number,owned),Full.world(~S,world))
def checkpoint_join(~S:Data,label:String,prior:String,pair:ReaderApplication<S> & String) -> ReaderApplication<S> & String:
  (app,text)=pair
  (app,prior ++ label ++ ":" ++ text ++ "\n")
def checkpoint(~S:Data,app:ReaderApplication<S>,label:String,prior:String) -> ReaderApplication<S> & String:checkpoint_join(~S,label,prior,observe(~S,app))
def final(~S:Data,pair:ReaderApplication<S> & String) -> String:
  (_,text)=pair
  text
def remove_flow(~S:Data,resources:P.Resources<S>) -> P.Resources<S>:
  match resources:
    case P.Resources{owned,_,level,flowStream,levelStream,frame,tick,trace}:P.Resources{owned,M.Missing{},level,flowStream,levelStream,frame,tick,trace}
def missing(~S:Data,app:ReaderApplication<S>) -> ReaderApplication<S>:
  match app:
    case ReaderApplication{owners,world,observations,status}:ReaderApplication{owners,P.map_resources(~S,r => remove_flow(~S,r),world),observations,status}
def failed_checkpoint(~S:Data,pair:ReaderApplication<S> & String) -> String:
  (app,prior)=pair
  final(~S,checkpoint(~S,run(~S,app),"missing-condition",prior))
def missing_checkpoint(~S:Data,pair:ReaderApplication<S> & String) -> String:
  (app,prior)=pair
  failed_checkpoint(~S,checkpoint(~S,missing(~S,app),"missing-fixture",prior))
def first(~S:Data,pair:ReaderApplication<S> & String) -> String:
  (app,prior)=pair
  missing_checkpoint(~S,checkpoint(~S,run(~S,app),"readers-register",prior))
def main_trace(~S:Data,result:Maybe<&1,ReaderApplication<S>>) -> String:
  match result:
    case None{}:"fixture-rejected"
    case Some{app}:first(~S,checkpoint(~S,app,"initial",""))
