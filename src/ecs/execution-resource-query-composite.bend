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
import ./execution-owner-continuation.bend as Continuation
import ./owner-product.bend as Product
import ./world.bend as W

# A child retains its hidden inventory until the enclosing group restores it.
# Advancing a phase consumes its callback and retains only the remaining methods.
type Child<-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data> is Type:
  Fresh{-Held:Type,restore:Held -> Owner,inspect:List<&2,U32> -> World -> Held -> World & (Held & Maybe<&2,FP>),prepare:List<&2,U32> -> World -> Held -> World & Held,invoke:H -> Held -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Held,Status>>,permits:Held -> Held & List<&2,P>,held:Held}
  Inspected{-Held:Type,restore:Held -> Owner,prepare:List<&2,U32> -> World -> Held -> World & Held,invoke:H -> Held -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Held,Status>>,permits:Held -> Held & List<&2,P>,held:Held}
  Prepared{-Held:Type,restore:Held -> Owner,invoke:H -> Held -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Held,Status>>,permits:Held -> Held & List<&2,P>,held:Held}
  Invokable{-Held:Type,restore:Held -> Owner,invoke:H -> Held -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Held,Status>>,held:Held}
  Finished{-Held:Type,restore:Held -> Owner,held:Held}
def restore_child(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,child:Child<S,World,H,Owner,P,Status,FP>) -> Owner:
  match child:
    case Fresh{Held,restore,_,_,_,_,held}:restore(held)
    case Inspected{Held,restore,_,_,_,held}:restore(held)
    case Prepared{Held,restore,_,_,held}:restore(held)
    case Invokable{Held,restore,_,held}:restore(held)
    case Finished{Held,restore,held}:restore(held)
def inspected_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,-Held:Type,restore:Held -> Owner,prepare:List<&2,U32> -> World -> Held -> World & Held,invoke:H -> Held -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Held,Status>>,permits:Held -> Held & List<&2,P>,result:World & (Held & Maybe<&2,FP>)) -> World & (Child<S,World,H,Owner,P,Status,FP> & Maybe<&2,FP>):
  match result:
    case (world,(held,footprint)):(world,(Inspected{Held,restore,prepare,invoke,permits,held},footprint))
def inspect_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,ids:List<&2,U32>,world:World,child:Child<S,World,H,Owner,P,Status,FP>) -> World & (Child<S,World,H,Owner,P,Status,FP> & Maybe<&2,FP>):
  match child:
    case Fresh{Held,restore,inspect,prepare,invoke,permits,held}:inspected_one(S,World,H,Owner,P,Status,FP,Held,restore,prepare,invoke,permits,inspect(ids,world,held))
    case child:(world,(child,None{}))
def prepared_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,-Held:Type,restore:Held -> Owner,invoke:H -> Held -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Held,Status>>,permits:Held -> Held & List<&2,P>,result:World & Held) -> World & Child<S,World,H,Owner,P,Status,FP>:
  match result:
    case (world,held):(world,Prepared{Held,restore,invoke,permits,held})
def prepare_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,ids:List<&2,U32>,world:World,child:Child<S,World,H,Owner,P,Status,FP>) -> World & Child<S,World,H,Owner,P,Status,FP>:
  match child:
    case Inspected{Held,restore,prepare,invoke,permits,held}:prepared_one(S,World,H,Owner,P,Status,FP,Held,restore,invoke,permits,prepare(ids,world,held))
    case child:(world,child)
def permitted_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,-Held:Type,restore:Held -> Owner,invoke:H -> Held -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Held,Status>>,result:Held & List<&2,P>) -> Child<S,World,H,Owner,P,Status,FP> & List<&2,P>:
  match result:
    case (held,permits):(Invokable{Held,restore,invoke,held},permits)
def permits_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,child:Child<S,World,H,Owner,P,Status,FP>) -> Child<S,World,H,Owner,P,Status,FP> & List<&2,P>:
  match child:
    case Prepared{Held,restore,invoke,permits,held}:permitted_one(S,World,H,Owner,P,Status,FP,Held,restore,invoke,permits(held))
    case child:(child,[])
def invoked_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,-Held:Type,restore:Held -> Owner,result:Phase.LeafResult<H,Held,Status>) -> Phase.LeafResult<H,Child<S,World,H,Owner,P,Status,FP>,Status>:
  match result:
    case Phase.LeafResult{scope,held,status}:Phase.LeafResult{scope,Finished{Held,restore,held},status}
    case Phase.LeafInventoryRefused{Inventory,inventory,held,status}:Phase.LeafInventoryRefused{Inventory,inventory,Finished{Held,restore,held},status}
