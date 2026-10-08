import Base
import ../bend-candidate/query-consumer.bend as A
import ../bend-candidate/full-v2/optional-resource.bend as Slot
import ../../../src/ecs/check.bend as Check
import check-state-garden.bend as R
import check-projection-garden.bend as P
import check-world-garden.bend as Dump
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/schedule.bend as Sch
import ../../../src/ecs/string-equality.bend as SE

# Instrumented diagnostic driver, excluded from feature timing. Each genuine
# registered System is run in a one-step Schedule so the full Check boundary
# snapshots can leave through an external carrier after that schedule returns.
# Diagnostic preload/record and System counters are outside Check.run.
def succeeded(result:W.World<A.Schema,A.Store,R.Resources,U32> & Unit) -> Sys.Outcome<W.World<A.Schema,A.Store,R.Resources,U32>,String,Unit>:
  (world,value)=result
  Sys.Succeeded{world,value}
def runner(world:W.World<A.Schema,A.Store,R.Resources,U32>,update:Bool) -> Sys.Outcome<W.World<A.Schema,A.Store,R.Resources,U32>,String,Unit>:
  match update:
    case False{}:succeeded(W.observe_resource(~A.Schema,~A.Store,~R.Resources,~U32,~Unit,~R.increment,world))
    case True{}:succeeded(W.observe_resource(~A.Schema,~A.Store,~R.Resources,~U32,~Unit,~R.update,world))
type Holder is Type:
  Holder{registry:Sys.Registry<A.Schema,A.Store,R.Resources,U32,Bool,String,Unit,runner>}
type State is Type:
  State{world:W.World<A.Schema,A.Store,R.Resources,U32>,first:Holder,second:Holder,update:Holder,text:String}
type Gate is Type:
  Gate{world:W.World<A.Schema,A.Store,R.Resources,U32>,holder:Holder,text:String}
def preload(snapshot:String,world:W.World<A.Schema,A.Store,R.Resources,U32>) -> W.World<A.Schema,A.Store,R.Resources,U32> & Unit:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:W.observe_resource_finish(~A.Schema,~A.Store,~R.Resources,~U32,~Unit,R.preload(snapshot,resource),namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)
def record(before:String,after:String,same:Bool,allowed:Bool,world:W.World<A.Schema,A.Store,R.Resources,U32>) -> W.World<A.Schema,A.Store,R.Resources,U32> & Unit:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:W.observe_resource_finish(~A.Schema,~A.Store,~R.Resources,~U32,~Unit,R.record(before,after,same,allowed,resource),namespace,nextId,highWater,live,capacity,depth,store,events,pending,registrations,nextSystemId,clock)
def recorded(allowed:Bool,result:W.World<A.Schema,A.Store,R.Resources,U32> & Unit) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  (world,_)=result
  (world,allowed)
def after_compared(+before:String,+after:String,+allowed:Bool,+same:Bool,world:W.World<A.Schema,A.Store,R.Resources,U32>) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  recorded(Bool.and(allowed,same),record(before,after,same,allowed,world))
def after(+before:String,allowed:Bool,result:W.World<A.Schema,A.Store,R.Resources,U32> & String) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  match result:
    case (world,+after):after_compared(before,after,allowed,SE.equal(before,after),world)
def checked(before:String,result:Check.Checked<A.Schema,A.Store,R.Resources,U32>) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  match result:
    case Check.Checked{world,Done{allowed}}:after(before,allowed,Dump.world(world))
    case Check.Checked{world,Fail{_}}:after(before,False{},Dump.world(world))
def before(snapshot:P.Snapshot,result:W.World<A.Schema,A.Store,R.Resources,U32> & String) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  (world,before)=result
  checked(before,P.run(snapshot,world))
def preloaded(snapshot:P.Snapshot,result:W.World<A.Schema,A.Store,R.Resources,U32> & Unit) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  (world,_)=result
  before(snapshot,Dump.world(world))
def projected(result:W.World<A.Schema,A.Store,R.Resources,U32> & P.Snapshot) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  match result:
    case (world,+snapshot):preloaded(snapshot,preload(P.shown(snapshot),world))
def condition(world:W.World<A.Schema,A.Store,R.Resources,U32>,slot:U32) -> W.World<A.Schema,A.Store,R.Resources,U32> & Bool:
  projected(P.observe(world))
