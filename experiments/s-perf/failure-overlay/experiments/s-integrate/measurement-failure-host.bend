import Base
import ../../../failure-service-guard.bend as FG
import ../../../failure-checks.bend as FV
import ./types.bend as T
import ./storage.bend as S
import ./commands.bend as C
import ./measurement-bend.bend as M
import ./host.bend as H
import ./host-observations.bend as E
import ./host-render.bend as J
import ./readers.bend as R
import ./reader-host.bend as RH
import ./streams.bend as ST
import ./dispatcher.bend as D
import ./schedule.bend as K
import ./systems.bend as U
import ./audited-invoker.bend as AI
import ./measurement-failure-invoker.bend as F

def is_b(kind:K.BodyKind) -> Bool:
  match kind:
    case K.B{}: True{}
    case _: False{}
def is_fast(kind:K.BodyKind) -> Bool:
  match kind:
    case K.Fast{}: True{}
    case _: False{}
def choose_outcome(kind:K.BodyKind,mode:K.Mode) -> T.Outcome:
  match kind:
    case K.A{}: T.Success{}
    case _: U.failed(mode)

def kept_binding(-Schema:Data,keep:Bool,binding:E.Binding<Schema>,rest:List<&2,E.Binding<Schema>>) -> List<&2,E.Binding<Schema>>:
  match keep:
    case True{}: binding <> rest
    case False{}: rest
def without_binding(-Schema:Data,+label:String,bindings:List<&2,E.Binding<Schema>>) -> List<&2,E.Binding<Schema>>:
  match bindings:
    case Nil{}: []
    case Con{E.Binding{+name,handle},rest}: kept_binding(Schema,Bool.not(String.eq(label,name)),E.Binding{name,handle},without_binding(Schema,label,rest))
def seed_reserved(~Owner:Type,~Handle:Data,~Payload:Type,next:Owner -> List<&2,Handle> -> Owner & List<&2,Handle>,issued:List<&2,Handle>,result:T.Reservation<Owner,Handle,Payload>) -> Owner & List<&2,Handle>:
  match result:
    case T.Reserved{owner,handle}: next(owner,handle <> issued)
    case T.ReserveRejected{owner,payload}: next(owner,issued)
def seed_body(~Owner:Type,~Handle:Data,~Payload:Type,~spawn:Owner -> Payload -> T.Reservation<Owner,Handle,Payload>,~make:U32 -> Payload,fuel:Nat,+j:U32,issued:List<&2,Handle>,owner:Owner) -> Owner & List<&2,Handle>:
  match fuel:
    case 0n: (owner,List.reverse(&2,Handle,issued))
    case 1n+rest: seed_reserved(Owner,Handle,Payload,w => handles => seed_body(Owner,Handle,Payload,spawn,make,rest,U32.add(j,1),handles,w),issued,spawn(owner,make(j)))
def seed_bindings(-Schema:Data,handles:List<&2,S.Handle<Schema>>) -> List<&2,E.Binding<Schema>>:
  match handles:
    case Nil{}: []
    case Con{handle,rest}: E.Binding{"seed",handle} <> seed_bindings(Schema,rest)
def selected_seed(-Schema:Data,+handles:List<&2,S.Handle<Schema>>,bindings:List<&2,E.Binding<Schema>>) -> List<&2,E.Binding<Schema>>:
  match handles:
    case Con{a,Con{b,_}}: E.Binding{"a",a} <> E.Binding{"b",b} <> List.append(&2,E.Binding<Schema>,seed_bindings(Schema,handles),bindings)
    case _: bindings
type Seed<-Owner:Type> is Type:
  Seed{owner:Owner,count:U32}
def seed_pair(-Owner:Type,-View:Type,count:U32,pair:Owner & View) -> Seed<Owner> & View:
  match pair:
    case (owner,view): (Seed{owner,count},view)
def seed_presence(~Owner:Type,~observe:Owner -> Owner & D.Presence,state:Seed<Owner>) -> Seed<Owner> & D.Presence:
  match state:
    case Seed{owner,count}: seed_pair(Owner,D.Presence,count,observe(owner))
