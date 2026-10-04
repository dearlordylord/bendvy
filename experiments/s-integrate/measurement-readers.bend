import Base
import ./measurement-lifecycle.bend as L
import ./measurement-bend.bend as M
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./host.bend as H
import ./host-observations.bend as E
import ./host-render.bend as J
import ./dispatcher.bend as D
import ./readers.bend as R
import ./schedule.bend as K
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A

type Systems is Data:
  Systems{spawn:K.System,dispose:K.System,update:K.System,fast:K.System,slow:K.System}
def nodes(slow:Bool,+update:K.System,+fast:K.System,reader:K.System) -> List<&2,K.Node>:
  match slow:
    case True{}: [K.Call{update,K.Normal{}},K.Call{fast,K.Normal{}},K.Call{reader,K.Normal{}}]
    case False{}: [K.Call{update,K.Normal{}},K.Call{fast,K.Normal{}}]

def motion_read_done(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,result:D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>) -> IO(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>):
  match result:
    case D.Invoked{host,audit,run,outcome,clock,escaped,observations}: IO.pure(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>,D.Invoked{L.MotionState{host,count,i,target,pending,foreign},audit,run,outcome,clock,escaped,observations})
def motion_read(system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:L.MotionState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>):
  match owner:
    case L.MotionState{host,count,i,target,pending,foreign}: IO.bind(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>,H.motion_invoke(system,mode,capture,clock,host,audit,run),result => motion_read_done(count,i,target,pending,foreign,result))
def motion_updated_read(-Owner:Type,set:Owner -> T.PositionToken -> U32 -> Owner,pair:Owner & T.Access<T.PositionView>) -> Owner:
  match pair:
    case (owner,T.Found{T.PositionView{values,_}}): set(owner,T.PositionToken{},U32.add(M.first(values),1))
    case (owner,_): owner
def motion_update_body(-Owner:Type,get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,set:Owner -> T.PositionToken -> U32 -> Owner,owner:Owner) -> Owner:
  motion_updated_read(Owner,set,get(owner,T.PositionToken{}))
def motion_published(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:H.MotionHost() & R.Clock) -> IO(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>):
  match pair:
    case (host,clock): IO.pure(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>,D.Invoked{L.MotionState{host,count,i,target,pending,foreign},audit,run,T.Success{},clock,None{},[]})
def motion_commit(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> H.MotionHost(),clock:R.Clock,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,U32>) -> IO(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>):
  match pair:
    case (world,pings): motion_published(count,i,target,pending,foreign,audit,run,H.publish(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,restore(world),clock,H.motion_pings(pings)))
def motion_update(owner:L.MotionState,+clock:R.Clock,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>):
  match owner:
    case L.MotionState{H.Host{world,logs,bindings,name,step,prior,events},count,+i,target,Some{+pending},foreign}:
      motion_commit(count,i,target,Some{pending},foreign,w => H.Host{w,logs,bindings,name,step,prior,events},clock,audit,run,X.storage_commit(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,X.tx_finish_success(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,X.tx_stage_ping(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,motion_update_body(X.Tx<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>>,A.motion_read_main,A.motion_set_main0,X.tx_begin(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<T.Position,T.Velocity,T.Selected>,world,pending)),i)),D.clock_tick(clock)))
    case state: IO.pure(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>,D.Invoked{state,audit,run,T.Failure{7},clock,None{},[]})
def motion_target(owner:L.MotionState) -> L.MotionState:
  match owner:
    case L.MotionState{host,count,i,_,+pending,foreign}: L.MotionState{host,count,i,pending,pending,foreign}
def motion_invoke_case(+system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:L.MotionState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,_,K.Inserts{},_,_,_,_}: motion_update(owner,clock,audit,run)
    case K.System{_,_,K.Dispose{},_,_,_,_}: L.motion_invoke(system,mode,capture,clock,motion_target(owner),audit,run)
    case K.System{_,_,K.Seed{},_,_,_,_}: L.motion_invoke(system,mode,capture,clock,owner,audit,run)
    case _: motion_read(system,mode,capture,clock,owner,audit,run)
