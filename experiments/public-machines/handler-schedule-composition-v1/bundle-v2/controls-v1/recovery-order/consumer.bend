import Base
import ./bridge.bend as Bridge
import ../../../application.bend as Old
import ../../../consumer.bend as Prior
import ../../../full-observe.bend as Full
import ../../../systems.bend as Systems
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/world.bend as Lens
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
type Application<S:Data> is Type:
  Application{world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>}
  Internal{world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,namespace:U32,recovery:B.Recovery<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>}
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
def observed(~S:Data,+namespace:U32,world:W.World<S,T.Store<S>,T.Resources<S>,Unit> & String,bundle:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>> & List<&2,String>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>> & String) -> Application<S> & String:
  match world bundle reader:
    case (world,a),(entries,b),(reader,c):(Application{world,B.Bundle{namespace,entries},reader},a ++ "/bundle=" ++ U32.show(namespace) ++ ":" ++ List.show(&2,String,x=>x,b) ++ "/readerRegistry=" ++ c)
def observe(~S:Data,app:Application<S>) -> Application<S> & String:
  match app:
    case Application{world,B.Bundle{namespace,items},reader}:observed(~S,namespace,Full.world(~S,world),entries(~S,items),Full.registry(~S,reader))
    case app:(app,"internal-owner-remainder")
def shown(~S:Data,label:String,pair:Application<S> & String) -> Application<S> & String:
  (app,text)=pair
  (app,label ++ ":" ++ text)
def snapshot(~S:Data,app:Application<S>) -> Application<S> & String:shown(~S,"snapshot",observe(~S,app))
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
def returned(~S:Data,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,result:Bridge.MarkerResult<S>) -> Application<S> & String:
  match result:
    case Bridge.MarkerResult{B.Returned{bundle,world,outcome},steps,observations}:shown(~S,"marker=" ++ status(outcome) ++ "/steps=" ++ List.show(&2,Sch.Step,Prior.step,steps) ++ "/observations=" ++ List.show(&2,Sch.Observation,Prior.observation,observations),observe(~S,Application{world,bundle,reader}))
    case Bridge.MarkerResult{B.InternalOwnerRemainder{namespace,recovery,world,_},_,_}:(Internal{world,namespace,recovery,reader},"internal-owner-remainder")
def marker(~S:Data,app:Application<S>) -> Application<S> & String:
  match app:
    case Application{world,bundle,reader}:returned(~S,reader,Bridge.run(~S,~has(~S),bundle,world))
    case app:(app,"internal-owner-remainder")
def unexpected_read(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,owners:H.Owners<S,T.Store<S>,T.Resources<S>,Unit,T.State,Systems.runner(~S)>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>) -> Application<S> & String:
  match bundle:
    case B.Bundle{namespace,entries}:(Internal{world,namespace,B.Recovery{entries,[],[],owners},reader},"internal-reader-owner-remainder")
def read_returned(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,app:Old.Application<S>) -> Application<S> & String:
  match app:
    case Old.Application{world,H.Owners{[],[],[]},reader}:shown(~S,"read",observe(~S,Application{world,bundle,reader}))
    case Old.Application{world,owners,reader}:unexpected_read(~S,world,owners,reader,bundle)
def read(~S:Data,app:Application<S>) -> Application<S> & String:
  match app:
    case Application{world,bundle,reader}:read_returned(~S,bundle,Old.read(~S,Old.Application{world,H.Owners{[],[],[]},reader}))
    case app:(app,"internal-owner-remainder")
def queue_taken(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>) -> Application<S>:
  (world,slot)=pair
  Application{Lens.put(~S,world,M.queue(~S,~T.MachineKey,~T.State,slot,T.Play{},False{})),bundle,reader}
def retry(~S:Data,id:U32,app:Application<S>) -> Application<S> & String:
  match id app:
    case 3 Application{world,bundle,reader}:marker(~S,queue_taken(~S,bundle,reader,Lens.take(~S,world)))
    case _ app:marker(~S,app)
def named(~S:Data,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,items:List<&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>>,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32) -> Application<S>:
  (world,namespace)=pair
  Application{world,B.Bundle{namespace,items},reader}
def converted(~S:Data,app:Old.Application<S>) -> Application<S>:
  match app:
    case Old.Application{world,H.Owners{exit,transition,enter},reader}:named(~S,reader,List.append(&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,wrapped(~S,B.ExitFrom{T.Boot{}},[1,2,1],exit),List.append(&1,B.Scheduled<S,T.MachineKey,T.State,U32,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,wrapped(~S,B.TransitionPair{T.Boot{},T.Play{}},[2],transition),wrapped(~S,B.EnterTo{T.Pause{}},[1],enter))),W.namespace(~S,~T.Store<S>,~T.Resources<S>,~Unit,world))
def created(~S:Data,+id:U32,result:Old.Construction<S>) -> String:
  match result:
    case Old.ConstructionRefused{_}:"construction-refused"
    case Old.Constructed{_,app}:Prior.sequence(~Application<S>,[snapshot(~S),marker(~S),read(~S),retry(~S,id),read(~S),snapshot(~S)],"",converted(~S,Old.queue_play(~S,Old.install_reader(~S,Prior.seeded(~S,id,app)))))
def scenario(~S:Data,id:U32) -> String:created(~S,id,Old.create(~S,W.factory()))
type Report is Data:Report{exit:String,transition:String,enter:String}
def report(~S:Data) -> Report:Report{scenario(~S,1),scenario(~S,2),scenario(~S,3)}
