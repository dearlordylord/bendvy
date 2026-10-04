import Base
import ./measurement-bend.bend as M
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./query.bend as Q
import ./observations.bend as O
import ./payload.bend as P
import ./host.bend as H
import ./host-render.bend as J
import ./host-observations.bend as E
import ./dispatcher.bend as D
import ./readers.bend as R
import ./schedule.bend as K
import ./capture.bend as LC

def index_case(kind:U32,+count:U32) -> U32:
  match kind:
    case 0: 0
    case 1: U32.div(count,2)
    case _: U32.sub(count,1)

type HostRestMotion is Type:
  HostRestMotion{host:H.MotionHost(),count:U32,iteration:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>}
# State includes only actual owners and returned issued handles.
type MotionState is Type:
  MotionState{host:H.MotionHost(),count:U32,iteration:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>}
def motion_presence_pair(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,pair:H.MotionHost() & D.Presence) -> MotionState & D.Presence:
  match pair:
    case (host,p): (MotionState{host,count,i,target,pending,foreign},p)
def motion_presence(owner:MotionState) -> MotionState & D.Presence:
  match owner:
    case MotionState{host,count,i,target,pending,foreign}: motion_presence_pair(count,i,target,pending,foreign,H.motion_presence(host))
def motion_frame_pair(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,pair:H.MotionHost() & (R.Readers & R.Clock)) -> MotionState & (R.Readers & R.Clock):
  match pair:
    case (host,p): (MotionState{host,count,i,target,pending,foreign},p)
def motion_frame(owner:MotionState,readers:R.Readers,boundary:R.Frame) -> MotionState & (R.Readers & R.Clock):
  match owner:
    case MotionState{host,count,i,target,pending,foreign}: motion_frame_pair(count,i,target,pending,foreign,H.motion_frame(host,readers,boundary))
def motion_clock_pair(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,pair:H.MotionHost() & R.Clock) -> MotionState & R.Clock:
  match pair:
    case (host,clock): (MotionState{host,count,i,target,pending,foreign},clock)
def motion_barrier(owner:MotionState,clock:R.Clock) -> MotionState & R.Clock:
  match owner:
    case MotionState{host,count,i,target,pending,foreign}: motion_clock_pair(count,i,target,pending,foreign,H.motion_barrier(host,clock))
def motion_transition(owner:MotionState,pending:Maybe<&2,Bool>,clock:R.Clock) -> MotionState & R.Clock:
  match owner:
    case MotionState{host,count,i,target,handle,foreign}: motion_clock_pair(count,i,target,handle,foreign,H.motion_transition(host,pending,clock))
def motion_reserve_world(owner:MotionState) -> MotionState:
  match owner:
    case MotionState{host,count,+i,target,_,foreign}: MotionState{H.motion_reserve(host,"pending",S.Bundle{M.motion_main(i,True{}),None{},None{}}),count,i,target,None{},foreign}
def motion_find_pending(owner:MotionState) -> MotionState:
  match owner:
    case MotionState{H.Host{world,logs,+bindings,name,step,prior,events},count,i,target,_,foreign}:
      MotionState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,H.binding_find(T.MotionSchema,"pending",List.reverse(&2,E.Binding<T.MotionSchema>,bindings)),foreign}

def motion_command(result:T.CommandResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match result:
    case T.CommandQueued{world}: world
    case T.CommandMissing{world,_}: world
def motion_dispose_host(owner:H.MotionHost(),+handle:S.Handle<T.MotionSchema>) -> H.MotionHost():
  match owner:
    case H.Host{world,logs,bindings,name,step,prior,events}:
      H.Host{motion_command(C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,motion_command(C.remove_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle)),handle)),logs,bindings,name,step,prior,events}
def motion_dispose(owner:MotionState) -> MotionState:
  match owner:
    case MotionState{host,count,i,Some{+target},pending,foreign}: MotionState{motion_dispose_host(host,target),count,i,Some{target},pending,foreign}
    case state: state
