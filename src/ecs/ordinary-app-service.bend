import Base
import ./change-tick.bend as Tick
import ./capabilities.bend as Cap
import ./ordinary-service-declaration.bend as D
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./schema-fragments.bend as Fragment
# Standalone service App retaining setup, provisioned schedule/registry and World.
# The payload owner stays in its resource Slot; debug controls observations only.
type Application<S:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,-scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>> is Type:
  Application{setup:D.Setup<S,C,R,E,scan>,plan:SP.Plan<S>,scheduled:SP.Provisioned<S,C,R,E,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>>,world:W.World<S,C,R,E>,debug:Bool}
# Installation result: success retains all owners in App; rejection returns World
# and setup, plus registry owner when registration succeeded but plan build failed.
type Installation<App:Type,World:Type,Setup:Data,Owner:Type> is Type:
  Installed{app:App}
  InstallRejected{world:World,setup:Setup,owner:Maybe<&1,Owner>}
# Detached service/setup/registry/schedule observation, not a host capability or
# confirmation that a later call will succeed.
type Inventory<S:Data> is Data:
  Inventory{entries:List<&2,Fragment.Entry<S>>,services:List<&2,D.Status<S>>,required:List<&2,SP.Requirement<S>>,namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,steps:List<&2,Sch.Step>}
# Every run result retains App. Missing reports unmet preflight requirements;
# Rejected is schedule admission refusal. Failed carries runner failure and
# observations; none of these add external IO rollback or payload recovery.
type RunResult<App:Type,S:Data> is Type:
  Finished{app:App,observations:List<&2,Sch.Observation>}
  Failed{app:App,error:Unit,observations:List<&2,Sch.Observation>}
  Rejected{app:App}
  Missing{app:App,missing:List<&2,SP.Requirement<S>>}
def built(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,plan:SP.Plan<S>,world:W.World<S,C,R,E>,result:SP.Build<S,C,R,E,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>>) -> Installation<Application<S,C,R,E,runner,scan>,W.World<S,C,R,E>,D.Setup<S,C,R,E,scan>,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>>:
  match result:
    case SP.Invalid{owner}:InstallRejected{world,setup,Some{owner}}
    case SP.Built{scheduled}:Installed{Application{setup,plan,scheduled,world,False{}}}
def planned(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,world:W.World<S,C,R,E>,owner:Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>,ns:U32,+id:U32,+plan:SP.Plan<S>) -> Installation<Application<S,C,R,E,runner,scan>,W.World<S,C,R,E>,D.Setup<S,C,R,E,scan>,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>>:
  built(~S,~C,~R,~E,~runner,~scan,setup,plan,world,SP.build(~S,~C,~R,~E,~Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>,ns,"service-schedule",plan,[id],owner))
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,requirement:SP.Requirement<S>,result:Sys.RegistrationResult<S,C,R,E,Unit,Unit,Unit,runner>) -> Installation<Application<S,C,R,E,runner,scan>,W.World<S,C,R,E>,D.Setup<S,C,R,E,scan>,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>>:
  match result:
    case Sys.RegistrationFailed{world}:InstallRejected{world,setup,None{}}
    case Sys.Registered{world,Sys.Registry{+ns,+id,name,access,cursor}}:planned(~S,~C,~R,~E,~runner,~scan,setup,world,Sys.Registry{ns,id,name,access,cursor},ns,id,SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Entry{Sch.System{id,0},[requirement]}})
# Set observation enablement while retaining World, setup and actual registry.
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,app:Application<S,C,R,E,runner,scan>,flag:Bool) -> Application<S,C,R,E,runner,scan>:
  match app:
    case Application{setup,plan,scheduled,world,_}:Application{setup,plan,scheduled,world,flag}
def described(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,plan:SP.Plan<S>,scheduled:SP.Provisioned<S,C,R,E,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>>,observed:W.World<S,C,R,E> & List<&2,D.Status<S>>) -> Application<S,C,R,E,runner,scan> & Maybe<&2,Inventory<S>>:
  match setup scheduled observed:
    case D.Setup{+entries}, SP.Provisioned{Sch.Schedule{+ns,+scheduleName,+steps,Sys.Registry{+registryNs,+id,+name,+access,+cursor}},+needs}, (world,statuses):(Application{D.Setup{entries},plan,SP.Provisioned{Sch.Schedule{ns,scheduleName,steps,Sys.Registry{registryNs,id,name,access,cursor}},needs},world,True{}},Some{Inventory{entries,statuses,needs,registryNs,id,name,access,cursor,steps}})
# Return App with optional detached Inventory. Disabled bypasses scan entirely;
# enabled scans availability without calling the service. Trusted setup callbacks
# remain responsible for owner-preserving observation.
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,app:Application<S,C,R,E,runner,scan>) -> Application<S,C,R,E,runner,scan> & Maybe<&2,Inventory<S>>:
  match app:
    case Application{setup,plan,scheduled,world,False{}}:(Application{setup,plan,scheduled,world,False{}},None{})
    case Application{setup,plan,scheduled,world,True{}}:described(~S,~C,~R,~E,~runner,~scan,setup,plan,scheduled,scan(world))
def dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,value:Sys.RunResult<S,C,R,E,Unit,Unit,Unit,runner>) -> Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner> & Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>:
  match value:
    case Sys.Completed{owner,outcome}:(owner,outcome)
    case Sys.RegistrationRejected{owner,world,_}:(owner,Sys.Failed{world,Unit{}})
