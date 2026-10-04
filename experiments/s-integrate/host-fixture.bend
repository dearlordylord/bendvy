import Base
import ./types.bend as T
import ./storage.bend as W
import ./identity.bend as I
import ./readers.bend as R
import ./schedule.bend as K
import ./capture.bend as C
import ./dispatcher.bend as D
import ./host.bend as H
import ./host-observations.bend as E
import ./host-render.bend as J
import ./systems.bend as U

type Definition is Data:
  Definition{name:String,kind:K.BodyKind,ledger:Bool,audit:Bool,gated:Bool,reader:Bool}
type Setup is Type:
  Setup{registry:K.Registry,systems:List<&2,K.System>}
def setup_next(next:K.Registry -> List<&2,K.System> -> Setup,systems:List<&2,K.System>,registered:K.Registered) -> Setup:
  match registered:
    case K.Registered{registry,system}: next(registry,system <> systems)
def setup(defs:List<&2,Definition>,registry:K.Registry,systems:List<&2,K.System>) -> Setup:
  match defs:
    case Nil{}: Setup{registry,systems}
    case Con{Definition{name,kind,ledger,audit,gated,reader},tail}:
      setup_next(reg => sys => setup(tail,reg,sys),systems,K.register(registry,name,kind,ledger,audit,gated,reader))
def definitions() -> List<&2,Definition>:
  [Definition{"ForeignLookup",K.ForeignLookup{},False{},False{},False{},False{}},Definition{"A",K.A{},True{},True{},False{},False{}},Definition{"B",K.B{},True{},True{},True{},True{}},Definition{"Fast",K.Fast{},False{},False{},False{},True{}},Definition{"TailInner",K.Tail{},False{},False{},False{},False{}},Definition{"TailOuter",K.Tail{},False{},False{},False{},False{}},Definition{"SeedAlpha",K.Seed{},False{},False{},False{},False{}},Definition{"SeedBeta",K.SeedBeta{},False{},False{},False{},False{}},Definition{"SetOn",K.SetOn{},False{},False{},False{},False{}},Definition{"SetOff",K.SetOff{},False{},False{},False{},False{}},Definition{"Cleanup",K.Cleanup{},False{},False{},False{},False{}},Definition{"Inserts",K.Inserts{},False{},False{},False{},False{}},Definition{"Dispose",K.Dispose{},False{},False{},False{},False{}},Definition{"SpawnS",K.SpawnS{},False{},False{},False{},False{}}]
def by_name_case(found:Bool,system:K.System,tail:Maybe<&2,K.System>) -> Maybe<&2,K.System>:
  match found:
    case True{}: Some{system}
    case False{}: tail
def by_name(+name:String,systems:List<&2,K.System>) -> Maybe<&2,K.System>:
  match systems:
    case Nil{}: None{}
    case Con{K.System{base,+label,kind,ledger,audit,gated,reader},tail}:
      by_name_case(String.eq(name,label),K.System{base,label,kind,ledger,audit,gated,reader},by_name(name,tail))
type Operation is Data:
  Call{name:String,mode:K.Mode}
  Nested{operations:List<&2,Operation>}
  Deferred{}
  Transition{}
type Frame is Data:
  Frame{beta:Bool,tracked:Bool,name:String,snapshot:Bool,operations:List<&2,Operation>}
def node_call(mode:K.Mode,found:Maybe<&2,K.System>,tail:List<&2,K.Node>) -> List<&2,K.Node>:
  match found:
    case Some{system}: K.Call{system,mode} <> tail
    case None{}: K.Call{K.System{4294967295,"Unknown",K.Tail{},False{},False{},False{},False{}},mode} <> tail
def nodes(+systems:List<&2,K.System>,ops:List<&2,Operation>) -> List<&2,K.Node>:
  match ops:
    case Nil{}: []
    case Con{Call{name,mode},tail}: node_call(mode,by_name(name,systems),nodes(systems,tail))
    case Con{Nested{nested},tail}: K.Nested{nodes(systems,nested)} <> nodes(systems,tail)
    case Con{Deferred{},tail}: K.Deferred{} <> nodes(systems,tail)
    case Con{Transition{},tail}: K.StateTransition{} <> nodes(systems,tail)