def motion_invoke(system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:MotionState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionState,S.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,_,K.Seed{},_,_,_,_}: IO.pure(D.Invoked<MotionState,S.Handle<T.MotionSchema>>,D.Invoked{motion_find_pending(motion_reserve_world(owner)),audit,run,T.Success{},clock,None{},[]})
    case K.System{_,_,K.Dispose{},_,_,_,_}: IO.pure(D.Invoked<MotionState,S.Handle<T.MotionSchema>>,D.Invoked{motion_dispose(owner),audit,run,T.Success{},clock,None{},[]})
    case _: IO.pure(D.Invoked<MotionState,S.Handle<T.MotionSchema>>,D.Invoked{owner,audit,run,T.Failure{7},clock,None{},[]})
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Dispatched<MotionState,S.Handle<T.MotionSchema>>):
  D.tick(MotionState,S.Handle<T.MotionSchema>,motion_presence,motion_invoke,motion_barrier,motion_transition,motion_frame,nodes,"MotionLedger","Mode",runtime)
def motion_continue(next:D.Runtime<MotionState,S.Handle<T.MotionSchema>> -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>>),result:D.Dispatched<MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>>):
  match result:
    case D.Dispatched{runtime,D.Complete{}}: next(runtime)
    case _: IO.die(D.Runtime<MotionState,S.Handle<T.MotionSchema>>,3,"dispatch failed")
def motion_step(nodes:List<&2,K.Node>,runtime:D.Runtime<MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>>):
  IO.bind(D.Dispatched<MotionState,S.Handle<T.MotionSchema>>,D.Runtime<MotionState,S.Handle<T.MotionSchema>>,motion_tick(nodes,runtime),result => motion_continue(state => IO.pure(D.Runtime<MotionState,S.Handle<T.MotionSchema>>,state),result))

type HostRestHealth is Type:
  HostRestHealth{host:H.HealthHost(),count:U32,iteration:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>}
# State includes only actual owners and returned issued handles.
type HealthState is Type:
  HealthState{host:H.HealthHost(),count:U32,iteration:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>}
def health_presence_pair(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,pair:H.HealthHost() & D.Presence) -> HealthState & D.Presence:
  match pair:
    case (host,p): (HealthState{host,count,i,target,pending,foreign},p)
def health_presence(owner:HealthState) -> HealthState & D.Presence:
  match owner:
    case HealthState{host,count,i,target,pending,foreign}: health_presence_pair(count,i,target,pending,foreign,H.health_presence(host))
def health_frame_pair(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,pair:H.HealthHost() & (R.Readers & R.Clock)) -> HealthState & (R.Readers & R.Clock):
  match pair:
    case (host,p): (HealthState{host,count,i,target,pending,foreign},p)
def health_frame(owner:HealthState,readers:R.Readers,boundary:R.Frame) -> HealthState & (R.Readers & R.Clock):
  match owner:
    case HealthState{host,count,i,target,pending,foreign}: health_frame_pair(count,i,target,pending,foreign,H.health_frame(host,readers,boundary))
def health_clock_pair(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,pair:H.HealthHost() & R.Clock) -> HealthState & R.Clock:
  match pair:
    case (host,clock): (HealthState{host,count,i,target,pending,foreign},clock)
def health_barrier(owner:HealthState,clock:R.Clock) -> HealthState & R.Clock:
  match owner:
    case HealthState{host,count,i,target,pending,foreign}: health_clock_pair(count,i,target,pending,foreign,H.health_barrier(host,clock))
def health_transition(owner:HealthState,pending:Maybe<&2,Bool>,clock:R.Clock) -> HealthState & R.Clock:
  match owner:
    case HealthState{host,count,i,target,handle,foreign}: health_clock_pair(count,i,target,handle,foreign,H.health_transition(host,pending,clock))
def health_reserve_world(owner:HealthState) -> HealthState:
  match owner:
    case HealthState{host,count,+i,target,_,foreign}: HealthState{H.health_reserve(host,"pending",S.Bundle{M.health_main(i,True{}),None{},None{}}),count,i,target,None{},foreign}
def health_find_pending(owner:HealthState) -> HealthState:
  match owner:
    case HealthState{H.Host{world,logs,+bindings,name,step,prior,events},count,i,target,_,foreign}:
      HealthState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,H.binding_find(T.HealthSchema,"pending",List.reverse(&2,E.Binding<T.HealthSchema>,bindings)),foreign}

def health_command(result:T.CommandResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match result:
    case T.CommandQueued{world}: world
    case T.CommandMissing{world,_}: world
def health_dispose_host(owner:H.HealthHost(),+handle:S.Handle<T.HealthSchema>) -> H.HealthHost():
  match owner:
    case H.Host{world,logs,bindings,name,step,prior,events}:
      H.Host{health_command(C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,health_command(C.remove_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle)),handle)),logs,bindings,name,step,prior,events}
