import Base
import types.bend as T
import world.bend as AppWorld
import systems.bend as Systems
import bundle.bend as B
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/machine.bend as M
import ../../../../src/ecs/machine-stream.bend as Stream
import ../../../../src/ecs/machine-handlers.bend as H
import ../../../../src/ecs/column.bend as Col

type Application<S:Data> is Type:
  Application{world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,bundle:B.Bundle<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,readerRegistry:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,status:Maybe<&2,B.Status<T.Requirement<S>>>}
  ApplicationRemainder{namespace:U32,recovery:B.Recovery<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,readerRegistry:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,status:Maybe<&2,B.Status<T.Requirement<S>>>}
type Spec<S:Data> is Data:
  NoSpecs{}
  OneSpec{selector:B.Selector<S,T.MachineKey,T.State>,needs:List<&2,T.Requirement<S>>,name:String}
  MoreSpecs{left:Spec<S>,right:Spec<S>}
type Installed<S:Data> is Type:
  Installed{world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,tree:B.Tree<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>}

def install_local(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,List.append(&1,T.LocalOwner,locals,[T.LocalOwner{ns,id,Local.Cell{ALeaf{0}}}]),tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}
def installed_one(~S:Data,selector:B.Selector<S,T.MachineKey,T.State>,needs:List<&2,T.Requirement<S>>,observed:Sys.RegistrationResult<S,T.Store<S>,T.Resources<S>,Unit,H.Invocation<T.State>,String,Unit,Systems.runner(~S)>) -> Installed<S>:
  match observed:
    case Sys.RegistrationFailed{world}: Installed{world,B.Empty{}}
    case Sys.Registered{world,Sys.Registry{+namespace,+id,+name,+access,+cursor}}:
      Installed{install_local(~S,world,id),B.Single{B.Scheduled{selector,needs,H.Entry{id,Sys.Registry{namespace,id,name,access,cursor}}}}}
def installed_pair(~S:Data,left:B.Tree<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,right:Installed<S>) -> Installed<S>:
  match right:
    case Installed{world,right}: Installed{world,B.Join{left,right}}
def installed_left(~S:Data,left:Installed<S>,next:W.World<S,T.Store<S>,T.Resources<S>,Unit> -> Installed<S>) -> Installed<S>:
  match left:
    case Installed{world,left}: installed_pair(~S,left,next(world))
def access_for(name:String) -> List<&2,String>:
  match name:
    case "inactiveExitPause": ["cells:write","owned:write","machine:write","extra:read"]
    case _: ["cells:write","owned:write","machine:write"]
def install(~S:Data,spec:Spec<S>,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> Installed<S>:
  match spec:
    case NoSpecs{}: Installed{world,B.Empty{}}
    case OneSpec{selector,needs,+name}: installed_one(~S,selector,needs,Sys.register(~S,~T.Store<S>,~T.Resources<S>,~Unit,~H.Invocation<T.State>,~String,~Unit,~Systems.runner(~S),world,name,access_for(name)))
    case MoreSpecs{left,right}: installed_left(~S,install(~S,left,world),w => install(~S,right,w))
def specs(~S:Data) -> Spec<S>:
  MoreSpecs{OneSpec{B.EnterTo{T.Play{}},[T.OwnedRequirement{},T.MachineRequirement{}],"enterPlay1"},MoreSpecs{MoreSpecs{OneSpec{B.ExitFrom{T.Boot{}},[T.OwnedRequirement{},T.MachineRequirement{}],"exitBoot0"},MoreSpecs{OneSpec{B.TransitionPair{T.Boot{},T.Pause{}},[T.OwnedRequirement{},T.MachineRequirement{}],"transitionBootPause"},OneSpec{B.EnterTo{T.Play{}},[T.OwnedRequirement{},T.MachineRequirement{}],"enterPlay0"}}},MoreSpecs{OneSpec{B.ExitFrom{T.Boot{}},[T.OwnedRequirement{},T.MachineRequirement{}],"exitBoot1"},MoreSpecs{OneSpec{B.TransitionPair{T.Boot{},T.Play{}},[T.OwnedRequirement{},T.MachineRequirement{}],"transitionBootPlay"},MoreSpecs{OneSpec{B.EnterTo{T.Pause{}},[T.OwnedRequirement{},T.MachineRequirement{}],"enterPause"},OneSpec{B.ExitFrom{T.Pause{}},[T.OwnedRequirement{},T.ExtraRequirement{},T.MachineRequirement{}],"inactiveExitPause"}}}}}}
def assembled(~S:Data,namespace:U32,result:Installed<S>) -> Application<S>:
  match result:
    case Installed{world,tree}: Application{world,B.bundle(~S,~T.MachineKey,~T.State,~T.Requirement<S>,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),namespace,tree),None{},None{}}