def motion_invoke(system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:L.MotionState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>):
  motion_invoke_case(system,mode,capture,clock,owner,audit,run)
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>):
  IO.bind(D.Dispatched<L.MotionState,S.Handle<T.MotionSchema>>,D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>,D.tick(L.MotionState,S.Handle<T.MotionSchema>,L.motion_presence,motion_invoke,L.motion_barrier,L.motion_transition,L.motion_frame,nodes,"MotionLedger","Mode",runtime),result => L.motion_continue(state => IO.pure(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>,state),result))
def motion_events(events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>) -> IO(Unit):
  match events:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{event,tail}:
      do IO<Unit>:
        IO.print(J.render_motion(event))
        motion_events(tail)
def motion_drain_owner(owner:L.MotionState) -> L.MotionState & List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>:
  match owner:
    case L.MotionState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,pending,foreign}: (L.MotionState{H.Host{world,logs,bindings,name,step,prior,[]},count,i,target,pending,foreign},events)
def motion_drained(pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>):
  match pair:
    case (runtime,events):
      do IO<D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>>:
        motion_events(events)
        return runtime
def motion_drain(runtime:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>): motion_drained(L.runtime_read(L.MotionState,S.Handle<T.MotionSchema>,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,motion_drain_owner,runtime))
def motion_iteration(owner:L.MotionState) -> L.MotionState & U32:
  match owner:
    case L.MotionState{host,count,+i,target,pending,foreign}: (L.MotionState{host,count,i,target,pending,foreign},i)
def motion_choose_read(i:U32,systems:Systems,runtime:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>):
  match systems:
    case Systems{_,_,update,fast,slow}: motion_tick(nodes(U32.is_eq(U32.mod(i,4),3),update,fast,slow),runtime)
def motion_iteration_nodes(systems:Systems,pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & U32) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>):
  match pair:
    case (runtime,i): motion_choose_read(i,systems,runtime)
def motion_loops(fuel:Nat,+systems:Systems,runtime:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>):
  match fuel systems:
    case 0n _: IO.pure(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>,runtime)
    case 1n+rest Systems{spawn,dispose,_,_,_}:
      do IO<D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>>:
        seeded : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_tick([K.Call{spawn,K.Normal{}},K.Deferred{}],runtime)
        updated : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_iteration_nodes(systems,L.runtime_read(L.MotionState,S.Handle<T.MotionSchema>,U32,motion_iteration,seeded))
        checked : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_drain(updated)
        disposed : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_tick([K.Call{dispose,K.Normal{}},K.Deferred{}],checked)
        motion_loops(rest,systems,L.runtime_map(L.MotionState,S.Handle<T.MotionSchema>,L.motion_next,disposed))

def motion_registered(restore:K.Registry -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>,spawn:K.System,dispose:K.System,update:K.System,fast:K.System,result:K.Registered) -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & Systems:
  match result:
    case K.Registered{registry,slow}: (restore(registry),Systems{spawn,dispose,update,fast,slow})
def motion_registered_fast(restore:K.Registry -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>,spawn:K.System,dispose:K.System,update:K.System,result:K.Registered) -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & Systems:
  match result:
    case K.Registered{registry,fast}: motion_registered(restore,spawn,dispose,update,fast,K.register(registry,"Slow",K.ReadOnlyLate{},False{},False{},False{},True{}))
def motion_registered_update(restore:K.Registry -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>,spawn:K.System,dispose:K.System,result:K.Registered) -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & Systems:
  match result:
    case K.Registered{registry,update}: motion_registered_fast(restore,spawn,dispose,update,K.register(registry,"Fast",K.Fast{},False{},False{},False{},True{}))
def motion_register(pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)) -> D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & Systems:
  match pair:
    case (D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,next},(spawn,dispose)):
      motion_registered_update(reg => D.Runtime{world,reg,readers,clock,audit,style,escaped,observations,next},spawn,dispose,K.register(registry,"Update",K.Inserts{},False{},False{},False{},False{}))
def motion_final_drain(systems:Systems,runtime:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>):
  match systems:
    case Systems{_,_,_,fast,slow}: motion_tick([K.Call{fast,K.Normal{}},K.Call{slow,K.Normal{}}],runtime)
def motion_run(pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & Systems) -> IO(Unit):
  match pair:
    case (state,+systems):
      do IO<Unit>:
        primed : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_final_drain(systems,state)
        initial : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_drain(primed)
        final : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_loops(64n,systems,initial)
        read : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_final_drain(systems,final)
        clean : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_drain(read)
        checked : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- L.motion_checkpoint("final",clean)
        L.motion_finish(checked)