def health_dispose(owner:HealthState) -> HealthState:
  match owner:
    case HealthState{host,count,i,Some{+target},pending,foreign}: HealthState{health_dispose_host(host,target),count,i,Some{target},pending,foreign}
    case state: state
def health_invoke(system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:HealthState,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthState,S.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,_,K.Seed{},_,_,_,_}: IO.pure(D.Invoked<HealthState,S.Handle<T.HealthSchema>>,D.Invoked{health_find_pending(health_reserve_world(owner)),audit,run,T.Success{},clock,None{},[]})
    case K.System{_,_,K.Dispose{},_,_,_,_}: IO.pure(D.Invoked<HealthState,S.Handle<T.HealthSchema>>,D.Invoked{health_dispose(owner),audit,run,T.Success{},clock,None{},[]})
    case _: IO.pure(D.Invoked<HealthState,S.Handle<T.HealthSchema>>,D.Invoked{owner,audit,run,T.Failure{7},clock,None{},[]})
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Dispatched<HealthState,S.Handle<T.HealthSchema>>):
  D.tick(HealthState,S.Handle<T.HealthSchema>,health_presence,health_invoke,health_barrier,health_transition,health_frame,nodes,"HealthLedger","Mode",runtime)
def health_continue(next:D.Runtime<HealthState,S.Handle<T.HealthSchema>> -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>>),result:D.Dispatched<HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>>):
  match result:
    case D.Dispatched{runtime,D.Complete{}}: next(runtime)
    case _: IO.die(D.Runtime<HealthState,S.Handle<T.HealthSchema>>,3,"dispatch failed")
def health_step(nodes:List<&2,K.Node>,runtime:D.Runtime<HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>>):
  IO.bind(D.Dispatched<HealthState,S.Handle<T.HealthSchema>>,D.Runtime<HealthState,S.Handle<T.HealthSchema>>,health_tick(nodes,runtime),result => health_continue(state => IO.pure(D.Runtime<HealthState,S.Handle<T.HealthSchema>>,state),result))

def mapped(-W:Type,-Out:Type,-V:Data,restore:W -> Out,pair:W & V) -> Out & V:
  match pair:
    case (world,value): (restore(world),value)
def runtime_map(-W:Type,-Handle:Data,apply:W -> W,state:D.Runtime<W,Handle>) -> D.Runtime<W,Handle>:
  match state:
    case D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}: D.Runtime{apply(world),registry,readers,clock,audit,style,escaped,observations,nextMode}
def runtime_read(-W:Type,-Handle:Data,-V:Data,read:W -> W & V,state:D.Runtime<W,Handle>) -> D.Runtime<W,Handle> & V:
  match state:
    case D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode}: mapped(W,D.Runtime<W,Handle>,V,world => D.Runtime{world,registry,readers,clock,audit,style,escaped,observations,nextMode},read(world))
def access_kind(-A:Data,value:T.Access<A>) -> U32:
  match value:
    case T.Missing{}: 0
    case T.Mismatch{}: 1
    case T.Found{_}: 2

def motion_host_handles(owner:MotionState) -> MotionState & List<&2,S.Handle<T.MotionSchema>>:
  match owner:
    case MotionState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,pending,foreign}:
      mapped(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,MotionState,List<&2,S.Handle<T.MotionSchema>>,w => MotionState{H.Host{w,logs,bindings,name,step,prior,events},count,i,target,pending,foreign},M.motion_handles(world))
def motion_prepare_pair(pair:MotionState & List<&2,S.Handle<T.MotionSchema>>) -> MotionState:
  match pair:
    case (MotionState{host,+count,+i,_,pending,foreign},handles): MotionState{host,count,i,List.get(&2,S.Handle<T.MotionSchema>,handles,U32.to_nat(index_case(U32.mod(i,3),count))),pending,foreign}