def invoke_one(-S:Data,-World:Type,-H:Type,-Owner:Type,-P:Data,-Status:Data,-FP:Data,empty:Status,scope:H,child:Child<S,World,H,Owner,P,Status,FP>) -> Task.Task<S,Authority.Permit,Phase.LeafResult<H,Child<S,World,H,Owner,P,Status,FP>,Status>>:
  match child:
    case Invokable{Held,restore,invoke,held}:Task.bind(S,Authority.Permit,Phase.LeafResult<H,Held,Status>,Phase.LeafResult<H,Child<S,World,H,Owner,P,Status,FP>,Status>,invoke(scope,held),result => Task.TDone{invoked_one(S,World,H,Owner,P,Status,FP,Held,restore,result)})
    case child:Task.TDone{Phase.LeafResult{scope,child,empty}}
type Node<-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data> is Type:
  Node{left:Child<S,World,H,Left,P,Status,FP>,right:Child<S,World,H,Right,P,Status,FP>,leftFootprint:Maybe<&2,FP>,rightFootprint:Maybe<&2,FP>,parallel:Bool}
def restore_node(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,node:Node<S,World,H,Left,Right,P,Status,FP>) -> Product.Owner<Left,Right>:
  match node:
    case Node{left,right,_,_,_}:Product.Owner{restore_child(S,World,H,Left,P,Status,FP,left),restore_child(S,World,H,Right,P,Status,FP,right)}
def inspection_done(-World:Type,-N:Type,-FP:Data,world:World,node:N,footprint:Maybe<&2,FP>) -> World & (N & Maybe<&2,FP>):
  (world,(node,footprint))
def inspection_nodes(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,combine:Maybe<&2,FP> -> Maybe<&2,FP> -> Maybe<&2,FP>,compatible:Maybe<&2,FP> -> Maybe<&2,FP> -> Bool,world:World,left:Child<S,World,H,Left,P,Status,FP>,right:Child<S,World,H,Right,P,Status,FP>,+lf:Maybe<&2,FP>,+rf:Maybe<&2,FP>) -> World & (Node<S,World,H,Left,Right,P,Status,FP> & Maybe<&2,FP>):
  inspection_done(World,Node<S,World,H,Left,Right,P,Status,FP>,FP,world,Node{left,right,lf,rf,compatible(lf,rf)},combine(lf,rf))
def right_inspected(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,combine:Maybe<&2,FP> -> Maybe<&2,FP> -> Maybe<&2,FP>,compatible:Maybe<&2,FP> -> Maybe<&2,FP> -> Bool,left:Child<S,World,H,Left,P,Status,FP>,+lf:Maybe<&2,FP>,result:World & (Child<S,World,H,Right,P,Status,FP> & Maybe<&2,FP>)) -> World & (Node<S,World,H,Left,Right,P,Status,FP> & Maybe<&2,FP>):
  match result:
    case (world,(right,rf)):inspection_nodes(S,World,H,Left,Right,P,Status,FP,combine,compatible,world,left,right,lf,rf)
def left_inspected(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,combine:Maybe<&2,FP> -> Maybe<&2,FP> -> Maybe<&2,FP>,compatible:Maybe<&2,FP> -> Maybe<&2,FP> -> Bool,ids:List<&2,U32>,right:Child<S,World,H,Right,P,Status,FP>,result:World & (Child<S,World,H,Left,P,Status,FP> & Maybe<&2,FP>)) -> World & (Node<S,World,H,Left,Right,P,Status,FP> & Maybe<&2,FP>):
  match result:
    case (world,(left,lf)):right_inspected(S,World,H,Left,Right,P,Status,FP,combine,compatible,left,lf,inspect_one(S,World,H,Right,P,Status,FP,ids,world,right))
def inspect_with_ids(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,combine:Maybe<&2,FP> -> Maybe<&2,FP> -> Maybe<&2,FP>,compatible:Maybe<&2,FP> -> Maybe<&2,FP> -> Bool,+ids:List<&2,U32>,world:World,node:Node<S,World,H,Left,Right,P,Status,FP>) -> World & (Node<S,World,H,Left,Right,P,Status,FP> & Maybe<&2,FP>):
  match node:
    case Node{left,right,_,_,_}:left_inspected(S,World,H,Left,Right,P,Status,FP,combine,compatible,ids,right,inspect_one(S,World,H,Left,P,Status,FP,ids,world,left))