def seed_barrier(~Owner:Type,~apply:Owner -> R.Clock -> Owner & R.Clock,state:Seed<Owner>,clock:R.Clock) -> Seed<Owner> & R.Clock:
  match state:
    case Seed{owner,count}: seed_pair(Owner,R.Clock,count,apply(owner,clock))
def seed_transition(~Owner:Type,~apply:Owner -> Maybe<&2,Bool> -> R.Clock -> Owner & R.Clock,state:Seed<Owner>,mode:Maybe<&2,Bool>,clock:R.Clock) -> Seed<Owner> & R.Clock:
  match state:
    case Seed{owner,count}: seed_pair(Owner,R.Clock,count,apply(owner,mode,clock))
def seed_frame(~Owner:Type,~frame:Owner -> R.Readers -> R.Frame -> Owner & (R.Readers & R.Clock),state:Seed<Owner>,readers:R.Readers,boundary:R.Frame) -> Seed<Owner> & (R.Readers & R.Clock):
  match state:
    case Seed{owner,count}: seed_pair(Owner,R.Readers & R.Clock,count,frame(owner,readers,boundary))
def seed_mapped(-Owner:Type,-Handle:Data,count:U32,result:D.Invoked<Owner,Handle>) -> D.Invoked<Seed<Owner>,Handle>:
  match result:
    case D.Invoked{owner,audit,run,outcome,clock,escaped,views}: D.Invoked{Seed{owner,count},audit,run,outcome,clock,escaped,views}
def seed_invoke(~Owner:Type,~Handle:Data,~invoke:U32 -> K.System -> K.Mode -> U32 -> R.Clock -> Owner -> Maybe<D.Audit> -> Maybe<R.Run> -> IO(D.Invoked<Owner,Handle>),system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,state:Seed<Owner>,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<Seed<Owner>,Handle>):
  match state:
    case Seed{owner,+count}: IO.bind(D.Invoked<Owner,Handle>,D.Invoked<Seed<Owner>,Handle>,invoke(count,system,mode,capture,clock,owner,audit,run),result => IO.pure(D.Invoked<Seed<Owner>,Handle>,seed_mapped(Owner,Handle,count,result)))
def seed_runtime(-Owner:Type,-Handle:Data,count:U32,state:D.Runtime<Owner,Handle>) -> D.Runtime<Seed<Owner>,Handle>:
  match state:
    case D.Runtime{owner,registry,readers,clock,audit,style,escaped,views,nextMode}: D.Runtime{Seed{owner,count},registry,readers,clock,audit,style,escaped,views,nextMode}
def seed_unwrapped(-Owner:Type,-Handle:Data,result:D.Dispatched<Seed<Owner>,Handle>) -> D.Dispatched<Owner,Handle>:
  match result:
    case D.Dispatched{D.Runtime{Seed{owner,_},registry,readers,clock,audit,style,escaped,views,nextMode},outcome}: D.Dispatched{D.Runtime{owner,registry,readers,clock,audit,style,escaped,views,nextMode},outcome}
type MotionFailure is Type:
  MotionFailure{host:H.MotionHost(),iteration:U32,failed:List<&2,S.Handle<T.MotionSchema>>}
def motion_seed_bundle(j:U32) -> S.Bundle<T.Position,T.Velocity,T.Selected>: M.motion_bundle(j,False{})
def motion_seed_world(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,payload:S.Bundle<T.Position,T.Velocity,T.Selected>) -> T.Reservation<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>:
  C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,payload)
def motion_seed_done(i:U32,failed:List<&2,S.Handle<T.MotionSchema>>,logs:RH.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Handle<T.MotionSchema>>) -> D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>:
  match pair:
    case (world,handles): D.Invoked{MotionFailure{H.Host{world,logs,selected_seed(T.MotionSchema,handles,bindings),name,step,prior,events},i,failed},audit,run,T.Success{},clock,None{},[]}
def motion_seed(count:U32,owner:MotionFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock) -> D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>:
  match owner:
    case MotionFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: motion_seed_done(i,failed,logs,bindings,name,step,prior,events,audit,run,clock,seed_body(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,motion_seed_world,motion_seed_bundle,U32.to_nat(count),0,[],world))
def motion_presence_done(i:U32,failed:List<&2,S.Handle<T.MotionSchema>>,pair:H.MotionHost() & D.Presence) -> MotionFailure & D.Presence:
  match pair:
    case (host,p): (MotionFailure{host,i,failed},p)
