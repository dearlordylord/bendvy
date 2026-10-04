import Base
import ./types.bend as T
import ./storage.bend as W
import ./identity.bend as I
import ./commands.bend as C
import ./structural-host-adapter.bend as A
import ./host.bend as H
import ./reader-host.bend as L
import ./streams.bend as S
import ./readers.bend as R
import ./schedule.bend as Q
import ./capture.bend as LC
import ./dispatcher.bend as D
import ./systems.bend as U
import ./observations.bend as O
import ./payload.bend as P
import ./storage-stage-fixture.bend as F
import ./observation-render.bend as Z
import ./host-observations.bend as E
import ./host-render.bend as J

type Rest<Schema:Data,Ping:Data,V:Data,AV:Data,Flag:Data,LV:Data,Mode:Data> is Type:
  Rest{logs:L.Logs<Schema,Ping>,bindings:List<&2,E.Binding<Schema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<Schema,V,AV,Flag,LV,Mode,Ping>>,registry:Q.Registry,readers:R.Readers,time:R.Clock,audit:Maybe<D.Audit>,style:LC.Style,escaped:List<&2,W.Handle<Schema>>,observations:List<&2,U.Observation>,next:Maybe<&2,Bool>}
def clock(v:R.Clock) -> String:
  match v:
    case R.Clock{tick,frame,retained,number}: U32.show(tick) ++ ":" ++ U32.show(frame) ++ ":" ++ U32.show(retained) ++ ":" ++ U32.show(number)
def state(v:T.ReaderState) -> String:
  match v:
    case T.ReaderState{registered,last,stream}: U32.show(registered) ++ ":" ++ U32.show(last) ++ ":" ++ U32.show(stream)
def interests(v:R.Interests) -> String:
  match v:
    case R.Interests{messages,removed,despawned}: Bool.show(messages) ++ ":" ++ List.show(&2,U32,U32.show,removed) ++ ":" ++ Bool.show(despawned)
def slot(v:R.Slot) -> String:
  match v:
    case R.Slot{key,interest,reader}: U32.show(key) ++ ":" ++ interests(interest) ++ ":" ++ state(reader)
def style(v:LC.Style) -> String:
  match v:
    case LC.Returned{}: "returned"
    case LC.Regenerated{}: "regenerated"
def kind(v:Q.BodyKind) -> String:
  match v:
    case Q.ForeignLookup{}: "ForeignLookup"
    case Q.A{}: "A"
    case Q.B{}: "B"
    case Q.Fast{}: "Fast"
    case Q.Tail{}: "Tail"
    case Q.SetOn{}: "SetOn"
    case Q.SetOff{}: "SetOff"
    case Q.Cleanup{}: "Cleanup"
    case Q.Snapshot{}: "Snapshot"
    case Q.Seed{}: "Seed"
    case Q.SeedBeta{}: "SeedBeta"
    case Q.Inserts{}: "Inserts"
    case Q.Dispose{}: "Dispose"
    case Q.SpawnS{}: "SpawnS"
    case Q.ReadOnlyLate{}: "ReadOnlyLate"
def system(v:Q.System) -> String:
  match v:
    case Q.System{base,name,body,ledger,audit,gated,reader}: U32.show(base) ++ ":" ++ name ++ ":" ++ kind(body) ++ ":" ++ Bool.show(ledger) ++ ":" ++ Bool.show(audit) ++ ":" ++ Bool.show(gated) ++ ":" ++ Bool.show(reader)
def system_text(sys:Q.System,value:T.Four) -> String:
  system(sys) ++ ":" ++ J.render_four(value) ++ ";"
def entries_head(+system:Q.System,tail:List<Q.Entry>,text:String,pair:LC.Local & T.Four) -> List<Q.Entry> & String:
  match pair:
    case (local,value): (Q.Entry{system,local} <> tail,system_text(system,value) ++ text)
def entries_tail(sys:Q.System,local:LC.Local,pair:List<Q.Entry> & String) -> List<Q.Entry> & String:
  match pair:
    case (tail,text): entries_head(sys,tail,text,LC.observe(local))
