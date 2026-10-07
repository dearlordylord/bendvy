import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/schedule.bend as Sch
import ../../src/ecs/transaction.bend as Tx
import ../../src/ecs/capabilities.bend as Cap

type Schema is Data:
  Schema{}
type Owners is Type:
  Owners{a: Sys.Registry<Schema,Unit,U32,U32,U32,String,Unit,runner>,b: Sys.Registry<Schema,Unit,U32,U32,U32,String,Unit,runner>}

def empty(_: Unit) -> Unit:
  Unit{}
def change(world: W.World<Schema,Unit,U32,U32>,+value: U32) -> W.World<Schema,Unit,U32,U32>:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,+resource,+events,pending,+registrations,+nextSystem,+clock}: W.World{ns,next,high,live,cap,depth,store,(resource * 10 + value : U32),events,pending,registrations,nextSystem,clock}
def activated(result: W.World<Schema,Unit,U32,U32> & W.Status) -> W.World<Schema,Unit,U32,U32>:
  (world,_) = result
  world
def reserved(reservation: W.World<Schema,Unit,U32,U32> & W.Reservation<Schema>) -> W.World<Schema,Unit,U32,U32>:
  match reservation:
    case (world,W.Reserved{handle}): activated(W.activate(~Schema,~Unit,~U32,~U32,world,handle))
    case (world,_): world
def queued(world: W.World<Schema,Unit,U32,U32>) -> W.World<Schema,Unit,U32,U32>:
  reserved(W.reserve_id(~Schema,~Unit,~U32,~U32,world))
def activate_handle(world: W.World<Schema,Unit,U32,U32>,handle: W.Handle<Schema>) -> W.World<Schema,Unit,U32,U32>:
  activated(W.activate(~Schema,~Unit,~U32,~U32,world,handle))
def queued_reserved(reservation: W.World<Schema,Unit,U32,U32> & W.Reservation<Schema>) -> W.World<Schema,Unit,U32,U32>:
  match reservation:
    case (world,W.Reserved{handle}): W.enqueue(~Schema,~Unit,~U32,~U32,world,w => activate_handle(w,handle))
    case (world,_): world
def enqueue_spawn(world: W.World<Schema,Unit,U32,U32>) -> W.World<Schema,Unit,U32,U32>:
  queued_reserved(W.reserve_id(~Schema,~Unit,~U32,~U32,world))
def live_value(observed: W.World<Schema,Unit,U32,U32> & List<&2,W.Handle<Schema>>) -> Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  (world,handles) = observed
  Sys.Succeeded{W.event_publish(~Schema,~Unit,~U32,~U32,change(world,(2 + U32.from_nat(List.length(&2,W.Handle<Schema>,handles)) : U32)),[2]),Unit{}}
def enqueue_all(commands: List<(W.World<Schema,Unit,U32,U32> -> W.World<Schema,Unit,U32,U32>)>,world: W.World<Schema,Unit,U32,U32>) -> W.World<Schema,Unit,U32,U32>:
  match commands:
    case []: world
    case command <> rest: enqueue_all(rest,W.enqueue(~Schema,~Unit,~U32,~U32,world,command))
def enqueue(world: W.World<Schema,Unit,U32,U32>,commands: List<(W.World<Schema,Unit,U32,U32> -> W.World<Schema,Unit,U32,U32>)>) -> W.World<Schema,Unit,U32,U32>:
  enqueue_all(commands,world)
def publish(world: W.World<Schema,Unit,U32,U32>,events: List<&2,U32>) -> W.World<Schema,Unit,U32,U32>:
  W.event_publish(~Schema,~Unit,~U32,~U32,world,events)
def restored(replaced: W.World<Schema,Unit,U32,U32> & U32) -> W.World<Schema,Unit,U32,U32>:
  (world,_) = replaced
  world
def restore_resource(world: W.World<Schema,Unit,U32,U32>,value: U32) -> W.World<Schema,Unit,U32,U32>:
  restored(W.replace_resource(~Schema,~Unit,~U32,~U32,world,value))
def failed_finished(result: Tx.Returned<W.World<Schema,Unit,U32,U32>,String>) -> Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  match result:
    case Tx.Returned{world,Tx.Failure{error}}: Sys.Failed{world,error}
    case Tx.Returned{world,Tx.Success{}}: Sys.Succeeded{world,Unit{}}