def motion_prepare(owner:MotionState) -> MotionState: motion_prepare_pair(motion_host_handles(owner))
def motion_lookup_value(pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<S.Handle<T.MotionSchema>>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & U32:
  match pair:
    case (world,value): (world,access_kind(S.Handle<T.MotionSchema>,value))
def motion_lookup(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,handle:Maybe<&2,S.Handle<T.MotionSchema>>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & U32:
  match handle:
    case None{}: (world,99)
    case Some{handle}: motion_lookup_value(Q.lookup(T.MotionSchema,T.Position,T.Velocity,T.Selected,Unit,Unit,Unit,S.Handle<T.MotionSchema>,T.MotionLedger,T.MotionMode,M.keep(~T.Position),M.keep(~T.Velocity),M.handle_client(~T.MotionSchema,~T.Selected),Q.Required{},world,handle))
def motion_observation3(p:U32,t:U32,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Four:
  match pair:
    case (world,f): (world,T.Four{p,t,f,0})
def motion_observation2(p:U32,foreign:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Four:
  match pair:
    case (world,t): motion_observation3(p,t,motion_lookup(world,Some{foreign}))
def motion_observation1(target:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Four:
  match pair:
    case (world,p): motion_observation2(p,foreign,motion_lookup(world,target))
def motion_views(count:U32,+i:U32,+target:Maybe<&2,S.Handle<T.MotionSchema>>,+pending:Maybe<&2,S.Handle<T.MotionSchema>>,+foreign:S.Handle<T.MotionSchema>,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> H.MotionHost(),query:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,lookups:T.Four,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> MotionState & String:
  match pair:
    case (world,view): (MotionState{restore(world),count,i,target,pending,foreign},"{\"iteration\":" ++ U32.show(i) ++ ",\"pending\":" ++ J.render_optional(S.Handle<T.MotionSchema>,J.render_handle(T.MotionSchema),pending) ++ ",\"target\":" ++ J.render_optional(S.Handle<T.MotionSchema>,J.render_handle(T.MotionSchema),target) ++ ",\"foreign\":" ++ J.render_handle(T.MotionSchema,foreign) ++ ",\"lookups\":" ++ J.render_four(lookups) ++ ",\"query\":" ++ J.render_list(O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,J.render_query(T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,J.render_position,J.render_velocity,J.render_selected),query) ++ ",\"world\":" ++ J.render_world(T.PositionView,T.VelocityView,T.Selected,J.render_position,J.render_velocity,J.render_selected,T.LedgerView,T.MotionMode,J.render_ledger,J.render_motion_mode,view) ++ "}")
def motion_queried(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> H.MotionHost(),kinds:T.Four,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> MotionState & String:
  match pair:
    case (world,query): motion_views(count,i,target,pending,foreign,restore,query,kinds,O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world))
def motion_observed(count:U32,i:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> H.MotionHost(),pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Four) -> MotionState & String:
  match pair:
    case (world,kinds): motion_queried(count,i,target,pending,foreign,restore,kinds,Q.each(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,T.MotionLedger,T.MotionMode,P.position_get,P.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),Q.Required{},world))
def motion_observe(owner:MotionState) -> MotionState & String:
  match owner:
    case MotionState{H.Host{world,logs,bindings,name,step,prior,events},count,i,+target,+pending,+foreign}:
      motion_observed(count,i,target,pending,foreign,w => H.Host{w,logs,bindings,name,step,prior,events},motion_observation1(target,foreign,motion_lookup(world,pending)))
def motion_printed(phase:String,pair:D.Runtime<MotionState,S.Handle<T.MotionSchema>> & String) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>>):
  match pair:
    case (runtime,value):
      do IO<D.Runtime<MotionState,S.Handle<T.MotionSchema>>>:
        IO.print("{\"phase\":" ++ J.render_string(phase) ++ ",\"observation\":" ++ value ++ "}")
        return runtime
def motion_checkpoint(phase:String,runtime:D.Runtime<MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>>):
  motion_printed(phase,runtime_read(MotionState,S.Handle<T.MotionSchema>,String,motion_observe,runtime))
def motion_next(owner:MotionState) -> MotionState:
  match owner:
    case MotionState{host,count,i,target,pending,foreign}: MotionState{host,count,U32.add(i,1),target,pending,foreign}
def motion_loops(fuel:Nat,+reserve:K.System,+dispose:K.System,runtime:D.Runtime<MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>>):
  match fuel:
    case 0n: IO.pure(D.Runtime<MotionState,S.Handle<T.MotionSchema>>,runtime)
    case 1n+rest:
      do IO<D.Runtime<MotionState,S.Handle<T.MotionSchema>>>:
        pending : D.Runtime<MotionState,S.Handle<T.MotionSchema>> <- motion_step([K.Call{reserve,K.Normal{}}],runtime_map(MotionState,S.Handle<T.MotionSchema>,motion_prepare,runtime))
        checked : D.Runtime<MotionState,S.Handle<T.MotionSchema>> <- motion_checkpoint("pending",pending)
        live : D.Runtime<MotionState,S.Handle<T.MotionSchema>> <- motion_step([K.Deferred{}],checked)
        checked : D.Runtime<MotionState,S.Handle<T.MotionSchema>> <- motion_checkpoint("live",live)
        gone : D.Runtime<MotionState,S.Handle<T.MotionSchema>> <- motion_step([K.Call{dispose,K.Normal{}},K.Deferred{}],checked)
        checked : D.Runtime<MotionState,S.Handle<T.MotionSchema>> <- motion_checkpoint("disposed",gone)
        motion_loops(rest,reserve,dispose,runtime_map(MotionState,S.Handle<T.MotionSchema>,motion_next,checked))
def motion_ready(+count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,foreign:S.Handle<T.MotionSchema>,+reserve:K.System,registered:K.Registered) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match registered:
    case K.Registered{registry,+dispose}:
      IO.bind(D.Runtime<MotionState,S.Handle<T.MotionSchema>>,D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),motion_step([K.Deferred{}],D.Runtime{MotionState{H.initial(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,"motion",M.motion_seed(U32.to_nat(count),0,False{},world),65536),count,0,None{},None{},foreign},registry,R.initial(),R.clock(),None{},LC.Returned{},[],[],None{}}),state => IO.pure(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),(state,(reserve,dispose))))
def motion_register(count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,foreign:S.Handle<T.MotionSchema>,registered:K.Registered) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match registered:
    case K.Registered{registry,reserve}: motion_ready(count,world,foreign,reserve,K.register(registry,"Dispose",K.Dispose{},False{},False{},False{},False{}))
def motion_foreign_reserved(count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match result:
    case T.Reserved{_,foreign}: motion_register(count,world,foreign,K.register(K.initial(),"Reserve",K.Seed{},False{},False{},False{},False{}))
    case _: IO.die(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),4,"foreign reserve failed")
def motion_foreign(count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match result:
    case T.Created{_,beta}: motion_foreign_reserved(count,world,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,S.Bundle{M.motion_main(999,True{}),None{},None{}}))
    case _: IO.die(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),4,"foreign creation failed")
def motion_created(count:U32,result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match result:
    case T.Created{factory,world}: motion_foreign(count,world,I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,M.motion_ledger,factory,T.MotionOn{}))
    case _: IO.die(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),4,"creation failed")