# Advanced single-registry adapter invoking tracked system execution. The supplied
# id argument is unused here: registry validation comes from Sys.run, and
# registration rejection is represented as Sys.Failed(Unit).
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,owner:Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>,world:W.World<S,C,R,E>,_:U32) -> Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner> & Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>:
  dispatched(~S,~C,~R,~E,~runner,Sys.run(~S,~C,~R,~E,~Unit,~Unit,~Unit,~runner,owner,world,Unit{}))
# Standalone service schedule condition is always true and returns World unchanged.
def condition(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,_:U32) -> W.World<S,C,R,E> & Bool:
  (world,True{})
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,plan:SP.Plan<S>,debug:Bool,needs:List<&2,SP.Requirement<S>>,value:Sch.RunResult<S,C,R,E,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>,Unit>) -> RunResult<Application<S,C,R,E,runner,scan>,S>:
  match value:
    case Sch.Finished{schedule,world,observations}:Finished{Application{setup,plan,SP.Provisioned{schedule,needs},world,debug},observations}
    case Sch.Failed{schedule,world,error,observations}:Failed{Application{setup,plan,SP.Provisioned{schedule,needs},world,debug},error,observations}
    case Sch.Rejected{schedule,world}:Rejected{Application{setup,plan,SP.Provisioned{schedule,needs},world,debug}}
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,plan:SP.Plan<S>,debug:Bool,value:SP.ProvisionResult<S,C,R,E,Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>,Unit>) -> RunResult<Application<S,C,R,E,runner,scan>,S>:
  match value:
    case SP.Missing{scheduled,world,missing}:Missing{Application{setup,plan,scheduled,world,debug},missing}
    case SP.Executed{value,needs}:executed(~S,~C,~R,~E,~runner,~scan,setup,plan,debug,needs,value)
# Scan provided services and preflight all requirements before any schedule step.
# Missing returns App without running its initial barrier or service. On admission,
# apply the installed barrier then dispatch the registered service; preserve App
# owners in every result. No guarantee covers arbitrary external call effects.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,app:Application<S,C,R,E,runner,scan>) -> RunResult<Application<S,C,R,E,runner,scan>,S>:
  match app:
    case Application{setup,plan,scheduled,world,debug}:provisioned(~S,~C,~R,~E,~runner,~scan,setup,plan,debug,SP.run(~S,~C,~R,~E,~Sys.Registry<S,C,R,E,Unit,Unit,Unit,runner>,~Unit,~dispatch(~S,~C,~R,~E,~runner),~condition(~S,~C,~R,~E),~D.provision(~S,~C,~R,~E,~scan),scheduled,world))
# Register one declaration-bound service and build a standalone barrier-then-system
# schedule with its service requirement. Does not call P or require Ready at install.
# Returns actual World/setup/possible registry on refusal; debug starts disabled.
def install(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & D.Slot<P>,~put:Rest -> D.Slot<P> -> R,~call:P -> P,~declaration:D.Declaration<S,R,P,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,world:W.World<S,C,R,E>,name:String) -> Installation<Application<S,C,R,E,D.runner(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration),scan>,W.World<S,C,R,E>,D.Setup<S,C,R,E,scan>,Sys.Registry<S,C,R,E,Unit,Unit,Unit,D.runner(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration)>>:
  registered(~S,~C,~R,~E,~D.runner(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration),~scan,setup,D.requirement(~S,~R,~P,~Rest,~take,~put,~call,declaration),D.define(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration,world,name))
def status_text(~S:Data,value:D.Status<S>) -> String:
  match value:
    case D.Status{id,key,provided}:"service(" ++ U32.show(id) ++ "," ++ key ++ "," ++ Bool.show(provided) ++ ")"
def requirement_text(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Service{id}:"service:" ++ U32.show(id)
    case SP.Component{id}:"component:" ++ U32.show(id)
    case SP.Resource{id}:"resource:" ++ U32.show(id)
def entry_text(~S:Data,value:Fragment.Entry<S>) -> String:
  match value:
    case Fragment.Entry{Fragment.Service{},key,name}:"Service(" ++ key ++ "," ++ name ++ ")"
    case _:"nonservice"
def step_text(value:Sch.Step) -> String:
  match value:
    case Sch.Barrier{}:"barrier"
    case Sch.Phase{name}:"phase:" ++ name
    case Sch.System{id,condition}:"system:" ++ U32.show(id) ++ ":" ++ U32.show(condition)
# Render only a detached optional Inventory; None renders debug=None. No service
# call, World access or host side effect is performed by this formatter.
def text(~S:Data,value:Maybe<&2,Inventory<S>>) -> String:
  match value:
    case None{}:"debug=None"
    case Some{Inventory{entries,statuses,required,ns,id,name,access,cursor,steps}}:"debug{entries=" ++ List.show(&2,Fragment.Entry<S>,entry_text(~S),entries) ++ ";services=" ++ List.show(&2,D.Status<S>,status_text(~S),statuses) ++ ";required=" ++ List.show(&2,SP.Requirement<S>,requirement_text(~S),required) ++ ";registry=" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,s => s,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ";steps=" ++ List.show(&2,Sch.Step,step_text,steps) ++ "}"
# Build an App inventory read capability using snapshot and its debug bypass.
# Does not grant service invocation or access to the actual payload owner.
def read(~S:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>) -> Cap.ValueRead<Application<S,C,R,E,runner,scan>,Maybe<&2,Inventory<S>>>:
  Cap.ValueRead{snapshot(~S,~C,~R,~E,~runner,~scan)}