def frames() -> List<&2,Frame>:
  [Frame{False{},True{},"E0-empty",False{},[]},Frame{False{},True{},"E0-prime",False{},[Call{"Fast",K.Observe{}},Call{"B",K.Observe{}}]},Frame{False{},True{},"E0-seed",False{},[Call{"SeedAlpha",K.Normal{}}]},Frame{True{},False{},"E0-seed.beta",False{},[Call{"SeedBeta",K.Normal{}}]},
   Frame{False{},False{},"E0-pending",True{},[]},Frame{True{},False{},"E0-pending",True{},[]},Frame{False{},True{},"E1-empty",False{},[]},Frame{False{},False{},"E1-before-D",True{},[]},Frame{True{},False{},"E1-before-D",True{},[]},
   Frame{False{},True{},"E1",False{},[Deferred{},Call{"Fast",K.Observe{}}]},Frame{True{},False{},"E1-D.beta",False{},[Deferred{}]},Frame{False{},False{},"E1",True{},[]},Frame{True{},False{},"E1",True{},[]},Frame{True{},False{},"E1-foreign-beta",False{},[Call{"ForeignLookup",K.Normal{}}]},Frame{False{},False{},"E1-foreign-alpha",False{},[Call{"ForeignLookup",K.Normal{}}]},
   Frame{False{},True{},"E2",False{},[Call{"A",K.Normal{}},Call{"Fast",K.Observe{}},Nested{[Call{"B",K.BFail{}},Call{"TailInner",K.Normal{}}]},Call{"TailOuter",K.Normal{}}]},
   Frame{False{},False{},"E3-before-empty",True{},[]},Frame{True{},False{},"E3-before-empty",True{},[]},Frame{False{},True{},"E3-empty",False{},[]},Frame{False{},False{},"E3-after-empty",True{},[]},Frame{True{},False{},"E3-after-empty",True{},[]},Frame{False{},True{},"E3",False{},[Call{"Fast",K.Observe{}}]},
   Frame{False{},True{},"E4-retry",False{},[Nested{[Call{"B",K.Retry{}},Call{"TailInner",K.Normal{}}]},Call{"TailOuter",K.Normal{}}]},Frame{False{},False{},"E4-before-empty",True{},[]},Frame{True{},False{},"E4-before-empty",True{},[]},Frame{False{},True{},"E4-empty",False{},[]},Frame{False{},False{},"E4-after-empty",True{},[]},Frame{True{},False{},"E4-after-empty",True{},[]},Frame{False{},True{},"E4-read",False{},[Call{"Fast",K.Observe{}},Call{"B",K.Observe{}}]},
   Frame{False{},True{},"E5",False{},[Deferred{},Call{"Fast",K.Observe{}},Call{"B",K.Observe{}}]},Frame{False{},False{},"E5",True{},[]},Frame{True{},False{},"E5",True{},[]},Frame{False{},True{},"E5-empty-D",False{},[Deferred{}]},Frame{False{},False{},"E5-after-empty-D",True{},[]},Frame{True{},False{},"E5-after-empty-D",True{},[]},
   Frame{False{},True{},"E6-off",False{},[Call{"SetOff",K.Normal{}},Transition{}]},
   Frame{False{},True{},"E6a",False{},[Call{"Cleanup",K.Normal{}}]},
   Frame{False{},False{},"E6a",True{},[]},
   Frame{True{},False{},"E6a",True{},[]},
   Frame{False{},True{},"E6b",False{},[Deferred{},Call{"Fast",K.Observe{}}]},
   Frame{False{},True{},"E6-empty1",False{},[]},
   Frame{False{},True{},"E6-empty2",False{},[]},
   Frame{False{},True{},"E6-empty3",False{},[]},
   Frame{False{},True{},"E6-skip",False{},[Call{"B",K.Observe{}}]},
   Frame{False{},False{},"E6b",True{},[]},
   Frame{True{},False{},"E6b",True{},[]},
   Frame{False{},True{},"E7-fail",False{},[Call{"SetOn",K.Normal{}},Transition{},Nested{[Call{"B",K.ObserveFail{}},Call{"TailInner",K.Normal{}}]},Call{"TailOuter",K.Normal{}}]},
   Frame{False{},True{},"E7-retry",False{},[Nested{[Call{"B",K.Observe{}},Call{"TailInner",K.Normal{}}]},Call{"TailOuter",K.Normal{}},Call{"Fast",K.Observe{}}]},
   Frame{False{},True{},"E8-pending",False{},[Call{"Inserts",K.Normal{}}]},
   Frame{False{},False{},"E8-before-D",True{},[]},
   Frame{True{},False{},"E8-before-D",True{},[]},
   Frame{False{},True{},"E8",False{},[Deferred{},Call{"Fast",K.Observe{}},Call{"B",K.Observe{}}]},
   Frame{False{},False{},"E8",True{},[]},
   Frame{True{},False{},"E8",True{},[]},
   Frame{False{},True{},"E9-pending",False{},[Call{"Dispose",K.Normal{}}]},
   Frame{False{},False{},"E9-before-D",True{},[]},
   Frame{True{},False{},"E9-before-D",True{},[]},
   Frame{False{},True{},"E9",False{},[Deferred{},Call{"Fast",K.Observe{}},Call{"B",K.Observe{}}]},
   Frame{False{},False{},"E9-empty",True{},[]},
   Frame{True{},False{},"E9-empty",True{},[]},
   Frame{False{},True{},"E9-empty-D",False{},[Deferred{}]},
   Frame{False{},True{},"E9-spawn-s",False{},[Call{"SpawnS",K.Normal{}}]},
   Frame{False{},False{},"E9-s-pending",True{},[]},
   Frame{True{},False{},"E9-s-pending",True{},[]},
   Frame{False{},True{},"E9-s-live",False{},[Deferred{}]},
   Frame{False{},False{},"E9-s",True{},[]},
   Frame{True{},False{},"E9-s",True{},[]}]