def motion_finish_counts(+clock:R.Clock,pair:K.Registry & List<&2,E.Count>) -> IO(Unit):
  match pair:
    case (_,counts): IO.print("{\"counts\":" ++ J.render_list(E.Count,J.render_count,counts) ++ ",\"tick\":" ++ U32.show(D.clock_tick(clock)) ++ ",\"frames\":" ++ U32.show(H.clock_frame(clock)) ++ "}")
def motion_finish(state:D.Runtime<MotionState,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match state:
    case D.Runtime{_,registry,_,clock,_,_,_,_,_}: motion_finish_counts(clock,H.count_registry(registry))
def motion_run(pair:D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)) -> IO(Unit):
  match pair:
    case (state,(reserve,dispose)): IO.bind(D.Runtime<MotionState,S.Handle<T.MotionSchema>>,Unit,motion_loops(64n,reserve,dispose,state),motion_finish)
def motion_start(count:U32) -> IO(Unit):
  IO.bind(D.Runtime<MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),Unit,motion_created(count,I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,M.motion_ledger,I.factory(),T.MotionOn{})),motion_run)

def health_host_handles(owner:HealthState) -> HealthState & List<&2,S.Handle<T.HealthSchema>>:
  match owner:
    case HealthState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,pending,foreign}:
      mapped(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,HealthState,List<&2,S.Handle<T.HealthSchema>>,w => HealthState{H.Host{w,logs,bindings,name,step,prior,events},count,i,target,pending,foreign},M.health_handles(world))
def health_prepare_pair(pair:HealthState & List<&2,S.Handle<T.HealthSchema>>) -> HealthState:
  match pair:
    case (HealthState{host,+count,+i,_,pending,foreign},handles): HealthState{host,count,i,List.get(&2,S.Handle<T.HealthSchema>,handles,U32.to_nat(index_case(U32.mod(i,3),count))),pending,foreign}
