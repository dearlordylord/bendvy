import Base
import driver.bend as D
import schema.bend as S
import consumers.bend as C
import operations.bend as Op
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/event-runtime.bend as Ev
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/reader-domains.bend as Domains
import ../../src/ecs/schedule.bend as Sch

def event_slot(owners: D.Owners,slot: D.Slot<D.EventOwner>,world: S.World(),+message: String) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners:
    case D.Owners{events,fast,_,cf,cs,rf,rs,operation,config,reads}: (D.Owners{events,fast,slot,cf,cs,rf,rs,operation,config,D.append_read(reads,C.quoted(message))},Sys.Succeeded{world,Unit{}})

def change_slot(owners: D.Owners,slot: D.Slot<D.ChangeRegistry()>,world: S.World(),+message: String) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners:
    case D.Owners{events,fast,slow,cf,_,rf,rs,operation,config,reads}: (D.Owners{events,fast,slow,cf,slot,rf,rs,operation,config,D.append_read(reads,C.quoted(message))},Sys.Succeeded{world,Unit{}})

def removal_slot(owners: D.Owners,slot: D.Slot<D.RemovalReader()>,world: S.World(),+message: String) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners:
    case D.Owners{events,fast,slow,cf,cs,rf,_,operation,config,reads}: (D.Owners{events,fast,slow,cf,cs,rf,slot,operation,config,D.append_read(reads,C.quoted(message))},Sys.Succeeded{world,Unit{}})

