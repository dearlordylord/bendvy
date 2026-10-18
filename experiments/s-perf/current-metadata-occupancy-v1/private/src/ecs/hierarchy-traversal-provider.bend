import Base
import entity-key.bend as Key
import ./relation-types.bend as G
import ./relation-commands.bend as A
import ./relation-reorder.bend as Reorder
import ./world.bend as W
import ./capabilities.bend as Cap
import ./hierarchy-traversal.bend as T
import ./hierarchy-provider.bend as P

# Separate traversal requests avoid computing unrelated snapshot fields.
# Descriptor and World remain hidden by the same rank-two authority boundary.
type Descendants<S:Data> is Data:
  Descendants{entity:W.Handle<S>,order:T.Order}
type Read<H:Type,S:Data> is Type:
  Read{root:Cap.Request<H,W.Handle<S>,Maybe<&2,W.Handle<S>>>,ancestors:Cap.Request<H,W.Handle<S>,Maybe<&2,P.Path<S>>>,descendants:Cap.Request<H,Descendants<S>,Maybe<&2,P.Path<S>>>}
type Selection is Data:
  Ancestors{}
  DescendantOrder{order:T.Order}
def selected(~S:Data,graph:G.Graph<S>,descriptor:G.Descriptor<S>,id:Key.Key,selection:Selection) -> T.Walk:
  match selection:
    case Ancestors{}: T.ancestors(~S,graph,descriptor,id)
    case DescendantOrder{order}: T.descendants(~S,graph,descriptor,id,order)
def store_path(~S:Data,~C:Type,store:A.Store<S,C>,descriptor:G.Descriptor<S>,target:W.Handle<S>,selection:Selection) -> A.Store<S,C> & P.Path<S>:
  match store target:
    case A.Store{components,+graph} W.Handle{+namespace,id}: (A.Store{components,graph},P.path(~S,selected(~S,graph,descriptor,id,selection),namespace))
def present_path(~S:Data,~C:Type,~R:Type,~E:Data,result:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & P.Path<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,P.Path<S>>:
  (world,value) = result
  (world,Some{value})
def checked_path(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,target:W.Handle<S>,selection:Selection) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,P.Path<S>>:
  match observed:
    case (world,False{}): (world,None{})
    case (world,True{}): present_path(~S,~C,~R,~E,W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~P.Path<S>,store => store_path(~S,~C,store,Reorder.descriptor(~S,descriptor),target,selection),world))
def lookup_path(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,target:W.Handle<S>,selection:Selection) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,P.Path<S>>:
  match target:
    case W.Handle{+namespace,+id}: checked_path(~S,~C,~R,~E,~descriptor,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{namespace,id}),W.Handle{namespace,id},selection)
def lookup_ancestors(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,target:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,P.Path<S>>:
  lookup_path(~S,~C,~R,~E,~descriptor,world,target,Ancestors{})
def lookup_descendants(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,request:Descendants<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,P.Path<S>>:
  match request:
    case Descendants{target,order}: lookup_path(~S,~C,~R,~E,~descriptor,world,target,DescendantOrder{order})
def store_root(~S:Data,~C:Type,store:A.Store<S,C>,descriptor:G.Descriptor<S>,target:W.Handle<S>) -> A.Store<S,C> & Maybe<&2,W.Handle<S>>:
  match store target:
    case A.Store{components,+graph} W.Handle{namespace,+id}: (A.Store{components,graph},P.handle(~S,T.root(T.ancestors(~S,graph,descriptor,id),id),namespace))
def checked_root(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,observed:W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Bool,target:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,W.Handle<S>>:
  match observed:
    case (world,False{}): (world,None{})
    case (world,True{}): W.with_store(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Maybe<&2,W.Handle<S>>,store => store_root(~S,~C,store,Reorder.descriptor(~S,descriptor),target),world)
def lookup_root(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,target:W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,W.Handle<S>>:
  match target:
    case W.Handle{+namespace,+id}: checked_root(~S,~C,~R,~E,~descriptor,W.valid(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,W.Handle{namespace,id}),W.Handle{namespace,id})
def root(-H:Type,-S:Data,caps:Read<H,S>,owner:H,target:W.Handle<S>) -> H & Maybe<&2,W.Handle<S>>:
  match caps:
    case Read{Cap.Request{get},_,_}: get(owner,target)
def ancestors(-H:Type,-S:Data,caps:Read<H,S>,owner:H,target:W.Handle<S>) -> H & Maybe<&2,P.Path<S>>:
  match caps:
    case Read{_,Cap.Request{get},_}: get(owner,target)
def descendants(-H:Type,-S:Data,caps:Read<H,S>,owner:H,target:W.Handle<S>,order:T.Order) -> H & Maybe<&2,P.Path<S>>:
  match caps:
    case Read{_,_,Cap.Request{get}}: get(owner,Descendants{target,order})
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.HierarchyDescriptor<S>,~Out:Type,~body:@-H:Type -> Read<H,S> -> W.Handle<S> -> H -> H & Out,target:W.Handle<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Out:
  body(W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Read{Cap.Request{lookup_root(~S,~C,~R,~E,~descriptor)},Cap.Request{lookup_ancestors(~S,~C,~R,~E,~descriptor)},Cap.Request{lookup_descendants(~S,~C,~R,~E,~descriptor)}},target,world)
