import Base
import driver.bend as D
import schema.bend as S
import consumers.bend as C
import mixed-controls.bend as Mixed
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/event-runtime.bend as Ev
import ../../src/ecs/reader-domains.bend as Domains
import ../../src/ecs/schedule.bend as Sch
import operations.bend as Op

type Mode is Data:
  Mode{fail: Bool,publish: Bool}
def event_text(+values: List<&2,S.Notice>,lagged: Bool) -> String:
  "{\"kind\":\"mixed-event-reader\",\"values\":" ++ C.numbers(C.ping_values(values)) ++ ",\"lagged\":" ++ C.boolean(lagged) ++ "}"
def returned(+text: String,result: Sys.Outcome<S.World(),C.Failure,String>) -> Sys.Outcome<S.World(),C.Failure,String>:
  match result:
    case Sys.Succeeded{world,_}: Sys.Succeeded{W.barrier(~S.Schema,~S.Store,~Unit,~S.Notice,world),text}
    case Sys.Failed{world,_}: Sys.Failed{world,C.Failed{text}}
def run_mode(mode: Mode,world: S.World(),+text: String) -> Sys.Outcome<S.World(),C.Failure,String>:
  match mode:
    case Mode{fail,True{}}: returned(text,Mixed.runner(world,fail))
    case Mode{_,False{}}: Sys.Succeeded{world,text}
def runner(world: S.World(),input: Ev.Input<S.Notice,Mode>) -> Sys.Outcome<S.World(),C.Failure,String>:
  match input:
    case Ev.Input{values,lagged,mode}: run_mode(mode,world,event_text(values,lagged))
def Registry() -> Type: Sys.Registry<S.Schema,S.Store,Unit,S.Notice,Ev.Input<S.Notice,Mode>,C.Failure,String,runner>
type ReaderOwner is Type:
  ReaderOwner{reader: Ev.Reader<S.Schema>,registry: Registry()}
type Owners is Type:
  Owners{base: D.Owners,reader: D.Slot<ReaderOwner>,mode: Mode}
type Host is Type:
  Host{world: S.World(),owners: Owners}
