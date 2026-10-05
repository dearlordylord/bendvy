# Actual lifecycle owner/dispatcher timing adapter; no numeric ECS surrogate.
import Base
import ./measurement-lifecycle.bend as L
import ./measurement-bend.bend as M
import ./measurement-compact.bend as C
import ./measurement-fields.bend as F
import ./types.bend as T
import ./storage.bend as S
import ./commands.bend as CMD
import ./identity.bend as I
import ./query.bend as Q
import ./observations.bend as O
import ./payload.bend as P
import ./host.bend as H
import ./host-render.bend as J
import ./host-observations.bend as E
import ./dispatcher.bend as D
import ./readers.bend as R
import ./schedule.bend as K

type Bench<Owner:Type,Handle:Data> is Type:
  Bench{owner:Owner,stale:List<&2,Handle>,total:U32,full:Bool}
type Seen<Handle:Data> is Data:
  Seen{handle:Handle,kind:U32}
def lift(-Owner:Type,-Handle:Data,-V:Type,stale:List<&2,Handle>,total:U32,full:Bool,pair:Owner & V) -> Bench<Owner,Handle> & V:
  match pair:
    case (owner,value): (Bench{owner,stale,total,full},value)
def phase(mode:K.Mode) -> U32:
  match mode:
    case K.Retry{}: 1
    case K.Observe{}: 2
    case _: 0
type Systems is Data:
  Systems{select:K.System,reserve:K.System,dispose:K.System,observe:K.System}

type MotionObservation is Data:
  MotionObservation{iteration:U32,phase:U32,query:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,ledger:Maybe<&2,T.LedgerView>,lookups:T.Four,stale:List<&2,Seen<S.Handle<T.MotionSchema>>>}
def motion_presence(owner:Bench<L.MotionState,S.Handle<T.MotionSchema>>) -> Bench<L.MotionState,S.Handle<T.MotionSchema>> & D.Presence:
  match owner:
    case Bench{state,stale,total,full}: lift(L.MotionState,S.Handle<T.MotionSchema>,D.Presence,stale,total,full,L.motion_presence(state))
def motion_frame(owner:Bench<L.MotionState,S.Handle<T.MotionSchema>>,readers:R.Readers,boundary:R.Frame) -> Bench<L.MotionState,S.Handle<T.MotionSchema>> & (R.Readers & R.Clock):
  match owner:
    case Bench{state,stale,total,full}: lift(L.MotionState,S.Handle<T.MotionSchema>,R.Readers & R.Clock,stale,total,full,L.motion_frame(state,readers,boundary))
def motion_barrier(owner:Bench<L.MotionState,S.Handle<T.MotionSchema>>,clock:R.Clock) -> IO(Bench<L.MotionState,S.Handle<T.MotionSchema>> & R.Clock):
  match owner:
    case Bench{state,stale,total,full}: IO.bind(L.MotionState & R.Clock,Bench<L.MotionState,S.Handle<T.MotionSchema>> & R.Clock,L.motion_barrier(state,clock),pair => IO.pure(Bench<L.MotionState,S.Handle<T.MotionSchema>> & R.Clock,lift(L.MotionState,S.Handle<T.MotionSchema>,R.Clock,stale,total,full,pair)))
def motion_transition(owner:Bench<L.MotionState,S.Handle<T.MotionSchema>>,pending:Maybe<&2,Bool>,clock:R.Clock) -> Bench<L.MotionState,S.Handle<T.MotionSchema>> & R.Clock:
  match owner:
    case Bench{state,stale,total,full}: lift(L.MotionState,S.Handle<T.MotionSchema>,R.Clock,stale,total,full,L.motion_transition(state,pending,clock))
def motion_seen_value(+handle:S.Handle<T.MotionSchema>,acc:List<&2,Seen<S.Handle<T.MotionSchema>>>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & U32) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,Seen<S.Handle<T.MotionSchema>>>:
  match pair:
    case (world,kind): (world,Seen{handle,kind} <> acc)
