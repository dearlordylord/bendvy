import Base
import ./world.bend as W
import ./local.bend as Local
import ./captures.bend as Capture
import ./captured-schedule-composition.bend as Comp
# Existing registered captures enter without copying their affine pack.
# Reusable arguments are Data; capture payload L remains arbitrary Type.
type Leaf<-S:Data,-C:Type,-R:Type,-E:Data,-L:Type,-Args:Data,-Error:Data,-Out:Type,-runner:W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>> is Type:
  Leaf{instance:Local.Instance<S,C,R,E,L,Args,Error,Out,runner>,args:Args,enabled:Bool}
def bind(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,instance:Local.Instance<S,C,R,E,L,Args,Error,Out,runner>,args:Args,enabled:Bool) -> Leaf<S,C,R,E,L,Args,Error,Out,runner>:
  Leaf{instance,args,enabled}
def catalog(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,leaf:Leaf<S,C,R,E,L,Args,Error,Out,runner>) -> Leaf<S,C,R,E,L,Args,Error,Out,runner> & List<&2,Comp.Identity>:
  match leaf:
    case Leaf{Local.Instance{+ns,+id,+name,+access,local},args,enabled}:(Leaf{Local.Instance{ns,id,name,access,local},args,enabled},[Comp.Identity{ns,id,name,access}])
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,args:Args,enabled:Bool,result:Local.Run<S,C,R,E,L,Args,Error,Out,runner>) -> Comp.Outcome<W.World<S,C,R,E>,Leaf<S,C,R,E,L,Args,Error,Out,runner>,Error>:
  match result:
    case Local.Completed{world,instance,Done{_},_}:Comp.Completed{world,Leaf{instance,args,enabled}}
    case Local.Completed{world,instance,Fail{error},_}:Comp.Failed{world,Leaf{instance,args,enabled},error}
    case Local.Refused{world,instance,_}:Comp.Refused{world,Leaf{instance,args,enabled}}
def selected(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,allowed:Bool,leaf:Leaf<S,C,R,E,L,Args,Error,Out,runner>,world:W.World<S,C,R,E>) -> Comp.Outcome<W.World<S,C,R,E>,Leaf<S,C,R,E,L,Args,Error,Out,runner>,Error>:
  match allowed leaf:
    case False{}, leaf:Comp.Refused{world,leaf}
    case True{}, Leaf{instance,args,False{}}:Comp.Skipped{world,Leaf{Capture.skip(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,instance),args,False{}}}
    case True{}, Leaf{instance,+args,True{}}:returned(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,args,True{},Capture.run(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,instance,world,args))
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~runner:W.World<S,C,R,E> -> L -> Args -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>,leaf:Leaf<S,C,R,E,L,Args,Error,Out,runner>,world:W.World<S,C,R,E>,id:U32) -> Comp.Outcome<W.World<S,C,R,E>,Leaf<S,C,R,E,L,Args,Error,Out,runner>,Error>:
  match leaf:
    case Leaf{Local.Instance{ns,+actual,name,access,local},args,enabled}:selected(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner,U32.is_eq(actual,id),Leaf{Local.Instance{ns,actual,name,access,local},args,enabled},world)
