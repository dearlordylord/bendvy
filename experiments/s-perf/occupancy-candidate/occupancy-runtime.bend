import Base
import ./occupancy.bend as O
import ./storage.bend as W
import ./readers.bend as R
import ./reader-host.bend as RH
import ./host.bend as H
import ./dispatcher.bend as D
import ./measurement-lifecycle.bend as L
import ./types.bend as T
import ./schedule.bend as K
import ./capture.bend as C
import ./systems.bend as U
import ./host-observations.bend as E

type Context is Data:
  Context{count: U32, iteration: U32}
def host_done(-Schema: Data,-M: Type,-A: Type,-F: Data,-Ledger: Type,-Mode: Data,-Ping: Data,-V: Data,-AV: Data,-LV: Data,bindings: List<&2,E.Binding<Schema>>,name: String,step: String,prior: D.DispatchOutcome,events: List<&2,E.TraceEvent<Schema,V,AV,F,LV,Mode,Ping>>,result: (W.World<Schema,M,A,F,Ledger,Mode> & O.WorldStats) & (RH.Logs<Schema,Ping> & O.LogView<Schema,Ping>)) -> H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV> & (O.WorldStats & O.LogView<Schema,Ping>):
  match result:
    case ((world,ws),(logs,lv)): (H.Host{world,logs,bindings,name,step,prior,events},(ws,lv))
def inspect_host(-Schema: Data,-M: Type,-A: Type,-F: Data,-Ledger: Type,-Mode: Data,-Ping: Data,-V: Data,-AV: Data,-LV: Data,host: H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV>) -> H.Host<Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV> & (O.WorldStats & O.LogView<Schema,Ping>):
  match host:
    case H.Host{world,logs,bindings,name,step,prior,events}: host_done(Schema,M,A,F,Ledger,Mode,Ping,V,AV,LV,bindings,name,step,prior,events,(O.inspect_world(Schema,M,A,F,Ledger,Mode,world),O.inspect_logs(Schema,Ping,logs)))
def motion_host_done(+count: U32,+iteration: U32,target: Maybe<&2,W.Handle<T.MotionSchema>>,pending: Maybe<&2,W.Handle<T.MotionSchema>>,foreign: W.Handle<T.MotionSchema>,result: H.MotionHost() & (O.WorldStats & O.LogView<T.MotionSchema,T.MotionPing>)) -> L.MotionState & (O.WorldStats & (O.LogView<T.MotionSchema,T.MotionPing> & Context)):
  match result:
    case (host,(ws,lv)): (L.MotionState{host,count,iteration,target,pending,foreign},(ws,(lv,Context{count,iteration})))
def inspect_motion(state: L.MotionState) -> L.MotionState & (O.WorldStats & (O.LogView<T.MotionSchema,T.MotionPing> & Context)):
  match state:
    case L.MotionState{host,count,iteration,target,pending,foreign}: motion_host_done(count,iteration,target,pending,foreign,inspect_host(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,host))
def health_host_done(+count: U32,+iteration: U32,target: Maybe<&2,W.Handle<T.HealthSchema>>,pending: Maybe<&2,W.Handle<T.HealthSchema>>,foreign: W.Handle<T.HealthSchema>,result: H.HealthHost() & (O.WorldStats & O.LogView<T.HealthSchema,T.HealthPing>)) -> L.HealthState & (O.WorldStats & (O.LogView<T.HealthSchema,T.HealthPing> & Context)):
  match result:
    case (host,(ws,lv)): (L.HealthState{host,count,iteration,target,pending,foreign},(ws,(lv,Context{count,iteration})))
def inspect_health(state: L.HealthState) -> L.HealthState & (O.WorldStats & (O.LogView<T.HealthSchema,T.HealthPing> & Context)):
  match state:
    case L.HealthState{host,count,iteration,target,pending,foreign}: health_host_done(count,iteration,target,pending,foreign,inspect_host(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,host))