def motion_start(count:U32) -> IO(Unit):
  IO.bind(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),Unit,L.motion_created(count,I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,M.motion_ledger,I.factory(),T.MotionOn{})),pair => motion_run(motion_register(pair)))

def health_read_done(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,result:D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>) -> IO(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>):
  match result:
    case D.Invoked{host,audit,run,outcome,clock,escaped,observations}: IO.pure(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>,D.Invoked{L.HealthState{host,count,i,target,pending,foreign},audit,run,outcome,clock,escaped,observations})
def health_read(system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:L.HealthState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>):
  match owner:
    case L.HealthState{host,count,i,target,pending,foreign}: IO.bind(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>,H.health_invoke(system,mode,capture,clock,host,audit,run),result => health_read_done(count,i,target,pending,foreign,result))
def health_updated_read(-Owner:Type,set:Owner -> T.VitalsToken -> U32 -> Owner,pair:Owner & T.Access<T.VitalsView>) -> Owner:
  match pair:
    case (owner,T.Found{T.VitalsView{values,_,_}}): set(owner,T.VitalsToken{},U32.add(M.first(values),1))
    case (owner,_): owner
def health_update_body(-Owner:Type,get:Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>,set:Owner -> T.VitalsToken -> U32 -> Owner,owner:Owner) -> Owner:
  health_updated_read(Owner,set,get(owner,T.VitalsToken{}))
def health_published(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:H.HealthHost() & R.Clock) -> IO(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>):
  match pair:
    case (host,clock): IO.pure(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>,D.Invoked{L.HealthState{host,count,i,target,pending,foreign},audit,run,T.Success{},clock,None{},[]})
def health_commit(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> H.HealthHost(),clock:R.Clock,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,U32>) -> IO(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>):
  match pair:
    case (world,pings): health_published(count,i,target,pending,foreign,audit,run,H.publish(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,restore(world),clock,H.health_pings(pings)))
def health_update(owner:L.HealthState,+clock:R.Clock,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>):
  match owner:
    case L.HealthState{H.Host{world,logs,bindings,name,step,prior,events},count,+i,target,Some{+pending},foreign}:
      health_commit(count,i,target,Some{pending},foreign,w => H.Host{w,logs,bindings,name,step,prior,events},clock,audit,run,X.storage_commit(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,X.tx_finish_success(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,X.tx_stage_ping(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,health_update_body(X.Tx<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>>,A.health_read_main,A.health_set_main0,X.tx_begin(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<T.Vitals,T.Armor,T.Tracked>,world,pending)),i)),D.clock_tick(clock)))
    case state: IO.pure(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>,D.Invoked{state,audit,run,T.Failure{7},clock,None{},[]})
def health_target(owner:L.HealthState) -> L.HealthState:
  match owner:
    case L.HealthState{host,count,i,_,+pending,foreign}: L.HealthState{host,count,i,pending,pending,foreign}
def health_invoke_case(+system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:L.HealthState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,_,K.Inserts{},_,_,_,_}: health_update(owner,clock,audit,run)
    case K.System{_,_,K.Dispose{},_,_,_,_}: L.health_invoke(system,mode,capture,clock,health_target(owner),audit,run)
    case K.System{_,_,K.Seed{},_,_,_,_}: L.health_invoke(system,mode,capture,clock,owner,audit,run)
    case _: health_read(system,mode,capture,clock,owner,audit,run)
def health_invoke(system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:L.HealthState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>):
  health_invoke_case(system,mode,capture,clock,owner,audit,run)
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>):
  IO.bind(D.Dispatched<L.HealthState,S.Handle<T.HealthSchema>>,D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>,D.tick(L.HealthState,S.Handle<T.HealthSchema>,L.health_presence,health_invoke,L.health_barrier,L.health_transition,L.health_frame,nodes,"HealthLedger","Mode",runtime),result => L.health_continue(state => IO.pure(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>,state),result))
def health_events(events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>) -> IO(Unit):
  match events:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{event,tail}:
      do IO<Unit>:
        IO.print(J.render_health(event))
        health_events(tail)
def health_drain_owner(owner:L.HealthState) -> L.HealthState & List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>:
  match owner:
    case L.HealthState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,pending,foreign}: (L.HealthState{H.Host{world,logs,bindings,name,step,prior,[]},count,i,target,pending,foreign},events)
