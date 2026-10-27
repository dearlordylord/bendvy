import Base
import ./execution-prepared.bend as Prep
import ./world.bend as W
import ./execution-state.bend as State
import ./execution-parallel-scope-registry.bend as Tree
import ./owner-product.bend as Product
import ./change-tick.bend as Tick

def clocked(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,leftPublish:List<&2,U32> -> Tick.Tick -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> -> L -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & L,rightPublish:List<&2,U32> -> Tick.Tick -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> -> R -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & R,ids:List<&2,U32>,owners:Product.Owner<L,R>,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Tick.Tick) -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Product.Owner<L,R>:
  match result:
    case (world,tick):Tree.publish_pair(W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,R,leftPublish,rightPublish,ids,tick,world,owners)
def pending_checked(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,-L:Type,-R:Type,leftPublish:List<&2,U32> -> Tick.Tick -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> -> L -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & L,rightPublish:List<&2,U32> -> Tick.Tick -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> -> R -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & R,ids:List<&2,U32>,result:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (Product.Owner<L,R> & Bool)) -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Product.Owner<L,R>:
  match result:
    case (world,(owners,False{})):(world,owners)
    case (world,(owners,True{})):clocked(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,L,R,leftPublish,rightPublish,ids,owners,W.advance_clock(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world))
def published_owners(~World:Type,-L:Type,-R:Type,-HL:Type,-HR:Type,left:HL -> L,right:HR -> R,result:World & Product.Owner<HL,HR>) -> World & Product.Owner<L,R>:
  match result:
    case (world,held):(world,Tree.restore_pair(L,R,HL,HR,left,right,held))
def pending_owners(~World:Type,-L:Type,-R:Type,-HL:Type,-HR:Type,left:HL -> L,right:HR -> R,result:World & (Product.Owner<HL,HR> & Bool)) -> World & (Product.Owner<L,R> & Bool):
  match result:
    case (world,(held,pending)):(world,(Tree.restore_pair(L,R,HL,HR,left,right,held),pending))
def apply_compiled(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,+ids:List<&2,U32>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,left:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CR,RR>,R,Error,Out>) -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Product.Owner<L,R>:
  match left right:
    case Tree.Runtime{HL,restoreLeft,l,_,_,_,_,lp,ls,_,_} Tree.Runtime{HR,restoreRight,r,_,_,_,_,rp,rs,_,_}:published_owners(~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,R,HL,HR,restoreLeft,restoreRight,pending_checked(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,HL,HR,ls,rs,ids,Tree.pending_pair(W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,HL,HR,lp,rp,ids,world,Product.Owner{l,r})))
def apply_deferred(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),ids:List<&2,U32>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,owners:Product.Owner<L,R>) -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & Product.Owner<L,R>:
  match owners:
    case Product.Owner{l,r}:apply_compiled(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,ids,world,Tree.compile(~S,~CL,~RL,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~L,~left,l),Tree.compile(~S,~CR,~RR,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~R,~right,r))
def pending_compiled(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,ids:List<&2,U32>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,left:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CL,RL>,L,Error,Out>,right:Tree.Runtime<S,W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Prep.Permit<S,Product.Owner<CL,CR>>,State.Scope<S,CR,RR>,R,Error,Out>) -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (Product.Owner<L,R> & Bool):
  match left right:
    case Tree.Runtime{HL,restoreLeft,l,_,_,_,_,lp,_,_,_} Tree.Runtime{HR,restoreRight,r,_,_,_,_,rp,_,_,_}:pending_owners(~W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,L,R,HL,HR,restoreLeft,restoreRight,Tree.pending_pair(W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,HL,HR,lp,rp,ids,world,Product.Owner{l,r}))
def pending(~S:Data,~CL:Type,~CR:Type,~RL:Type,~RR:Type,~E:Data,~Error:Data,~Out:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Product.Owner<CL,CR>,~CL,~RL,~E,~Error,~Out,~L),~right:Tree.Selection(~S,~Product.Owner<CL,CR>,~CR,~RR,~E,~Error,~Out,~R),ids:List<&2,U32>,world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,owners:Product.Owner<L,R>) -> W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E> & (Product.Owner<L,R> & Bool):
  match owners:
    case Product.Owner{l,r}:pending_compiled(~S,~CL,~CR,~RL,~RR,~E,~Error,~Out,~L,~R,ids,world,Tree.compile(~S,~CL,~RL,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~L,~left,l),Tree.compile(~S,~CR,~RR,~E,~Error,~Out,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~R,~right,r))