def inspect(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,combine:Maybe<&2,FP> -> Maybe<&2,FP> -> Maybe<&2,FP>,compatible:Maybe<&2,FP> -> Maybe<&2,FP> -> Bool,ids:List<&2,U32>,world:World,node:Node<S,World,H,Left,Right,P,Status,FP>) -> World & (Node<S,World,H,Left,Right,P,Status,FP> & Maybe<&2,FP>):
  inspect_with_ids(S,World,H,Left,Right,P,Status,FP,combine,compatible,ids,world,node)
def right_prepared(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,left:Child<S,World,H,Left,P,Status,FP>,lf:Maybe<&2,FP>,rf:Maybe<&2,FP>,parallel:Bool,result:World & Child<S,World,H,Right,P,Status,FP>) -> World & Node<S,World,H,Left,Right,P,Status,FP>:
  match result:
    case (world,right):(world,Node{left,right,lf,rf,parallel})
def left_prepared(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,ids:List<&2,U32>,right:Child<S,World,H,Right,P,Status,FP>,lf:Maybe<&2,FP>,rf:Maybe<&2,FP>,parallel:Bool,result:World & Child<S,World,H,Left,P,Status,FP>) -> World & Node<S,World,H,Left,Right,P,Status,FP>:
  match result:
    case (world,left):right_prepared(S,World,H,Left,Right,P,Status,FP,left,lf,rf,parallel,prepare_one(S,World,H,Right,P,Status,FP,ids,world,right))
def prepare_with_ids(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,+ids:List<&2,U32>,world:World,node:Node<S,World,H,Left,Right,P,Status,FP>) -> World & Node<S,World,H,Left,Right,P,Status,FP>:
  match node:
    case Node{left,right,lf,rf,parallel}:left_prepared(S,World,H,Left,Right,P,Status,FP,ids,right,lf,rf,parallel,prepare_one(S,World,H,Left,P,Status,FP,ids,world,left))
def prepare(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,ids:List<&2,U32>,world:World,node:Node<S,World,H,Left,Right,P,Status,FP>) -> World & Node<S,World,H,Left,Right,P,Status,FP>:
  prepare_with_ids(S,World,H,Left,Right,P,Status,FP,ids,world,node)
def permitted(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,lf:Maybe<&2,FP>,rf:Maybe<&2,FP>,parallel:Bool,left:Child<S,World,H,Left,P,Status,FP> & List<&2,P>,right:Child<S,World,H,Right,P,Status,FP> & List<&2,P>) -> Node<S,World,H,Left,Right,P,Status,FP> & List<&2,P>:
  match left right:
    case (left,lp), (right,rp):(Node{left,right,lf,rf,parallel},List.append(&2,P,lp,rp))
def permits(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,node:Node<S,World,H,Left,Right,P,Status,FP>) -> Node<S,World,H,Left,Right,P,Status,FP> & List<&2,P>:
  match node:
    case Node{left,right,lf,rf,parallel}:permitted(S,World,H,Left,Right,P,Status,FP,lf,rf,parallel,permits_one(S,World,H,Left,P,Status,FP,left),permits_one(S,World,H,Right,P,Status,FP,right))
def invoked(-S:Data,-World:Type,-H:Type,-Left:Type,-Right:Type,-P:Data,-Status:Data,-FP:Data,lf:Maybe<&2,FP>,rf:Maybe<&2,FP>,parallel:Bool,result:Phase.LeafResult<H,Product.Owner<Child<S,World,H,Left,P,Status,FP>,Child<S,World,H,Right,P,Status,FP>>,Status>) -> Phase.LeafResult<H,Node<S,World,H,Left,Right,P,Status,FP>,Status>:
  match result:
    case Phase.LeafResult{scope,Product.Owner{left,right},status}:Phase.LeafResult{scope,Node{left,right,lf,rf,parallel},status}
    case Phase.LeafInventoryRefused{Inventory,inventory,Product.Owner{left,right},status}:Phase.LeafInventoryRefused{Inventory,inventory,Node{left,right,lf,rf,parallel},status}
