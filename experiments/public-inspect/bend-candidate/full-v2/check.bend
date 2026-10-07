import Base
import ../inspect.bend as I
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/capabilities.bend as Cap

# Check-condition projection has no Inspector instance or reader registration.
# Closed setup provides presence requirements and read-only declaration grants.
type Error is Data:
  MissingRuntimeRequirements{resources:List<&2,String>}
type Plan<-S:Data,-Store:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Plan{required:W.World<S,Store,R,E> -> W.World<S,Store,R,E> & List<&2,String>,caps:Ops(I.Frame<S,Store,R,E>)}
type Checked<S:Data,Store:Type,R:Type,E:Data> is Type:
  Checked{world:W.World<S,Store,R,E>,result:Result<&2,&2,Error,Bool>}
def completed(~S:Data,~Store:Type,~R:Type,~E:Data,result:I.Frame<S,Store,R,E> & Bool) -> Checked<S,Store,R,E>:
  match result:
    case (I.Frame{world,_},value):Checked{world,Done{value}}
def ready(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Bool,~caps:Ops(I.Frame<S,Store,R,E>),args:A,result:W.World<S,Store,R,E> & List<&2,String>) -> Checked<S,Store,R,E>:
  match result:
    case (world,[]):completed(~S,~Store,~R,~E,Cap.invoke(~Ops,~A,~Bool,~body,~I.Frame<S,Store,R,E>,~caps,args,I.Frame{world,0}))
    case (world,name <> rest):Checked{world,Fail{MissingRuntimeRequirements{name <> rest}}}
def required_field(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,plan:Plan<S,Store,R,E,Ops>) -> W.World<S,Store,R,E> -> W.World<S,Store,R,E> & List<&2,String>:
  match plan:
    case Plan{required,_}:required
def caps(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,plan:Plan<S,Store,R,E,Ops>) -> Ops(I.Frame<S,Store,R,E>):
  match plan:
    case Plan{_,caps}:caps
def run(~S:Data,~Store:Type,~R:Type,~E:Data,~Ops:Type -> Type,~A:Data,~body:@-H:Type -> @-caps:Ops(H) -> A -> H -> H & Bool,~plan:Plan<S,Store,R,E,Ops>,args:A,world:W.World<S,Store,R,E>) -> Checked<S,Store,R,E>:
  ready(~S,~Store,~R,~E,~Ops,~A,~body,~caps(~S,~Store,~R,~E,~Ops,plan),args,required_field(~S,~Store,~R,~E,~Ops,plan)(world))