def health_drained(pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>):
  match pair:
    case (runtime,events):
      do IO<D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>>:
        health_events(events)
        return runtime
def health_drain(runtime:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>): health_drained(L.runtime_read(L.HealthState,S.Handle<T.HealthSchema>,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,health_drain_owner,runtime))
def health_iteration(owner:L.HealthState) -> L.HealthState & U32:
  match owner:
    case L.HealthState{host,count,+i,target,pending,foreign}: (L.HealthState{host,count,i,target,pending,foreign},i)
def health_choose_read(i:U32,systems:Systems,runtime:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>):
  match systems:
    case Systems{_,_,update,fast,slow}: health_tick(nodes(U32.is_eq(U32.mod(i,4),3),update,fast,slow),runtime)
def health_iteration_nodes(systems:Systems,pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & U32) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>):
  match pair:
    case (runtime,i): health_choose_read(i,systems,runtime)
def health_loops(fuel:Nat,+systems:Systems,runtime:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>):
  match fuel systems:
    case 0n _: IO.pure(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>,runtime)
    case 1n+rest Systems{spawn,dispose,_,_,_}:
      do IO<D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>>:
        seeded : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_tick([K.Call{spawn,K.Normal{}},K.Deferred{}],runtime)
        updated : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_iteration_nodes(systems,L.runtime_read(L.HealthState,S.Handle<T.HealthSchema>,U32,health_iteration,seeded))
        checked : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_drain(updated)
        disposed : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_tick([K.Call{dispose,K.Normal{}},K.Deferred{}],checked)
        health_loops(rest,systems,L.runtime_map(L.HealthState,S.Handle<T.HealthSchema>,L.health_next,disposed))

def health_registered(restore:K.Registry -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>,spawn:K.System,dispose:K.System,update:K.System,fast:K.System,result:K.Registered) -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & Systems:
  match result:
    case K.Registered{registry,slow}: (restore(registry),Systems{spawn,dispose,update,fast,slow})
def health_registered_fast(restore:K.Registry -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>,spawn:K.System,dispose:K.System,update:K.System,result:K.Registered) -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & Systems:
  match result:
    case K.Registered{registry,fast}: health_registered(restore,spawn,dispose,update,fast,K.register(registry,"Slow",K.ReadOnlyLate{},False{},False{},False{},True{}))
def health_registered_update(restore:K.Registry -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>,spawn:K.System,dispose:K.System,result:K.Registered) -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & Systems:
  match result:
    case K.Registered{registry,update}: health_registered_fast(restore,spawn,dispose,update,K.register(registry,"Fast",K.Fast{},False{},False{},False{},True{}))
def health_register(pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)) -> D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & Systems:
  match pair:
    case (D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,next},(spawn,dispose)):
      health_registered_update(reg => D.Runtime{world,reg,readers,clock,audit,style,escaped,observations,next},spawn,dispose,K.register(registry,"Update",K.Inserts{},False{},False{},False{},False{}))
def health_final_drain(systems:Systems,runtime:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>):
  match systems:
    case Systems{_,_,_,fast,slow}: health_tick([K.Call{fast,K.Normal{}},K.Call{slow,K.Normal{}}],runtime)
def health_run(pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & Systems) -> IO(Unit):
  match pair:
    case (state,+systems):
      do IO<Unit>:
        primed : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_final_drain(systems,state)
        initial : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_drain(primed)
        final : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_loops(64n,systems,initial)
        read : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_final_drain(systems,final)
        clean : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_drain(read)
        checked : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- L.health_checkpoint("final",clean)
        L.health_finish(checked)
def health_start(count:U32) -> IO(Unit):
  IO.bind(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),Unit,L.health_created(count,I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,M.health_ledger,I.factory(),T.HealthOn{})),pair => health_run(health_register(pair)))

def choose(schema:U32,count:U32) -> IO(Unit):
  match schema:
    case 0: motion_start(count)
    case 1: health_start(count)
    case _: IO.die(Unit,2,"schema")
def parsed(schema:Maybe<&2,U32>,count:Maybe<&2,U32>) -> IO(Unit):
  match schema count:
    case Some{schema} Some{count}: choose(schema,count)
    case _ _: IO.die(Unit,2,"args")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,_}}}: parsed(U32.read(schema),U32.read(count))
    case _: IO.die(Unit,2,"schema count")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