def dispatched(result:Sys.RunResult<A.Schema,A.Store,R.Resources,U32,Bool,String,Unit,runner>) -> Holder & Sys.Outcome<W.World<A.Schema,A.Store,R.Resources,U32>,String,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(Holder{registry},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(Holder{registry},Sys.Failed{world,"registration-rejected"})
def dispatch(holder:Holder,world:W.World<A.Schema,A.Store,R.Resources,U32>,id:U32) -> Holder & Sys.Outcome<W.World<A.Schema,A.Store,R.Resources,U32>,String,Unit>:
  match holder:
    case Holder{registry}:dispatched(Sys.run(~A.Schema,~A.Store,~R.Resources,~U32,~Bool,~String,~Unit,~runner,registry,world,False{}))
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Ran{id}:"Ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"Skipped:" ++ U32.show(id)
    case Sch.Entered{name}:"Entered:" ++ name
    case Sch.Applied{}:"Applied"
def diagnostic_text(value:R.Diagnostic) -> String:
  match value:
    case R.Diagnostic{snapshot,before,after,same,allowed,ran,checks}:"snapshot=" ++ snapshot ++ "|allowed=" ++ Bool.show(allowed) ++ "|same=" ++ Bool.show(same) ++ "|ran=" ++ U32.show(ran) ++ "|checks=" ++ U32.show(checks) ++ "\nbefore=" ++ before ++ "\nafter=" ++ after ++ "\n"
def gate_diagnostic(holder:Holder,text:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & R.Diagnostic) -> Gate:
  (world,diagnostic)=result
  Gate{world,holder,text ++ diagnostic_text(diagnostic)}
def finished(result:Sch.RunResult<A.Schema,A.Store,R.Resources,U32,Holder,String>) -> Gate:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,holder},world,observations}:gate_diagnostic(holder,"observations=" ++ List.show(&2,Sch.Observation,observation,observations) ++ "\n",W.observe_resource(~A.Schema,~A.Store,~R.Resources,~U32,~R.Diagnostic,~R.diagnostic,world))
    case Sch.Failed{Sch.Schedule{_,_,_,holder},world,error,_}:Gate{world,holder,"schedule-failed:" ++ error}
    case Sch.Rejected{Sch.Schedule{_,_,_,holder},world}:Gate{world,holder,"schedule-rejected"}
def built(world:W.World<A.Schema,A.Store,R.Resources,U32>,result:Sch.Build<A.Schema,A.Store,R.Resources,U32,Holder>) -> Gate:
  match result:
    case Sch.Built{schedule}:finished(Sch.run(~A.Schema,~A.Store,~R.Resources,~U32,~Holder,~String,~dispatch,~condition,schedule,world))
    case Sch.Invalid{holder}:Gate{world,holder,"build-rejected"}
def named(holder:Holder,+id:U32,result:W.World<A.Schema,A.Store,R.Resources,U32> & U32) -> Gate:
  (world,namespace)=result
  built(world,Sch.build(~A.Schema,~A.Store,~R.Resources,~U32,~Holder,namespace,"DiagnosticGate",[Sch.System{id,0}],[id],holder))
def identified(world:W.World<A.Schema,A.Store,R.Resources,U32>,result:Sys.Registry<A.Schema,A.Store,R.Resources,U32,Bool,String,Unit,runner> & U32) -> Gate:
  (registry,id)=result
  named(Holder{registry},id,W.namespace(~A.Schema,~A.Store,~R.Resources,~U32,world))
def gate(world:W.World<A.Schema,A.Store,R.Resources,U32>,holder:Holder) -> Gate:
  match holder:
    case Holder{registry}:identified(world,Sys.identity(~A.Schema,~A.Store,~R.Resources,~U32,~Bool,~String,~Unit,~runner,registry))
def second_gate(first:Holder,update:Holder,text:String,result:Gate) -> State:
  match result:
    case Gate{world,second,line}:State{world,first,second,update,text ++ line}
def first_gate(second:Holder,update:Holder,text:String,result:Gate) -> State:
  match result:
    case Gate{world,first,line}:second_gate(first,update,text ++ line,gate(world,second))
# Absence is checked before any projection, and the actual Check.run also
# rejects the requirement before invoking its Bool callback.
def missing_diagnostic(first:Holder,second:Holder,update:Holder,text:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & R.Diagnostic) -> State:
  match result:
    case (world,R.Diagnostic{_,_,_,_,_,ran,checks}):State{world,first,second,update,text ++ "|ran=" ++ U32.show(ran) ++ "|checks=" ++ U32.show(checks) ++ "|observations=[]\n"}
def missing_after(first:Holder,second:Holder,update:Holder,text:String,names:List<&2,String>,before:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & String) -> State:
  (world,after)=result
  missing_diagnostic(first,second,update,text ++ "before=" ++ before ++ "\nafter=" ++ after ++ "\nresult=MissingRuntimeRequirements:" ++ List.show(&2,String,x => x,names),W.observe_resource(~A.Schema,~A.Store,~R.Resources,~U32,~R.Diagnostic,~R.diagnostic,world))
def missing_checked(first:Holder,second:Holder,update:Holder,text:String,before:String,result:Check.Checked<A.Schema,A.Store,R.Resources,U32>) -> State:
  match result:
    case Check.Checked{world,Fail{Check.MissingRuntimeRequirements{names}}}:missing_after(first,second,update,text,names,before,Dump.world(world))
    case Check.Checked{world,Done{_}}:State{world,first,second,update,text ++ "missing-preflight-unexpected-success"}
def missing(first:Holder,second:Holder,update:Holder,text:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & String) -> State:
  (world,before)=result
  missing_checked(first,second,update,text,before,P.run(P.Snapshot{[],[]},world))
