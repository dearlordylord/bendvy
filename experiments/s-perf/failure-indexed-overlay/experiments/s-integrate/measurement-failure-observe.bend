import Base
import ../../../failure-indexed-checks.bend as FV
import ./types.bend as T
import ./storage.bend as S
import ./query.bend as Q
import ./observations.bend as O
import ./payload.bend as P
import ./host.bend as H
import ./host-render.bend as J
import ./reader-host.bend as RH
import ./host-observations.bend as E
import ./dispatcher.bend as D
import ./readers.bend as R
import ./schedule.bend as K
import ./measurement-failure-host.bend as F

def motion_row(row:O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>) -> String:
  J.render_query(T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,J.render_position,J.render_velocity,J.render_selected,row)
def motion_lookup_done(+handle:S.Handle<T.MotionSchema>,next:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> -> List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>> -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,seen:List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & T.Access<O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>:
  match pair:
    case (world,result): next(world,List.append(&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,seen,[E.Lookup{"",handle,result}]))
def motion_lookups(handles:List<&2,S.Handle<T.MotionSchema>>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,seen:List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>:
  match handles:
    case Nil{}: (world,seen)
    case Con{+handle,rest}: motion_lookup_done(handle,w => rows => motion_lookups(rest,w,rows),seen,Q.lookup(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,T.MotionLedger,T.MotionMode,P.position_get,P.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),Q.Required{},world,handle))
def motion_append_handle(found:Maybe<&2,S.Handle<T.MotionSchema>>,rest:List<&2,S.Handle<T.MotionSchema>>) -> List<&2,S.Handle<T.MotionSchema>>:
  match found:
    case None{}: rest
    case Some{handle}: handle <> rest
type MotionRest is Type:
  MotionRest{logs:RH.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,iteration:U32,failed:List<&2,S.Handle<T.MotionSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock}

def motion_guard(valid:Bool,owner:D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match valid:
    case True{}: IO.pure(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>,owner)
    case False{}: IO.die(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>,22,"quiet observation full-field guard")
def motion_resource_done(+rows:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,+lookups:List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,+ledger:Maybe<&2,T.LedgerView>,rest:MotionRest) -> IO(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match rest:
    case MotionRest{logs,+bindings,name,+step,prior,events,+iteration,failed,audit,run,clock}:
      motion_guard(FV.motion(FV.seed_count(T.MotionSchema,bindings),iteration,step,rows,lookups,ledger),D.Invoked{F.MotionFailure{H.Host{world,logs,bindings,name,step,prior,List.append(&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>,events,[E.FailureObserved{"Motion",iteration,step,rows,ledger,lookups}])},iteration,failed},audit,run,T.Success{},clock,None{},[]})
def motion_resource(rows:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,lookups:List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,rest:MotionRest,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & Maybe<&2,T.LedgerView>) -> IO(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match pair:
    case (world,ledger): motion_resource_done(rows,lookups,world,ledger,rest)
def motion_looked(rows:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,rest:MotionRest,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,E.Lookup<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> IO(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match pair:
    case (world,lookups): motion_resource(rows,lookups,rest,S.with_ledger(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.LedgerView,world,P.motion_ledger_get))
def motion_queried(handles:List<&2,S.Handle<T.MotionSchema>>,rest:MotionRest,pair:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> IO(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match pair:
    case (world,rows): motion_looked(rows,rest,motion_lookups(handles,world,[]))
def motion_observe(owner:F.MotionFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock) -> IO(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match owner:
    case F.MotionFailure{H.Host{world,logs,+bindings,name,step,prior,events},iteration,+failed}:
      motion_queried(motion_append_handle(H.binding_find(T.MotionSchema,"p",bindings),motion_append_handle(H.binding_find(T.MotionSchema,"q",bindings),motion_append_handle(H.binding_find(T.MotionSchema,"r",bindings),failed))),MotionRest{logs,bindings,name,step,prior,events,iteration,failed,audit,run,clock},Q.each(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,T.MotionLedger,T.MotionMode,P.position_get,P.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),Q.Required{},world))
def motion_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:F.MotionFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match system:
    case K.System{_,_,K.Snapshot{},_,_,_,_}: motion_observe(owner,audit,run,clock)
    case other: F.motion_invoke(other,mode,count,clock,owner,audit,run)
def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<F.MotionFailure,S.Handle<T.MotionSchema>>) -> IO(D.Dispatched<F.MotionFailure,S.Handle<T.MotionSchema>>):
  D.tick(F.MotionFailure,S.Handle<T.MotionSchema>,F.motion_presence,motion_invoke,F.motion_barrier,F.motion_transition,F.motion_frame,nodes,"MotionLedger","MotionMode",runtime)

def health_row(row:O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>) -> String:
  J.render_query(T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,J.render_vitals,J.render_armor,J.render_tracked,row)
def health_lookup_done(+handle:S.Handle<T.HealthSchema>,next:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> -> List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>> -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,seen:List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & T.Access<O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>:
  match pair:
    case (world,result): next(world,List.append(&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,seen,[E.Lookup{"",handle,result}]))
def health_lookups(handles:List<&2,S.Handle<T.HealthSchema>>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,seen:List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>:
  match handles:
    case Nil{}: (world,seen)
    case Con{+handle,rest}: health_lookup_done(handle,w => rows => health_lookups(rest,w,rows),seen,Q.lookup(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,T.HealthLedger,T.HealthMode,P.vitals_get,P.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),Q.Required{},world,handle))
def health_append_handle(found:Maybe<&2,S.Handle<T.HealthSchema>>,rest:List<&2,S.Handle<T.HealthSchema>>) -> List<&2,S.Handle<T.HealthSchema>>:
  match found:
    case None{}: rest
    case Some{handle}: handle <> rest
type HealthRest is Type:
  HealthRest{logs:RH.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,iteration:U32,failed:List<&2,S.Handle<T.HealthSchema>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock}

def health_guard(valid:Bool,owner:D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match valid:
    case True{}: IO.pure(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>,owner)
    case False{}: IO.die(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>,22,"quiet observation full-field guard")
def health_resource_done(+rows:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,+lookups:List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,+ledger:Maybe<&2,T.LedgerView>,rest:HealthRest) -> IO(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match rest:
    case HealthRest{logs,+bindings,name,+step,prior,events,+iteration,failed,audit,run,clock}:
      health_guard(FV.health(FV.seed_count(T.HealthSchema,bindings),iteration,step,rows,lookups,ledger),D.Invoked{F.HealthFailure{H.Host{world,logs,bindings,name,step,prior,List.append(&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>,events,[E.FailureObserved{"Health",iteration,step,rows,ledger,lookups}])},iteration,failed},audit,run,T.Success{},clock,None{},[]})
def health_resource(rows:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,lookups:List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,rest:HealthRest,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & Maybe<&2,T.LedgerView>) -> IO(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match pair:
    case (world,ledger): health_resource_done(rows,lookups,world,ledger,rest)
def health_looked(rows:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,rest:HealthRest,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,E.Lookup<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match pair:
    case (world,lookups): health_resource(rows,lookups,rest,S.with_ledger(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.LedgerView,world,P.health_ledger_get))
def health_queried(handles:List<&2,S.Handle<T.HealthSchema>>,rest:HealthRest,pair:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> IO(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match pair:
    case (world,rows): health_looked(rows,rest,health_lookups(handles,world,[]))
def health_observe(owner:F.HealthFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock) -> IO(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match owner:
    case F.HealthFailure{H.Host{world,logs,+bindings,name,step,prior,events},iteration,+failed}:
      health_queried(health_append_handle(H.binding_find(T.HealthSchema,"p",bindings),health_append_handle(H.binding_find(T.HealthSchema,"q",bindings),health_append_handle(H.binding_find(T.HealthSchema,"r",bindings),failed))),HealthRest{logs,bindings,name,step,prior,events,iteration,failed,audit,run,clock},Q.each(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,T.HealthLedger,T.HealthMode,P.vitals_get,P.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),Q.Required{},world))
def health_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:F.HealthFailure,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match system:
    case K.System{_,_,K.Snapshot{},_,_,_,_}: health_observe(owner,audit,run,clock)
    case other: F.health_invoke(other,mode,count,clock,owner,audit,run)
def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<F.HealthFailure,S.Handle<T.HealthSchema>>) -> IO(D.Dispatched<F.HealthFailure,S.Handle<T.HealthSchema>>):
  D.tick(F.HealthFailure,S.Handle<T.HealthSchema>,F.health_presence,health_invoke,F.health_barrier,F.health_transition,F.health_frame,nodes,"HealthLedger","HealthMode",runtime)