def motion_presence(owner:MotionFailure) -> MotionFailure & D.Presence:
  match owner:
    case MotionFailure{host,i,failed}: motion_presence_done(i,failed,H.motion_presence(host))
def motion_clock_done(i:U32,failed:List<&2,S.Handle<T.MotionSchema>>,pair:H.MotionHost() & R.Clock) -> MotionFailure & R.Clock:
  match pair:
    case (host,clock): (MotionFailure{host,i,failed},clock)
def motion_barrier(owner:MotionFailure,clock:R.Clock) -> MotionFailure & R.Clock:
  match owner:
    case MotionFailure{host,i,failed}: motion_clock_done(i,failed,H.motion_barrier(host,clock))
def motion_transition(owner:MotionFailure,mode:Maybe<&2,Bool>,clock:R.Clock) -> MotionFailure & R.Clock:
  match owner:
    case MotionFailure{host,i,failed}: motion_clock_done(i,failed,H.motion_transition(host,mode,clock))
def motion_frame_done(i:U32,failed:List<&2,S.Handle<T.MotionSchema>>,pair:H.MotionHost() & (R.Readers & R.Clock)) -> MotionFailure & (R.Readers & R.Clock):
  match pair:
    case (host,rest): (MotionFailure{host,i,failed},rest)
def motion_frame(owner:MotionFailure,readers:R.Readers,boundary:R.Frame) -> MotionFailure & (R.Readers & R.Clock):
  match owner:
    case MotionFailure{host,i,failed}: motion_frame_done(i,failed,H.motion_frame(host,readers,boundary))
def motion_record(+label:String,handle:S.Handle<T.MotionSchema>,owner:H.MotionHost()) -> H.MotionHost():
  match owner:
    case H.Host{world,logs,bindings,name,step,prior,events}: H.Host{world,logs,E.Binding{label,handle} <> without_binding(T.MotionSchema,label,bindings),name,step,prior,events}
def motion_latest(+system:K.System,mode:K.Mode,handle:S.Handle<T.MotionSchema>,owner:H.MotionHost()) -> H.MotionHost():
  match system:
    case K.System{_,_,K.A{},_,_,_,_}: motion_record("p",handle,owner)
    case K.System{_,_,K.B{},_,_,_,_}: motion_record(H.reservation_name(K.B{},mode),handle,owner)
    case _: owner
def motion_mapped(i:U32,failed:List<&2,S.Handle<T.MotionSchema>>,system:K.System,mode:K.Mode,result:D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>) -> D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>:
  match result:
    case D.Invoked{host,audit,run,T.Failure{code},clock,Some{+handle},views}: D.Invoked{MotionFailure{motion_latest(system,mode,handle,host),i,handle <> failed},audit,run,T.Failure{code},clock,Some{handle},views}
    case D.Invoked{host,audit,run,outcome,clock,Some{+handle},views}: D.Invoked{MotionFailure{motion_latest(system,mode,handle,host),i,failed},audit,run,outcome,clock,Some{handle},views}
    case D.Invoked{host,audit,run,outcome,clock,escaped,views}: D.Invoked{MotionFailure{host,i,failed},audit,run,outcome,clock,escaped,views}
