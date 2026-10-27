import Base
import ./execution-composer-layout.bend as L
import ./execution-state.bend as State
import ./execution-query-store.bend as QueryStore
import ./execution-resource-store.bend as ResourceStore
import ./execution-resource-query-leaf.bend as Leaf
import ./execution-resource-query-footprint.bend as Footprint
import ./execution-resource-query-composite-task.bend as CompositeTask
import ./execution-resource-query-task.bend as Phase
import ./execution-prepared.bend as Prep
import ./execution-parallel-schedule.bend as Ready
import ./execution-reservation-task.bend as Task
import ./execution-reservation-authority.bend as Authority
import ./owner-product.bend as Product
import ./world.bend as W

# Child fixed interpretation is regenerated from lexical closed factories only.
# Each child restores its retained Node, preserving actual Compilation/Prepared.
def inspected_one(-World:Type,-Held:Type,-Owner:Type,-FP:Data,restore:Held -> Owner,result:World & (Held & Maybe<&2,FP>)) -> World & (Owner & Maybe<&2,FP>):
  match result:
    case (world,(held,footprint)):(world,(restore(held),footprint))
def inspect_one(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,-Owner:Type,ids:List<&2,U32>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,leaf:Leaf.Leaf<S,components,resources,E,Owner,Error,Out>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Owner & Maybe<&2,Footprint.Footprint<S,components,resources>>):
  match leaf:
    case Leaf.Leaf{Held,restore,inspect,_,_,_,held}:inspected_one(W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Held,Owner,Footprint.Footprint<S,components,resources>,restore,inspect(ids,world,held))
def prepared_one(-World:Type,-Held:Type,-Owner:Type,restore:Held -> Owner,result:World & Held) -> World & Owner:
  match result:
    case (world,held):(world,restore(held))
def prepare_one(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,-Owner:Type,ids:List<&2,U32>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,leaf:Leaf.Leaf<S,components,resources,E,Owner,Error,Out>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Owner:
  match leaf:
    case Leaf.Leaf{Held,restore,_,prepare,_,_,held}:prepared_one(W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Held,Owner,restore,prepare(ids,world,held))
def permitted_one(-Held:Type,-Owner:Type,-P:Data,restore:Held -> Owner,result:Held & List<&2,P>) -> Owner & List<&2,P>:
  match result:
    case (held,permits):(restore(held),permits)
def permits_one(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,-Owner:Type,leaf:Leaf.Leaf<S,components,resources,E,Owner,Error,Out>) -> Owner & List<&2,Prep.Permit<S,L.columns(~S,components)>>:
  match leaf:
    case Leaf.Leaf{Held,restore,_,_,_,permits,held}:permitted_one(Held,Owner,Prep.Permit<S,L.columns(~S,components)>,restore,permits(held))
def invoked_one(-H:Type,-Held:Type,-Owner:Type,-Status:Data,restore:Held -> Owner,result:Phase.LeafResult<H,Held,Status>) -> Phase.LeafResult<H,Owner,Status>:
  match result:
    case Phase.LeafResult{scope,held,status}:Phase.LeafResult{scope,restore(held),status}
    case Phase.LeafInventoryRefused{Inventory,inventory,held,status}:Phase.LeafInventoryRefused{Inventory,inventory,restore(held),status}
def invoke_one(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,-Owner:Type,scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,leaf:Leaf.Leaf<S,components,resources,E,Owner,Error,Out>) -> Task.Task<S,Authority.Permit,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Owner,List<&2,Ready.Completed<Error,Out>>>>:
  match leaf:
    case Leaf.Leaf{Held,restore,_,_,invoke,_,held}:Task.bind(S,Authority.Permit,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Held,List<&2,Ready.Completed<Error,Out>>>,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Owner,List<&2,Ready.Completed<Error,Out>>>,invoke(scope,held),result => Task.TDone{invoked_one(State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Held,Owner,List<&2,Ready.Completed<Error,Out>>,restore,result)})
type Node<-Left:Type,-Right:Type,-FP:Data> is Type:
  Node{nodes:Product.Owner<Left,Right>,left:Maybe<&2,FP>,right:Maybe<&2,FP>,parallel:Bool}
def restore_node(-Left:Type,-Right:Type,-FP:Data,node:Node<Left,Right,FP>) -> Product.Owner<Left,Right>:
  match node:
    case Node{nodes,_,_,_}:nodes
def inspection_done(-World:Type,-N:Type,-FP:Data,world:World,node:N,footprint:Maybe<&2,FP>) -> World & (N & Maybe<&2,FP>):
  (world,(node,footprint))
def compatible(~S:Data,~components:L.Layout,~resources:L.Layout,left:Maybe<&2,Footprint.Footprint<S,components,resources>>,right:Maybe<&2,Footprint.Footprint<S,components,resources>>) -> Bool:
  match left right:
    case Some{left} Some{right}:Footprint.compatible(~S,~components,~resources,left,right)
    case _ _:False{}
def inspection_nodes(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,left:Left,+leftFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,right:Right,+rightFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Node<Left,Right,Footprint.Footprint<S,components,resources>> & Maybe<&2,Footprint.Footprint<S,components,resources>>):
  inspection_done(W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,Node<Left,Right,Footprint.Footprint<S,components,resources>>,Footprint.Footprint<S,components,resources>,world,Node{Product.Owner{left,right},leftFootprint,rightFootprint,compatible(~S,~components,~resources,leftFootprint,rightFootprint)},Footprint.combine(~S,~components,~resources,leftFootprint,rightFootprint))
def right_inspected(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,left:Left,+leftFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,result:W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Right & Maybe<&2,Footprint.Footprint<S,components,resources>>)) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Node<Left,Right,Footprint.Footprint<S,components,resources>> & Maybe<&2,Footprint.Footprint<S,components,resources>>):
  match result:
    case (world,(right,rightFootprint)):inspection_nodes(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,left,leftFootprint,world,right,rightFootprint)