def required(first:Holder,second:Holder,update:Holder,text:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & List<&2,String>) -> State:
  match result:
    case (world,[]):first_gate(second,update,text,gate(world,first))
    case (world,_ <> _):missing(first,second,update,text,Dump.world(world))
def phase(label:String,state:State) -> State:
  match state:
    case State{world,first,second,update,text}:required(first,second,update,text ++ label ++ "\n",R.required(world))
def final(state:State) -> String:
  match state:
    case State{_,_,_,_,text}:text
# Earlier committed score write is an actual registered System execution.
def updated(first:Holder,second:Holder,text:String,result:Sys.RunResult<A.Schema,A.Store,R.Resources,U32,Bool,String,Unit,runner>) -> String:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,_}}:final(phase("committed-before-check",State{world,first,second,Holder{registry},text}))
    case Sys.Completed{_,Sys.Failed{_,error}}:"update-failed:" ++ error
    case Sys.RegistrationRejected{_,_,_}:"update-rejected"
def update_present(first:Holder,second:Holder,text:String,world:W.World<A.Schema,A.Store,R.Resources,U32>,update:Holder) -> String:
  match update:
    case Holder{registry}:updated(first,second,text,Sys.run(~A.Schema,~A.Store,~R.Resources,~U32,~Bool,~String,~Unit,~runner,registry,world,True{}))
def update_ready(first:Holder,second:Holder,update:Holder,text:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & List<&2,String>) -> String:
  match result:
    case (world,[]):update_present(first,second,text,world,update)
    case (world,_ <> _):final(phase("committed-before-check",State{world,first,second,update,text}))
def update_phase(state:State) -> String:
  match state:
    case State{world,first,second,update,text}:update_ready(first,second,update,text,R.required(world))
def seeded(first:Holder,second:Holder,update:Holder,text:String,result:C.Replacement<W.World<A.Schema,A.Store,R.Resources,U32>,A.Payload>) -> String:
  match result:
    case C.Replaced{world,_}:update_phase(phase("one",State{world,first,second,update,text}))
    case _:"seed-replacement-rejected"
def activated(+target:W.Handle<A.Schema>,first:Holder,second:Holder,update:Holder,text:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):seeded(first,second,update,text,C.replace(~A.Schema,~A.Store,~R.Resources,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,A.family(),world,target,Some{A.Payload{Array.set(U32,Array.new(U32,2n,11),3,14)}}))
    case _:"seed-activation-rejected"
def reserved(first:Holder,second:Holder,update:Holder,text:String,result:W.World<A.Schema,A.Store,R.Resources,U32> & W.Reservation<A.Schema>) -> String:
  match result:
    case (world,W.Reserved{+target}):activated(target,first,second,update,text,W.activate(~A.Schema,~A.Store,~R.Resources,~U32,world,target))
    case _:"seed-reservation-rejected"
def seed(state:State) -> String:
  match state:
    case State{world,first,second,update,text}:reserved(first,second,update,text,W.reserve_id(~A.Schema,~A.Store,~R.Resources,~U32,world))
def registered_update(first:Holder,second:Holder,result:Sys.RegistrationResult<A.Schema,A.Store,R.Resources,U32,Bool,String,Unit,runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:seed(phase("empty",State{world,first,second,Holder{registry},""}))
    case _:"update-registration-rejected"
def registered_second(first:Holder,result:Sys.RegistrationResult<A.Schema,A.Store,R.Resources,U32,Bool,String,Unit,runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:registered_update(first,Holder{registry},Sys.register(~A.Schema,~A.Store,~R.Resources,~U32,~Bool,~String,~Unit,~runner,world,"Garden/Update",["score:write"]))
    case _:"second-registration-rejected"
def registered_first(result:Sys.RegistrationResult<A.Schema,A.Store,R.Resources,U32,Bool,String,Unit,runner>) -> String:
  match result:
    case Sys.Registered{world,registry}:registered_second(Holder{registry},Sys.register(~A.Schema,~A.Store,~R.Resources,~U32,~Bool,~String,~Unit,~runner,world,"Garden/Second",["diagnostic:write"]))
    case _:"first-registration-rejected"
def created(result:W.Creation<A.Schema,A.Store,R.Resources,U32>) -> String:
  match result:
    case W.Created{_,world}:registered_first(Sys.register(~A.Schema,~A.Store,~R.Resources,~U32,~Bool,~String,~Unit,~runner,world,"Garden/First",["diagnostic:write"]))
    case _:"creation-rejected"
def run(slot:Slot.Slot<A.Resource>) -> String:
  created(W.create(~A.Schema,~A.Store,~R.Resources,~U32,~A.empty,W.factory(),R.Resources{slot,R.fresh()}))
def main() -> String:
  "Absent\n" ++ run(Slot.Absent{}) ++ "Present\n" ++ run(Slot.Present{A.Resource{Array.set(U32,Array.new(U32,2n,21),3,24)}})
