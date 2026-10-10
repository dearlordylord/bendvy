import Base
import ./handler-app-cursor-mutant.bend as App
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/bridge.bend as Phase
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-handler-bundle.bend as Operation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-schedule.bend as Ordinary
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/application.bend as Old
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/consumer.bend as Prior
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/full-observe.bend as Full
import /workspace/formal-proofs/bendvy/experiments/public-machines/handler-schedule-composition-v1/systems.bend as Systems
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/world.bend as Lens
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
def state(value:T.State) -> String:
  match value:
    case T.Boot{}:"Boot"
    case T.Play{}:"Play"
    case T.Pause{}:"Pause"
def selector(~S:Data,value:B.Selector<S,T.MachineKey,T.State>) -> String:
  match value:
    case B.ExitFrom{value}:"exit:" ++ state(value)
    case B.TransitionPair{from,to}:"transition:" ++ state(from) ++ ">" ++ state(to)
    case B.EnterTo{value}:"enter:" ++ state(value)
def wrapped(~S:Data,+select:B.Selector<S,T.MachineKey,T.State>,+needs:List<&2,U32>,items:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>>) -> List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>:
  match items:
    case []:[]
    case head <> rest:B.Scheduled{select,needs,head} <> wrapped(~S,select,needs,rest)
def entry_observed(~S:Data,+select:B.Selector<S,T.MachineKey,T.State>,+needs:List<&2,U32>,tail:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>> & List<&2,String>,head:List<&1,H.Entry<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>> & List<&2,String>) -> List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>> & List<&2,String>:
  match tail head:
    case (rest,text),(head,shown):(List.append(&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,wrapped(~S,select,needs,head),rest),(selector(~S,select) ++ ":needs=" ++ List.show(&2,U32,U32.show,needs) ++ ":" ++ List.show(&2,String,x=>x,shown)) <> text)
def entries(~S:Data,items:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>) -> List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>> & List<&2,String>:
  match items:
    case []:([],[])
    case B.Scheduled{select,needs,entry} <> rest:entry_observed(~S,select,needs,entries(~S,rest),Full.entries(~S,[entry]))
def available(~S:Data,id:U32,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool:
  match pair:
    case (world,M.Missing{}):(Lens.put(~S,world,M.Missing{}),False{})
    case (world,slot):(Lens.put(~S,world,slot),U32.is_le(id,2))
# Requirement1 is actual machine availability; requirement2 is the typed affine
# resource owner installed by construction. Unknown requirements refuse.
def has(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool:
  match id:
    case 1:available(~S,1,Lens.take(~S,world))
    case 2:(world,True{})
    case _:(world,False{})
def phase_text(value:H.Phase) -> String:
  match value:
    case H.Exit{}:"exit"
    case H.Transition{}:"transition"
    case H.Enter{}:"enter"
def status(value:B.Status<U32>) -> String:
  match value:
    case B.Completed{}:"completed"
    case B.HandlerFailed{phase,error}:"failed:" ++ phase_text(phase) ++ ":" ++ error
    case B.MissingRequirements{missing}:"missing:" ++ List.show(&2,U32,U32.show,missing)
    case B.ForeignBundle{}:"foreign"
    case B.MachineUnavailable{}:"unavailable"
def ordinary_application(~S:Data) -> Type:App.Application<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S),Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>>
def debug_entry(~S:Data,value:App.EntryView<S,T.MachineKey,T.State,U32>) -> String:
  match value:
    case App.EntryView{select,needs,namespace,entryId,id,name,access,cursor}:selector(~S,select) ++ ":needs=" ++ List.show(&2,U32,U32.show,needs) ++ ":owner=" ++ U32.show(namespace) ++ ":" ++ U32.show(entryId) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":cursor=" ++ U32.show(cursor)
def debug_view(~S:Data,value:Maybe<&2,App.Description<S,T.MachineKey,T.State,U32>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{App.Description{namespace,name,steps,entries}}:name ++ ":namespace=" ++ U32.show(namespace) ++ ":steps=" ++ List.show(&2,Sch.Step,Prior.step,steps) ++ ":entries=" ++ List.show(&2,App.EntryView<S,T.MachineKey,T.State,U32>,debug_entry(~S),entries)
def physical_returned(~S:Data,+namespace:U32,declaration:Ordinary.Declaration<S>,debug:Bool,label:String,world:W.World<S,T.Store<S>,T.Resources<S>,Unit> & String,bundle:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>> & List<&2,String>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>> & String) -> ordinary_application(~S) & String:
  match world bundle reader:
    case (world,a),(items,b),(reader,c):(App.Application{world,B.Bundle{namespace,items},declaration,reader,debug},label ++ a ++ "/bundle=" ++ U32.show(namespace) ++ ":" ++ List.show(&2,String,x=>x,b) ++ "/readerRegistry=" ++ c)
def physical(~S:Data,label:String,app:ordinary_application(~S)) -> ordinary_application(~S) & String:
  match app:
    case App.Application{world,B.Bundle{namespace,items},declaration,reader,debug}:physical_returned(~S,namespace,declaration,debug,label,Full.world(~S,world),entries(~S,items),Full.registry(~S,reader))
    case app:(app,label ++ "internal-owner-remainder")
def snap_returned(~S:Data,result:ordinary_application(~S) & Maybe<&2,App.Description<S,T.MachineKey,T.State,U32>>) -> ordinary_application(~S) & String:
  (app,description)=result
  physical(~S,"debug=" ++ debug_view(~S,description) ++ "/",app)
def ordinary_snapshot(~S:Data,flag:Bool,app:ordinary_application(~S)) -> ordinary_application(~S) & String:
  snap_returned(~S,App.snapshot(~S,~T.MachineKey,~T.State,~U32,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),~Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,App.enabled(~S,~T.MachineKey,~T.State,~U32,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),~Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,app,flag)))