def entries(values:List<Q.Entry>) -> List<Q.Entry> & String:
  match values:
    case Nil{}: ([],"")
    case Con{Q.Entry{sys,local},tail}: entries_tail(sys,local,entries(tail))
def registry_done(+next:U32,pair:List<Q.Entry> & String) -> Q.Registry & String:
  match pair:
    case (values,text): (Q.Registry{next,values},U32.show(next) ++ ":" ++ text)
def registry(owner:Q.Registry) -> Q.Registry & String:
  match owner:
    case Q.Registry{next,values}: registry_done(next,entries(values))
def batch(~V:Data,~show:V -> String,v:S.Batch<V>) -> String:
  match v:
    case S.Batch{tick,count,values}: U32.show(tick) ++ ":" ++ U32.show(count) ++ ":" ++ List.show(&2,V,show,values)
def handle(-Schema:Data,v:W.Handle<Schema>) -> String:
  match v:
    case W.Handle{namespace,id}: U32.show(namespace) ++ ":" ++ U32.show(id)
def binding(-Schema:Data,v:E.Binding<Schema>) -> String:
  match v:
    case E.Binding{label,h}: label ++ ":" ++ handle(Schema,h)
def observation(v:U.Observation) -> String:
  match v:
    case U.MainObserved{view}: J.render_access(T.MainView,J.render_main_view,view)
    case U.LedgerObserved{view}: J.render_optional(T.LedgerView,J.render_ledger,view)
    case U.ReservedObserved{view}: "reserved:" ++ J.render_access(T.MainView,J.render_main_view,view)
def registry_audit_done(present:Bool,pair:Q.Registry & String) -> Q.Registry & String:
  match pair:
    case (reg,text): (reg,text ++ "|audit=" ++ Bool.show(present))
def registry_audit(reg:Q.Registry,present:Bool) -> Q.Registry & String:
  registry_audit_done(present,registry(reg))
def motion_main(value:U32) -> T.Position:
  T.Position{F.vector(value),7}
def motion_ledger(u:Unit) -> T.MotionLedger:
  T.MotionLedger{F.vector(100),4}
def motion_world_seen(rest:Rest<T.MotionSchema,T.MotionPing,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>,regtext:String,pair:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> D.Runtime<H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>,W.Handle<T.MotionSchema>> & String:
  match rest pair:
    case Rest{L.Logs{S.PingLog{S.Buffer{+pc,+ps,+pd,+pf,+pr}},S.LifeLog{S.Buffer{+rc,+rs,+rd,+rf,+rr}},S.LifeLog{S.Buffer{+dc,+ds,+dd,+df,+dr}}},+bindings,+name,+step,+prior,+events,reg,R.Readers{+slots},+time,audit,+sty,+escaped,+obs,+next} Tuple{world,view}:
      (D.Runtime{H.Host{world,L.Logs{S.PingLog{S.Buffer{pc,ps,pd,pf,pr}},S.LifeLog{S.Buffer{rc,rs,rd,rf,rr}},S.LifeLog{S.Buffer{dc,ds,dd,df,dr}}},bindings,name,step,prior,events},reg,R.Readers{slots},time,audit,sty,escaped,obs,next},Z.motion(view) ++ "|ping=" ++ U32.show(pc) ++ ":" ++ U32.show(ps) ++ ":" ++ U32.show(pd) ++ ":" ++ List.show(&2,S.Batch<T.MotionPing>,batch(T.MotionPing,J.render_motion_ping),pf) ++ ":" ++ List.show(&2,S.Batch<T.MotionPing>,batch(T.MotionPing,J.render_motion_ping),pr) ++ "|removed=" ++ U32.show(rc) ++ ":" ++ U32.show(rs) ++ ":" ++ U32.show(rd) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.MotionSchema>>,batch(W.Handle<T.MotionSchema>,handle(T.MotionSchema)),rf) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.MotionSchema>>,batch(W.Handle<T.MotionSchema>,handle(T.MotionSchema)),rr) ++ "|despawned=" ++ U32.show(dc) ++ ":" ++ U32.show(ds) ++ ":" ++ U32.show(dd) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.MotionSchema>>,batch(W.Handle<T.MotionSchema>,handle(T.MotionSchema)),df) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.MotionSchema>>,batch(W.Handle<T.MotionSchema>,handle(T.MotionSchema)),dr) ++ "|bindings=" ++ List.show(&2,E.Binding<T.MotionSchema>,binding(T.MotionSchema),bindings) ++ "|host=" ++ name ++ ":" ++ step ++ ":" ++ J.render_dispatch_outcome(prior) ++ ":" ++ List.show(&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>,J.render_motion,events) ++ "|registry=" ++ regtext ++ "|readers=" ++ List.show(&2,R.Slot,slot,slots) ++ "|clock=" ++ clock(time) ++ "|style=" ++ style(sty) ++ "|escaped=" ++ List.show(&2,W.Handle<T.MotionSchema>,handle(T.MotionSchema),escaped) ++ "|observations=" ++ List.show(&2,U.Observation,observation,obs) ++ "|next=" ++ Maybe.show(&2,Bool,Bool.show,next))