def motion_seen_next(ih:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> List<&2,Seen<S.Handle<T.MotionSchema>>> -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,Seen<S.Handle<T.MotionSchema>>>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,Seen<S.Handle<T.MotionSchema>>>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,Seen<S.Handle<T.MotionSchema>>>:
  match pair:
    case (world,acc): ih(world,acc)
def motion_stales(handles:List<&2,S.Handle<T.MotionSchema>>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,acc:List<&2,Seen<S.Handle<T.MotionSchema>>>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,Seen<S.Handle<T.MotionSchema>>>:
  match handles:
    case Nil{}: (world,List.reverse(&2,Seen<S.Handle<T.MotionSchema>>,acc))
    case Con{+handle,tail}: motion_seen_next(w => a => motion_stales(tail,w,a),motion_seen_value(handle,acc,L.motion_lookup(world,Some{handle})))
def motion_ledger_pair(restore:Maybe<T.MotionLedger> -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,pair:Maybe<T.MotionLedger> & Maybe<&2,T.LedgerView>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,T.LedgerView>:
  match pair:
    case (ledger,value): (restore(ledger),value)
def motion_ledger(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,T.LedgerView>:
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}: motion_ledger_pair(l => S.World{namespace,next,rows,pending,l,mode},O.maybe_get(T.MotionLedger,T.LedgerView,P.motion_ledger_get,ledger))
def motion_observed_stales(i:U32,phase:U32,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> L.MotionState,query:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,ledger:Maybe<&2,T.LedgerView>,lookups:T.Four,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,Seen<S.Handle<T.MotionSchema>>>) -> L.MotionState & MotionObservation:
  match pair:
    case (world,stale): (restore(world),MotionObservation{i,phase,query,ledger,lookups,stale})
def motion_observed_lookups(i:U32,phase:U32,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> L.MotionState,query:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,ledger:Maybe<&2,T.LedgerView>,stale:List<&2,S.Handle<T.MotionSchema>>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Four) -> L.MotionState & MotionObservation:
  match pair:
    case (world,lookups): motion_observed_stales(i,phase,restore,query,ledger,lookups,motion_stales(stale,world,[]))
def motion_observed_ledger(i:U32,phase:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> L.MotionState,query:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,stale:List<&2,S.Handle<T.MotionSchema>>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,T.LedgerView>) -> L.MotionState & MotionObservation:
  match pair:
    case (world,ledger): motion_observed_lookups(i,phase,restore,query,ledger,stale,L.motion_observation1(target,foreign,L.motion_lookup(world,pending)))
def motion_observed_query(i:U32,phase:U32,target:Maybe<&2,S.Handle<T.MotionSchema>>,pending:Maybe<&2,S.Handle<T.MotionSchema>>,foreign:S.Handle<T.MotionSchema>,restore:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> L.MotionState,stale:List<&2,S.Handle<T.MotionSchema>>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> L.MotionState & MotionObservation:
  match pair:
    case (world,query): motion_observed_ledger(i,phase,target,pending,foreign,restore,query,stale,motion_ledger(world))
def motion_observe(phase:U32,stale:List<&2,S.Handle<T.MotionSchema>>,state:L.MotionState) -> L.MotionState & MotionObservation:
  match state:
    case L.MotionState{H.Host{world,logs,bindings,name,step,prior,events},count,+i,+target,+pending,+foreign}:
      motion_observed_query(i,phase,target,pending,foreign,w => L.MotionState{H.Host{w,logs,bindings,name,step,prior,events},count,i,target,pending,foreign},stale,Q.each(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,T.MotionLedger,T.MotionMode,P.position_get,P.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),Q.Required{},world))
def motion_seen_hash(value:Seen<S.Handle<T.MotionSchema>>) -> U32:
  match value:
    case Seen{S.Handle{namespace,id},kind}: C.mix(C.mix(C.mix(1,namespace),id),kind)
def motion_stales_hash(values:List<&2,Seen<S.Handle<T.MotionSchema>>>,seed:U32) -> U32:
  match values:
    case Nil{}: C.mix(seed,0)
    case Con{head,tail}: motion_stales_hash(tail,C.mix(seed,motion_seen_hash(head)))
def motion_hash(value:MotionObservation) -> U32:
  match value:
    case MotionObservation{i,p,query,ledger,lookups,stale}: C.mix(C.mix(C.mix(C.mix(C.mix(C.mix(1,i),p),C.motion_query(query,1)),C.ledger(ledger)),C.four(1,lookups)),motion_stales_hash(stale,1))
def motion_seen_json(value:Seen<S.Handle<T.MotionSchema>>) -> String:
  match value:
    case Seen{handle,kind}: "[" ++ J.render_handle(T.MotionSchema,handle) ++ "," ++ U32.show(kind) ++ "]"
def motion_json(value:MotionObservation) -> String:
  match value:
    case MotionObservation{i,p,query,ledger,lookups,stale}: J.render_concat(["{\"iteration\":",U32.show(i),",\"phase\":",U32.show(p),",\"query\":",F.motion_query(query),",\"ledger\":",J.render_optional(T.LedgerView,J.render_ledger,ledger),",\"lookups\":",J.render_four(lookups),",\"stale\":",J.render_list(Seen<S.Handle<T.MotionSchema>>,motion_seen_json,stale),"}"])
def motion_printed(full:Bool,value:MotionObservation,result:D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>) -> IO(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match full:
    case False{}: IO.pure(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,result)
    case True{}:
      do IO<D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>>:
        IO.print(motion_json(value))
        return result
def motion_observation_done(+stale:List<&2,S.Handle<T.MotionSchema>>,total:U32,+full:Bool,clock:R.Clock,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:L.MotionState & MotionObservation) -> IO(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match pair:
    case (state,+value): motion_printed(full,value,D.Invoked{Bench{state,stale,C.mix(total,motion_hash(value)),full},audit,run,T.Success{},clock,None{},[]})
def motion_observe_call(mode:K.Mode,clock:R.Clock,bench:Bench<L.MotionState,S.Handle<T.MotionSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match bench:
    case Bench{state,+stale,total,full}: motion_observation_done(stale,total,full,clock,audit,run,motion_observe(phase(mode),stale,state))
def motion_record(bench:Bench<L.MotionState,S.Handle<T.MotionSchema>>) -> Bench<L.MotionState,S.Handle<T.MotionSchema>>:
  match bench:
    case Bench{L.MotionState{host,count,i,Some{+target},pending,foreign},stale,total,full}: Bench{L.MotionState{host,count,i,Some{target},pending,foreign},List.append(&2,S.Handle<T.MotionSchema>,stale,[target]),total,full}
    case other: other
def motion_selected(bench:Bench<L.MotionState,S.Handle<T.MotionSchema>>) -> Bench<L.MotionState,S.Handle<T.MotionSchema>>:
  match bench:
    case Bench{state,stale,total,full}: Bench{L.motion_prepare(state),stale,total,full}
def motion_delegated(stale:List<&2,S.Handle<T.MotionSchema>>,total:U32,full:Bool,result:D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match result:
    case D.Invoked{state,audit,run,outcome,clock,escaped,observations}: IO.pure(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,D.Invoked{Bench{state,stale,total,full},audit,run,outcome,clock,escaped,observations})
def motion_delegate(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,bench:Bench<L.MotionState,S.Handle<T.MotionSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match bench:
    case Bench{state,stale,total,full}: IO.bind(D.Invoked<L.MotionState,S.Handle<T.MotionSchema>>,D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,L.motion_invoke(system,mode,count,clock,state,audit,run),r => motion_delegated(stale,total,full,r))
def motion_invoke_case(+system:K.System,mode:K.Mode,count:U32,clock:R.Clock,bench:Bench<L.MotionState,S.Handle<T.MotionSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,_,K.Snapshot{},_,_,_,_}: motion_observe_call(mode,clock,bench,audit,run)
    case K.System{_,_,K.Inserts{},_,_,_,_}: IO.pure(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,D.Invoked{motion_selected(bench),audit,run,T.Success{},clock,None{},[]})
    case K.System{_,_,K.Dispose{},_,_,_,_}: motion_delegate(system,mode,count,clock,motion_record(bench),audit,run)
    case _: motion_delegate(system,mode,count,clock,bench,audit,run)
def motion_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,bench:Bench<L.MotionState,S.Handle<T.MotionSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>): motion_invoke_case(system,mode,count,clock,bench,audit,run)
def motion_continued(result:D.Dispatched<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match result:
    case D.Dispatched{runtime,D.Complete{}}: IO.pure(D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,runtime)
    case _: IO.die(D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,3,"lifecycle dispatch rejected")
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  IO.bind(D.Dispatched<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,D.tick(Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>,motion_presence,motion_invoke,motion_barrier,motion_transition,motion_frame,nodes,"MotionLedger","Mode",runtime),motion_continued)
def motion_next(bench:Bench<L.MotionState,S.Handle<T.MotionSchema>>) -> Bench<L.MotionState,S.Handle<T.MotionSchema>>:
  match bench:
    case Bench{state,stale,total,full}: Bench{L.motion_next(state),stale,total,full}
def motion_loops(fuel:Nat,+systems:Systems,runtime:D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>):
  match fuel systems:
    case 0n _: IO.pure(D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,runtime)
    case 1n+rest Systems{select,reserve,dispose,+observe}:
      do IO<D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>>:
        a : D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> <- motion_tick([K.Call{select,K.Normal{}},K.Call{reserve,K.Normal{}}],runtime)
        b : D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> <- motion_tick([K.Call{observe,K.Normal{}}],a)
        c : D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> <- motion_tick([K.Deferred{}],b)
        d : D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> <- motion_tick([K.Call{observe,K.Retry{}}],c)
        e : D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> <- motion_tick([K.Call{dispose,K.Normal{}},K.Deferred{}],d)
        f : D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> <- motion_tick([K.Call{observe,K.Observe{}}],e)
        motion_loops(rest,systems,L.runtime_map(Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>,motion_next,f))

type HealthObservation is Data:
  HealthObservation{iteration:U32,phase:U32,query:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,ledger:Maybe<&2,T.LedgerView>,lookups:T.Four,stale:List<&2,Seen<S.Handle<T.HealthSchema>>>}
def health_presence(owner:Bench<L.HealthState,S.Handle<T.HealthSchema>>) -> Bench<L.HealthState,S.Handle<T.HealthSchema>> & D.Presence:
  match owner:
    case Bench{state,stale,total,full}: lift(L.HealthState,S.Handle<T.HealthSchema>,D.Presence,stale,total,full,L.health_presence(state))
def health_frame(owner:Bench<L.HealthState,S.Handle<T.HealthSchema>>,readers:R.Readers,boundary:R.Frame) -> Bench<L.HealthState,S.Handle<T.HealthSchema>> & (R.Readers & R.Clock):
  match owner:
    case Bench{state,stale,total,full}: lift(L.HealthState,S.Handle<T.HealthSchema>,R.Readers & R.Clock,stale,total,full,L.health_frame(state,readers,boundary))
def health_barrier(owner:Bench<L.HealthState,S.Handle<T.HealthSchema>>,clock:R.Clock) -> IO(Bench<L.HealthState,S.Handle<T.HealthSchema>> & R.Clock):
  match owner:
    case Bench{state,stale,total,full}: IO.bind(L.HealthState & R.Clock,Bench<L.HealthState,S.Handle<T.HealthSchema>> & R.Clock,L.health_barrier(state,clock),pair => IO.pure(Bench<L.HealthState,S.Handle<T.HealthSchema>> & R.Clock,lift(L.HealthState,S.Handle<T.HealthSchema>,R.Clock,stale,total,full,pair)))
def health_transition(owner:Bench<L.HealthState,S.Handle<T.HealthSchema>>,pending:Maybe<&2,Bool>,clock:R.Clock) -> Bench<L.HealthState,S.Handle<T.HealthSchema>> & R.Clock:
  match owner:
    case Bench{state,stale,total,full}: lift(L.HealthState,S.Handle<T.HealthSchema>,R.Clock,stale,total,full,L.health_transition(state,pending,clock))
def health_seen_value(+handle:S.Handle<T.HealthSchema>,acc:List<&2,Seen<S.Handle<T.HealthSchema>>>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & U32) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,Seen<S.Handle<T.HealthSchema>>>:
  match pair:
    case (world,kind): (world,Seen{handle,kind} <> acc)
def health_seen_next(ih:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> List<&2,Seen<S.Handle<T.HealthSchema>>> -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,Seen<S.Handle<T.HealthSchema>>>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,Seen<S.Handle<T.HealthSchema>>>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,Seen<S.Handle<T.HealthSchema>>>:
  match pair:
    case (world,acc): ih(world,acc)
def health_stales(handles:List<&2,S.Handle<T.HealthSchema>>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,acc:List<&2,Seen<S.Handle<T.HealthSchema>>>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,Seen<S.Handle<T.HealthSchema>>>:
  match handles:
    case Nil{}: (world,List.reverse(&2,Seen<S.Handle<T.HealthSchema>>,acc))
    case Con{+handle,tail}: health_seen_next(w => a => health_stales(tail,w,a),health_seen_value(handle,acc,L.health_lookup(world,Some{handle})))
def health_ledger_pair(restore:Maybe<T.HealthLedger> -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,pair:Maybe<T.HealthLedger> & Maybe<&2,T.LedgerView>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,T.LedgerView>:
  match pair:
    case (ledger,value): (restore(ledger),value)
def health_ledger(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,T.LedgerView>:
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}: health_ledger_pair(l => S.World{namespace,next,rows,pending,l,mode},O.maybe_get(T.HealthLedger,T.LedgerView,P.health_ledger_get,ledger))
def health_observed_stales(i:U32,phase:U32,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> L.HealthState,query:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,ledger:Maybe<&2,T.LedgerView>,lookups:T.Four,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,Seen<S.Handle<T.HealthSchema>>>) -> L.HealthState & HealthObservation:
  match pair:
    case (world,stale): (restore(world),HealthObservation{i,phase,query,ledger,lookups,stale})
def health_observed_lookups(i:U32,phase:U32,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> L.HealthState,query:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,ledger:Maybe<&2,T.LedgerView>,stale:List<&2,S.Handle<T.HealthSchema>>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Four) -> L.HealthState & HealthObservation:
  match pair:
    case (world,lookups): health_observed_stales(i,phase,restore,query,ledger,lookups,health_stales(stale,world,[]))
def health_observed_ledger(i:U32,phase:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> L.HealthState,query:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,stale:List<&2,S.Handle<T.HealthSchema>>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,T.LedgerView>) -> L.HealthState & HealthObservation:
  match pair:
    case (world,ledger): health_observed_lookups(i,phase,restore,query,ledger,stale,L.health_observation1(target,foreign,L.health_lookup(world,pending)))
def health_observed_query(i:U32,phase:U32,target:Maybe<&2,S.Handle<T.HealthSchema>>,pending:Maybe<&2,S.Handle<T.HealthSchema>>,foreign:S.Handle<T.HealthSchema>,restore:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> L.HealthState,stale:List<&2,S.Handle<T.HealthSchema>>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> L.HealthState & HealthObservation:
  match pair:
    case (world,query): health_observed_ledger(i,phase,target,pending,foreign,restore,query,stale,health_ledger(world))
def health_observe(phase:U32,stale:List<&2,S.Handle<T.HealthSchema>>,state:L.HealthState) -> L.HealthState & HealthObservation:
  match state:
    case L.HealthState{H.Host{world,logs,bindings,name,step,prior,events},count,+i,+target,+pending,+foreign}:
      health_observed_query(i,phase,target,pending,foreign,w => L.HealthState{H.Host{w,logs,bindings,name,step,prior,events},count,i,target,pending,foreign},stale,Q.each(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,T.HealthLedger,T.HealthMode,P.vitals_get,P.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),Q.Required{},world))
def health_seen_hash(value:Seen<S.Handle<T.HealthSchema>>) -> U32:
  match value:
    case Seen{S.Handle{namespace,id},kind}: C.mix(C.mix(C.mix(1,namespace),id),kind)
def health_stales_hash(values:List<&2,Seen<S.Handle<T.HealthSchema>>>,seed:U32) -> U32:
  match values:
    case Nil{}: C.mix(seed,0)
    case Con{head,tail}: health_stales_hash(tail,C.mix(seed,health_seen_hash(head)))
def health_hash(value:HealthObservation) -> U32:
  match value:
    case HealthObservation{i,p,query,ledger,lookups,stale}: C.mix(C.mix(C.mix(C.mix(C.mix(C.mix(1,i),p),C.health_query(query,1)),C.ledger(ledger)),C.four(1,lookups)),health_stales_hash(stale,1))
def health_seen_json(value:Seen<S.Handle<T.HealthSchema>>) -> String:
  match value:
    case Seen{handle,kind}: "[" ++ J.render_handle(T.HealthSchema,handle) ++ "," ++ U32.show(kind) ++ "]"
def health_json(value:HealthObservation) -> String:
  match value:
    case HealthObservation{i,p,query,ledger,lookups,stale}: J.render_concat(["{\"iteration\":",U32.show(i),",\"phase\":",U32.show(p),",\"query\":",F.health_query(query),",\"ledger\":",J.render_optional(T.LedgerView,J.render_ledger,ledger),",\"lookups\":",J.render_four(lookups),",\"stale\":",J.render_list(Seen<S.Handle<T.HealthSchema>>,health_seen_json,stale),"}"])
def health_printed(full:Bool,value:HealthObservation,result:D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>) -> IO(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match full:
    case False{}: IO.pure(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,result)
    case True{}:
      do IO<D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>>:
        IO.print(health_json(value))
        return result
def health_observation_done(+stale:List<&2,S.Handle<T.HealthSchema>>,total:U32,+full:Bool,clock:R.Clock,audit:Maybe<D.Audit>,run:Maybe<R.Run>,pair:L.HealthState & HealthObservation) -> IO(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match pair:
    case (state,+value): health_printed(full,value,D.Invoked{Bench{state,stale,C.mix(total,health_hash(value)),full},audit,run,T.Success{},clock,None{},[]})
def health_observe_call(mode:K.Mode,clock:R.Clock,bench:Bench<L.HealthState,S.Handle<T.HealthSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match bench:
    case Bench{state,+stale,total,full}: health_observation_done(stale,total,full,clock,audit,run,health_observe(phase(mode),stale,state))
def health_record(bench:Bench<L.HealthState,S.Handle<T.HealthSchema>>) -> Bench<L.HealthState,S.Handle<T.HealthSchema>>:
  match bench:
    case Bench{L.HealthState{host,count,i,Some{+target},pending,foreign},stale,total,full}: Bench{L.HealthState{host,count,i,Some{target},pending,foreign},List.append(&2,S.Handle<T.HealthSchema>,stale,[target]),total,full}
    case other: other
def health_selected(bench:Bench<L.HealthState,S.Handle<T.HealthSchema>>) -> Bench<L.HealthState,S.Handle<T.HealthSchema>>:
  match bench:
    case Bench{state,stale,total,full}: Bench{L.health_prepare(state),stale,total,full}
def health_delegated(stale:List<&2,S.Handle<T.HealthSchema>>,total:U32,full:Bool,result:D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match result:
    case D.Invoked{state,audit,run,outcome,clock,escaped,observations}: IO.pure(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,D.Invoked{Bench{state,stale,total,full},audit,run,outcome,clock,escaped,observations})
def health_delegate(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,bench:Bench<L.HealthState,S.Handle<T.HealthSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match bench:
    case Bench{state,stale,total,full}: IO.bind(D.Invoked<L.HealthState,S.Handle<T.HealthSchema>>,D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,L.health_invoke(system,mode,count,clock,state,audit,run),r => health_delegated(stale,total,full,r))
def health_invoke_case(+system:K.System,mode:K.Mode,count:U32,clock:R.Clock,bench:Bench<L.HealthState,S.Handle<T.HealthSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,_,K.Snapshot{},_,_,_,_}: health_observe_call(mode,clock,bench,audit,run)
    case K.System{_,_,K.Inserts{},_,_,_,_}: IO.pure(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,D.Invoked{health_selected(bench),audit,run,T.Success{},clock,None{},[]})
    case K.System{_,_,K.Dispose{},_,_,_,_}: health_delegate(system,mode,count,clock,health_record(bench),audit,run)
    case _: health_delegate(system,mode,count,clock,bench,audit,run)
def health_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,bench:Bench<L.HealthState,S.Handle<T.HealthSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>): health_invoke_case(system,mode,count,clock,bench,audit,run)
def health_continued(result:D.Dispatched<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match result:
    case D.Dispatched{runtime,D.Complete{}}: IO.pure(D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,runtime)
    case _: IO.die(D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,3,"lifecycle dispatch rejected")
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  IO.bind(D.Dispatched<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,D.tick(Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>,health_presence,health_invoke,health_barrier,health_transition,health_frame,nodes,"HealthLedger","Mode",runtime),health_continued)
def health_next(bench:Bench<L.HealthState,S.Handle<T.HealthSchema>>) -> Bench<L.HealthState,S.Handle<T.HealthSchema>>:
  match bench:
    case Bench{state,stale,total,full}: Bench{L.health_next(state),stale,total,full}
def health_loops(fuel:Nat,+systems:Systems,runtime:D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>):
  match fuel systems:
    case 0n _: IO.pure(D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,runtime)
    case 1n+rest Systems{select,reserve,dispose,+observe}:
      do IO<D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>>:
        a : D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> <- health_tick([K.Call{select,K.Normal{}},K.Call{reserve,K.Normal{}}],runtime)
        b : D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> <- health_tick([K.Call{observe,K.Normal{}}],a)
        c : D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> <- health_tick([K.Deferred{}],b)
        d : D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> <- health_tick([K.Call{observe,K.Retry{}}],c)
        e : D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> <- health_tick([K.Call{dispose,K.Normal{}},K.Deferred{}],d)
        f : D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> <- health_tick([K.Call{observe,K.Observe{}}],e)
        health_loops(rest,systems,L.runtime_map(Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>,health_next,f))

def motion_observed_registration(restore:K.Registry -> D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,select:K.System,reserve:K.System,dispose:K.System,result:K.Registered) -> D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> & Systems:
  match result:
    case K.Registered{registry,observe}: (restore(registry),Systems{select,reserve,dispose,observe})
def motion_selected_registration(restore:K.Registry -> D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>,reserve:K.System,dispose:K.System,result:K.Registered) -> D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> & Systems:
  match result:
    case K.Registered{registry,select}: motion_observed_registration(restore,select,reserve,dispose,K.register(registry,"Observe",K.Snapshot{},True{},False{},False{},False{}))
def motion_registration(full:Bool,pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)) -> D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> & Systems:
  match pair:
    case (D.Runtime{state,registry,readers,clock,audit,style,escaped,observations,next},(reserve,dispose)):
      motion_selected_registration(reg => D.Runtime{Bench{state,[],1,full},reg,readers,clock,audit,style,escaped,observations,next},reserve,dispose,K.register(registry,"Select",K.Inserts{},False{},False{},False{},False{}))
def motion_foreign_checked(count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,foreign:S.Handle<T.MotionSchema>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & U32) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match pair:
    case (_,2): L.motion_register(count,world,foreign,K.register(K.initial(),"Reserve",K.Seed{},False{},False{},False{},False{}))
    case _: IO.die(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),4,"foreign fixture is not live")
def motion_foreign_applied(count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,+foreign:S.Handle<T.MotionSchema>,pair:CMD.CheckedApply<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match pair:
    case CMD.Applied{beta,_}: motion_foreign_checked(count,world,foreign,L.motion_lookup(beta,Some{foreign}))
    case CMD.CapacityRejected{_}: IO.die(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),20,"indexed foreign fixture capacity rejected")
    case CMD.InvariantFault{_,_,_}: IO.die(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),21,"indexed foreign fixture placement invariant failed")
def motion_foreign_reserved(count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,result:T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match result:
    case T.Reserved{beta,foreign}: motion_foreign_applied(count,world,foreign,CMD.apply_checked(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,1))
    case _: IO.die(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),4,"foreign reservation failed")
def motion_foreign(count:U32,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match result:
    case T.Created{_,beta}: motion_foreign_reserved(count,world,CMD.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,S.Bundle{M.motion_main(999,True{}),None{},None{}}))
    case _: IO.die(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),4,"foreign creation failed")
def motion_created(count:U32,result:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)):
  match result:
    case T.Created{factory,world}: motion_foreign(count,world,I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,M.motion_ledger,factory,T.MotionOn{}))
    case _: IO.die(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),4,"creation failed")
def motion_events(values:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>) -> IO(Unit):
  match values:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.print(J.render_motion(head))
        motion_events(tail)
def motion_drained_owner(owner:L.MotionState) -> L.MotionState & List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>:
  match owner:
    case L.MotionState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,pending,foreign}: (L.MotionState{H.Host{world,logs,bindings,name,step,prior,[]},count,i,target,pending,foreign},events)
def motion_drained(pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>):
  match pair:
    case (runtime,events):
      do IO<D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>>:
        motion_events(events)
        return runtime
def motion_drain(runtime:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>>): motion_drained(L.runtime_read(L.MotionState,S.Handle<T.MotionSchema>,List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,motion_drained_owner,runtime))
def motion_finish(elapsed:Nat,runtime:D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  match runtime:
    case D.Runtime{Bench{state,stale,total,_},registry,readers,clock,audit,style,escaped,observations,next}:
      do IO<Unit>:
        IO.print("{\"milliseconds\":" ++ Nat.show(elapsed) ++ ",\"digest\":" ++ U32.show(total) ++ ",\"staleCount\":" ++ Nat.show(List.length(&2,S.Handle<T.MotionSchema>,stale)) ++ "}")
        clean : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- motion_drain(D.Runtime{state,registry,readers,clock,audit,style,escaped,observations,next})
        checked : D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> <- L.motion_checkpoint("final",clean)
        L.motion_finish(checked)
def motion_stop(start:Nat,runtime:D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>>) -> IO(Unit):
  do IO<Unit>:
    end : Nat <- IO.now()
    motion_finish(Nat.sub(end,start),runtime)
def motion_run(pair:D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> & Systems) -> IO(Unit):
  match pair:
    case (runtime,systems):
      do IO<Unit>:
        start : Nat <- IO.now()
        final : D.Runtime<Bench<L.MotionState,S.Handle<T.MotionSchema>>,S.Handle<T.MotionSchema>> <- motion_loops(64n,systems,runtime)
        motion_stop(start,final)
def motion_ready(full:Bool,pair:D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System)) -> IO(Unit): motion_run(motion_registration(full,pair))
def motion_start(count:U32,full:Bool) -> IO(Unit):
  IO.bind(D.Runtime<L.MotionState,S.Handle<T.MotionSchema>> & (K.System & K.System),Unit,motion_created(count,I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,M.motion_ledger,I.factory(),T.MotionOn{})),pair => motion_ready(full,pair))

def health_observed_registration(restore:K.Registry -> D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,select:K.System,reserve:K.System,dispose:K.System,result:K.Registered) -> D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> & Systems:
  match result:
    case K.Registered{registry,observe}: (restore(registry),Systems{select,reserve,dispose,observe})
def health_selected_registration(restore:K.Registry -> D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>,reserve:K.System,dispose:K.System,result:K.Registered) -> D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> & Systems:
  match result:
    case K.Registered{registry,select}: health_observed_registration(restore,select,reserve,dispose,K.register(registry,"Observe",K.Snapshot{},True{},False{},False{},False{}))
def health_registration(full:Bool,pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)) -> D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> & Systems:
  match pair:
    case (D.Runtime{state,registry,readers,clock,audit,style,escaped,observations,next},(reserve,dispose)):
      health_selected_registration(reg => D.Runtime{Bench{state,[],1,full},reg,readers,clock,audit,style,escaped,observations,next},reserve,dispose,K.register(registry,"Select",K.Inserts{},False{},False{},False{},False{}))
def health_foreign_checked(count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,foreign:S.Handle<T.HealthSchema>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & U32) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match pair:
    case (_,2): L.health_register(count,world,foreign,K.register(K.initial(),"Reserve",K.Seed{},False{},False{},False{},False{}))
    case _: IO.die(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),4,"foreign fixture is not live")
def health_foreign_applied(count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,+foreign:S.Handle<T.HealthSchema>,pair:CMD.CheckedApply<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match pair:
    case CMD.Applied{beta,_}: health_foreign_checked(count,world,foreign,L.health_lookup(beta,Some{foreign}))
    case CMD.CapacityRejected{_}: IO.die(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),20,"indexed foreign fixture capacity rejected")
    case CMD.InvariantFault{_,_,_}: IO.die(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),21,"indexed foreign fixture placement invariant failed")
def health_foreign_reserved(count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,result:T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match result:
    case T.Reserved{beta,foreign}: health_foreign_applied(count,world,foreign,CMD.apply_checked(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,1))
    case _: IO.die(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),4,"foreign reservation failed")
def health_foreign(count:U32,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match result:
    case T.Created{_,beta}: health_foreign_reserved(count,world,CMD.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,S.Bundle{M.health_main(999,True{}),None{},None{}}))
    case _: IO.die(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),4,"foreign creation failed")
def health_created(count:U32,result:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)):
  match result:
    case T.Created{factory,world}: health_foreign(count,world,I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,M.health_ledger,factory,T.HealthOn{}))
    case _: IO.die(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),4,"creation failed")
