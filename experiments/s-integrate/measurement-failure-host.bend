import Base
import ./types.bend as T
import ./storage.bend as S
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

type MotionFailure is Type:
  MotionFailure{host:H.MotionHost(),iteration:U32,failed:List<&2,S.Handle<T.MotionSchema>>}
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
def motion_mapped(i:U32,failed:List<&2,S.Handle<T.MotionSchema>>,result:D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>) -> D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>:
  match result:
    case D.Invoked{host,audit,run,T.Failure{code},clock,Some{+handle},views}: D.Invoked{MotionFailure{host,i,handle <> failed},audit,run,T.Failure{code},clock,Some{handle},views}
    case D.Invoked{host,audit,run,outcome,clock,escaped,views}: D.Invoked{MotionFailure{host,i,failed},audit,run,outcome,clock,escaped,views}
def motion_transaction(i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,+clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>,selected:Maybe<&2,S.Handle<T.MotionSchema>>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match owner audit selected:
    case H.Host{world,logs,bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(AI.ServiceResult<S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,T.PositionView,T.VelocityView,T.Selected>,D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,F.motion_invoke(i,is_b(kind),choose_outcome(kind,mode),count,D.clock_tick(clock),world,handle,audit),result => H.motion_service(kind,mode,name,count,clock,logs,bindings,worldName,step,prior,events,run,result))
    case state service _: IO.pure(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked{state,service,run,T.Failure{10},clock,None{},[]})
def motion_body(i:U32,+kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: motion_transaction(i,kind,mode,name,count,clock,H.Host{world,logs,bindings,worldName,step,prior,events},audit,run,H.binding_find(T.MotionSchema,H.selected_name(kind),bindings))
def motion_read_body(prime:Bool,i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:R.Run) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match prime:
    case True{}: IO.pure(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked{owner,audit,Some{run},T.Success{},clock,None{},[]})
    case False{}: motion_body(i,kind,mode,name,count,clock,owner,audit,Some{run})
def motion_read_done(+i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,clock:R.Clock,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,removed:ST.LifeLog<S.Handle<T.MotionSchema>>,despawned:ST.LifeLog<S.Handle<T.MotionSchema>>,bindings:List<&2,E.Binding<T.MotionSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,audit:Maybe<D.Audit>,result:ST.PingRead<T.MotionPing>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match result:
    case ST.PingRead{ping,run,+messages,+lag}:
      IO.bind(Unit,D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,IO.print("FAILURE-READ:" ++ U32.show(i) ++ ":" ++ name ++ ":" ++ U32.show(count) ++ ":" ++ J.render_list(T.MotionPing,J.render_motion_ping,messages) ++ ":" ++ Bool.show(lag)),_ => motion_read_body(Bool.or(is_fast(kind),Bool.and(is_b(kind),Bool.not(U.writes(mode)))),i,kind,mode,name,count,clock,H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,events},audit,run))
def motion_active(i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match owner run:
    case H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,events} Some{run}: motion_read_done(i,kind,mode,name,count,clock,world,removed,despawned,bindings,worldName,step,prior,events,audit,ST.read_ping(T.MotionPing,ping,run))
    case host None{}: motion_body(i,kind,mode,name,count,clock,host,audit,None{})
def motion_b_choose(active:Bool,i:U32,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match active:
    case True{}: motion_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case False{}: H.motion_body(K.B{},mode,name,count,clock,owner,audit,run)
def motion_chosen(i:U32,+system:K.System,+mode:K.Mode,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,name,K.A{},_,_,_,_}: motion_active(i,K.A{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.B{},_,_,_,_}: motion_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.Fast{},_,_,_,_}: motion_active(i,K.Fast{},mode,name,count,clock,owner,audit,run)
    case _: H.motion_invoke(system,mode,count,clock,owner,audit,run)
def motion_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:MotionFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>):
  match owner:
    case MotionFailure{host,+i,failed}: IO.bind(D.Invoked<H.MotionHost(),S.Handle<T.MotionSchema>>,D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>,motion_chosen(i,system,mode,count,clock,host,audit,run),result => IO.pure(D.Invoked<MotionFailure,S.Handle<T.MotionSchema>>,motion_mapped(i,failed,result)))
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Dispatched<MotionFailure,S.Handle<T.MotionSchema>>):
  D.tick(MotionFailure,S.Handle<T.MotionSchema>,motion_presence,motion_invoke,motion_barrier,motion_transition,motion_frame,nodes,"MotionLedger","MotionMode",runtime)

type HealthFailure is Type:
  HealthFailure{host:H.HealthHost(),iteration:U32,failed:List<&2,S.Handle<T.HealthSchema>>}
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
def health_mapped(i:U32,failed:List<&2,S.Handle<T.HealthSchema>>,result:D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>) -> D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>:
  match result:
    case D.Invoked{host,audit,run,T.Failure{code},clock,Some{+handle},views}: D.Invoked{HealthFailure{host,i,handle <> failed},audit,run,T.Failure{code},clock,Some{handle},views}
    case D.Invoked{host,audit,run,outcome,clock,escaped,views}: D.Invoked{HealthFailure{host,i,failed},audit,run,outcome,clock,escaped,views}
def health_transaction(i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,+clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>,selected:Maybe<&2,S.Handle<T.HealthSchema>>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match owner audit selected:
    case H.Host{world,logs,bindings,worldName,step,prior,events} Some{audit} Some{handle}:
      IO.bind(AI.ServiceResult<S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,T.VitalsView,T.ArmorView,T.Tracked>,D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,F.health_invoke(i,is_b(kind),choose_outcome(kind,mode),count,D.clock_tick(clock),world,handle,audit),result => H.health_service(kind,mode,name,count,clock,logs,bindings,worldName,step,prior,events,run,result))
    case state service _: IO.pure(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked{state,service,run,T.Failure{10},clock,None{},[]})
def health_body(i:U32,+kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match owner:
    case H.Host{world,logs,+bindings,worldName,step,prior,events}: health_transaction(i,kind,mode,name,count,clock,H.Host{world,logs,bindings,worldName,step,prior,events},audit,run,H.binding_find(T.HealthSchema,H.selected_name(kind),bindings))
def health_read_body(prime:Bool,i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:R.Run) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match prime:
    case True{}: IO.pure(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked{owner,audit,Some{run},T.Success{},clock,None{},[]})
    case False{}: health_body(i,kind,mode,name,count,clock,owner,audit,Some{run})
def health_read_done(+i:U32,+kind:K.BodyKind,+mode:K.Mode,+name:String,+count:U32,clock:R.Clock,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,removed:ST.LifeLog<S.Handle<T.HealthSchema>>,despawned:ST.LifeLog<S.Handle<T.HealthSchema>>,bindings:List<&2,E.Binding<T.HealthSchema>>,worldName:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,audit:Maybe<D.Audit>,result:ST.PingRead<T.HealthPing>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match result:
    case ST.PingRead{ping,run,+messages,+lag}:
      IO.bind(Unit,D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,IO.print("FAILURE-READ:" ++ U32.show(i) ++ ":" ++ name ++ ":" ++ U32.show(count) ++ ":" ++ J.render_list(T.HealthPing,J.render_health_ping,messages) ++ ":" ++ Bool.show(lag)),_ => health_read_body(Bool.or(is_fast(kind),Bool.and(is_b(kind),Bool.not(U.writes(mode)))),i,kind,mode,name,count,clock,H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,events},audit,run))
def health_active(i:U32,kind:K.BodyKind,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match owner run:
    case H.Host{world,RH.Logs{ping,removed,despawned},bindings,worldName,step,prior,events} Some{run}: health_read_done(i,kind,mode,name,count,clock,world,removed,despawned,bindings,worldName,step,prior,events,audit,ST.read_ping(T.HealthPing,ping,run))
    case host None{}: health_body(i,kind,mode,name,count,clock,host,audit,None{})
def health_b_choose(active:Bool,i:U32,mode:K.Mode,name:String,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match active:
    case True{}: health_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case False{}: H.health_body(K.B{},mode,name,count,clock,owner,audit,run)
def health_chosen(i:U32,+system:K.System,+mode:K.Mode,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,name,K.A{},_,_,_,_}: health_active(i,K.A{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.B{},_,_,_,_}: health_active(i,K.B{},mode,name,count,clock,owner,audit,run)
    case K.System{_,name,K.Fast{},_,_,_,_}: health_active(i,K.Fast{},mode,name,count,clock,owner,audit,run)
    case _: H.health_invoke(system,mode,count,clock,owner,audit,run)
def health_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:HealthFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>):
  match owner:
    case HealthFailure{host,+i,failed}: IO.bind(D.Invoked<H.HealthHost(),S.Handle<T.HealthSchema>>,D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>,health_chosen(i,system,mode,count,clock,host,audit,run),result => IO.pure(D.Invoked<HealthFailure,S.Handle<T.HealthSchema>>,health_mapped(i,failed,result)))
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Dispatched<HealthFailure,S.Handle<T.HealthSchema>>):
  D.tick(HealthFailure,S.Handle<T.HealthSchema>,health_presence,health_invoke,health_barrier,health_transition,health_frame,nodes,"HealthLedger","HealthMode",runtime)
