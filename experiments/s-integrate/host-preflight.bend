import Base
import ./types.bend as T
import ./storage.bend as W
import ./host.bend as H
import ./dispatcher.bend as D
import ./schedule.bend as Q
import ./readers.bend as R
import ./systems.bend as U
import ./capture.bend as LC
import ./reader-host.bend as L
import ./host-observations.bend as E
import ./host-render.bend as J

def motion_invoke_copy(+system:Q.System,mode:Q.Mode,+count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),W.Handle<T.MotionSchema>>):
  IO.bind(Unit,D.Invoked<H.MotionHost(),W.Handle<T.MotionSchema>>,IO.print("PREFLIGHT-INVOKE:motion:" ++ H.system_name(system) ++ ":" ++ U32.show(count)), _ => H.motion_invoke(system,mode,count,clock,owner,audit,run))
def motion_invoke(system:Q.System,mode:Q.Mode,count:U32,clock:R.Clock,owner:H.MotionHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.MotionHost(),W.Handle<T.MotionSchema>>):
  motion_invoke_copy(system,mode,count,clock,owner,audit,run)

def motion_tick(nodes:List<&2,Q.Node>,runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>):
  D.tick(~H.MotionHost(),~W.Handle<T.MotionSchema>,~H.motion_presence,~motion_invoke,~H.motion_barrier,~H.motion_transition,~H.motion_frame,nodes,"MotionLedger","MotionMode",runtime)
def motion_without_ledger(runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>:
  match runtime:
    case D.Runtime{H.Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}: D.Runtime{H.Host{W.World{ns,next,rows,pending,None{},mode},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}
def motion_without_audit(runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>:
  match runtime:
    case D.Runtime{owner,registry,readers,clock,audit,sty,escaped,obs,desired}: D.Runtime{owner,registry,readers,clock,None{},sty,escaped,obs,desired}
def motion_off(runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>:
  match runtime:
    case D.Runtime{H.Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}: D.Runtime{H.Host{W.World{ns,next,rows,pending,ledger,T.MotionOff{}},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}
def health_invoke_copy(+system:Q.System,mode:Q.Mode,+count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),W.Handle<T.HealthSchema>>):
  IO.bind(Unit,D.Invoked<H.HealthHost(),W.Handle<T.HealthSchema>>,IO.print("PREFLIGHT-INVOKE:health:" ++ H.system_name(system) ++ ":" ++ U32.show(count)), _ => H.health_invoke(system,mode,count,clock,owner,audit,run))
def health_invoke(system:Q.System,mode:Q.Mode,count:U32,clock:R.Clock,owner:H.HealthHost(),audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<H.HealthHost(),W.Handle<T.HealthSchema>>):
  health_invoke_copy(system,mode,count,clock,owner,audit,run)

def health_tick(nodes:List<&2,Q.Node>,runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>):
  D.tick(~H.HealthHost(),~W.Handle<T.HealthSchema>,~H.health_presence,~health_invoke,~H.health_barrier,~H.health_transition,~H.health_frame,nodes,"HealthLedger","HealthMode",runtime)
def health_without_ledger(runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>:
  match runtime:
    case D.Runtime{H.Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}: D.Runtime{H.Host{W.World{ns,next,rows,pending,None{},mode},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}
def health_without_audit(runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>:
  match runtime:
    case D.Runtime{owner,registry,readers,clock,audit,sty,escaped,obs,desired}: D.Runtime{owner,registry,readers,clock,None{},sty,escaped,obs,desired}
def health_off(runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>:
  match runtime:
    case D.Runtime{H.Host{W.World{ns,next,rows,pending,ledger,mode},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}: D.Runtime{H.Host{W.World{ns,next,rows,pending,ledger,T.HealthOff{}},logs,bindings,name,step,prior,events},registry,readers,clock,audit,sty,escaped,obs,desired}
def motion_probe_done(label:String,result:D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>):
  match result:
    case D.Dispatched{runtime,+outcome}: IO.bind(Unit,D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,IO.print("PREFLIGHT-RESULT:motion:" ++ label ++ ":" ++ J.render_dispatch_outcome(outcome)), _ => IO.pure(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,D.Dispatched{runtime,outcome}))
def motion_probe(+label:String,nodes:List<&2,Q.Node>,runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>):
  IO.bind(Unit,D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,IO.print("PREFLIGHT-BEGIN:motion:" ++ label), _ => IO.bind(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,motion_tick(nodes,runtime),r => motion_probe_done(label,r)))
def health_probe_done(label:String,result:D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>):
  match result:
    case D.Dispatched{runtime,+outcome}: IO.bind(Unit,D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,IO.print("PREFLIGHT-RESULT:health:" ++ label ++ ":" ++ J.render_dispatch_outcome(outcome)), _ => IO.pure(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,D.Dispatched{runtime,outcome}))
def health_probe(+label:String,nodes:List<&2,Q.Node>,runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>):
  IO.bind(Unit,D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,IO.print("PREFLIGHT-BEGIN:health:" ++ label), _ => IO.bind(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,health_tick(nodes,runtime),r => health_probe_done(label,r)))

def motion_exchange_done(original:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,result:D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>) -> D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>:
  match original result:
    case D.Runtime{owner,unused,readers,clock,audit,style,escaped,observations,nextMode} D.Dispatched{D.Runtime{fresh,registry,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode},outcome}:
      (D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode},D.Dispatched{D.Runtime{fresh,unused,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode},outcome})
def motion_exchange(+label:String,nodes:List<&2,Q.Node>,original:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,fresh:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>):
  match original fresh:
    case D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode} D.Runtime{freshOwner,unused,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode}:
      IO.bind(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,motion_probe(label,nodes,D.Runtime{freshOwner,registry,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode}),result => IO.pure(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,motion_exchange_done(D.Runtime{owner,unused,readers,clock,audit,style,escaped,observations,nextMode},result)))

def health_exchange_done(original:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,result:D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>) -> D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>:
  match original result:
    case D.Runtime{owner,unused,readers,clock,audit,style,escaped,observations,nextMode} D.Dispatched{D.Runtime{fresh,registry,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode},outcome}:
      (D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode},D.Dispatched{D.Runtime{fresh,unused,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode},outcome})
def health_exchange(+label:String,nodes:List<&2,Q.Node>,original:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,fresh:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>):
  match original fresh:
    case D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode} D.Runtime{freshOwner,unused,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode}:
      IO.bind(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,health_probe(label,nodes,D.Runtime{freshOwner,registry,freshReaders,freshClock,freshAudit,freshStyle,freshEscaped,freshObservations,freshNextMode}),result => IO.pure(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,health_exchange_done(D.Runtime{owner,unused,readers,clock,audit,style,escaped,observations,nextMode},result)))