def health_events(values:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>) -> IO(Unit):
  match values:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.print(J.render_health(head))
        health_events(tail)
def health_drained_owner(owner:L.HealthState) -> L.HealthState & List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>:
  match owner:
    case L.HealthState{H.Host{world,logs,bindings,name,step,prior,events},count,i,target,pending,foreign}: (L.HealthState{H.Host{world,logs,bindings,name,step,prior,[]},count,i,target,pending,foreign},events)
def health_drained(pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>):
  match pair:
    case (runtime,events):
      do IO<D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>>:
        health_events(events)
        return runtime
def health_drain(runtime:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>>): health_drained(L.runtime_read(L.HealthState,S.Handle<T.HealthSchema>,List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,health_drained_owner,runtime))
def health_finish(elapsed:Nat,runtime:D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  match runtime:
    case D.Runtime{Bench{state,stale,total,_},registry,readers,clock,audit,style,escaped,observations,next}:
      do IO<Unit>:
        IO.print("{\"milliseconds\":" ++ Nat.show(elapsed) ++ ",\"digest\":" ++ U32.show(total) ++ ",\"staleCount\":" ++ Nat.show(List.length(&2,S.Handle<T.HealthSchema>,stale)) ++ "}")
        clean : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- health_drain(D.Runtime{state,registry,readers,clock,audit,style,escaped,observations,next})
        checked : D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> <- L.health_checkpoint("final",clean)
        L.health_finish(checked)
def health_stop(start:Nat,runtime:D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>>) -> IO(Unit):
  do IO<Unit>:
    end : Nat <- IO.now()
    health_finish(Nat.sub(end,start),runtime)
def health_run(pair:D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> & Systems) -> IO(Unit):
  match pair:
    case (runtime,systems):
      do IO<Unit>:
        start : Nat <- IO.now()
        final : D.Runtime<Bench<L.HealthState,S.Handle<T.HealthSchema>>,S.Handle<T.HealthSchema>> <- health_loops(64n,systems,runtime)
        health_stop(start,final)
def health_ready(full:Bool,pair:D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System)) -> IO(Unit): health_run(health_registration(full,pair))
def health_start(count:U32,full:Bool) -> IO(Unit):
  IO.bind(D.Runtime<L.HealthState,S.Handle<T.HealthSchema>> & (K.System & K.System),Unit,health_created(count,I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,M.health_ledger,I.factory(),T.HealthOn{})),pair => health_ready(full,pair))

def once(schema:U32,count:U32,full:Bool) -> IO(Unit):
  match schema:
    case 0: motion_start(count,full)
    case 1: health_start(count,full)
    case _: IO.die(Unit,2,"unknown schema")
def choose(+schema:U32,+count:U32,full:Bool) -> IO(Unit):
  match full:
    case True{}: once(schema,count,True{})
    case False{}:
      do IO<Unit>:
        once(schema,count,False{})
        once(schema,count,False{})
def parsed(schema:Maybe<&2,U32>,count:Maybe<&2,U32>,full:Maybe<&2,U32>) -> IO(Unit):
  match schema count full:
    case Some{schema} Some{count} Some{full}: choose(schema,count,U32.is_eq(full,1))
    case _ _ _: IO.die(Unit,2,"schema count full required")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,Con{full,_}}}}: parsed(U32.read(schema),U32.read(count),U32.read(full))
    case _: IO.die(Unit,2,"schema count full required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