def motion_transaction(+i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,+clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>,selected:Maybe<&2,S.Handle<T.MotionSchema>>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match owner audit selected:
    case H.Host{world,logs,+bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(AI.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,F.motion_invoke(i,is_b(kind),choose_outcome(kind,mode),count,D.clock_tick(clock),world,handle,audit),result => IO.bind(AI.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,FG.guard(~S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~FV.position,FV.seed_count(T.MotionSchema,bindings),i,is_b(kind),True{},result),checked => H.motion_service(kind,mode,name,count,clock,logs,bindings,worldName,step,prior,events,run,checked)))
    case state service _: IO.pure(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked{state,service,run,T.Failure{10},clock,None{},[]})
def motion_body(i:U32,+kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: motion_transaction(i,kind,mode,name,count,clock,H.Host{world,logs,bindings,worldName,step,prior,events},audit,run,H.binding_find(T.MotionSchema,H.selected_name(kind),bindings))
def motion_read_body(prime:Bool,i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:R.Run) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match prime:
    case True{}: IO.pure(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked{owner,audit,Some{run},T.Success{},clock,None{},[]})
    case False{}: motion_body(i,kind,mode,name,count,clock,owner,audit,Some{run})

def motion_read_guard(valid:Bool,next:Unit -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>)) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match valid:
    case True{}: next(Unit{})
    case False{}: IO.die(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,23,"quiet reader full-field guard")
def motion_read_done(+i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,+clock:R.Clock,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,removed:ST.LifeLog<S.Handle<T.MotionSchema>>,despawned:ST.LifeLog<S.Handle<T.MotionSchema>>,bindings:List<&2,E.Binding<T.MotionSchema>>,worldName:String,+step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,audit:Maybe<D.Audit>,result:ST.PingRead<T.MotionPing>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match result:
    case ST.PingRead{ping,run,+messages,+lag}:
      motion_read_guard(FV.read(~T.MotionPing,~FV.motion_code,i,name,step,count,messages,lag,D.clock_tick(clock),H.clock_frame(clock)),unit => motion_read_body(Bool.or(is_fast(kind),Bool.and(is_b(kind),Bool.not(U.writes(mode)))),i,kind,mode,name,count,clock,H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,List.append(&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>,events,[E.FailureRead{i,name,count,messages,lag,D.clock_tick(clock),H.clock_frame(clock)}])},audit,run))
def motion_active(i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match owner run:
    case H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,events} Some{run}: motion_read_done(i,kind,mode,name,count,clock,world,removed,despawned,bindings,worldName,step,prior,events,audit,ST.read_ping(T.MotionPing,ping,run))
    case host None{}: motion_body(i,kind,mode,name,count,clock,host,audit,None{})
def motion_b_choose(active:Bool,i:U32,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match active:
    case True{}: motion_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case False{}: H.motion_body(K.B{},mode,name,count,clock,owner,audit,run)
def motion_despawn_result(next:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,result:T.CommandResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match result:
    case T.CommandQueued{world}: next(world)
    case T.CommandMissing{world,_}: next(world)
def motion_despawned(handles:List<&2,S.Handle<T.MotionSchema>>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match handles:
    case Nil{}: world
    case Con{handle,rest}: motion_despawn_result(w => motion_despawned(rest,w),C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,handle))
def motion_dispose_found(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,first:Maybe<&2,S.Handle<T.MotionSchema>>,second:Maybe<&2,S.Handle<T.MotionSchema>>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>:
  match first second:
    case Some{p} Some{r}: motion_despawned([p,r],world)
    case _ _: world
def motion_dispose(owner:H.MotionHost()) -> H.MotionHost():
  match owner:
    case H.Host{world,logs,+bindings,name,step,prior,events}: H.Host{motion_dispose_found(world,H.binding_find(T.MotionSchema,"p",bindings),H.binding_find(T.MotionSchema,"r",bindings)),logs,bindings,name,step,prior,events}
def motion_chosen(i:U32,+system:K.System,+mode:K.Mode,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,name,K.A{},_,_,_,_}: motion_active(i,K.A{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.B{},_,_,_,_}: motion_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.Fast{},_,_,_,_}: motion_active(i,K.Fast{},mode,name,count,clock,owner,audit,run)
    case K.System{_,_,K.Dispose{},_,_,_,_}: IO.pure(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked{motion_dispose(owner),audit,run,T.Success{},clock,None{},[]})
    case _: H.motion_invoke(system,mode,count,clock,owner,audit,run)
def motion_invoke_copy(+system:K.System,+mode:K.Mode,count:U32,clock:R.Clock,owner:MotionFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>):
  match owner:
    case MotionFailure{host,+i,failed}: IO.bind(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>,motion_chosen(i,system,mode,count,clock,host,audit,run),result => IO.pure(D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>,motion_mapped(i,failed,system,mode,result)))
def motion_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:MotionFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>):
  motion_invoke_copy(system,mode,count,clock,owner,audit,run)
def motion_seed_invoke(count:U32,system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:MotionFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,_,K.Seed{},_,_,_,_}: IO.pure(D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>,motion_seed(count,owner,audit,run,clock))
    case other: motion_invoke(other,mode,capture,clock,owner,audit,run)
def motion_seed_tick(count:U32,nodes:List<&2,K.Node>,runtime:D.Runtime<MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Dispatched<MotionFailure,S.Handle<T.MotionSchema>>):
  IO.bind(D.Dispatched<Seed<MotionFailure>,S.Handle<T.MotionSchema>>,D.Dispatched<MotionFailure,S.Handle<T.MotionSchema>>,
    D.tick(Seed<MotionFailure>,S.Handle<T.MotionSchema>,seed_presence(~MotionFailure,~motion_presence),seed_invoke(~MotionFailure,~S.Handle<T.MotionSchema>,~motion_seed_invoke),seed_barrier(~MotionFailure,~motion_barrier),seed_transition(~MotionFailure,~motion_transition),seed_frame(~MotionFailure,~motion_frame),nodes,"MotionLedger","MotionMode",seed_runtime(MotionFailure,S.Handle<T.MotionSchema>,count,runtime)),
    result => IO.pure(D.Dispatched<MotionFailure,S.Handle<T.MotionSchema>>,seed_unwrapped(MotionFailure,S.Handle<T.MotionSchema>,result)))
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Dispatched<MotionFailure,S.Handle<T.MotionSchema>>):
  D.tick(MotionFailure,S.Handle<T.MotionSchema>,motion_presence,motion_invoke,motion_barrier,motion_transition,motion_frame,nodes,"MotionLedger","MotionMode",runtime)

type HealthFailure is Type:
  HealthFailure{host:H.HealthHost(),iteration:U32,failed:List<&2,S.Handle<T.HealthSchema>>}
def health_seed_bundle(j:U32) -> S.Bundle<T.Vitals,T.Armor,T.Tracked>: M.health_bundle(j,False{})
def health_seed_world(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,payload:S.Bundle<T.Vitals,T.Armor,T.Tracked>) -> T.Reservation<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>:
  C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,payload)
def health_seed_done(i:U32,failed:List<&2,S.Handle<T.HealthSchema>>,logs:RH.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Handle<T.HealthSchema>>) -> D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>:
  match pair:
    case (world,handles): D.Invoked{HealthFailure{H.Host{world,logs,selected_seed(T.HealthSchema,handles,bindings),name,step,prior,events},i,failed},audit,run,T.Success{},clock,None{},[]}
def health_seed(count:U32,owner:HealthFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock) -> D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>:
  match owner:
    case HealthFailure{H.Host{world,logs,bindings,name,step,prior,events},i,failed}: health_seed_done(i,failed,logs,bindings,name,step,prior,events,audit,run,clock,seed_body(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,health_seed_world,health_seed_bundle,U32.to_nat(count),0,[],world))
def health_presence_done(i:U32,failed:List<&2,S.Handle<T.HealthSchema>>,pair:H.HealthHost() & D.Presence) -> HealthFailure & D.Presence:
  match pair:
    case (host,p): (HealthFailure{host,i,failed},p)
def health_presence(owner:HealthFailure) -> HealthFailure & D.Presence:
  match owner:
    case HealthFailure{host,i,failed}: health_presence_done(i,failed,H.health_presence(host))
def health_clock_done(i:U32,failed:List<&2,S.Handle<T.HealthSchema>>,pair:H.HealthHost() & R.Clock) -> HealthFailure & R.Clock:
  match pair:
    case (host,clock): (HealthFailure{host,i,failed},clock)
def health_barrier(owner:HealthFailure,clock:R.Clock) -> HealthFailure & R.Clock:
  match owner:
    case HealthFailure{host,i,failed}: health_clock_done(i,failed,H.health_barrier(host,clock))
def health_transition(owner:HealthFailure,mode:Maybe<&2,Bool>,clock:R.Clock) -> HealthFailure & R.Clock:
  match owner:
    case HealthFailure{host,i,failed}: health_clock_done(i,failed,H.health_transition(host,mode,clock))
def health_frame_done(i:U32,failed:List<&2,S.Handle<T.HealthSchema>>,pair:H.HealthHost() & (R.Readers & R.Clock)) -> HealthFailure & (R.Readers & R.Clock):
  match pair:
    case (host,rest): (HealthFailure{host,i,failed},rest)
def health_frame(owner:HealthFailure,readers:R.Readers,boundary:R.Frame) -> HealthFailure & (R.Readers & R.Clock):
  match owner:
    case HealthFailure{host,i,failed}: health_frame_done(i,failed,H.health_frame(host,readers,boundary))
def health_record(+label:String,handle:S.Handle<T.HealthSchema>,owner:H.HealthHost()) -> H.HealthHost():
  match owner:
    case H.Host{world,logs,bindings,name,step,prior,events}: H.Host{world,logs,E.Binding{label,handle} <> without_binding(T.HealthSchema,label,bindings),name,step,prior,events}
def health_latest(+system:K.System,mode:K.Mode,handle:S.Handle<T.HealthSchema>,owner:H.HealthHost()) -> H.HealthHost():
  match system:
    case K.System{_,_,K.A{},_,_,_,_}: health_record("p",handle,owner)
    case K.System{_,_,K.B{},_,_,_,_}: health_record(H.reservation_name(K.B{},mode),handle,owner)
    case _: owner
def health_mapped(i:U32,failed:List<&2,S.Handle<T.HealthSchema>>,system:K.System,mode:K.Mode,result:D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>) -> D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>:
  match result:
    case D.Invoked{host,audit,run,T.Failure{code},clock,Some{+handle},views}: D.Invoked{HealthFailure{health_latest(system,mode,handle,host),i,handle <> failed},audit,run,T.Failure{code},clock,Some{handle},views}
    case D.Invoked{host,audit,run,outcome,clock,Some{+handle},views}: D.Invoked{HealthFailure{health_latest(system,mode,handle,host),i,failed},audit,run,outcome,clock,Some{handle},views}
    case D.Invoked{host,audit,run,outcome,clock,escaped,views}: D.Invoked{HealthFailure{host,i,failed},audit,run,outcome,clock,escaped,views}
def health_transaction(+i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,+clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>,selected:Maybe<&2,S.Handle<T.HealthSchema>>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match owner audit selected:
    case H.Host{world,logs,+bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(AI.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,F.health_invoke(i,is_b(kind),choose_outcome(kind,mode),count,D.clock_tick(clock),world,handle,audit),result => IO.bind(AI.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,FG.guard(~S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~FV.vitals,FV.seed_count(T.HealthSchema,bindings),i,is_b(kind),False{},result),checked => H.health_service(kind,mode,name,count,clock,logs,bindings,worldName,step,prior,events,run,checked)))
    case state service _: IO.pure(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked{state,service,run,T.Failure{10},clock,None{},[]})
def health_body(i:U32,+kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: health_transaction(i,kind,mode,name,count,clock,H.Host{world,logs,bindings,worldName,step,prior,events},audit,run,H.binding_find(T.HealthSchema,H.selected_name(kind),bindings))
def health_read_body(prime:Bool,i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:R.Run) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match prime:
    case True{}: IO.pure(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked{owner,audit,Some{run},T.Success{},clock,None{},[]})
    case False{}: health_body(i,kind,mode,name,count,clock,owner,audit,Some{run})

def health_read_guard(valid:Bool,next:Unit -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>)) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match valid:
    case True{}: next(Unit{})
    case False{}: IO.die(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,23,"quiet reader full-field guard")
def health_read_done(+i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,+clock:R.Clock,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,removed:ST.LifeLog<S.Handle<T.HealthSchema>>,despawned:ST.LifeLog<S.Handle<T.HealthSchema>>,bindings:List<&2,E.Binding<T.HealthSchema>>,worldName:String,+step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,audit:Maybe<D.Audit>,result:ST.PingRead<T.HealthPing>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match result:
    case ST.PingRead{ping,run,+messages,+lag}:
      health_read_guard(FV.read(~T.HealthPing,~FV.health_code,i,name,step,count,messages,lag,D.clock_tick(clock),H.clock_frame(clock)),unit => health_read_body(Bool.or(is_fast(kind),Bool.and(is_b(kind),Bool.not(U.writes(mode)))),i,kind,mode,name,count,clock,H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,List.append(&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>,events,[E.FailureRead{i,name,count,messages,lag,D.clock_tick(clock),H.clock_frame(clock)}])},audit,run))
def health_active(i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match owner run:
    case H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,events} Some{run}: health_read_done(i,kind,mode,name,count,clock,world,removed,despawned,bindings,worldName,step,prior,events,audit,ST.read_ping(T.HealthPing,ping,run))
    case host None{}: health_body(i,kind,mode,name,count,clock,host,audit,None{})
def health_b_choose(active:Bool,i:U32,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match active:
    case True{}: health_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case False{}: H.health_body(K.B{},mode,name,count,clock,owner,audit,run)
def health_despawn_result(next:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,result:T.CommandResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match result:
    case T.CommandQueued{world}: next(world)
    case T.CommandMissing{world,_}: next(world)
def health_despawned(handles:List<&2,S.Handle<T.HealthSchema>>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match handles:
    case Nil{}: world
    case Con{handle,rest}: health_despawn_result(w => health_despawned(rest,w),C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,handle))
def health_dispose_found(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,first:Maybe<&2,S.Handle<T.HealthSchema>>,second:Maybe<&2,S.Handle<T.HealthSchema>>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>:
  match first second:
    case Some{p} Some{r}: health_despawned([p,r],world)
    case _ _: world
def health_dispose(owner:H.HealthHost()) -> H.HealthHost():
  match owner:
    case H.Host{world,logs,+bindings,name,step,prior,events}: H.Host{health_dispose_found(world,H.binding_find(T.HealthSchema,"p",bindings),H.binding_find(T.HealthSchema,"r",bindings)),logs,bindings,name,step,prior,events}
def health_chosen(i:U32,+system:K.System,+mode:K.Mode,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,name,K.A{},_,_,_,_}: health_active(i,K.A{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.B{},_,_,_,_}: health_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.Fast{},_,_,_,_}: health_active(i,K.Fast{},mode,name,count,clock,owner,audit,run)
    case K.System{_,_,K.Dispose{},_,_,_,_}: IO.pure(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked{health_dispose(owner),audit,run,T.Success{},clock,None{},[]})
    case _: H.health_invoke(system,mode,count,clock,owner,audit,run)
def health_invoke_copy(+system:K.System,+mode:K.Mode,count:U32,clock:R.Clock,owner:HealthFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>):
  match owner:
    case HealthFailure{host,+i,failed}: IO.bind(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>,health_chosen(i,system,mode,count,clock,host,audit,run),result => IO.pure(D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>,health_mapped(i,failed,system,mode,result)))
def health_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:HealthFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>):
  health_invoke_copy(system,mode,count,clock,owner,audit,run)
def health_seed_invoke(count:U32,system:K.System,mode:K.Mode,capture:U32,clock:R.Clock,owner:HealthFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,_,K.Seed{},_,_,_,_}: IO.pure(D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>,health_seed(count,owner,audit,run,clock))
    case other: health_invoke(other,mode,capture,clock,owner,audit,run)
def health_seed_tick(count:U32,nodes:List<&2,K.Node>,runtime:D.Runtime<HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Dispatched<HealthFailure,S.Handle<T.HealthSchema>>):
  IO.bind(D.Dispatched<Seed<HealthFailure>,S.Handle<T.HealthSchema>>,D.Dispatched<HealthFailure,S.Handle<T.HealthSchema>>,
    D.tick(Seed<HealthFailure>,S.Handle<T.HealthSchema>,seed_presence(~HealthFailure,~health_presence),seed_invoke(~HealthFailure,~S.Handle<T.HealthSchema>,~health_seed_invoke),seed_barrier(~HealthFailure,~health_barrier),seed_transition(~HealthFailure,~health_transition),seed_frame(~HealthFailure,~health_frame),nodes,"HealthLedger","HealthMode",seed_runtime(HealthFailure,S.Handle<T.HealthSchema>,count,runtime)),
    result => IO.pure(D.Dispatched<HealthFailure,S.Handle<T.HealthSchema>>,seed_unwrapped(HealthFailure,S.Handle<T.HealthSchema>,result)))
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Dispatched<HealthFailure,S.Handle<T.HealthSchema>>):
  D.tick(HealthFailure,S.Handle<T.HealthSchema>,health_presence,health_invoke,health_barrier,health_transition,health_frame,nodes,"HealthLedger","HealthMode",runtime)