def event_joined(owners: D.Owners,slot: D.Slot<D.EventOwner>,+message: String,result: Domains.Detached<S.Schema,S.Store,Unit,S.Notice>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result:
    case D.Owners{_,fast,slow,cf,cs,rf,rs,operation,config,reads}, Domains.Detached{world,events}: event_slot(D.Owners{D.Occupied{events},fast,slow,cf,cs,rf,rs,operation,config,reads},slot,world,message)

def event_disposed(owners: D.Owners,+notices: List<&2,S.Notice>,result: Ev.Disposal<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.event_body>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Ev.Disposed{runtime}: event_joined(owners,D.Empty{},"event-disposed",Domains.detach(~S.Schema,~S.Store,~Unit,~S.Notice,runtime,notices))
    case Ev.DisposalRejected{runtime,reader,registry}: event_joined(owners,D.Occupied{D.EventOwner{reader,registry}},"event-disposal-rejected",Domains.detach(~S.Schema,~S.Store,~Unit,~S.Notice,runtime,notices))
def event_registered(owners: D.Owners,+notices: List<&2,S.Notice>,result: Ev.Registered<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.event_body>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Ev.Registered{runtime,reader,registry}: event_joined(owners,D.Occupied{D.EventOwner{reader,registry}},"event-registered-late",Domains.detach(~S.Schema,~S.Store,~Unit,~S.Notice,runtime,notices))
    case Ev.RegisterFailed{runtime}: event_joined(owners,D.Empty{},"event-register-failed",Domains.detach(~S.Schema,~S.Store,~Unit,~S.Notice,runtime,notices))
def event_lifecycle(id: U32,owners: D.Owners,observed: S.World() & List<&2,S.Notice>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match id owners observed:
    case 10 D.Owners{D.Occupied{events},fast,D.Occupied{D.EventOwner{reader,registry}},cf,cs,rf,rs,operation,config,reads}, (world,+notices): event_disposed(D.Owners{D.Empty{},fast,D.Empty{},cf,cs,rf,rs,operation,config,reads},notices,Ev.dispose(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.event_body,Domains.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),reader,registry))
    case 11 D.Owners{D.Occupied{events},fast,D.Empty{},cf,cs,rf,rs,operation,config,reads}, (world,+notices): event_registered(D.Owners{D.Empty{},fast,D.Empty{},cf,cs,rf,rs,operation,config,reads},notices,Ev.register(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.event_body,Domains.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),"event-slow",["Ping.read"]))
    case _ owners, (world,_): (owners,Sys.Failed{world,C.Failed{"lifecycle-event-slot"}})

def removal_disposed(owners: D.Owners,result: Rm.Disposal<S.Schema,S.Store,Unit,S.Notice,S.AllToken,C.select>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Rm.Disposed{world}: removal_slot(owners,D.Empty{},world,"removal-disposed")
    case Rm.DisposalRejected{world,reader}: removal_slot(owners,D.Occupied{reader},world,"removal-disposal-rejected")
def removal_registered(owners: D.Owners,result: Rm.Registered<S.Schema,S.Store,Unit,S.Notice,S.AllToken,C.select>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Rm.Registered{world,reader}: removal_slot(owners,D.Occupied{reader},world,"removal-registered-late")
    case Rm.Rejected{world}: removal_slot(owners,D.Empty{},world,"removal-register-failed")

def change_disposed(owners: D.Owners,result: Sys.Disposal<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Sys.Disposed{world}: change_slot(owners,D.Empty{},world,"change-disposed")
    case Sys.DisposalRejected{world,registry}: change_slot(owners,D.Occupied{registry},world,"change-disposal-rejected")
def change_registered(owners: D.Owners,result: Sys.RegistrationResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,C.change_runner>) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Sys.Registered{world,registry}: change_slot(owners,D.Occupied{registry},world,"change-registered-late")
    case Sys.RegistrationFailed{world}: change_slot(owners,D.Empty{},world,"change-register-failed")

def dispatch(owners: D.Owners,world: S.World(),id: U32) -> D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners id:
    case owners 10: event_lifecycle(10,owners,W.events_view(~S.Schema,~S.Store,~Unit,~S.Notice,world))
    case owners 11: event_lifecycle(11,owners,W.events_view(~S.Schema,~S.Store,~Unit,~S.Notice,world))
    case D.Owners{events,fast,slow,cf,cs,rf,D.Occupied{reader},operation,config,reads} 12: removal_disposed(D.Owners{events,fast,slow,cf,cs,rf,D.Empty{},operation,config,reads},Rm.dispose(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~C.select,reader,world))
    case owners 13: removal_registered(owners,Rm.register(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~C.select,world,"removal-slow"))
    case D.Owners{events,fast,slow,cf,D.Occupied{registry},rf,rs,operation,config,reads} 14: change_disposed(D.Owners{events,fast,slow,cf,D.Empty{},rf,rs,operation,config,reads},Sys.dispose(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,registry,world))
    case owners 15: change_registered(owners,Sys.register(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~C.change_runner,world,"change-slow",["Stock.write","Stock.changed"]))
    case owners _: D.dispatch(owners,world,id)

def built(world: S.World(),result: Sch.Build<S.Schema,S.Store,Unit,S.Notice,D.Owners>) -> D.Host & Bool:
  match result:
    case Sch.Built{schedule}: D.run_result(Sch.run_with_skip(~S.Schema,~S.Store,~Unit,~S.Notice,~D.Owners,~C.Failure,~D.skip,~dispatch,~Op.condition,schedule,world))
    case Sch.Invalid{owners}: (D.Host{world,owners},False{})
def named(owners: D.Owners,+steps: List<&2,Sch.Step>,observed: S.World() & U32) -> D.Host & Bool:
  (world,namespace) = observed
  built(world,Sch.build(~S.Schema,~S.Store,~Unit,~S.Notice,~D.Owners,namespace,"lifecycle",steps,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],owners))
def tick(host: D.Host,+steps: List<&2,Sch.Step>) -> D.Host & Bool:
  match host:
    case D.Host{world,owners}: named(owners,steps,W.namespace(~S.Schema,~S.Store,~Unit,~S.Notice,world))
def completed(observed: D.Host & String) -> IO(Unit):
  (host,text) = observed
  IO.print(text)
def after_dispose(observed: D.Host & Bool) -> IO(Unit):
  (host,ok) = observed
  completed(D.snapshot("after-re-registration",tick(host,[Sch.System{11,1},Sch.System{13,1},Sch.System{15,1},Sch.System{5,1},Sch.System{7,1},Sch.System{9,1},Sch.System{4,1},Sch.System{6,1},Sch.System{8,1}])))
def edited(observed: D.Host & Bool) -> IO(Unit):
  (host,ok) = observed
  after_dispose(tick(host,[Sch.System{10,1},Sch.System{12,1},Sch.System{14,1}]))
def seeded(observed: D.Host & Bool) -> IO(Unit):
  (host,ok) = observed
  edited(D.tick(D.configure(host,True{},D.Config{Op.Request{2,0,0,None{},False{}},False{},False{},False{},False{}}),[Sch.System{2,1},Sch.Barrier{},Sch.System{4,1},Sch.System{6,1},Sch.System{8,1}]))
def started(host: Maybe<&1,D.Host>) -> IO(Unit):
  match host:
    case Some{host}: seeded(D.tick(host,[Sch.System{1,1},Sch.Barrier{},Sch.System{4,1},Sch.System{6,1},Sch.System{8,1}]))
    case None{}: IO.print("initialization-failed")
def main() -> IO(Unit):
  started(D.init_created(W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty_store,W.factory(),Unit{})))