def prefix(schema: String,phase: String,context: Context,clock: R.Clock) -> String:
  match context clock:
    case Context{count,iteration} R.Clock{tick,_,_,frame}: "occupancy:" ++ schema ++ ":" ++ U32.show(count) ++ ":" ++ U32.show(iteration) ++ ":" ++ phase ++ ":" ++ U32.show(tick) ++ ":" ++ U32.show(frame) ++ ":"
def named_reader(include: Bool,name: String,+key: U32,records: List<&2,O.ReaderStats>,tail: String) -> String:
  match include:
    case False{}: tail
    case True{}: name ++ ":" ++ U32.show(key) ++ ":" ++ O.format_optional_reader(O.find_reader(key,records)) ++ ";" ++ tail
def named_readers(systems: List<&2,K.System>,+records: List<&2,O.ReaderStats>) -> String:
  match systems:
    case Nil{}: "end"
    case Con{K.System{key,name,_,_,_,_,reader},tail}: named_reader(reader,name,key,records,named_readers(tail,records))
def runtime_registered(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,state: State,+clock: R.Clock,audit: Maybe<D.Audit>,style: C.Style,escaped: List<&2,W.Handle<Schema>>,observations: List<&2,U.Observation>,nextMode: Maybe<&2,Bool>,stats: O.WorldStats,logs: O.LogView<Schema,Ping>,context: Context,+records: List<&2,O.ReaderStats>,result: (R.Readers & O.Holders) & (K.Registry & List<&2,K.System>)) -> IO(D.Runtime<State,W.Handle<Schema>>):
  match result:
    case ((readers,holds),(registry,systems)):
      do IO<D.Runtime<State,W.Handle<Schema>>>:
        IO.print(prefix(schema,phase,context,clock) ++ "world=" ++ O.format_world(stats) ++ "|" ++ O.format_logs(Schema,Ping,logs) ++ "|readers=" ++ O.format_readers(records) ++ "|holders=" ++ O.format_holders(holds) ++ "|bases=" ++ named_readers(systems,records))
        return D.Runtime{state,registry,readers,clock,audit,style,escaped,observations,nextMode}
def runtime_holders(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,state: State,registry: K.Registry,+clock: R.Clock,audit: Maybe<D.Audit>,style: C.Style,escaped: List<&2,W.Handle<Schema>>,observations: List<&2,U.Observation>,nextMode: Maybe<&2,Bool>,stats: O.WorldStats,logs: O.LogView<Schema,Ping>,context: Context,records: List<&2,O.ReaderStats>,result: R.Readers & O.Holders) -> IO(D.Runtime<State,W.Handle<Schema>>):
  runtime_registered(Schema,Ping,State,schema,phase,state,clock,audit,style,escaped,observations,nextMode,stats,logs,context,records,(result,D.registry_values(registry)))
def runtime_readers(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,state: State,registry: K.Registry,clock: R.Clock,audit: Maybe<D.Audit>,style: C.Style,escaped: List<&2,W.Handle<Schema>>,observations: List<&2,U.Observation>,nextMode: Maybe<&2,Bool>,stats: O.WorldStats,logs: O.LogView<Schema,Ping>,context: Context,result: R.Readers & List<&2,O.ReaderStats>) -> IO(D.Runtime<State,W.Handle<Schema>>):
  match result:
    case (readers,records): runtime_holders(Schema,Ping,State,schema,phase,state,registry,clock,audit,style,escaped,observations,nextMode,stats,logs,context,records,O.inspect_holders(readers))
def runtime_done(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,registry: K.Registry,readers: R.Readers,clock: R.Clock,audit: Maybe<D.Audit>,style: C.Style,escaped: List<&2,W.Handle<Schema>>,observations: List<&2,U.Observation>,nextMode: Maybe<&2,Bool>,result: State & (O.WorldStats & (O.LogView<Schema,Ping> & Context))) -> IO(D.Runtime<State,W.Handle<Schema>>):
  match result:
    case (state,(stats,(+logs,context))): runtime_readers(Schema,Ping,State,schema,phase,state,registry,clock,audit,style,escaped,observations,nextMode,stats,logs,context,O.inspect_readers(Schema,Ping,readers,logs))