def health_prepare(owner:HealthState) -> HealthState: health_prepare_pair(health_host_handles(owner))
def health_lookup_value(pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<S.Handle<T.HealthSchema>>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & U32:
  match pair:
    case (world,value): (world,access_kind(S.Handle<T.HealthSchema>,value))
def health_lookup(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,handle:Maybe<&2,S.Handle<T.HealthSchema>>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & U32:
  match handle:
    case None{}: (world,99)
    case Some{handle}: health_lookup_value(Q.lookup(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,Unit,Unit,Unit,S.Handle<T.HealthSchema>,T.HealthLedger,T.HealthMode,M.keep(~T.Vitals),M.keep(~T.Armor),M.handle_client(~T.HealthSchema,~T.Tracked),Q.Required{},world,handle))
def health_observation3(p:U32,t:U32,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Four:
  match pair:
    case (world,f): (world,T.Four{p,t,f,0})
def health_observation2(p:U32,foreign:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Four:
  match pair:
    case (world,t): health_observation3(p,t,health_lookup(world,Some{foreign}))
def health_observation1(target:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Four:
  match pair:
    case (world,p): health_observation2(p,foreign,health_lookup(world,target))
def health_views(count:U32,+i:U32,+target:Maybe<&2,S.Handle<T.HealthSchema>>,+pending:Maybe<&2,S.Handle<T.HealthSchema>>,+foreign:S.Handle<T.HealthSchema>,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> H.HealthHost(),query:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,lookups:T.Four,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> HealthState & String:
  match pair:
    case (world,view): (HealthState{restore(world),count,i,target,pending,foreign},"{\"iteration\":" ++ U32.show(i) ++ ",\"pending\":" ++ J.render_optional(S.Handle<T.HealthSchema>,J.render_handle(T.HealthSchema),pending) ++ ",\"target\":" ++ J.render_optional(S.Handle<T.HealthSchema>,J.render_handle(T.HealthSchema),target) ++ ",\"foreign\":" ++ J.render_handle(T.HealthSchema,foreign) ++ ",\"lookups\":" ++ J.render_four(lookups) ++ ",\"query\":" ++ J.render_list(O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,J.render_query(T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,J.render_vitals,J.render_armor,J.render_tracked),query) ++ ",\"world\":" ++ J.render_world(T.VitalsView,T.ArmorView,T.Tracked,J.render_vitals,J.render_armor,J.render_tracked,T.LedgerView,T.HealthMode,J.render_ledger,J.render_health_mode,view) ++ "}")
def health_queried(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> H.HealthHost(),kinds:T.Four,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> HealthState & String:
  match pair:
    case (world,query): health_views(count,i,target,pending,foreign,restore,query,kinds,O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world))
def health_observed(count:U32,i:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> H.HealthHost(),pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Four) -> HealthState & String:
  match pair:
    case (world,kinds): health_queried(count,i,target,pending,foreign,restore,kinds,Q.each(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,T.HealthLedger,T.HealthMode,P.vitals_get,P.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),Q.Required{},world))
def health_observe(owner:HealthState) -> HealthState & String:
  match owner:
    case HealthState{H.Host{world,logs,bindings,name,step,prior,events},count,i,+target,+pending,+foreign}:
      health_observed(count,i,target,pending,foreign,w => H.Host{w,logs,bindings,name,step,prior,events},health_observation1(target,foreign,health_lookup(world,pending)))
def health_printed(phase:String,pair:D.Runtime<HealthState,S.Handle<T.HealthSchema>> & String) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>>):
  match pair:
    case (runtime,value):
      do IO<D.Runtime<HealthState,S.Handle<T.HealthSchema>>>:
        IO.print("{\"phase\":" ++ J.render_string(phase) ++ ",\"observation\":" ++ value ++ "}")
        return runtime
def health_checkpoint(phase:String,runtime:D.Runtime<HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>>):
  health_printed(phase,runtime_read(HealthState,S.Handle<T.HealthSchema>,String,health_observe,runtime))
def health_next(owner:HealthState) -> HealthState:
  match owner:
    case HealthState{host,count,i,target,pending,foreign}: HealthState{host,count,U32.add(i,1),target,pending,foreign}
def health_loops(fuel:Nat,+reserve:K.System,+dispose:K.System,runtime:D.Runtime<HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>>):
  match fuel:
    case 0n: IO.pure(D.Runtime<HealthState,S.Handle<T.HealthSchema>>,runtime)
    case 1n+rest:
      do IO<D.Runtime<HealthState,S.Handle<T.HealthSchema>>>:
        pending : D.Runtime<HealthState,S.Handle<T.HealthSchema>> <- health_step([K.Call{reserve,K.Normal{}}],runtime_map(HealthState,S.Handle<T.HealthSchema>,health_prepare,runtime))
        checked : D.Runtime<HealthState,S.Handle<T.HealthSchema>> <- health_checkpoint("pending",pending)
        live : D.Runtime<HealthState,S.Handle<T.HealthSchema>> <- health_step([K.Deferred{}],checked)
        checked : D.Runtime<HealthState,S.Handle<T.HealthSchema>> <- health_checkpoint("live",live)
        gone : D.Runtime<HealthState,S.Handle<T.HealthSchema>> <- health_step([K.Call{dispose,K.Normal{}},K.Deferred{}],checked)
        checked : D.Runtime<HealthState,S.Handle<T.HealthSchema>> <- health_checkpoint("disposed",gone)
        health_loops(rest,reserve,dispose,runtime_map(HealthState,S.Handle<T.HealthSchema>,health_next,checked))
def health_ready(+count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,foreign:S.Handle<T.HealthSchema>,+reserve:K.System,registered:K.Registered) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match registered:
    case K.Registered{registry,+dispose}:
      IO.bind(D.Runtime<HealthState,S.Handle<T.HealthSchema>>,D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),health_step([K.Deferred{}],D.Runtime{HealthState{H.initial(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,"health",M.health_seed(U32.to_nat(count),0,False{},world),65536),count,0,None{},None{},foreign},registry,R.initial(),R.clock(),None{},LC.Returned{},[],[],None{}}),state => IO.pure(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),(state,(reserve,dispose))))
def health_register(count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,foreign:S.Handle<T.HealthSchema>,registered:K.Registered) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match registered:
    case K.Registered{registry,reserve}: health_ready(count,world,foreign,reserve,K.register(registry,"Dispose",K.Dispose{},False{},False{},False{},False{}))
def health_foreign_reserved(count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match result:
    case T.Reserved{_,foreign}: health_register(count,world,foreign,K.register(K.initial(),"Reserve",K.Seed{},False{},False{},False{},False{}))
    case _: IO.die(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),4,"foreign reserve failed")
def health_foreign(count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match result:
    case T.Created{_,beta}: health_foreign_reserved(count,world,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,S.Bundle{M.health_main(999,True{}),None{},None{}}))
    case _: IO.die(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),4,"foreign creation failed")
def health_created(count:U32,result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match result:
    case T.Created{factory,world}: health_foreign(count,world,I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,M.health_ledger,factory,T.HealthOn{}))
    case _: IO.die(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),4,"creation failed")
