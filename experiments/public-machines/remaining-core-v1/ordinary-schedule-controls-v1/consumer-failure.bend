import Base
import installer.bend as I
import ../marker-phases-v1/apply-retention-v1/consumer.bend as C
import ../marker-phases-v1/apply-retention-v1/phases.bend as Ph
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
type InstalledApplication<S:Data> is Type:InstalledApplication{schedule:Sch.Schedule<S,Array<Array<U32>>,C.Resources<S>,String,C.Owners<S>>,world:W.World<S,Array<Array<U32>>,C.Resources<S>,String>,observations:List<&2,Sch.Observation>,status:String}
def finite_failure(~S:Data,owners:C.Owners<S>,world:W.World<S,Array<Array<U32>>,C.Resources<S>,String>) -> C.Owners<S> & Sys.Outcome<W.World<S,Array<Array<U32>>,C.Resources<S>,String>,String,Unit>:(owners,Sys.Failed{W.event_publish(~S,~Array<Array<U32>>,~C.Resources<S>,~String,world,["finite-phase-failure"]),"finite-phase-error"})
def success(~S:Data,pair:C.Owners<S> & W.World<S,Array<Array<U32>>,C.Resources<S>,String>) -> C.Owners<S> & Sys.Outcome<W.World<S,Array<Array<U32>>,C.Resources<S>,String>,String,Unit>:
  (owners,world)=pair
  (owners,Sys.Succeeded{world,Unit{}})
def selected_group(~S:Data,phase:U32,marker:Ph.PhasedMarker<S,W.World<S,Array<Array<U32>>,C.Resources<S>,String>,C.Owners<S>>,owners:C.Owners<S>,world:W.World<S,Array<Array<U32>>,C.Resources<S>,String>) -> C.Owners<S> & Sys.Outcome<W.World<S,Array<Array<U32>>,C.Resources<S>,String>,String,Unit>:
  match phase marker:
    case 1 Ph.PhasedMarker{apply,_,_,_}:success(~S,M.run_owned_marker(~S,~W.World<S,Array<Array<U32>>,C.Resources<S>,String>,~C.Owners<S>,apply,owners,world))
    case 2 Ph.PhasedMarker{_,exit,_,_}:success(~S,M.run_owned_marker(~S,~W.World<S,Array<Array<U32>>,C.Resources<S>,String>,~C.Owners<S>,exit,owners,world))
    case 3 Ph.PhasedMarker{_,_,transition,_}:success(~S,M.run_owned_marker(~S,~W.World<S,Array<Array<U32>>,C.Resources<S>,String>,~C.Owners<S>,transition,owners,world))
    case _ Ph.PhasedMarker{_,_,_,enter}:success(~S,M.run_owned_marker(~S,~W.World<S,Array<Array<U32>>,C.Resources<S>,String>,~C.Owners<S>,enter,owners,world))
def group(~S:Data,phase:U32,owners:C.Owners<S>,world:W.World<S,Array<Array<U32>>,C.Resources<S>,String>) -> C.Owners<S> & Sys.Outcome<W.World<S,Array<Array<U32>>,C.Resources<S>,String>,String,Unit>:selected_group(~S,phase,C.marker(~S),owners,world)
def installed(~S:Data,world:W.World<S,Array<Array<U32>>,C.Resources<S>,String>,built:Sch.Build<S,Array<Array<U32>>,C.Resources<S>,String,C.Owners<S>>) -> Maybe<&1,InstalledApplication<S>>:
  match built:
    case Sch.Invalid{_}:None{}
    case Sch.Built{schedule}:Some{InstalledApplication{schedule,world,[],"ready"}}
def named(~S:Data,owners:C.Owners<S>,pair:W.World<S,Array<Array<U32>>,C.Resources<S>,String> & U32) -> Maybe<&1,InstalledApplication<S>>:
  (world,namespace)=pair
  installed(~S,world,I.install(~S,~Array<Array<U32>>,~C.Resources<S>,~String,~C.Owners<S>,~String,I.declare(~S,"ordinary-machine-marker"),namespace,owners))