def install_namespace(~S:Data,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & U32) -> Application<S>:
  (world,namespace)=pair
  assembled(~S,namespace,install(~S,specs(~S),world))
def initial_resources(~S:Data) -> T.Resources<S>:
  T.Resources{ANode{ALeaf{0},ALeaf{19}},M.Present{T.Boot{},M.NoPending{},None{},False{}},Stream.empty(~T.State),None{},[],0n,[],[],0,Some{ANode{ALeaf{5},ALeaf{29}}},0,[]}
def empty_store(~S:Data,_:Unit) -> T.Store<S>:
  T.Store{Col.Column{ALeaf{Some{ANode{ALeaf{0},ALeaf{7}}}},[]}}
type Construction<S:Data> is Type:
  Constructed{factory:W.Factory,application:Application<S>}
  ConstructionRefused{factory:W.Factory}
def activated(~S:Data,factory:W.Factory,result:W.World<S,T.Store<S>,T.Resources<S>,Unit> & W.Status) -> Construction<S>:
  match result:
    case (world,W.Accepted{}): Constructed{factory,install_namespace(~S,W.namespace(~S,~T.Store<S>,~T.Resources<S>,~Unit,world))}
    case (_,W.Rejected{_}): ConstructionRefused{factory}
def reserved(~S:Data,factory:W.Factory,result:W.World<S,T.Store<S>,T.Resources<S>,Unit> & W.Reservation<S>) -> Construction<S>:
  match result:
    case (world,W.Reserved{handle}): activated(~S,factory,W.activate(~S,~T.Store<S>,~T.Resources<S>,~Unit,world,handle))
    case (_,W.ReservationRejected{_}): ConstructionRefused{factory}
def created(~S:Data,result:W.Creation<S,T.Store<S>,T.Resources<S>,Unit>) -> Construction<S>:
  match result:
    case W.CreateRejected{factory,_}: ConstructionRefused{factory}
    case W.Created{factory,world}: reserved(~S,factory,W.reserve_id(~S,~T.Store<S>,~T.Resources<S>,~Unit,world))
def create(~S:Data,factory:W.Factory) -> Construction<S>:
  created(~S,W.create(~S,~T.Store<S>,~T.Resources<S>,~Unit,~(u => empty_store(~S,u)),factory,initial_resources(~S)))


def requirement_same(~S:Data,left:T.Requirement<S>,right:T.Requirement<S>) -> Bool:
  match left right:
    case T.MachineRequirement{} T.MachineRequirement{}: True{}
    case T.OwnedRequirement{} T.OwnedRequirement{}: True{}
    case T.ExtraRequirement{} T.ExtraRequirement{}: True{}
    case _ _: False{}
def machine_present(~S:Data,slot:M.Slot<S,T.MachineKey,T.State>) -> Bool:
  match slot:
    case M.Missing{}: False{}
    case _: True{}
def extra_present(owner:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & Bool:
  match owner:
    case None{}: (None{},False{})
    case Some{owner}: (Some{owner},True{})
def extra_checked(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,pair:Maybe<&1,Array<U32>> & Bool) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool:
  match world pair:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,_,failureId,attemptLog},events,pending,registrations,nextSystem,clock}, (extra,allowed):
      (W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock},allowed)
def has_extra(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}:
      extra_checked(~S,W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,None{},failureId,attemptLog},events,pending,registrations,nextSystem,clock},extra_present(extra))
