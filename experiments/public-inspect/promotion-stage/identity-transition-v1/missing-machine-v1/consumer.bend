import Base
import ../state.bend as State
import ../dump.bend as Dump
import ../consumer.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MD
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

def declaration(~S:Data) -> MD.Declaration<S,State.FlowToken,U32,State.Resources<S>,State.flow(~S)>:
  MD.declared(~S,~State.FlowToken,~U32,~State.Resources<S>,~State.flow(~S),"Flow",[7,9])
def view_text(~S:Data,view:M.CurrentView<S,State.FlowToken,U32>) -> String:
  match view:
    case M.Unavailable{}:"Unavailable"
    case M.Current{value}:"Current:" ++ U32.show(value)
def inspected(~S:Data,result:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.CurrentView<S,State.FlowToken,U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  match result:
    case (I.Frame{world,cursor},view):(world,"cursor=" ++ U32.show(cursor) ++ ":" ++ view_text(~S,view))
def inspect(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  inspected(~S,Cap.value_read(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~M.CurrentView<S,State.FlowToken,U32>,~MD.inspect(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~declaration(~S)),I.Frame{world,19}))
def matched(~S:Data,result:I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Bool) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  match result:
    case (I.Frame{world,_},value):(world,Bool.show(value))
def matches(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  matched(~S,MD.matches(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S,~State.FlowToken,~U32,~U32.is_eq,~MD.inspect(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~declaration(~S)),I.Frame{world,19},7))
def condition_body(~S:Data,~H:Type,~cap:Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>,_:Unit,owner:H) -> H & Bool:
  MD.matches(~H,~S,~State.FlowToken,~U32,~U32.is_eq,~cap,owner,7)
def plan(~S:Data) -> K.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,H => Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>>:
  K.Plan{MD.required(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~declaration(~S)),MD.condition(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~State.flow(~S),~declaration(~S))}
# Operational callback follows successful Check; Check capability remains read-only.
def callback_resource(~S:Data,resource:State.Resources<S>) -> State.Resources<S> & Unit:
  match resource:
    case State.Resources{owned,flow,level,ran,flowStream,levelStream}:(State.Resources{owned,flow,level,(ran+1:U32),flowStream,levelStream},Unit{})
def callback_done(~S:Data,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & Unit) -> Sys.Outcome<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,K.Error,Bool>:
  (world,_)=result
  Sys.Succeeded{world,True{}}
def checked(~S:Data,result:K.Checked<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Sys.Outcome<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,K.Error,Bool>:
  match result:
    case K.Checked{world,Fail{error}}:Sys.Failed{world,error}
    case K.Checked{world,Done{False{}}}:Sys.Succeeded{world,False{}}
    case K.Checked{world,Done{True{}}}:callback_done(~S,W.observe_resource(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~callback_resource(~S),world))
def runner(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,args:Unit) -> Sys.Outcome<W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,K.Error,Bool>:
  checked(~S,K.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~H => Cap.ValueRead<H,M.CurrentView<S,State.FlowToken,U32>>,~Unit,~condition_body(~S),~plan(~S),args,world))
def error_text(error:K.Error) -> String:
  match error:
    case K.MissingRuntimeRequirements{names}:"MissingRuntimeRequirements:" ++ List.show(&2,String,x => x,names)
def completed(~S:Data,result:Sys.RunResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>) -> Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)> & W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String:
  match result:
    case Sys.Completed{Sys.Registry{+ns,+id,+name,+access,+cursor},Sys.Succeeded{world,value}}:(Sys.Registry{ns,id,name,access,cursor},world,"id=" ++ U32.show(id) ++ ":cursor=" ++ U32.show(cursor) ++ ":Succeeded:" ++ Bool.show(value))
    case Sys.Completed{Sys.Registry{+ns,+id,+name,+access,+cursor},Sys.Failed{world,error}}:(Sys.Registry{ns,id,name,access,cursor},world,"id=" ++ U32.show(id) ++ ":cursor=" ++ U32.show(cursor) ++ ":Failed:" ++ error_text(error))
    case Sys.RegistrationRejected{registry,world,_}:(registry,world,"RegistrationRejected")
def detached_dump(~S:Data,+slot:M.Slot<S,State.FlowToken,U32>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.Slot<S,State.FlowToken,U32> & String:
  (world,text)=result
  (world,slot,"detached:held=" ++ Dump.slot(~S,~State.FlowToken,slot) ++ ":" ++ text)
def detached(~S:Data,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.Slot<S,State.FlowToken,U32>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.Slot<S,State.FlowToken,U32> & String:
  match result:
    case (world,slot):detached_dump(~S,slot,Dump.world(~S,Setup.put(~S,world,M.Missing{})))
def returned14(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  List.append(&2,String,previous,["world14:" ++ text])
def step14(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned14(~S,registry,held,previous,Dump.world(~S,world))
def returned13(~S:Data,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)> & W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (registry,world,text)=result
  step14(~S,registry,world,held,List.append(&2,String,previous,["restored-required:" ++ text]))
def step13(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned13(~S,held,previous,completed(~S,Sys.run_tracked(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~K.Error,~Bool,~runner(~S),registry,world,Unit{})))
def returned12(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step13(~S,registry,world,held,List.append(&2,String,previous,["restored-matches:" ++ text]))
def step12(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned12(~S,registry,held,previous,matches(~S,world))
def returned11(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step12(~S,registry,world,held,List.append(&2,String,previous,["restored-inspect:" ++ text]))
def step11(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned11(~S,registry,held,previous,inspect(~S,world))
def returned10(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step11(~S,registry,world,held,List.append(&2,String,previous,["restored:" ++ text]))
def step10(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned10(~S,registry,held,previous,Dump.world(~S,Setup.put(~S,world,held)))
def returned9(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step10(~S,registry,world,held,List.append(&2,String,previous,["world9:" ++ text]))
def step9(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned9(~S,registry,held,previous,Dump.world(~S,world))
def returned8(~S:Data,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)> & W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (registry,world,text)=result
  step9(~S,registry,world,held,List.append(&2,String,previous,["missing-required:" ++ text]))
def step8(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned8(~S,held,previous,completed(~S,Sys.run_tracked(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~K.Error,~Bool,~runner(~S),registry,world,Unit{})))
def returned7(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step8(~S,registry,world,held,List.append(&2,String,previous,["world7:" ++ text]))
def step7(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned7(~S,registry,held,previous,Dump.world(~S,world))
def returned6(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step7(~S,registry,world,held,List.append(&2,String,previous,["missing-matches:" ++ text]))
def step6(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned6(~S,registry,held,previous,matches(~S,world))
def returned5(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step6(~S,registry,world,held,List.append(&2,String,previous,["world5:" ++ text]))
def step5(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned5(~S,registry,held,previous,Dump.world(~S,world))
def returned4(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step5(~S,registry,world,held,List.append(&2,String,previous,["missing-second:" ++ text]))
def step4(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned4(~S,registry,held,previous,inspect(~S,world))
def returned3(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step4(~S,registry,world,held,List.append(&2,String,previous,["world3:" ++ text]))
def step3(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned3(~S,registry,held,previous,Dump.world(~S,world))
def returned2(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step3(~S,registry,world,held,List.append(&2,String,previous,["missing-first:" ++ text]))
def step2(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned2(~S,registry,held,previous,inspect(~S,world))
def returned1(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & M.Slot<S,State.FlowToken,U32> & String) -> List<&2,String>:
  (world,held,text)=result
  step2(~S,registry,world,held,List.append(&2,String,previous,[text]))
def step1(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned1(~S,registry,previous,detached(~S,Setup.take(~S,world)))
def returned0(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>,result:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & String) -> List<&2,String>:
  (world,text)=result
  step1(~S,registry,world,held,List.append(&2,String,previous,["world0:" ++ text]))
def step0(~S:Data,registry:Sys.Registry<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,+held:M.Slot<S,State.FlowToken,U32>,previous:List<&2,String>) -> List<&2,String>:
  returned0(~S,registry,held,previous,Dump.world(~S,world))
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,K.Error,Bool,runner(~S)>) -> List<&2,String>:
  match result:
    case Sys.Registered{world,registry}:step0(~S,registry,world,M.Missing{},[])
    case Sys.RegistrationFailed{_}:["RegistrationFailed"]
def created(~S:Data,result:W.Creation<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> List<&2,String>:
  match result:
    case W.Created{_,world}:registered(~S,Sys.register(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Unit,~K.Error,~Bool,~runner(~S),W.enqueue(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,Setup.pending(~S)),"RequiredFlowCallback",["Flow"]))
    case W.CreateRejected{_,_}:["CreateRejected"]
def run(~S:Data) -> List<&2,String>:
  created(~S,W.create(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~Setup.store(~S),W.factory(),Setup.resources(~S)))
