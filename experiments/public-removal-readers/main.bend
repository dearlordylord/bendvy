import Base
import ./schema.bend as S
import ../../src/ecs/world.bend as W
import ../../src/ecs/removals.bend as Rm
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/system.bend as Sys

type State is Type:
  State{world: W.World<S.Schema,S.Store,Unit,S.Notice>,fast: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,slow: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,one: W.Handle<S.Schema>,two: W.Handle<S.Schema>,log: String}

def read_result(slow: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,one: W.Handle<S.Schema>,two: W.Handle<S.Schema>,log: String,result: Rm.Run<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected,Unit,String>) -> State:
  match result:
    case Rm.Completed{reader,Sys.Succeeded{world,text}}: State{world,reader,slow,one,two,log ++ "[" ++ text ++ "]"}
    case Rm.Completed{reader,Sys.Failed{world,_}}: State{world,reader,slow,one,two,log ++ "[FAIL]"}
    case Rm.Invalid{reader,world}: State{world,reader,slow,one,two,log ++ "[INVALID]"}

def read(~consume: List<&2,Rm.Record<S.Schema,S.AllToken>> -> Result<&2,&1,Unit,String>,state: State) -> State:
  match state:
    case State{world,fast,slow,one,two,log}: read_result(slow,one,two,log,Rm.run(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,~Unit,~String,~consume,fast,world))
def swap(state: State) -> State:
  match state:
    case State{world,fast,slow,one,two,log}: State{world,slow,fast,one,two,log}
def barrier(state: State) -> State:
  match state:
    case State{world,fast,slow,one,two,log}: State{W.barrier(~S.Schema,~S.Store,~Unit,~S.Notice,world),fast,slow,one,two,log}
def remove(state: State) -> State:
  match state:
    case State{world,fast,slow,+one,two,log}: State{S.finish(S.remove_a(T.begin(~W.World<S.Schema,S.Store,Unit,S.Notice>,~S.Notice,world),one),T.Success{}),fast,slow,one,two,log}
def despawn(state: State) -> State:
  match state:
    case State{world,fast,slow,one,+two,log}: State{S.finish(S.despawn(S.despawn(T.begin(~W.World<S.Schema,S.Store,Unit,S.Notice>,~S.Notice,world),two),two),T.Success{}),fast,slow,one,two,log}
def failed_remove(state: State) -> State:
  match state:
    case State{world,fast,slow,+one,two,log}: State{S.finish(S.remove_a(T.begin(~W.World<S.Schema,S.Store,Unit,S.Notice>,~S.Notice,world),one),T.Failure{Unit{}}),fast,slow,one,two,log}
def skipped(state: State) -> State:
  match state:
    case State{world,fast,slow,one,two,log}: State{world,fast,Rm.skip(~S.Schema,~S.Notice,~S.AllToken,~S.selected,slow),one,two,log}
def disposed_last(log: String,result: Rm.Disposal<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected>) -> IO(Unit):
  match result:
    case Rm.Disposed{W.World{_,_,_,_,_,_,_,_,events,_,_,_,_}}: IO.print(log ++ ";after-last=" ++ Nat.show(Rm.count(~S.Notice,events)))
    case _: IO.print("DISPOSAL_ERROR")
def disposed_first(slow: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,log: String,result: Rm.Disposal<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected>) -> IO(Unit):
  match result:
    case Rm.Disposed{W.World{ns,next,high,live,cap,dep,store,resource,+events,pending,regs,sid,clock}}: disposed_last(log ++ ";after-first=" ++ Nat.show(Rm.count(~S.Notice,events)),Rm.dispose(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,slow,W.World{ns,next,high,live,cap,dep,store,resource,events,pending,regs,sid,clock}))
    case _: IO.print("DISPOSAL_ERROR")
def store_observed(fast: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,slow: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,log: String,result: W.World<S.Schema,S.Store,Unit,S.Notice> & String) -> IO(Unit):
  (world,text) = result
  disposed_first(slow,log ++ "\n" ++ text,Rm.dispose(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,fast,world))
def timing_observed(log: String,result: W.World<S.Schema,S.Store,Unit,S.Notice> & String) -> IO(Unit):
  (world,text) = result
  IO.print(log ++ "\n" ++ text)
def timing_finished(state: State) -> IO(Unit):
  match state:
    case State{world,_,_,_,_,log}: timing_observed(log,W.with_store(~S.Schema,~S.Store,~Unit,~S.Notice,~String,S.store_text,world))
def stale_observed(fast: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,slow: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,log: String,result: W.World<S.Schema,S.Store,Unit,S.Notice> & String) -> IO(Unit):
  match result:
    case (world,"missing"): store_observed(fast,slow,log,W.with_store(~S.Schema,~S.Store,~Unit,~S.Notice,~String,S.store_text,world))
    case _: IO.print("STALE_LOOKUP_BUG")
