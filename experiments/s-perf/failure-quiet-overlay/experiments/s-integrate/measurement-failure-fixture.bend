import Base
import ./types.bend as T
import ./systems.bend as U
import ./storage.bend as S
import ./identity.bend as I
import ./host.bend as H
import ./reader-host.bend as RH
import ./host-observations.bend as E
import ./readers.bend as R
import ./dispatcher.bend as D
import ./schedule.bend as K
import ./capture.bend as LC
import ./measurement-bend.bend as M
import ./measurement-lifecycle.bend as L
import ./measurement-failure-host.bend as F

type Definition is Data:
  Definition{name:String,kind:K.BodyKind,ledger:Bool,audit:Bool,reader:Bool}
def definitions() -> List<&2,Definition>:
  [Definition{"Seed",K.Seed{},False{},False{},False{}},Definition{"A",K.A{},True{},True{},False{}},Definition{"B",K.B{},True{},True{},True{}},Definition{"PublicationObserver",K.Fast{},False{},False{},True{}},Definition{"Observe",K.Snapshot{},True{},False{},False{}},Definition{"DisposeTransient",K.Dispose{},False{},False{},False{}}]
type Registered is Type:
  Registered{registry:K.Registry,systems:List<&2,K.System>}
def registered(next:K.Registry -> List<&2,K.System> -> Registered,systems:List<&2,K.System>,value:K.Registered) -> Registered:
  match value:
    case K.Registered{registry,system}: next(registry,system <> systems)
def register(defs:List<&2,Definition>,systems:List<&2,K.System>,registry:K.Registry) -> Registered:
  match defs:
    case Nil{}: Registered{registry,systems}
    case Con{Definition{name,kind,ledger,audit,reader},rest}: registered(reg => sys => register(rest,sys,reg),systems,K.register(registry,name,kind,ledger,audit,False{},reader))

type Ready<-W:Type,-H:Data> is Type:
  Ready{runtime:D.Runtime<W,H>,systems:List<&2,K.System>}
def find_case(hit:Bool,system:K.System,rest:Maybe<&2,K.System>) -> Maybe<&2,K.System>:
  match hit:
    case True{}: Some{system}
    case False{}: rest
def find(+name:String,systems:List<&2,K.System>) -> Maybe<&2,K.System>:
  match systems:
    case Nil{}: None{}
    case Con{K.System{base,+label,kind,ledger,audit,gated,reader},rest}: find_case(String.eq(name,label),K.System{base,label,kind,ledger,audit,gated,reader},find(name,rest))

def motion_registered(world:S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,registered:Registered) -> Ready<F.MotionFailure,S.Handle<T.MotionSchema>>:
  match registered:
    case Registered{registry,systems}: Ready{D.Runtime{F.MotionFailure{H.initial(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,"motion",world,65536),0,[]},registry,R.initial(),R.clock(),Some{D.Recorded{[]}},LC.Returned{},[],[],None{}},systems}
def motion_created(value:T.Creation<S.Factory,S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(Ready<F.MotionFailure,S.Handle<T.MotionSchema>>):
  match value:
    case T.Created{_,world}: IO.pure(Ready<F.MotionFailure,S.Handle<T.MotionSchema>>,motion_registered(world,register(definitions(),[],K.initial())))
    case _: IO.die(Ready<F.MotionFailure,S.Handle<T.MotionSchema>>,13,"factory rejected")
def motion_initial(count:U32) -> IO(Ready<F.MotionFailure,S.Handle<T.MotionSchema>>):
  motion_created(I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,M.motion_ledger,I.factory(),T.MotionOn{}))
def health_registered(world:S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,registered:Registered) -> Ready<F.HealthFailure,S.Handle<T.HealthSchema>>:
  match registered:
    case Registered{registry,systems}: Ready{D.Runtime{F.HealthFailure{H.initial(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,"health",world,65536),0,[]},registry,R.initial(),R.clock(),Some{D.Recorded{[]}},LC.Returned{},[],[],None{}},systems}
def health_created(value:T.Creation<S.Factory,S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(Ready<F.HealthFailure,S.Handle<T.HealthSchema>>):
  match value:
    case T.Created{_,world}: IO.pure(Ready<F.HealthFailure,S.Handle<T.HealthSchema>>,health_registered(world,register(definitions(),[],K.initial())))
    case _: IO.die(Ready<F.HealthFailure,S.Handle<T.HealthSchema>>,13,"factory rejected")
def health_initial(count:U32) -> IO(Ready<F.HealthFailure,S.Handle<T.HealthSchema>>):
  health_created(I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,M.health_ledger,I.factory(),T.HealthOn{}))