def left_inspected(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,+ids:List<&2,U32>,right:Right,result:W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Left & Maybe<&2,Footprint.Footprint<S,components,resources>>)) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Node<Left,Right,Footprint.Footprint<S,components,resources>> & Maybe<&2,Footprint.Footprint<S,components,resources>>):
  match result:
    case (world,(left,footprint)):right_inspected(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,left,footprint,inspect_one(~S,~components,~resources,~E,~Error,~Out,Right,ids,world,makeRight(right)))
def inspect_with_ids(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,+ids:List<&2,U32>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,node:Node<Left,Right,Footprint.Footprint<S,components,resources>>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Node<Left,Right,Footprint.Footprint<S,components,resources>> & Maybe<&2,Footprint.Footprint<S,components,resources>>):
  match node:
    case Node{Product.Owner{left,right},_,_,_}:left_inspected(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,ids,right,inspect_one(~S,~components,~resources,~E,~Error,~Out,Left,ids,world,makeLeft(left)))
def inspect(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,ids:List<&2,U32>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,node:Node<Left,Right,Footprint.Footprint<S,components,resources>>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & (Node<Left,Right,Footprint.Footprint<S,components,resources>> & Maybe<&2,Footprint.Footprint<S,components,resources>>):
  inspect_with_ids(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,ids,world,node)

def right_prepared(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,left:Left,parallel:Bool,leftFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,rightFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,result:W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Right) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Node<Left,Right,Footprint.Footprint<S,components,resources>>:
  match result:
    case (world,right):(world,Node{Product.Owner{left,right},leftFootprint,rightFootprint,parallel})
def left_prepared(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,ids:List<&2,U32>,right:Right,parallel:Bool,leftFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,rightFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,result:W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Left) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Node<Left,Right,Footprint.Footprint<S,components,resources>>:
  match result:
    case (world,left):right_prepared(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,left,parallel,leftFootprint,rightFootprint,prepare_one(~S,~components,~resources,~E,~Error,~Out,Right,ids,world,makeRight(right)))
def prepare_with_ids(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,+ids:List<&2,U32>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,node:Node<Left,Right,Footprint.Footprint<S,components,resources>>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Node<Left,Right,Footprint.Footprint<S,components,resources>>:
  match node:
    case Node{Product.Owner{left,right},lf,rf,parallel}:left_prepared(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,ids,right,parallel,lf,rf,prepare_one(~S,~components,~resources,~E,~Error,~Out,Left,ids,world,makeLeft(left)))
def prepare(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,ids:List<&2,U32>,world:W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,node:Node<Left,Right,Footprint.Footprint<S,components,resources>>) -> W.World<S,L.columns(~S,components),L.resources(~S,resources),E> & Node<Left,Right,Footprint.Footprint<S,components,resources>>:
  prepare_with_ids(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,ids,world,node)
def permitted(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,parallel:Bool,leftFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,rightFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,left:Left & List<&2,Prep.Permit<S,L.columns(~S,components)>>,right:Right & List<&2,Prep.Permit<S,L.columns(~S,components)>>) -> Node<Left,Right,Footprint.Footprint<S,components,resources>> & List<&2,Prep.Permit<S,L.columns(~S,components)>>:
  match left right:
    case (left,lp), (right,rp):(Node{Product.Owner{left,right},leftFootprint,rightFootprint,parallel},List.append(&2,Prep.Permit<S,L.columns(~S,components)>,lp,rp))
def permits(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,node:Node<Left,Right,Footprint.Footprint<S,components,resources>>) -> Node<Left,Right,Footprint.Footprint<S,components,resources>> & List<&2,Prep.Permit<S,L.columns(~S,components)>>:
  match node:
    case Node{Product.Owner{left,right},lf,rf,parallel}:permitted(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,parallel,lf,rf,permits_one(~S,~components,~resources,~E,~Error,~Out,Left,makeLeft(left)),permits_one(~S,~components,~resources,~E,~Error,~Out,Right,makeRight(right)))
def invoked(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,parallel:Bool,leftFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,rightFootprint:Maybe<&2,Footprint.Footprint<S,components,resources>>,result:Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Product.Owner<Left,Right>,List<&2,Ready.Completed<Error,Out>>>) -> Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Node<Left,Right,Footprint.Footprint<S,components,resources>>,List<&2,Ready.Completed<Error,Out>>>:
  match result:
    case Phase.LeafResult{scope,nodes,status}:Phase.LeafResult{scope,Node{nodes,leftFootprint,rightFootprint,parallel},status}
    case Phase.LeafInventoryRefused{Inventory,inventory,nodes,status}:Phase.LeafInventoryRefused{Inventory,inventory,Node{nodes,leftFootprint,rightFootprint,parallel},status}
def invoke(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,node:Node<Left,Right,Footprint.Footprint<S,components,resources>>) -> Task.Task<S,Authority.Permit,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Node<Left,Right,Footprint.Footprint<S,components,resources>>,List<&2,Ready.Completed<Error,Out>>>>:
  match node:
    case Node{Product.Owner{left,right},Some{+lf},Some{+rf},+parallel}:Task.bind(S,Authority.Permit,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Product.Owner<Left,Right>,List<&2,Ready.Completed<Error,Out>>>,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Node<Left,Right,Footprint.Footprint<S,components,resources>>,List<&2,Ready.Completed<Error,Out>>>,CompositeTask.run(~S,~components,~resources,Left,Right,List<&2,Ready.Completed<Error,Out>>,(left => right => List.append(&2,Ready.Completed<Error,Out>,left,right)),(scope => node => invoke_one(~S,~components,~resources,~E,~Error,~Out,Left,scope,makeLeft(node))),(scope => node => invoke_one(~S,~components,~resources,~E,~Error,~Out,Right,scope,makeRight(node))),scope,left,right,lf,rf,[],parallel),result => Task.TDone{invoked(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight,parallel,Some{lf},Some{rf},result)})
    case node:Task.TDone{Phase.LeafResult{scope,node,[]}}
def from_nodes(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,nodes:Product.Owner<Left,Right>) -> Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>:
  Leaf.Leaf{Node<Left,Right,Footprint.Footprint<S,components,resources>>,restore_node(Left,Right,Footprint.Footprint<S,components,resources>),inspect(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight),prepare(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight),invoke(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight),permits(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeLeft,~makeRight),Node{nodes,None{},None{},False{}}}
