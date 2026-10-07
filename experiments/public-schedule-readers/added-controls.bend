import Base
import driver.bend as D
import schema.bend as S
import consumers.bend as C
import operations.bend as Op
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/compose.bend as Q
import ../../src/ecs/schedule.bend as Sch

def added(ctx: C.frame()) -> C.frame() & Bool:
  Q.lifecycle_match(~S.Schema,~S.Store,~Unit,~S.Notice,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),~Q.Added{},ctx)
def selected(ctx: C.frame()) -> C.frame() & Bool:
  Q.both(~S.Schema,~S.Store,~Unit,~S.Notice,~added,~C.changed,ctx)
def plan() -> Q.Plan<S.Schema,S.Store,Unit,S.Notice,C.Ops>:
  Q.Plan{C.ChangeCaps{Q.write_family(~S.Schema,~S.Store,~Unit,~S.Notice,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock()),Q.handle_read(~S.Schema,~S.Store,~Unit,~S.Notice)},selected}
def runner(world: S.World(),args: C.ReadArgs) -> Sys.Outcome<S.World(),C.Failure,String>:
  match args:
    case C.ReadArgs{+name,fail,own,cursor}: C.change_result(name,Q.each_since(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Ops,~C.Mode,~String,~String,~plan(),~C.transactional_body,C.Mode{own,fail},world,cursor))
def Registry() -> Type: Sys.Registry<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,runner>
type Owners is Type:
  Owners{base: D.Owners,reader: D.Slot<Registry()>,own: Bool}
type Host is Type:
  Host{world: S.World(),owners: Owners}
def append(base: D.Owners,+text: String) -> D.Owners:
  match base:
    case D.Owners{events,fast,slow,cf,cs,rf,rs,op,config,+reads}: D.Owners{events,fast,slow,cf,cs,rf,rs,op,config,D.append_read(reads,text)}
def completed(base: D.Owners,own: Bool,result: Sys.RunResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,runner>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,+text}}: (Owners{append(base,text),D.Occupied{registry},own},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,C.Failed{+text}}}: (Owners{append(base,text),D.Occupied{registry},own},Sys.Failed{world,C.Failed{text}})
    case Sys.RegistrationRejected{registry,world,_}: (Owners{base,D.Occupied{registry},own},Sys.Failed{world,C.Failed{"added-rejected"}})
def identified(base: D.Owners,+own: Bool,world: S.World(),identified: Registry() & U32) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  (registry,cursor) = identified
  completed(base,own,Sys.run_tracked(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~runner,registry,world,C.ReadArgs{"change-added",False{},own,cursor}))
def forwarded(reader: D.Slot<Registry()>,own: Bool,result: D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  (base,outcome) = result
  (Owners{base,reader,own},outcome)
def dispatch(owners: Owners,world: S.World(),id: U32) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners id:
    case Owners{base,D.Occupied{reader},own} 100: identified(base,own,world,Sys.cursor(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~runner,reader))
    case Owners{base,reader,own} _: forwarded(reader,own,D.dispatch(base,world,id))
def skip(owners: Owners,world: S.World(),id: U32) -> Owners & S.World():
  (owners,world)
def result(result: Sch.RunResult<S.Schema,S.Store,Unit,S.Notice,Owners,C.Failure>) -> Host & Bool:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,owners},world,_}: (Host{world,owners},True{})
    case Sch.Failed{Sch.Schedule{_,_,_,owners},world,_,_}: (Host{world,owners},False{})
    case Sch.Rejected{Sch.Schedule{_,_,_,owners},world}: (Host{world,owners},False{})
def built(world: S.World(),build: Sch.Build<S.Schema,S.Store,Unit,S.Notice,Owners>) -> Host & Bool:
  match build:
    case Sch.Built{schedule}: result(Sch.run_with_skip(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,~C.Failure,~skip,~dispatch,~Op.condition,schedule,world))
    case Sch.Invalid{owners}: (Host{world,owners},False{})
def prepared(reader: D.Slot<Registry()>,own: Bool,+steps: List<&2,Sch.Step>,host: D.Host) -> Host & Bool:
  match host:
    case D.Host{world,base}: built(world,Sch.build(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,1,"added",steps,[1,100],Owners{base,reader,own}))
def tick(host: Host,+enabled: Bool,+own: Bool,+steps: List<&2,Sch.Step>) -> Host & Bool:
  match host:
    case Host{world,Owners{base,reader,_}}: prepared(reader,own,steps,D.frame(D.configure(D.Host{world,base},enabled,D.Config{Op.Request{4,0,0,None{},False{}},False{},False{},False{},False{}})))
def snapped(reader: D.Slot<Registry()>,own: Bool,observed: D.Host & String) -> Host & String:
  (D.Host{world,base},text) = observed
  (Host{world,Owners{base,reader,own}},text)
def snapshot(+label: String,observed: Host & Bool) -> Host & String:
  match observed:
    case (Host{world,Owners{base,reader,own}},ok): snapped(reader,own,D.snapshot(label,(D.Host{world,base},ok)))
def fourth(+log: List<&2,String>,observed: Host & String) -> IO(Unit):
  (host,text) = observed
  IO.print("{\"format\":1,\"application\":\"AddedSchedule\",\"checkpoints\":" ++ C.array(List.append(&2,String,log,[text])) ++ "}")
def third(+log: List<&2,String>,observed: Host & String) -> IO(Unit):
  (host,text) = observed
  fourth(List.append(&2,String,log,[text]),snapshot("added-own-write-consumed",tick(host,True{},True{},[Sch.System{100,0}])))
def second(+first: String,observed: Host & String) -> IO(Unit):
  (host,text) = observed
  third([first,text],snapshot("added-resume-own-write",tick(host,True{},True{},[Sch.System{100,0}])))
def first(observed: Host & String) -> IO(Unit):
  (host,text) = observed
  second(text,snapshot("added-skipped-spawn",tick(host,False{},False{},[Sch.System{1,1},Sch.Barrier{},Sch.System{100,0}])))
def registered(base: D.Owners,result: Sys.RegistrationResult<S.Schema,S.Store,Unit,S.Notice,C.ReadArgs,C.Failure,String,runner>) -> IO(Unit):
  match result:
    case Sys.Registered{world,reader}: first(snapshot("added-seed",tick(Host{world,Owners{base,D.Occupied{reader},False{}}},True{},False{},[Sch.System{1,1},Sch.Barrier{},Sch.System{100,0}])))
    case _: IO.print("added-registration-failed")
def created(host: Maybe<&1,D.Host>) -> IO(Unit):
  match host:
    case Some{D.Host{world,base}}: registered(base,Sys.register(~S.Schema,~S.Store,~Unit,~S.Notice,~C.ReadArgs,~C.Failure,~String,~runner,world,"change-added",["Stock.added","Stock.changed","Stock.write"]))
    case _: IO.print("added-creation-failed")
def main() -> IO(Unit):
  created(D.init_created(W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty_store,W.factory(),Unit{})))