def inspect_runtime(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,runtime: D.Runtime<State,W.Handle<Schema>>,inspect: State -> State & (O.WorldStats & (O.LogView<Schema,Ping> & Context))) -> IO(D.Runtime<State,W.Handle<Schema>>):
  match runtime:
    case D.Runtime{state,registry,readers,clock,audit,style,escaped,observations,nextMode}: runtime_done(Schema,Ping,State,schema,phase,registry,readers,clock,audit,style,escaped,observations,nextMode,inspect(state))
def state_done(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,+clock: R.Clock,result: State & (O.WorldStats & (O.LogView<Schema,Ping> & Context))) -> IO(State):
  match result:
    case (state,(stats,(logs,context))):
      do IO<State>:
        IO.print(prefix(schema,phase,context,clock) ++ "world=" ++ O.format_world(stats) ++ "|" ++ O.format_logs(Schema,Ping,logs) ++ "|readers=unavailable-in-state-hook|holders=unavailable-in-state-hook")
        return state
def inspect_state(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,clock: R.Clock,state: State,inspect: State -> State & (O.WorldStats & (O.LogView<Schema,Ping> & Context))) -> IO(State):
  state_done(Schema,Ping,State,schema,phase,clock,inspect(state))
type RunView is Data:
  RunView{key: U32, state: T.ReaderState, boundary: T.ReadBoundary}
def inspect_run(run: Maybe<R.Run>) -> Maybe<R.Run> & Maybe<&2,RunView>:
  match run:
    case None{}: (None{},None{})
    case Some{R.Run{+key,interests,+state,+boundary}}: (Some{R.Run{key,interests,state,boundary}},Some{RunView{key,state,boundary}})
def format_run(-Schema: Data,-Ping: Data,view: Maybe<&2,RunView>,logs: O.LogView<Schema,Ping>) -> String:
  match view logs:
    case None{} _: "null"
    case Some{RunView{key,T.ReaderState{+registered,_,_},T.ReadBoundary{+since,+stream,+thisRun}}} O.LogView{+ping,+removed,+despawned}: U32.show(key) ++ ":" ++ U32.show(registered) ++ ":" ++ U32.show(since) ++ ":" ++ U32.show(stream) ++ ":" ++ U32.show(thisRun) ++ ":" ++ U32.show(O.view_unread(Ping,stream,ping)) ++ ":" ++ U32.show(O.view_unread(W.Handle<Schema>,since,removed)) ++ ":" ++ U32.show(O.view_unread(W.Handle<Schema>,since,despawned)) ++ ":" ++ Bool.show(O.view_lag(Ping,stream,registered,ping)) ++ ":" ++ Bool.show(O.view_lag(W.Handle<Schema>,since,registered,removed)) ++ ":" ++ Bool.show(O.view_lag(W.Handle<Schema>,since,registered,despawned))
def state_run_done(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,clock: R.Clock,result: (State & (O.WorldStats & (O.LogView<Schema,Ping> & Context))) & (Maybe<R.Run> & Maybe<&2,RunView>)) -> IO(State & Maybe<R.Run>):
  match result:
    case ((state,(stats,(+logs,context))),(run,view)):
      do IO<State & Maybe<R.Run>>:
        IO.print(prefix(schema,phase,context,clock) ++ "world=" ++ O.format_world(stats) ++ "|" ++ O.format_logs(Schema,Ping,logs) ++ "|readers=unavailable-in-state-hook|holders=unavailable-in-state-hook|running=" ++ format_run(Schema,Ping,view,logs))
        return (state,run)
def inspect_state_run(-Schema: Data,-Ping: Data,-State: Type,schema: String,phase: String,clock: R.Clock,state: State,run: Maybe<R.Run>,inspect: State -> State & (O.WorldStats & (O.LogView<Schema,Ping> & Context))) -> IO(State & Maybe<R.Run>):
  state_run_done(Schema,Ping,State,schema,phase,clock,(inspect(state),inspect_run(run)))