def failed_replaced(replaced: W.World<Schema,Unit,U32,U32> & U32) -> Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  (world,old) = replaced
  tx = Tx.add_undo(~W.World<Schema,Unit,U32,U32>,~U32,Tx.begin(~W.World<Schema,Unit,U32,U32>,~U32,world),w => restore_resource(w,old))
  staged = Tx.stage(~W.World<Schema,Unit,U32,U32>,~U32,Tx.emit(~W.World<Schema,Unit,U32,U32>,~U32,tx,7),queued)
  failed_finished(Tx.finish(~W.World<Schema,Unit,U32,U32>,~U32,~String,~enqueue,~publish,staged,Tx.Failure{"planned"}))
def failure_reserved(reservation: W.World<Schema,Unit,U32,U32> & W.Reservation<Schema>) -> Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  (world,_) = reservation
  failed_replaced(W.replace_resource(~Schema,~Unit,~U32,~U32,world,777))
def runner_value(world: W.World<Schema,Unit,U32,U32>,+value: U32) -> Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  match value:
    case 2: live_value(W.handles(~Schema,~Unit,~U32,~U32,world))
    case 6: Sys.Succeeded{enqueue_spawn(publish(change(world,2),[2])),Unit{}}
    case 7: failure_reserved(W.reserve_id(~Schema,~Unit,~U32,~U32,world))
    case 8: Sys.Succeeded{enqueue_spawn(world),Unit{}}
    case +value: Sys.Succeeded{W.event_publish(~Schema,~Unit,~U32,~U32,change(world,value),[value]),Unit{}}
def runner(world: W.World<Schema,Unit,U32,U32>,value: U32) -> Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  runner_value(world,value)
def result_a(result: Sys.RunResult<Schema,Unit,U32,U32,U32,String,Unit,runner>,b: Sys.Registry<Schema,Unit,U32,U32,U32,String,Unit,runner>) -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  match result:
    case Sys.Completed{a,outcome}: (Owners{a,b},outcome)
    case Sys.RegistrationRejected{a,world,_}: (Owners{a,b},Sys.Failed{world,"registration"})
def result_b(result: Sys.RunResult<Schema,Unit,U32,U32,U32,String,Unit,runner>,a: Sys.Registry<Schema,Unit,U32,U32,U32,String,Unit,runner>) -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  match result:
    case Sys.Completed{b,outcome}: (Owners{a,b},outcome)
    case Sys.RegistrationRejected{b,world,_}: (Owners{a,b},Sys.Failed{world,"registration"})
def dispatch_value(owners: Owners,world: W.World<Schema,Unit,U32,U32>,+id: U32) -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  match owners id:
    case Owners{a,b} 1: result_a(Sys.run(~Schema,~Unit,~U32,~U32,~U32,~String,~Unit,~runner,a,world,8),b)
    case Owners{a,b} 2: result_b(Sys.run(~Schema,~Unit,~U32,~U32,~U32,~String,~Unit,~runner,b,world,2),a)
    case owners _: (owners,Sys.Failed{world,"unknown"})
def dispatch(owners: Owners,world: W.World<Schema,Unit,U32,U32>,id: U32) -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  dispatch_value(owners,world,id)
def project_counter_value(+value: U32) -> U32 & U32:
  (value,value)
def project_counter(value: U32) -> U32 & U32:
  project_counter_value(value)
def read_counter(world: W.World<Schema,Unit,U32,U32>) -> W.World<Schema,Unit,U32,U32> & U32:
  W.observe_resource(~Schema,~Unit,~U32,~U32,~U32,~project_counter,world)
def gameplay_read(~H: Type,~cap: Cap.ValueRead<H,U32>,ctx: H) -> H & U32:
  Cap.value_read(~H,~U32,~cap,ctx)
def condition_observed(observed: W.World<Schema,Unit,U32,U32> & U32,slot: U32) -> W.World<Schema,Unit,U32,U32> & Bool:
  (world,value) = observed
  (world,Bool.and(Bool.not(U32.is_eq(slot,0)),U32.is_lt(value,1000000)))
def condition(world: W.World<Schema,Unit,U32,U32>,slot: U32) -> W.World<Schema,Unit,U32,U32> & Bool:
  condition_observed(gameplay_read(~W.World<Schema,Unit,U32,U32>,~Cap.ValueRead{read_counter},world),slot)