def restored(owners: Owners,reader: ReaderOwner,+text: String,fail: Bool,result: Domains.Detached<S.Schema,S.Store,Unit,S.Notice>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result:
    case Owners{D.Owners{_,fast,slow,cf,cs,rf,rs,op,config,+reads},_,mode}, Domains.Detached{world,events}: (Owners{D.Owners{D.Occupied{events},fast,slow,cf,cs,rf,rs,op,config,D.append_read(reads,text)},D.Occupied{reader},mode},D.as_unit(C.finish(world,text,fail)))
def completed(owners: Owners,+notices: List<&2,S.Notice>,result: Ev.RunResult<S.Schema,S.Store,Unit,S.Notice,Mode,C.Failure,String,runner>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Ev.Ran{runtime,reader,registry,Ev.Succeeded{+text}}: restored(owners,ReaderOwner{reader,registry},text,False{},Domains.recover(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,runtime,notices))
    case Ev.Ran{runtime,reader,registry,Ev.Failed{C.Failed{+text}}}: restored(owners,ReaderOwner{reader,registry},text,True{},Domains.recover(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,runtime,notices))
    case Ev.Ran{runtime,reader,registry,_}: restored(owners,ReaderOwner{reader,registry},"rejected",True{},Domains.recover(~S.Schema,~S.Store,~Unit,~S.Notice,~S.is_event,runtime,notices))
def read_view(events: Domains.Events<S.Schema,S.Notice>,owners: Owners,observed: S.World() & List<&2,S.Notice>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners observed:
    case Owners{base,D.Occupied{ReaderOwner{reader,registry}},+mode}, (world,+notices): completed(Owners{base,D.Empty{},mode},notices,Ev.run(~S.Schema,~S.Store,~Unit,~S.Notice,~Mode,~C.Failure,~String,~runner,Domains.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world),reader,registry,mode))
    case owners, (world,_): (owners,Sys.Failed{world,C.Failed{"mixed-event-empty"}})
def read_domain(events: Domains.Events<S.Schema,S.Notice>,owners: Owners,world: S.World()) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  read_view(events,owners,W.events_view(~S.Schema,~S.Store,~Unit,~S.Notice,world))
def forwarded(reader: D.Slot<ReaderOwner>,mode: Mode,result: D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  (base,outcome) = result
  (Owners{base,reader,mode},outcome)
def dispatch(owners: Owners,world: S.World(),id: U32) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners id:
    case Owners{D.Owners{D.Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads},reader,mode} 17: Domains.drive(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,~(Owners & Sys.Outcome<S.World(),C.Failure,Unit>),~S.is_event,~read_domain,events,Owners{D.Owners{D.Empty{},fast,slow,cf,cs,rf,rs,op,config,reads},reader,mode},world)
    case Owners{base,reader,mode} _: forwarded(reader,mode,D.dispatch(base,world,id))
def skipped(reader: D.Slot<ReaderOwner>,mode: Mode,result: D.Owners & S.World()) -> Owners & S.World():
  (base,world) = result
  (Owners{base,reader,mode},world)
def skip(owners: Owners,world: S.World(),id: U32) -> Owners & S.World():
  match owners:
    case Owners{base,reader,mode}: skipped(reader,mode,D.skip(base,world,id))
def result(result: Sch.RunResult<S.Schema,S.Store,Unit,S.Notice,Owners,C.Failure>) -> Host & Bool:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,owners},world,_}: (Host{world,owners},True{})
    case Sch.Failed{Sch.Schedule{_,_,_,owners},world,_,_}: (Host{world,owners},False{})
    case Sch.Rejected{Sch.Schedule{_,_,_,owners},world}: (Host{world,owners},False{})
def built(world: S.World(),build: Sch.Build<S.Schema,S.Store,Unit,S.Notice,Owners>) -> Host & Bool:
  match build:
    case Sch.Built{schedule}: result(Sch.run_with_skip(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,~C.Failure,~skip,~dispatch,~Op.condition,schedule,world))
    case Sch.Invalid{owners}: (Host{world,owners},False{})
def configured(reader: D.Slot<ReaderOwner>,mode: Mode,+steps: List<&2,Sch.Step>,host: D.Host) -> Host & Bool:
  match host:
    case D.Host{world,D.Owners{events,fast,slow,cf,cs,rf,rs,op,config,_}}: built(world,Sch.build(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,1,"mixed-event",steps,[4,5,8,17],Owners{D.Owners{events,fast,slow,cf,cs,rf,rs,op,config,[]},reader,mode}))
def framed(reader: D.Slot<ReaderOwner>,mode: Mode,framing: Bool,+steps: List<&2,Sch.Step>,host: D.Host) -> Host & Bool:
  match framing:
    case True{}: configured(reader,mode,steps,D.frame(host))
    case False{}: configured(reader,mode,steps,host)
def tick(host: Host,+enabled: Bool,+mode: Mode,+framing: Bool,+steps: List<&2,Sch.Step>) -> Host & Bool:
  match host:
    case Host{world,Owners{base,reader,_}}: framed(reader,mode,framing,steps,D.configure(D.Host{world,base},enabled,D.Config{Op.Request{4,0,0,None{},False{}},False{},False{},False{},False{}}))
def snapped(reader: D.Slot<ReaderOwner>,mode: Mode,observed: D.Host & String) -> Host & String:
  (D.Host{world,base},text) = observed
  (Host{world,Owners{base,reader,mode}},text)
def snapshot(+label: String,observed: Host & Bool) -> Host & String:
  match observed:
    case (Host{world,Owners{base,reader,mode}},ok): snapped(reader,mode,D.snapshot(label,(D.Host{world,base},ok)))
def fourth(+log: List<&2,String>,observed: Host & String) -> IO(Unit):
  (host,text) = observed
  IO.print("{\"format\":1,\"application\":\"MixedEventReader\",\"checkpoints\":" ++ C.array(List.append(&2,String,log,[text])) ++ "}")
def third(+log: List<&2,String>,observed: Host & String) -> IO(Unit):
  (host,text) = observed
  fourth(List.append(&2,String,log,[text]),snapshot("peers-retained-own-consumed",tick(host,True{},Mode{False{},False{}},False{},[Sch.System{5,1},Sch.System{4,0},Sch.System{8,0},Sch.System{17,1}])))
def second(+first: String,observed: Host & String) -> IO(Unit):
  (host,text) = observed
  third([first,text],snapshot("event-skip-removal-preserve",tick(host,False{},Mode{False{},False{}},True{},[Sch.System{4,0},Sch.System{8,0}])))
def first(observed: Host & String) -> IO(Unit):
  (host,text) = observed
  second(text,snapshot("event-reader-mixed-retry",tick(host,True{},Mode{False{},True{}},False{},[Sch.System{17,1}])))
def started(owners: D.Owners,result: Domains.Detached<S.Schema,S.Store,Unit,S.Notice>,reader: ReaderOwner) -> IO(Unit):
  match owners result:
    case D.Owners{_,fast,slow,cf,cs,rf,rs,op,config,reads}, Domains.Detached{world,events}: first(snapshot("event-reader-mixed-failed",tick(Host{W.event_publish(~S.Schema,~S.Store,~Unit,~S.Notice,world,[S.Ping{42}]),Owners{D.Owners{D.Occupied{events},fast,slow,cf,cs,rf,rs,op,config,reads},D.Occupied{reader},Mode{True{},True{}}}},True{},Mode{True{},True{}},False{},[Sch.System{17,1}])))
def registered(base: D.Owners,result: Ev.Registered<S.Schema,S.Store,Unit,S.Notice,Mode,C.Failure,String,runner>) -> IO(Unit):
  match result:
    case Ev.Registered{runtime,reader,registry}: started(base,Domains.detach(~S.Schema,~S.Store,~Unit,~S.Notice,runtime,[]),ReaderOwner{reader,registry})
    case _: IO.print("mixed-reader-registration-failed")
def setup(host: D.Host) -> IO(Unit):
  match host:
    case D.Host{world,D.Owners{D.Occupied{Domains.Events{ns,batches,positions,next,tick,start,boundary,_,dropped,values}},fast,slow,cf,cs,rf,rs,op,config,reads}}: registered(D.Owners{D.Empty{},fast,slow,cf,cs,rf,rs,op,config,reads},Ev.register(~S.Schema,~S.Store,~Unit,~S.Notice,~Mode,~C.Failure,~String,~runner,Domains.attach(~S.Schema,~S.Store,~Unit,~S.Notice,Domains.Events{ns,batches,positions,next,tick,start,boundary,2n,dropped,values},world),"event-mixed",["Ping.read","Ping.write","Aux.remove","deferred.Ping.write"]))
    case _: IO.print("mixed-reader-setup-failed")
def seeded(observed: D.Host & Bool) -> IO(Unit):
  (host,ok) = observed
  setup(host)
def created(host: Maybe<&1,D.Host>) -> IO(Unit):
  match host:
    case Some{host}: seeded(D.tick(host,[Sch.System{1,1},Sch.Barrier{},Sch.System{4,1},Sch.System{5,1},Sch.System{8,1}]))
    case _: IO.print("mixed-reader-create-failed")
def main() -> IO(Unit):
  created(D.init_created(W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty_store,W.factory(),Unit{})))
