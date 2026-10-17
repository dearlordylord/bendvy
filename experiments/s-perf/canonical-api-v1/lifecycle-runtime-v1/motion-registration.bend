import Base
import motion-domain.bend as D
import motion-systems.bend as S
import ../dense-runtime-v1/motion.bend as F
import ../dense-runtime-v1/types.bend as Types
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/world.bend as W

type RejectedOwners is Type:
  First{capture:Array<U32>}
  Second{select:S.Instance(~S.select_runner),capture:Array<U32>}
  Third{select:S.Instance(~S.select_runner),reserve:S.Instance(~S.reserve_runner),capture:Array<U32>}
  Fourth{select:S.Instance(~S.select_runner),reserve:S.Instance(~S.reserve_runner),dispose:S.Instance(~S.dispose_runner),capture:Array<U32>}
type Registration is Type:
  Ready{world:D.World(),owners:S.Owners}
  Stopped{world:D.World(),owners:RejectedOwners}
def name(kind:D.Operation) -> String:
  match kind:
    case D.Select{}:"Lifecycle/Select"
    case D.Reserve{}:"Lifecycle/Reserve"
    case D.Dispose{}:"Lifecycle/Dispose"
    case D.Observe{}:"Lifecycle/Observe"
def initial(tag:U32) -> Array<U32>:ANode{ALeaf{0},ALeaf{tag}}
def register(~run:D.World()->Array<U32>->D.Frame->Local.Outcome<D.World(),Array<U32>,Unit,D.Output>,+kind:D.Operation,tag:U32,world:D.World()) -> Local.Registered<Types.MotionSchema,F.Store(),F.Resources(),Nat,Array<U32>,D.Frame,Unit,D.Output,run>:
  Local.register(~Types.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Array<U32>,~D.Frame,~Unit,~D.Output,~run,world,name(kind),D.access(kind),initial(tag))
def observe_registered(select:S.Instance(~S.select_runner),reserve:S.Instance(~S.reserve_runner),dispose:S.Instance(~S.dispose_runner),count:U32,foreign:W.Handle<Types.MotionSchema>,result:Local.Registered<Types.MotionSchema,F.Store(),F.Resources(),Nat,Array<U32>,D.Frame,Unit,D.Output,S.observe_runner>) -> Registration:
  match result:
    case Local.Registered{world,observe}:Ready{world,S.Owners{select,reserve,dispose,observe,D.Frame{count,0,0,None{},None{},foreign,[],[]},1,[],[]}}
    case Local.RegistrationRejected{world,capture}:Stopped{world,Fourth{select,reserve,dispose,capture}}
def dispose_registered(select:S.Instance(~S.select_runner),reserve:S.Instance(~S.reserve_runner),count:U32,foreign:W.Handle<Types.MotionSchema>,result:Local.Registered<Types.MotionSchema,F.Store(),F.Resources(),Nat,Array<U32>,D.Frame,Unit,D.Output,S.dispose_runner>) -> Registration:
  match result:
    case Local.Registered{world,dispose}:observe_registered(select,reserve,dispose,count,foreign,register(~S.observe_runner,D.Observe{},104,world))
    case Local.RegistrationRejected{world,capture}:Stopped{world,Third{select,reserve,capture}}
def reserve_registered(select:S.Instance(~S.select_runner),count:U32,foreign:W.Handle<Types.MotionSchema>,result:Local.Registered<Types.MotionSchema,F.Store(),F.Resources(),Nat,Array<U32>,D.Frame,Unit,D.Output,S.reserve_runner>) -> Registration:
  match result:
    case Local.Registered{world,reserve}:dispose_registered(select,reserve,count,foreign,register(~S.dispose_runner,D.Dispose{},103,world))
    case Local.RegistrationRejected{world,capture}:Stopped{world,Second{select,capture}}
def select_registered(count:U32,foreign:W.Handle<Types.MotionSchema>,result:Local.Registered<Types.MotionSchema,F.Store(),F.Resources(),Nat,Array<U32>,D.Frame,Unit,D.Output,S.select_runner>) -> Registration:
  match result:
    case Local.Registered{world,select}:reserve_registered(select,count,foreign,register(~S.reserve_runner,D.Reserve{},102,world))
    case Local.RegistrationRejected{world,capture}:Stopped{world,First{capture}}
def run(world:D.World(),count:U32,foreign:W.Handle<Types.MotionSchema>) -> Registration:select_registered(count,foreign,register(~S.select_runner,D.Select{},101,world))