def show_steps(steps: List<&2,Sch.Observation>) -> String:
  match steps:
    case []: ""
    case Sch.Entered{name} <> rest: "phase:" ++ name ++ ";" ++ show_steps(rest)
    case Sch.Ran{id} <> rest: "run:" ++ U32.show(id) ++ ";" ++ show_steps(rest)
    case Sch.Skipped{id} <> rest: "skip:" ++ U32.show(id) ++ ";" ++ show_steps(rest)
    case Sch.Applied{} <> rest: "barrier;" ++ show_steps(rest)
def numbers(values: List<&2,U32>) -> String:
  match values:
    case []: ""
    case value <> rest: U32.show(value) ++ "," ++ numbers(rest)
def ids(handles: List<&2,W.Handle<Schema>>) -> String:
  match handles:
    case []: ""
    case W.Handle{_,id} <> rest: U32.show(id) ++ "," ++ ids(rest)
def capture_handles(observed: W.World<Schema,Unit,U32,U32> & List<&2,W.Handle<Schema>>,+prefix: String) -> W.World<Schema,Unit,U32,U32> & String:
  (world,handles) = observed
  (world,prefix ++ ":" ++ ids(handles))
def capture(world: W.World<Schema,Unit,U32,U32>) -> W.World<Schema,Unit,U32,U32> & String:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,+resource,+events,pending,+registrations,+nextSystem,+clock}: capture_handles(W.handles(~Schema,~Unit,~U32,~U32,W.World{ns,next,high,live,cap,depth,store,resource,events,pending,registrations,nextSystem,clock}),U32.show(resource) ++ ":" ++ numbers(events))

def dispatch_fail_value(owners: Owners,world: W.World<Schema,Unit,U32,U32>,+id: U32) -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  match owners id:
    case Owners{a,b} 1: result_a(Sys.run(~Schema,~Unit,~U32,~U32,~U32,~String,~Unit,~runner,a,world,6),b)
    case Owners{a,b} 2: result_b(Sys.run(~Schema,~Unit,~U32,~U32,~U32,~String,~Unit,~runner,b,world,7),a)
    case owners _: (owners,Sys.Failed{world,"unknown"})
def dispatch_fail(owners: Owners,world: W.World<Schema,Unit,U32,U32>,id: U32) -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>:
  dispatch_fail_value(owners,world,id)
def record_capture(schedule: Sch.Schedule<Schema,Unit,U32,U32,Owners>,captured: W.World<Schema,Unit,U32,U32> & String,+lines: List<&2,String>) -> Sch.Schedule<Schema,Unit,U32,U32,Owners> & (W.World<Schema,Unit,U32,U32> & List<&2,String>):
  (world,text) = captured
  (schedule,(world,List.append(&2,String,lines,[text])))
def record_run(result: Sch.RunResult<Schema,Unit,U32,U32,Owners,String>,+lines: List<&2,String>) -> Sch.Schedule<Schema,Unit,U32,U32,Owners> & (W.World<Schema,Unit,U32,U32> & List<&2,String>):
  match result:
    case Sch.Finished{schedule,world,+observations}: record_capture(schedule,capture(world),List.append(&2,String,lines,["ok:" ++ show_steps(observations)]))
    case Sch.Failed{schedule,world,+error,+observations}: record_capture(schedule,capture(world),List.append(&2,String,lines,["fail:" ++ error ++ ":" ++ show_steps(observations)]))
    case Sch.Rejected{schedule,world}: record_capture(schedule,capture(world),List.append(&2,String,lines,["rejected"]))
def show_lines(lines: List<&2,String>) -> String:
  match lines:
    case []: ""
    case line <> rest: line ++ "\n" ++ show_lines(rest)
def flush_capture(captured: W.World<Schema,Unit,U32,U32> & String,+lines: List<&2,String>) -> String:
  (_,text) = captured
  show_lines(lines) ++ "flush:" ++ text ++ "\n"
def final_nested(nested: W.World<Schema,Unit,U32,U32> & List<&2,String>) -> String:
  (world,lines) = nested
  flush_capture(capture(W.barrier(~Schema,~Unit,~U32,~U32,world)),lines)