def motion_registry_seen(owner:H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>,readers:R.Readers,time:R.Clock,audit:Maybe<D.Audit>,sty:LC.Style,escaped:List<&2,W.Handle<T.MotionSchema>>,obs:List<&2,U.Observation>,next:Maybe<&2,Bool>,pair:Q.Registry & String) -> D.Runtime<H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>,W.Handle<T.MotionSchema>> & String:
  match owner pair:
    case H.Host{world,logs,bindings,name,step,prior,events} Tuple{reg,text}: motion_world_seen(Rest{logs,bindings,name,step,prior,events,reg,readers,time,audit,sty,escaped,obs,next},text,O.world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,T.VelocityView,T.LedgerView,P.position_get,P.velocity_get,P.motion_ledger_get,world))
def motion_audit_seen(owner:H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>,readers:R.Readers,time:R.Clock,sty:LC.Style,escaped:List<&2,W.Handle<T.MotionSchema>>,obs:List<&2,U.Observation>,next:Maybe<&2,Bool>,reg:Q.Registry,pair:Maybe<D.Audit> & Bool) -> D.Runtime<H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>,W.Handle<T.MotionSchema>> & String:
  match pair:
    case (audit,present): motion_registry_seen(owner,readers,time,audit,sty,escaped,obs,next,registry_audit(reg,present))
def motion_observe(owner:D.Runtime<H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>,W.Handle<T.MotionSchema>>) -> D.Runtime<H.Host<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView>,W.Handle<T.MotionSchema>> & String:
  match owner:
    case D.Runtime{host,reg,readers,time,audit,sty,escaped,obs,next}: motion_audit_seen(host,readers,time,sty,escaped,obs,next,reg,D.audit_present(audit))
def health_main(value:U32) -> T.Vitals:
  T.Vitals{F.vector(value),9,2}
def health_ledger(u:Unit) -> T.HealthLedger:
  T.HealthLedger{F.vector(100),4}