def ordinary_ran(~S:Data,result:App.RunResult<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S),Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>>) -> ordinary_application(~S) & String:
  match result:
    case App.RunResult{Operation.MarkerResult{B.Returned{bundle,world,outcome},steps,observations},declaration,reader,debug}:physical(~S,"marker=" ++ status(outcome) ++ "/steps=" ++ List.show(&2,Sch.Step,Prior.step,steps) ++ "/observations=" ++ List.show(&2,Sch.Observation,Prior.observation,observations) ++ "/",App.Application{world,bundle,declaration,reader,debug})
    case App.RunResult{result,declaration,reader,debug}:(App.Recovering{result,declaration,reader,debug},"internal-owner-remainder")
def ordinary_marker(~S:Data,app:ordinary_application(~S)) -> ordinary_application(~S) & String:
  ordinary_ran(~S,App.run_app(~S,~T.MachineKey,~T.State,~U32,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),~Lens.take(~S),~Lens.put(~S),~Phase.published(~S),~T.same,~U32.is_eq,~has(~S),~Phase.tick(~S),~Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,app))
def ordinary_read_finished(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,declaration:Ordinary.Declaration<S>,debug:Bool,registry:Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>,outcome:Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>) -> ordinary_application(~S) & String:
  match outcome:
    case Sys.Succeeded{world,_}:physical(~S,"read:",App.Application{world,bundle,declaration,Some{registry},debug})
    case Sys.Failed{world,_}:physical(~S,"read:",App.Application{world,bundle,declaration,Some{registry},debug})
def ordinary_read_returned(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,declaration:Ordinary.Declaration<S>,debug:Bool,result:Sys.RunResult<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>) -> ordinary_application(~S) & String:
  match result:
    case Sys.Completed{registry,outcome}:ordinary_read_finished(~S,bundle,declaration,debug,registry,outcome)
    case Sys.RegistrationRejected{registry,world,_}:physical(~S,"read:",App.Application{world,bundle,declaration,Some{registry},debug})
def ordinary_read(~S:Data,app:ordinary_application(~S)) -> ordinary_application(~S) & String:
  match app:
    case App.Application{world,bundle,declaration,Some{reader},debug}:ordinary_read_returned(~S,bundle,declaration,debug,Sys.run_tracked(~S,~T.Store<S>,~T.Resources<S>,~Unit,~Unit,~String,~Unit,~Systems.reader_runner(~S),reader,world,Unit{}))
    case app:physical(~S,"read:",app)
def ordinary_queued(~S:Data,declaration:Ordinary.Declaration<S>,debug:Bool,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>) -> ordinary_application(~S):
  (world,slot)=pair
  App.Application{Lens.put(~S,world,M.queue(~S,~T.MachineKey,~T.State,slot,T.Play{},False{})),bundle,declaration,reader,debug}
def ordinary_retry(~S:Data,id:U32,app:ordinary_application(~S)) -> ordinary_application(~S) & String:
  match id app:
    case 3 App.Application{world,bundle,declaration,reader,debug}:ordinary_marker(~S,ordinary_queued(~S,declaration,debug,bundle,reader,Lens.take(~S,world)))
    case _ app:ordinary_marker(~S,app)
def ordinary_named(~S:Data,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,items:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32) -> ordinary_application(~S):
  (world,namespace)=pair
  App.Application{world,B.Bundle{namespace,items},Ordinary.declare(~S,"handler-bundle-global-marker"),reader,False{}}
def ordinary_converted(~S:Data,app:Old.Application<S>) -> ordinary_application(~S):
  match app:
    case Old.Application{world,H.Owners{exit,transition,enter},reader}:ordinary_named(~S,reader,List.append(&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,wrapped(~S,B.ExitFrom{T.Boot{}},[1,2,1],exit),List.append(&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,wrapped(~S,B.TransitionPair{T.Boot{},T.Play{}},[2],transition),wrapped(~S,B.EnterTo{T.Play{}},[1],enter))),W.namespace(~S,~T.Store<S>,~T.Resources<S>,~Unit,world))
def ordinary_created(~S:Data,+id:U32,result:Old.Construction<S>) -> String:
  match result:
    case Old.ConstructionRefused{_}:"construction-refused"
    case Old.Constructed{_,app}:Prior.sequence(~ordinary_application(~S),[ordinary_snapshot(~S,False{}),ordinary_snapshot(~S,True{}),ordinary_snapshot(~S,True{}),ordinary_marker(~S),ordinary_snapshot(~S,False{}),ordinary_snapshot(~S,True{}),ordinary_read(~S),ordinary_retry(~S,id),ordinary_snapshot(~S,True{}),ordinary_read(~S),ordinary_snapshot(~S,False{})],"",ordinary_converted(~S,Old.queue_play(~S,Old.install_reader(~S,Prior.seeded(~S,id,app)))))
def ordinary_scenario(~S:Data,id:U32) -> String:ordinary_created(~S,id,Old.create(~S,W.factory()))
type Report is Data:Report{exit:String,transition:String,enter:String}
def report(~S:Data) -> Report:Report{ordinary_scenario(~S,1),ordinary_scenario(~S,2),ordinary_scenario(~S,3)}