type MotionLane is Type:
  MotionLane{alpha:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,beta:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,systems:List<&2,K.System>,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>}
def motion_collected(beta:Bool,other:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,systems:List<&2,K.System>,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> MotionLane:
  match beta:
    case True{}: MotionLane{other,runtime,systems,events}
    case False{}: MotionLane{runtime,other,systems,events}
def motion_collect(beta:Bool,other:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,systems:List<&2,K.System>,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,result:D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>) -> MotionLane:
  match result:
    case D.Dispatched{D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},_}:
      motion_collected(beta,other,systems,List.append(&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>,events,produced),D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,[]},registry,readers,clock,audit,style,escaped,observations,nextMode})
def motion_snapshot_registered(tracked:Bool,name:String,owner:H.MotionHost(),readers:R.Readers,clock:R.Clock,audit:Maybe<D.Audit>,style:C.Style,escaped:List<&2,W.Handle<T.MotionSchema>>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,registration:K.Registered) -> IO(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>):
  match registration:
    case K.Registered{registry,system}: H.motion_dispatch(tracked,name,[K.Call{system,K.Normal{}}],D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode})
def motion_frame(snapshot:Bool,tracked:Bool,name:String,steps:List<&2,K.Node>,runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>):
  match snapshot runtime:
    case False{} state: H.motion_dispatch(tracked,name,steps,state)
    case True{} D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      motion_snapshot_registered(tracked,name,owner,readers,clock,audit,style,escaped,observations,nextMode,K.register(registry,"Snapshot",K.Snapshot{},True{},False{},False{},False{}))