def has_machine(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,+slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock},machine_present(~S,slot))
def has_requirement(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,requirement:T.Requirement<S>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit> & Bool:
  match requirement:
    case T.MachineRequirement{}: has_machine(~S,world)
    case T.OwnedRequirement{}: (world,True{})
    case T.ExtraRequirement{}: has_extra(~S,world)
def published(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,event:M.Transition<T.State>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,+tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,Stream.publish(~T.State,stream,tick,event),reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}
def marker_tick(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,1n+tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}
def frame(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  marker_tick(~S,W.barrier(~S,~T.Store<S>,~T.Resources<S>,~Unit,world))
def retained(~S:Data,readerRegistry:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,result:B.BundleResult<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>) -> Application<S>:
  match result:
    case B.Returned{bundle,world,status}: Application{world,bundle,readerRegistry,Some{status}}
    case B.InternalOwnerRemainder{namespace,recovery,world,status}: ApplicationRemainder{namespace,recovery,world,readerRegistry,Some{status}}
def marker(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,bundle,readerRegistry,_}:
      retained(~S,readerRegistry,B.run(~S,~T.MachineKey,~T.State,~T.Requirement<S>,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),~AppWorld.take(~S),~AppWorld.put(~S),~published(~S),~T.same,~requirement_same(~S),~has_requirement(~S),~frame(~S),bundle,world))
    case app: app

def reader_installed(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,namespace:U32,id:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,_,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,Some{Stream.Reader{namespace,id}},locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}
def reader_registered(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,status:Maybe<&2,B.Status<T.Requirement<S>>>,result:Sys.RegistrationResult<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>) -> Application<S>:
  match result:
    case Sys.RegistrationFailed{world}: Application{world,bundle,None{},status}
    case Sys.Registered{world,Sys.Registry{+namespace,+id,+name,+access,+cursor}}: Application{reader_installed(~S,world,namespace,id),bundle,Some{Sys.Registry{namespace,id,name,access,cursor}},status}
def install_reader(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,bundle,_,status}: reader_registered(~S,bundle,status,Sys.register(~S,~T.Store<S>,~T.Resources<S>,~Unit,~Unit,~String,~Unit,~Systems.reader_runner(~S),world,"reader",["machine:read"]))
    case app: app
def read_completed(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,status:Maybe<&2,B.Status<T.Requirement<S>>>,registry:Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>,result:Sys.Outcome<W.World<S,T.Store<S>,T.Resources<S>,Unit>,String,Unit>) -> Application<S>:
  match result:
    case Sys.Succeeded{world,_}: Application{world,bundle,Some{registry},status}
    case Sys.Failed{world,_}: Application{world,bundle,Some{registry},status}
def read_result(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,status:Maybe<&2,B.Status<T.Requirement<S>>>,result:Sys.RunResult<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>) -> Application<S>:
  match result:
    case Sys.Completed{registry,outcome}: read_completed(~S,bundle,status,registry,outcome)
    case Sys.RegistrationRejected{registry,world,_}: Application{world,bundle,Some{registry},status}
def read(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,bundle,Some{registry},status}: read_result(~S,bundle,status,Sys.run_tracked(~S,~T.Store<S>,~T.Resources<S>,~Unit,~Unit,~String,~Unit,~Systems.reader_runner(~S),registry,world,Unit{}))
    case app: app

def queued(~S:Data,bundle:B.Bundle<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,reader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,status:Maybe<&2,B.Status<T.Requirement<S>>>,value:T.State,skip:Bool,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>) -> Application<S>:
  (world,slot)=pair
  Application{AppWorld.put(~S,world,M.queue(~S,~T.MachineKey,~T.State,slot,value,skip)),bundle,reader,status}
def queue(~S:Data,app:Application<S>,value:T.State,skip:Bool) -> Application<S>:
  match app:
    case Application{world,bundle,reader,status}: queued(~S,bundle,reader,status,value,skip,AppWorld.take(~S,world))
    case app: app

def extra_supplied(owner:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>>:
  match owner:
    case Some{owner}: Some{owner}
    case None{}: Some{ANode{ALeaf{5},ALeaf{29}}}
def extra_selected(present:Bool,owner:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>>:
  match present:
    case True{}: extra_supplied(owner)
    case False{}: None{}
def set_extra(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,present:Bool) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failureId,attemptLog},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra_selected(present,extra),failureId,attemptLog},events,pending,registrations,nextSystem,clock}
def supply(~S:Data,app:Application<S>,present:Bool) -> Application<S>:
  match app:
    case Application{world,bundle,reader,status}: Application{set_extra(~S,world,present),bundle,reader,status}
    case app: app