def finished(state: State) -> IO(Unit):
  match state:
    case State{world,fast,slow,one,two,log}: stale_observed(fast,slow,log,S.lookup_a(world,two))
def scenario(~finish: State -> IO(Unit),state: State) -> IO(Unit):
  s = read(~S.consume,state)
  s = failed_remove(s)
  s = barrier(s)
  s = read(~S.consume,s)
  s = remove(s)
  s = read(~S.consume,s)
  s = barrier(s)
  s = read(~S.consume,s)
  s = read(~S.consume,s)
  s = skipped(s)
  s = despawn(s)
  s = read(~S.consume,s)
  s = barrier(s)
  s = read(~S.reject,s)
  s = read(~S.consume,s)
  s = swap(s)
  s = read(~S.consume,s)
  s = read(~S.consume,s)
  s = swap(s)
  s = remove(s)
  s = barrier(s)
  s = read(~S.consume,s)
  s = failed_remove(s)
  s = barrier(s)
  finish(read(~S.consume,s))

def second_reader(~finish: State -> IO(Unit),one: W.Handle<S.Schema>,two: W.Handle<S.Schema>,fast: Rm.Reader<S.Schema,S.Notice,S.AllToken,S.selected>,registered: Rm.Registered<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected>) -> IO(Unit):
  match registered:
    case Rm.Registered{world,slow}: scenario(~finish,State{world,fast,slow,one,two,""})
    case Rm.Rejected{_}: IO.print("REGISTRATION_ERROR")
def first_reader(~finish: State -> IO(Unit),+one: W.Handle<S.Schema>,+two: W.Handle<S.Schema>,registered: Rm.Registered<S.Schema,S.Store,Unit,S.Notice,S.AllToken,S.selected>) -> IO(Unit):
  match registered:
    case Rm.Registered{world,fast}: second_reader(~finish,one,two,fast,Rm.register(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,world,"slow"))
    case Rm.Rejected{_}: IO.print("REGISTRATION_ERROR")
def seeded(~finish: State -> IO(Unit),one: W.Handle<S.Schema>,two: W.Handle<S.Schema>,world: W.World<S.Schema,S.Store,Unit,S.Notice>) -> IO(Unit):
  first_reader(~finish,one,two,Rm.register(~S.Schema,~S.Store,~Unit,~S.Notice,~S.AllToken,~S.selected,world,"fast"))
def activated(~finish: State -> IO(Unit),+one: W.Handle<S.Schema>,+two: W.Handle<S.Schema>,result: W.World<S.Schema,S.Store,Unit,S.Notice> & W.Status) -> IO(Unit):
  match result:
    case (world,W.Accepted{}): seeded(~finish,one,two,S.seed(world,one,two))
    case _: IO.print("ACTIVATION_ERROR")
def two_reserved(~finish: State -> IO(Unit),+one: W.Handle<S.Schema>,result: W.World<S.Schema,S.Store,Unit,S.Notice> & W.Reservation<S.Schema>) -> IO(Unit):
  match result:
    case (world,W.Reserved{+two}): activated(~finish,one,two,W.activate(~S.Schema,~S.Store,~Unit,~S.Notice,world,two))
    case _: IO.print("RESERVATION_ERROR")
def one_activated(~finish: State -> IO(Unit),one: W.Handle<S.Schema>,result: W.World<S.Schema,S.Store,Unit,S.Notice> & W.Status) -> IO(Unit):
  match result:
    case (world,W.Accepted{}): two_reserved(~finish,one,W.reserve_id(~S.Schema,~S.Store,~Unit,~S.Notice,world))
    case _: IO.print("ACTIVATION_ERROR")
def one_reserved(~finish: State -> IO(Unit),result: W.World<S.Schema,S.Store,Unit,S.Notice> & W.Reservation<S.Schema>) -> IO(Unit):
  match result:
    case (world,W.Reserved{+one}): one_activated(~finish,one,W.activate(~S.Schema,~S.Store,~Unit,~S.Notice,world,one))
    case _: IO.print("RESERVATION_ERROR")
def created(~finish: State -> IO(Unit),result: W.Creation<S.Schema,S.Store,Unit,S.Notice>) -> IO(Unit):
  match result:
    case W.Created{_,world}: one_reserved(~finish,W.reserve_id(~S.Schema,~S.Store,~Unit,~S.Notice,world))
    case _: IO.print("CREATION_ERROR")
def main() -> IO(Unit):
  created(~finished,W.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty,W.factory(),Unit{}))