def motion_choose(beta:Bool,tracked:Bool,name:String,snapshot:Bool,ops:List<&2,Operation>,lane:MotionLane) -> IO(MotionLane):
  match beta lane:
    case False{} MotionLane{alpha,beta,+systems,events}: IO.bind(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,MotionLane,motion_frame(snapshot,tracked,name,nodes(systems,ops),alpha),result => IO.pure(MotionLane,motion_collect(False{},beta,systems,events,result)))
    case True{} MotionLane{alpha,beta,+systems,events}: IO.bind(D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,MotionLane,motion_frame(snapshot,tracked,name,nodes(systems,ops),beta),result => IO.pure(MotionLane,motion_collect(True{},alpha,systems,events,result)))
def motion_foreign_put(label:String,found:Maybe<&2,W.Handle<T.MotionSchema>>,runtime:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>:
  match found runtime:
    case Some{handle} D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,events},registry,readers,clock,audit,style,escaped,observations,nextMode}: D.Runtime{H.Host{world,logs,E.Binding{label,handle} <> bindings,worldName,step,prior,events},registry,readers,clock,audit,style,escaped,observations,nextMode}
    case None{} state: state
def motion_foreign_prepare(beta:Bool,lane:MotionLane) -> MotionLane:
  match beta lane:
    case False{} MotionLane{alpha,D.Runtime{H.Host{world,logs,+bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},systems,events}: MotionLane{motion_foreign_put("z",H.binding_find(T.MotionSchema,"z",bindings),alpha),D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},systems,events}
    case True{} MotionLane{D.Runtime{H.Host{world,logs,+bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},beta,systems,events}: MotionLane{D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},motion_foreign_put("a",H.binding_find(T.MotionSchema,"a",bindings),beta),systems,events}
def motion_choose_foreign(isForeign:Bool,+beta:Bool,tracked:Bool,name:String,snapshot:Bool,ops:List<&2,Operation>,lane:MotionLane) -> IO(MotionLane):
  match isForeign:
    case True{}: motion_choose(beta,tracked,name,snapshot,ops,motion_foreign_prepare(beta,lane))
    case False{}: motion_choose(beta,tracked,name,snapshot,ops,lane)
def motion_run(plan:List<&2,Frame>,lane:MotionLane) -> IO(MotionLane):
  match plan:
    case Nil{}: IO.pure(MotionLane,lane)
    case Con{Frame{beta,tracked,+name,snapshot,ops},+tail}: IO.bind(MotionLane,MotionLane,motion_choose_foreign(Bool.or(String.eq(name,"E1-foreign-alpha"),String.eq(name,"E1-foreign-beta")),beta,tracked,name,snapshot,ops,lane),next => motion_run(tail,next))
def motion_ledger(unit:Unit) -> T.MotionLedger: T.MotionLedger{U.quad(100,101,102,103),4}
def motion_setup_beta(alpha:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,style:C.Style,systems:List<&2,K.System>,result:Setup) -> MotionLane:
  match result:
    case Setup{registry,_}: MotionLane{alpha,D.Runtime{H.initial(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,"beta",world,65536),registry,R.initial(),R.clock(),Some{D.Console{}},style,[],[],None{}},systems,[]}
def motion_setup_alpha(betaWorld:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,+style:C.Style,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,result:Setup) -> MotionLane:
  match result:
    case Setup{registry,systems}: motion_setup_beta(D.Runtime{H.initial(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,"alpha",world,65536),registry,R.initial(),R.clock(),Some{D.Console{}},style,[],[],None{}},betaWorld,style,systems,setup(definitions(),K.initial(),[]))
def motion_created_beta(alpha:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,style:C.Style,result:T.Creation<W.Factory,W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> Maybe<MotionLane>:
  match result:
    case T.CreateRejected{_}: None{}
    case T.Created{_,beta}: Some{motion_setup_alpha(beta,style,alpha,setup(definitions(),K.initial(),[]))}
def motion_created_alpha(style:C.Style,result:T.Creation<W.Factory,W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> Maybe<MotionLane>:
  match result:
    case T.CreateRejected{_}: None{}
    case T.Created{factory,alpha}: motion_created_beta(alpha,style,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~motion_ledger,factory,T.MotionOn{}))
def motion_initial(style:C.Style) -> Maybe<MotionLane>:
  motion_created_alpha(style,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~motion_ledger,I.factory(),T.MotionOn{}))