def compatible(~S:Data,~components:L.Layout,~resources:L.Layout,left:Maybe<&2,Footprint.Footprint<S,components,resources>>,right:Maybe<&2,Footprint.Footprint<S,components,resources>>) -> Bool:
  match left right:
    case Some{left} Some{right}:Footprint.compatible(~S,~components,~resources,left,right)
    case _ _:False{}
def invoke(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,-Left:Type,-Right:Type,scope:State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,node:Node<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>) -> Task.Task<S,Authority.Permit,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Node<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>,List<&2,Ready.Completed<Error,Out>>>>:
  match node:
    case Node{left,right,Some{+lf},Some{+rf},+parallel}:Task.bind(S,Authority.Permit,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Product.Owner<Child<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>,Child<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>>,List<&2,Ready.Completed<Error,Out>>>,Phase.LeafResult<State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Node<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>,List<&2,Ready.Completed<Error,Out>>>,CompositeTask.run(~S,~components,~resources,Child<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>,Child<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>,List<&2,Ready.Completed<Error,Out>>,(left => right => List.append(&2,Ready.Completed<Error,Out>,left,right)),(scope => child => invoke_one(S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>,[],scope,child)),(scope => child => invoke_one(S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>,[],scope,child)),scope,left,right,lf,rf,[],parallel),result => Task.TDone{invoked(S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>,Some{lf},Some{rf},parallel,result)})
    case node:Task.TDone{Phase.LeafResult{scope,node,[]}}
def child(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,-Owner:Type,leaf:Leaf.Leaf<S,components,resources,E,Owner,Error,Out>) -> Child<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Owner,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>:
  match leaf:
    case Leaf.Leaf{Held,restore,inspect,prepare,invoke,permits,held}:Fresh{Held,restore,inspect,prepare,invoke,permits,held}
def from_children(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,-Left:Type,-Right:Type,pair:Leaf.Leaf<S,components,resources,E,Left,Error,Out> & Leaf.Leaf<S,components,resources,E,Right,Error,Out>) -> Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>:
  match pair:
    case (left,right):Leaf.Leaf{Node<S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>>,restore_node(S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>),inspect(S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>,Footprint.combine(~S,~components,~resources),compatible(~S,~components,~resources)),prepare(S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>),invoke(~S,~components,~resources,~E,~Error,~Out,Left,Right),permits(S,W.World<S,L.columns(~S,components),L.resources(~S,resources),E>,State.Scope<S,QueryStore.Storage<S,components>,ResourceStore.Storage<S,resources>>,Left,Right,Prep.Permit<S,L.columns(~S,components)>,List<&2,Ready.Completed<Error,Out>>,Footprint.Footprint<S,components,resources>),Node{child(~S,~components,~resources,~E,~Error,~Out,Left,left),child(~S,~components,~resources,~E,~Error,~Out,Right,right),None{},None{},False{}}}
def left_made(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,pair:Right & Leaf.Leaf<S,components,resources,E,Left,Error,Out>) -> Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>:
  match pair:
    case (right,left):
      continuation:Continuation.PairedHeader<Leaf.Leaf<S,components,resources,E,Right,Error,Out>,Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>> = Continuation.PairedHeader{Leaf.Leaf<S,components,resources,E,Left,Error,Out>,left,from_children(~S,~components,~resources,~E,~Error,~Out,Left,Right)}
      Continuation.paired_returned(Leaf.Leaf<S,components,resources,E,Right,Error,Out>,Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>,continuation,makeRight(right))
def from_nodes(~S:Data,~components:L.Layout,~resources:L.Layout,~E:Data,~Error:Data,~Out:Data,~Left:Type,~Right:Type,~makeLeft:Left -> Leaf.Leaf<S,components,resources,E,Left,Error,Out>,~makeRight:Right -> Leaf.Leaf<S,components,resources,E,Right,Error,Out>,nodes:Product.Owner<Left,Right>) -> Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>:
  match nodes:
    case Product.Owner{left,right}:
      continuation:Continuation.PairedHeader<Leaf.Leaf<S,components,resources,E,Left,Error,Out>,Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>> = Continuation.PairedHeader{Right,right,left_made(~S,~components,~resources,~E,~Error,~Out,~Left,~Right,~makeRight)}
      Continuation.paired_returned(Leaf.Leaf<S,components,resources,E,Left,Error,Out>,Leaf.Leaf<S,components,resources,E,Product.Owner<Left,Right>,Error,Out>,continuation,makeLeft(left))