def created(~S:Data,result:Maybe<&1,C.Application<S>>) -> Maybe<&1,InstalledApplication<S>>:
  match result:
    case None{}:None{}
    case Some{C.Application{owners,world}}:named(~S,owners,W.namespace(~S,~Array<Array<U32>>,~C.Resources<S>,~String,world))
def create(~S:Data) -> Maybe<&1,InstalledApplication<S>>:created(~S,C.create(~S))
def returned(~S:Data,result:Sch.RunResult<S,Array<Array<U32>>,C.Resources<S>,String,C.Owners<S>,String>) -> InstalledApplication<S>:
  match result:
    case Sch.Finished{schedule,world,observations}:InstalledApplication{schedule,world,observations,"finished"}
    case Sch.Failed{schedule,world,error,observations}:InstalledApplication{schedule,world,observations,"failed:" ++ error}
    case Sch.Rejected{schedule,world}:InstalledApplication{schedule,world,[],"rejected"}
def run(~S:Data,app:InstalledApplication<S>) -> InstalledApplication<S>:
  match app:
    case InstalledApplication{schedule,world,_,_}:returned(~S,I.run(~S,~Array<Array<U32>>,~C.Resources<S>,~String,~C.Owners<S>,~String,~(h => w => group(~S,1,h,w)),~(h => w => group(~S,2,h,w)),~(h => w => finite_failure(~S,h,w)),~(h => w => group(~S,4,h,w)),schedule,world))
def step(value:Sch.Step) -> String:
  match value:
    case Sch.Barrier{}:"barrier"
    case Sch.Phase{name}:"phase:" ++ name
    case Sch.System{id,condition}:"system:" ++ U32.show(id) ++ ":condition=" ++ U32.show(condition)
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Applied{}:"applied"
    case Sch.Entered{name}:"entered:" ++ name
    case Sch.Ran{id}:"ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"skipped:" ++ U32.show(id)
def observed(~S:Data,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+observations:List<&2,Sch.Observation>,+status:String,pair:C.Application<S> & String) -> InstalledApplication<S> & String:
  match pair:
    case (C.Application{owners,world},text):(InstalledApplication{Sch.Schedule{namespace,name,steps,owners},world,observations,status},text ++ "/schedule=" ++ U32.show(namespace) ++ ":" ++ name ++ ":" ++ List.show(&2,Sch.Step,step,steps) ++ "/observations=" ++ List.show(&2,Sch.Observation,observation,observations) ++ "/scheduleStatus=" ++ status)
def observe(~S:Data,app:InstalledApplication<S>) -> InstalledApplication<S> & String:
  match app:
    case InstalledApplication{Sch.Schedule{namespace,name,steps,owners},world,observations,status}:observed(~S,namespace,name,steps,observations,status,C.observe(~S,C.Application{owners,world}))
def checkpoint_observed(~S:Data,label:String,prior:String,pair:InstalledApplication<S> & String) -> InstalledApplication<S> & String:
  match pair:
    case (app,text):(app,prior ++ label ++ ":" ++ text ++ "\n")
def checkpoint(~S:Data,app:InstalledApplication<S>,label:String,prior:String) -> InstalledApplication<S> & String:checkpoint_observed(~S,label,prior,observe(~S,app))
def final(~S:Data,pair:InstalledApplication<S> & String) -> String:
  (_,text)=pair
  text
def second(~S:Data,pair:InstalledApplication<S> & String) -> String:
  (app,prior)=pair
  final(~S,checkpoint(~S,run(~S,app),"marker2",prior))
def first(~S:Data,pair:InstalledApplication<S> & String) -> String:
  (app,prior)=pair
  second(~S,checkpoint(~S,run(~S,app),"marker1",prior))
def main_trace(~S:Data,result:Maybe<&1,InstalledApplication<S>>) -> String:
  match result:
    case None{}:"installation-refused"
    case Some{app}:first(~S,checkpoint(~S,app,"initial",""))