def motion_emit(lane:MotionLane) -> IO(Unit):
  match lane:
    case MotionLane{_,_,_,events}: IO.print(J.render_list(~E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>,~J.render_motion,events))
def motion_execute(style:C.Style,maybe:Maybe<MotionLane>) -> IO(Unit):
  match maybe:
    case None{}: IO.print("SETUP-REJECTED")
    case Some{lane}: IO.bind(MotionLane,Unit,motion_run(frames(),lane),motion_emit)
type HealthLane is Type:
  HealthLane{alpha:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,beta:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,systems:List<&2,K.System>,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>}
def health_collected(beta:Bool,other:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,systems:List<&2,K.System>,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> HealthLane:
  match beta:
    case True{}: HealthLane{other,runtime,systems,events}
    case False{}: HealthLane{runtime,other,systems,events}
def health_collect(beta:Bool,other:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,systems:List<&2,K.System>,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,result:D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>) -> HealthLane:
  match result:
    case D.Dispatched{D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},_}:
      health_collected(beta,other,systems,List.append(&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>,events,produced),D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,[]},registry,readers,clock,audit,style,escaped,observations,nextMode})
def health_snapshot_registered(tracked:Bool,name:String,owner:H.HealthHost(),readers:R.Readers,clock:R.Clock,audit:Maybe<D.Audit>,style:C.Style,escaped:List<&2,W.Handle<T.HealthSchema>>,observations:List<&2,U.Observation>,nextMode:Maybe<&2,Bool>,registration:K.Registered) -> IO(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>):
  match registration:
    case K.Registered{registry,system}: H.health_dispatch(tracked,name,[K.Call{system,K.Normal{}}],D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode})
def health_frame(snapshot:Bool,tracked:Bool,name:String,steps:List<&2,K.Node>,runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>):
  match snapshot runtime:
    case False{} state: H.health_dispatch(tracked,name,steps,state)
    case True{} D.Runtime{owner,registry,readers,clock,audit,style,escaped,observations,nextMode}:
      health_snapshot_registered(tracked,name,owner,readers,clock,audit,style,escaped,observations,nextMode,K.register(registry,"Snapshot",K.Snapshot{},True{},False{},False{},False{}))
def health_choose(beta:Bool,tracked:Bool,name:String,snapshot:Bool,ops:List<&2,Operation>,lane:HealthLane) -> IO(HealthLane):
  match beta lane:
    case False{} HealthLane{alpha,beta,+systems,events}: IO.bind(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,HealthLane,health_frame(snapshot,tracked,name,nodes(systems,ops),alpha),result => IO.pure(HealthLane,health_collect(False{},beta,systems,events,result)))
    case True{} HealthLane{alpha,beta,+systems,events}: IO.bind(D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,HealthLane,health_frame(snapshot,tracked,name,nodes(systems,ops),beta),result => IO.pure(HealthLane,health_collect(True{},alpha,systems,events,result)))
def health_foreign_put(label:String,found:Maybe<&2,W.Handle<T.HealthSchema>>,runtime:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>:
  match found runtime:
    case Some{handle} D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,events},registry,readers,clock,audit,style,escaped,observations,nextMode}: D.Runtime{H.Host{world,logs,E.Binding{label,handle} <> bindings,worldName,step,prior,events},registry,readers,clock,audit,style,escaped,observations,nextMode}
    case None{} state: state
