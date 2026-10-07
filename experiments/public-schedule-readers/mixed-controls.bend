import Base
import driver.bend as D
import schema.bend as S
import consumers.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/reader-domains.bend as Domains
import ../../src/ecs/schedule.bend as Sch
import operations.bend as Op

def barrier_ping(world: S.World()) -> S.World():
  W.event_publish(~S.Schema,~S.Store,~Unit,~S.Notice,world,[S.Ping{11}])
def runner(world: S.World(),fail: Bool) -> Sys.Outcome<S.World(),C.Failure,String>:
  Op.finished(Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~S.Notice,~C.Failure,T.stage(~S.World(),~S.Notice,S.remove_aux(T.emit(~S.World(),~S.Notice,T.begin(~S.World(),~S.Notice,world),S.Ping{10}),W.Handle{1,1}),barrier_ping),Op.outcome(fail)))
def Registry() -> Type: Sys.Registry<S.Schema,S.Store,Unit,S.Notice,Bool,C.Failure,String,runner>
type Owners is Type:
  Owners{base: D.Owners,registry: D.Slot<Registry()>,fail: Bool}
type Host is Type:
  Host{world: S.World(),owners: Owners}
def restored(owners: Owners,result: Sys.RunResult<S.Schema,S.Store,Unit,S.Notice,Bool,C.Failure,String,runner>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners result:
    case Owners{base,_,fail}, Sys.Completed{registry,outcome}: (Owners{base,D.Occupied{registry},fail},D.as_unit(outcome))
    case Owners{base,_,fail}, Sys.RegistrationRejected{registry,world,_}: (Owners{base,D.Occupied{registry},fail},Sys.Failed{world,C.Failed{"mixed-rejected"}})
def forwarded(registry: D.Slot<Registry()>,fail: Bool,result: D.Owners & Sys.Outcome<S.World(),C.Failure,Unit>) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  (base,outcome) = result
  (Owners{base,registry,fail},outcome)
def dispatch(owners: Owners,world: S.World(),id: U32) -> Owners & Sys.Outcome<S.World(),C.Failure,Unit>:
  match owners id:
    case Owners{base,D.Occupied{registry},+fail} 16: restored(Owners{base,D.Empty{},fail},Sys.run(~S.Schema,~S.Store,~Unit,~S.Notice,~Bool,~C.Failure,~String,~runner,registry,world,fail))
    case Owners{base,registry,fail} _: forwarded(registry,fail,D.dispatch(base,world,id))
    case owners _: (owners,Sys.Failed{world,C.Failed{"mixed-empty-slot"}})
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
def tick(host: Host,+fail: Bool) -> Host & Bool:
  match host:
    case Host{world,Owners{base,registry,_}}: built(world,Sch.build(~S.Schema,~S.Store,~Unit,~S.Notice,~Owners,1,"mixed",[Sch.System{16,1},Sch.Barrier{},Sch.System{4,1},Sch.System{8,1}],[4,8,16],Owners{base,registry,fail}))
def snap_return(registry: D.Slot<Registry()>,fail: Bool,observed: D.Host & String) -> Host & String:
  (D.Host{world,base},text) = observed
  (Host{world,Owners{base,registry,fail}},text)
def snapshot(+label: String,observed: Host & Bool) -> Host & String:
  match observed:
    case (Host{world,Owners{base,registry,fail}},ok): snap_return(registry,fail,D.snapshot(label,(D.Host{world,base},ok)))
def print_retry(+first: String,observed: Host & String) -> IO(Unit):
  (host,second) = observed
  IO.print("[" ++ first ++ "," ++ second ++ "]")
def retry(observed: Host & String) -> IO(Unit):
  (host,+first) = observed
  print_retry(first,snapshot("mixed-retry",tick(host,False{})))
def registered(base: D.Owners,result: Sys.RegistrationResult<S.Schema,S.Store,Unit,S.Notice,Bool,C.Failure,String,runner>) -> IO(Unit):
  match result:
    case Sys.Registered{world,registry}: retry(snapshot("mixed-failed",tick(Host{world,Owners{base,D.Occupied{registry},True{}}},True{})))
    case _: IO.print("mixed-registration-failed")
def seeded(observed: D.Host & Bool) -> IO(Unit):
  match observed:
    case (D.Host{world,base},_): registered(base,Sys.register(~S.Schema,~S.Store,~Unit,~S.Notice,~Bool,~C.Failure,~String,~runner,world,"mixed-publication",["Ping.write","Aux.remove","deferred.Ping.write"]))
def created(host: Maybe<&1,D.Host>) -> IO(Unit):
  match host:
    case Some{host}: seeded(D.tick(host,[Sch.System{1,1},Sch.Barrier{}]))
    case _: IO.print("mixed-create-failed")
def main() -> IO(Unit):
  created(D.init_created(W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty_store,W.factory(),Unit{})))