def final(result: Sch.Schedule<Schema,Unit,U32,U32,Owners> & (W.World<Schema,Unit,U32,U32> & List<&2,String>)) -> String:
  (_,nested) = result
  final_nested(nested)
def twice_nested(~selected: Owners -> W.World<Schema,Unit,U32,U32> -> U32 -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>,schedule: Sch.Schedule<Schema,Unit,U32,U32,Owners>,nested: W.World<Schema,Unit,U32,U32> & List<&2,String>) -> String:
  (world,lines) = nested
  final(record_run(Sch.run(~Schema,~Unit,~U32,~U32,~Owners,~String,~selected,~condition,schedule,world),lines))
def twice_second(~selected: Owners -> W.World<Schema,Unit,U32,U32> -> U32 -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>,first: Sch.Schedule<Schema,Unit,U32,U32,Owners> & (W.World<Schema,Unit,U32,U32> & List<&2,String>)) -> String:
  (schedule,nested) = first
  twice_nested(~selected,schedule,nested)
def built(~selected: Owners -> W.World<Schema,Unit,U32,U32> -> U32 -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>,build: Sch.Build<Schema,Unit,U32,U32,Owners>,world: W.World<Schema,Unit,U32,U32>) -> String:
  match build:
    case Sch.Invalid{_}: "invalid\n"
    case Sch.Built{schedule}: twice_second(~selected,record_run(Sch.run(~Schema,~Unit,~U32,~U32,~Owners,~String,~selected,~condition,schedule,world),[]))
def init_b(~selected: Owners -> W.World<Schema,Unit,U32,U32> -> U32 -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>,result: Sys.RegistrationResult<Schema,Unit,U32,U32,U32,String,Unit,runner>,a: Sys.Registry<Schema,Unit,U32,U32,U32,String,Unit,runner>,+steps: List<&2,Sch.Step>) -> String:
  match result:
    case Sys.RegistrationFailed{_}: "registration-failed"
    case Sys.Registered{world,b}: built(~selected,Sch.build(~Schema,~Unit,~U32,~U32,~Owners,1,"tick",steps,[1,2],Owners{a,b}),world)
def init_a(~selected: Owners -> W.World<Schema,Unit,U32,U32> -> U32 -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>,result: Sys.RegistrationResult<Schema,Unit,U32,U32,U32,String,Unit,runner>,+steps: List<&2,Sch.Step>) -> String:
  match result:
    case Sys.RegistrationFailed{_}: "registration-failed"
    case Sys.Registered{world,a}: init_b(~selected,Sys.register(~Schema,~Unit,~U32,~U32,~U32,~String,~Unit,~runner,world,"B",["resource.write","events.publish"]),a,steps)
def created(~selected: Owners -> W.World<Schema,Unit,U32,U32> -> U32 -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>,result: W.Creation<Schema,Unit,U32,U32>,+steps: List<&2,Sch.Step>) -> String:
  match result:
    case W.CreateRejected{_,_}: "create-failed"
    case W.Created{_,world}: init_a(~selected,Sys.register(~Schema,~Unit,~U32,~U32,~U32,~String,~Unit,~runner,world,"A",["commands.enqueue"]),steps)
def scenario(~selected: Owners -> W.World<Schema,Unit,U32,U32> -> U32 -> Owners & Sys.Outcome<W.World<Schema,Unit,U32,U32>,String,Unit>,+steps: List<&2,Sch.Step>) -> String:
  created(~selected,W.create(~Schema,~Unit,~U32,~U32,~empty,W.factory(),0),steps)
def main() -> IO(Unit):
  IO.print(scenario(~dispatch,[Sch.Phase{"before"},Sch.System{1,1},Sch.Phase{"after"},Sch.System{2,1}]) ++ scenario(~dispatch,[Sch.Phase{"before"},Sch.System{1,1},Sch.Barrier{},Sch.Phase{"after"},Sch.System{2,1}]) ++ scenario(~dispatch,[Sch.System{1,1},Sch.System{2,0},Sch.Barrier{}]) ++ scenario(~dispatch,[Sch.System{1,1},Sch.System{1,0}]) ++ scenario(~dispatch,[Sch.System{3,1}]) ++ scenario(~dispatch_fail,[Sch.Phase{"failure"},Sch.System{1,1},Sch.System{2,1},Sch.Barrier{}]))