def health_finish_counts(+clock:R.Clock,pair:K.Registry & List<&2,E.Count>) -> IO(Unit):
  match pair:
    case (_,counts): IO.print("{\"counts\":" ++ J.render_list(E.Count,J.render_count,counts) ++ ",\"tick\":" ++ U32.show(D.clock_tick(clock)) ++ ",\"frames\":" ++ U32.show(H.clock_frame(clock)) ++ "}")
def health_finish(state:D.Runtime<HealthState,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match state:
    case D.Runtime{_,registry,_,clock,_,_,_,_,_}: health_finish_counts(clock,H.count_registry(registry))
def health_run(pair:D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)) -> IO(Unit):
  match pair:
    case (state,(reserve,dispose)): IO.bind(D.Runtime<HealthState,S.Handle<T.HealthSchema>>,Unit,health_loops(64n,reserve,dispose,state),health_finish)
def health_start(count:U32) -> IO(Unit):
  IO.bind(D.Runtime<HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),Unit,health_created(count,I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,M.health_ledger,I.factory(),T.HealthOn{})),health_run)

def choose(schema:U32,count:U32) -> IO(Unit):
  match schema:
    case 0: motion_start(count)
    case 1: health_start(count)
    case _: IO.die(Unit,2,"bad schema")
def parsed(schema:Maybe<&2,U32>,count:Maybe<&2,U32>) -> IO(Unit):
  match schema count:
    case Some{schema} Some{count}: choose(schema,count)
    case _ _: IO.die(Unit,2,"bad args")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,_}}}: parsed(U32.read(schema),U32.read(count))
    case _: IO.die(Unit,2,"schema count")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
