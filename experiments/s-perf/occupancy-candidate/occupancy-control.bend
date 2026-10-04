import Base
import ./occupancy.bend as O
import ./streams.bend as S
import ./readers.bend as R
import ./reader-host.bend as H
import ./storage.bend as W
import ./types.bend as T

type State is Type:
  State{logs: H.Logs<T.MotionSchema,U32>,readers: R.Readers,clock: R.Clock}
def snapshot_holders(+label: String,logs: H.Logs<T.MotionSchema,U32>,clock: R.Clock,view: O.LogView<T.MotionSchema,U32>,records: List<&2,O.ReaderStats>,result: R.Readers & O.Holders) -> IO(State):
  match result:
    case (readers,holds):
      do IO<State>:
        IO.print("metric:" ++ label ++ ":" ++ O.format_logs(T.MotionSchema,U32,view))
        IO.print("metric:" ++ label ++ ":readers=" ++ O.format_readers(records))
        IO.print("metric:" ++ label ++ ":holders=" ++ O.format_holders(holds))
        return State{logs,readers,clock}
def snapshot_readers(label: String,logs: H.Logs<T.MotionSchema,U32>,clock: R.Clock,view: O.LogView<T.MotionSchema,U32>,result: R.Readers & List<&2,O.ReaderStats>) -> IO(State):
  match result:
    case (readers,records): snapshot_holders(label,logs,clock,view,records,O.inspect_holders(readers))
def snapshot_logs(label: String,readers: R.Readers,clock: R.Clock,result: H.Logs<T.MotionSchema,U32> & O.LogView<T.MotionSchema,U32>) -> IO(State):
  match result:
    case (logs,+view): snapshot_readers(label,logs,clock,view,O.inspect_readers(T.MotionSchema,U32,readers,view))
def snapshot(label: String,state: State) -> IO(State):
  match state:
    case State{logs,readers,clock}: snapshot_logs(label,readers,clock,O.inspect_logs(T.MotionSchema,U32,logs))
def append(state: State,values: List<&2,U32>) -> State:
  match state:
    case State{logs,readers,R.Clock{+tick,start,retained,frame}}:
      +next = U32.add(tick,1)
      State{H.append_ping(T.MotionSchema,U32,logs,next,values),readers,R.Clock{next,start,retained,frame}}
def outcome(success: Bool) -> T.Outcome:
  match success:
    case True{}: T.Success{}
    case False{}: T.Failure{9}
def read_done(label: String,success: Bool,readers: R.Readers,clock: R.Clock,result: H.Read<T.MotionSchema,U32>) -> IO(State):
  match result:
    case H.Read{logs,run,H.Delivery{_,messages,removed,despawned,ml,rl,dl}}:
      do IO<State>:
        IO.print("trace:" ++ label ++ ":" ++ U32.show(O.length(U32,messages)) ++ ":" ++ U32.show(O.length(W.Handle<T.MotionSchema>,removed)) ++ ":" ++ U32.show(O.length(W.Handle<T.MotionSchema>,despawned)) ++ ":" ++ Bool.show(ml) ++ ":" ++ Bool.show(rl) ++ ":" ++ Bool.show(dl))
        return State{logs,R.complete(readers,run,outcome(success)),clock}
def read_started(label: String,success: Bool,logs: H.Logs<T.MotionSchema,U32>,result: R.Started) -> IO(State):
  match result:
    case R.Started{readers,clock,run}: read_done(label,success,readers,clock,H.read(T.MotionSchema,U32,logs,run))
def read(label: String,key: U32,success: Bool,state: State) -> IO(State):
  match state:
    case State{logs,readers,clock}: read_started(label,success,logs,R.begin(readers,key,R.Interests{True{},[0],True{}},clock))
def trimmed(result: H.Framed<T.MotionSchema,U32>) -> State:
  match result:
    case H.Framed{logs,readers,clock}: State{logs,readers,clock}
def trim(state: State) -> State:
  match state:
    case State{logs,readers,+clock}: trimmed(H.frame(T.MotionSchema,U32,logs,readers,R.Frame{clock,None{},4}))
def lifecycle(state: State) -> State:
  match state:
    case State{logs,readers,+clock}: State{H.append_changes(T.MotionSchema,U32,logs,2,[W.MainRemoved{W.Handle{7,1}},W.MainRemoved{W.Handle{7,2}},W.Despawned{W.Handle{7,3}}]),readers,clock}
def skip(state: State,key: U32) -> State:
  match state:
    case State{logs,readers,R.Clock{+tick,start,retained,frame}}: State{logs,R.skip(readers,key,tick),R.Clock{tick,start,retained,frame}}
def buffer_print(label: String,result: S.Buffer<U32> & O.BufferView<U32>) -> IO(Unit):
  match result:
    case (_,view): IO.print("metric:" ++ label ++ ":" ++ O.format_view(U32,view))
def main() -> IO(Unit):
  do IO<Unit>:
    zero : State <- read("registered-zero",4,False{},State{H.initial(T.MotionSchema,U32,4),R.initial(),R.clock()})
    zero : State <- snapshot("registered-zero",zero)
    s : State = State{H.initial(T.MotionSchema,U32,4),R.initial(),R.clock()}
    s : State = append(append(s,[10,11,12]),[20])
    s : State = lifecycle(s)
    s : State <- snapshot("rear",s)
    s : State <- read("failed1",1,False{},s)
    s : State <- read("failed2",2,False{},s)
    s : State <- snapshot("two-holders",s)
    s : State = trim(s)
    s : State <- snapshot("front",s)
    s : State = trim(append(s,[30,31,32]))
    s : State = trim(append(s,[40,41,42]))
    s : State <- snapshot("dropped",s)
    s : State <- read("late-failure",3,False{},s)
    s : State <- snapshot("late",s)
    s : State <- read("retry-success",1,True{},s)
    s : State <- snapshot("empty-unread-nonzero",s)
    s : State = skip(s,2)
    s : State <- snapshot("skip",s)
    buffer_print("malformed",O.inspect_buffer(U32,S.Buffer{4,99,0,[S.Batch{1,2,[7]}],[S.Batch{2,1,[8]}]}))
    buffer_print("whole-batch",O.inspect_buffer(U32,S.trim_buffer(U32,S.append_buffer(U32,S.Buffer{2,0,0,[],[]},1,[1,2,3]),0,[0])))
    buffer_print("unit-batches",O.inspect_buffer(U32,S.trim_buffer(U32,S.append_units(U32,[1,2,3],1,S.Buffer{2,0,0,[],[]}),0,[0])))
    return Unit{}