def set_failure(~S:Data,world:W.World<S,T.Store<S>,T.Resources<S>,Unit>,failure:U32) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,_,attemptLog},events,pending,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,T.Resources{owned,slot,stream,reader,locals,tick,prefix,delivered,applied,extra,failure,attemptLog},events,pending,registrations,nextSystem,clock}
def failing(~S:Data,app:Application<S>,id:U32) -> Application<S>:
  match app:
    case Application{world,bundle,reader,status}: Application{set_failure(~S,world,id),bundle,reader,status}
    case app: app
def initial_state(~S:Data,pair:W.World<S,T.Store<S>,T.Resources<S>,Unit> & M.Slot<S,T.MachineKey,T.State>,state:T.State) -> W.World<S,T.Store<S>,T.Resources<S>,Unit>:
  (world,slot)=pair
  AppWorld.put(~S,world,M.Present{state,M.NoPending{},None{},False{}})
def initialized(~S:Data,app:Application<S>,state:T.State) -> Application<S>:
  match app:
    case Application{world,bundle,reader,status}: Application{initial_state(~S,AppWorld.take(~S,world),state),bundle,reader,status}
    case app: app

type ForeignResult<S:Data> is Type:
  ForeignNotApplications{source:Application<S>,target:Application<S>}
  ForeignRetained{source:Application<S>,target:Application<S>,status:B.Status<T.Requirement<S>>}
  ForeignInternal{sourceWorld:W.World<S,T.Store<S>,T.Resources<S>,Unit>,sourceReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,sourceStatus:Maybe<&2,B.Status<T.Requirement<S>>>,targetBundle:B.Bundle<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,targetReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,targetStatus:Maybe<&2,B.Status<T.Requirement<S>>>,result:B.BundleResult<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>}
def foreign_join(~S:Data,sourceWorld:W.World<S,T.Store<S>,T.Resources<S>,Unit>,sourceReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,sourceStatus:Maybe<&2,B.Status<T.Requirement<S>>>,targetBundle:B.Bundle<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>,targetReader:Maybe<&1,Sys.Registry<S,T.Store<S>,T.Resources<S>,Unit,Unit,String,Unit,Systems.reader_runner(~S)>>,targetStatus:Maybe<&2,B.Status<T.Requirement<S>>>,result:B.BundleResult<S,T.MachineKey,T.State,T.Requirement<S>,T.Store<S>,T.Resources<S>,Unit,Systems.runner(~S)>) -> ForeignResult<S>:
  match result:
    case B.Returned{sourceBundle,targetWorld,status}: ForeignRetained{Application{sourceWorld,sourceBundle,sourceReader,sourceStatus},Application{targetWorld,targetBundle,targetReader,targetStatus},status}
    case result: ForeignInternal{sourceWorld,sourceReader,sourceStatus,targetBundle,targetReader,targetStatus,result}
def foreign(~S:Data,source:Application<S>,target:Application<S>) -> ForeignResult<S>:
  match source target:
    case Application{sourceWorld,sourceBundle,sourceReader,sourceStatus} Application{targetWorld,targetBundle,targetReader,targetStatus}:
      foreign_join(~S,sourceWorld,sourceReader,sourceStatus,targetBundle,targetReader,targetStatus,B.run(~S,~T.MachineKey,~T.State,~T.Requirement<S>,~T.Store<S>,~T.Resources<S>,~Unit,~Systems.runner(~S),~AppWorld.take(~S),~AppWorld.put(~S),~published(~S),~T.same,~requirement_same(~S),~has_requirement(~S),~frame(~S),sourceBundle,targetWorld))
    case source target: ForeignNotApplications{source,target}