def health_foreign_prepare(beta:Bool,lane:HealthLane) -> HealthLane:
  match beta lane:
    case False{} HealthLane{alpha,D.Runtime{H.Host{world,logs,+bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},systems,events}: HealthLane{health_foreign_put("z",H.binding_find(T.HealthSchema,"z",bindings),alpha),D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},systems,events}
    case True{} HealthLane{D.Runtime{H.Host{world,logs,+bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},beta,systems,events}: HealthLane{D.Runtime{H.Host{world,logs,bindings,worldName,step,prior,produced},registry,readers,clock,audit,style,escaped,observations,nextMode},health_foreign_put("a",H.binding_find(T.HealthSchema,"a",bindings),beta),systems,events}
def health_choose_foreign(isForeign:Bool,+beta:Bool,tracked:Bool,name:String,snapshot:Bool,ops:List<&2,Operation>,lane:HealthLane) -> IO(HealthLane):
  match isForeign:
    case True{}: health_choose(beta,tracked,name,snapshot,ops,health_foreign_prepare(beta,lane))
    case False{}: health_choose(beta,tracked,name,snapshot,ops,lane)
def health_run(plan:List<&2,Frame>,lane:HealthLane) -> IO(HealthLane):
  match plan:
    case Nil{}: IO.pure(HealthLane,lane)
    case Con{Frame{beta,tracked,+name,snapshot,ops},+tail}: IO.bind(HealthLane,HealthLane,health_choose_foreign(Bool.or(String.eq(name,"E1-foreign-alpha"),String.eq(name,"E1-foreign-beta")),beta,tracked,name,snapshot,ops,lane),next => health_run(tail,next))
def health_ledger(unit:Unit) -> T.HealthLedger: T.HealthLedger{U.quad(100,101,102,103),4}
def health_setup_beta(alpha:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,style:C.Style,systems:List<&2,K.System>,result:Setup) -> HealthLane:
  match result:
    case Setup{registry,_}: HealthLane{alpha,D.Runtime{H.initial(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,"beta",world,65536),registry,R.initial(),R.clock(),Some{D.Console{}},style,[],[],None{}},systems,[]}
def health_setup_alpha(betaWorld:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,+style:C.Style,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,result:Setup) -> HealthLane:
  match result:
    case Setup{registry,systems}: health_setup_beta(D.Runtime{H.initial(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,"alpha",world,65536),registry,R.initial(),R.clock(),Some{D.Console{}},style,[],[],None{}},betaWorld,style,systems,setup(definitions(),K.initial(),[]))
def health_created_beta(alpha:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,style:C.Style,result:T.Creation<W.Factory,W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> Maybe<HealthLane>:
  match result:
    case T.CreateRejected{_}: None{}
    case T.Created{_,beta}: Some{health_setup_alpha(beta,style,alpha,setup(definitions(),K.initial(),[]))}
def health_created_alpha(style:C.Style,result:T.Creation<W.Factory,W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> Maybe<HealthLane>:
  match result:
    case T.CreateRejected{_}: None{}
    case T.Created{factory,alpha}: health_created_beta(alpha,style,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~health_ledger,factory,T.HealthOn{}))
def health_initial(style:C.Style) -> Maybe<HealthLane>:
  health_created_alpha(style,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~health_ledger,I.factory(),T.HealthOn{}))
def health_emit(lane:HealthLane) -> IO(Unit):
  match lane:
    case HealthLane{_,_,_,events}: IO.print(J.render_list(~E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>,~J.render_health,events))
def health_execute(style:C.Style,maybe:Maybe<HealthLane>) -> IO(Unit):
  match maybe:
    case None{}: IO.print("SETUP-REJECTED")
    case Some{lane}: IO.bind(HealthLane,Unit,health_run(frames(),lane),health_emit)
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("{\"kind\":\"Lane\",\"schema\":\"Motion\",\"style\":\"returned-owner\"}")
    motion_execute(C.Returned{},motion_initial(C.Returned{}))
    IO.print("{\"kind\":\"Lane\",\"schema\":\"Motion\",\"style\":\"regenerated-closure\"}")
    motion_execute(C.Regenerated{},motion_initial(C.Regenerated{}))
    IO.print("{\"kind\":\"Lane\",\"schema\":\"Health\",\"style\":\"returned-owner\"}")
    health_execute(C.Returned{},health_initial(C.Returned{}))
    IO.print("{\"kind\":\"Lane\",\"schema\":\"Health\",\"style\":\"regenerated-closure\"}")
    health_execute(C.Regenerated{},health_initial(C.Regenerated{}))
    return Unit{}