def health_world_seen(rest:Rest<T.HealthSchema,T.HealthPing,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>,regtext:String,pair:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> D.Runtime<H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>,W.Handle<T.HealthSchema>> & String:
  match rest pair:
    case Rest{L.Logs{S.PingLog{S.Buffer{+pc,+ps,+pd,+pf,+pr}},S.LifeLog{S.Buffer{+rc,+rs,+rd,+rf,+rr}},S.LifeLog{S.Buffer{+dc,+ds,+dd,+df,+dr}}},+bindings,+name,+step,+prior,+events,reg,R.Readers{+slots},+time,audit,+sty,+escaped,+obs,+next} Tuple{world,view}:
      (D.Runtime{H.Host{world,L.Logs{S.PingLog{S.Buffer{pc,ps,pd,pf,pr}},S.LifeLog{S.Buffer{rc,rs,rd,rf,rr}},S.LifeLog{S.Buffer{dc,ds,dd,df,dr}}},bindings,name,step,prior,events},reg,R.Readers{slots},time,audit,sty,escaped,obs,next},Z.health(view) ++ "|ping=" ++ U32.show(pc) ++ ":" ++ U32.show(ps) ++ ":" ++ U32.show(pd) ++ ":" ++ List.show(&2,S.Batch<T.HealthPing>,batch(T.HealthPing,J.render_health_ping),pf) ++ ":" ++ List.show(&2,S.Batch<T.HealthPing>,batch(T.HealthPing,J.render_health_ping),pr) ++ "|removed=" ++ U32.show(rc) ++ ":" ++ U32.show(rs) ++ ":" ++ U32.show(rd) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.HealthSchema>>,batch(W.Handle<T.HealthSchema>,handle(T.HealthSchema)),rf) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.HealthSchema>>,batch(W.Handle<T.HealthSchema>,handle(T.HealthSchema)),rr) ++ "|despawned=" ++ U32.show(dc) ++ ":" ++ U32.show(ds) ++ ":" ++ U32.show(dd) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.HealthSchema>>,batch(W.Handle<T.HealthSchema>,handle(T.HealthSchema)),df) ++ ":" ++ List.show(&2,S.Batch<W.Handle<T.HealthSchema>>,batch(W.Handle<T.HealthSchema>,handle(T.HealthSchema)),dr) ++ "|bindings=" ++ List.show(&2,E.Binding<T.HealthSchema>,binding(T.HealthSchema),bindings) ++ "|host=" ++ name ++ ":" ++ step ++ ":" ++ J.render_dispatch_outcome(prior) ++ ":" ++ List.show(&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>,J.render_health,events) ++ "|registry=" ++ regtext ++ "|readers=" ++ List.show(&2,R.Slot,slot,slots) ++ "|clock=" ++ clock(time) ++ "|style=" ++ style(sty) ++ "|escaped=" ++ List.show(&2,W.Handle<T.HealthSchema>,handle(T.HealthSchema),escaped) ++ "|observations=" ++ List.show(&2,U.Observation,observation,obs) ++ "|next=" ++ Maybe.show(&2,Bool,Bool.show,next))
def health_registry_seen(owner:H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>,readers:R.Readers,time:R.Clock,audit:Maybe<D.Audit>,sty:LC.Style,escaped:List<&2,W.Handle<T.HealthSchema>>,obs:List<&2,U.Observation>,next:Maybe<&2,Bool>,pair:Q.Registry & String) -> D.Runtime<H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>,W.Handle<T.HealthSchema>> & String:
  match owner pair:
    case H.Host{world,logs,bindings,name,step,prior,events} Tuple{reg,text}: health_world_seen(Rest{logs,bindings,name,step,prior,events,reg,readers,time,audit,sty,escaped,obs,next},text,O.world(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.VitalsView,T.ArmorView,T.LedgerView,P.vitals_get,P.armor_get,P.health_ledger_get,world))
def health_audit_seen(owner:H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>,readers:R.Readers,time:R.Clock,sty:LC.Style,escaped:List<&2,W.Handle<T.HealthSchema>>,obs:List<&2,U.Observation>,next:Maybe<&2,Bool>,reg:Q.Registry,pair:Maybe<D.Audit> & Bool) -> D.Runtime<H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>,W.Handle<T.HealthSchema>> & String:
  match pair:
    case (audit,present): health_registry_seen(owner,readers,time,audit,sty,escaped,obs,next,registry_audit(reg,present))
def health_observe(owner:D.Runtime<H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>,W.Handle<T.HealthSchema>>) -> D.Runtime<H.Host<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView>,W.Handle<T.HealthSchema>> & String:
  match owner:
    case D.Runtime{host,reg,readers,time,audit,sty,escaped,obs,next}: health_audit_seen(host,readers,time,sty,escaped,obs,next,reg,D.audit_present(audit))
