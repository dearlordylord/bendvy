import Base
import ./execution-lifecycle-notices.bend as Notice
import ./execution-composer-layout.bend as Layout
import ./execution-state.bend as State
import ./execution-declaration.bend as D

type Next<-S:Data,-H:Type,-origin:Layout.Layout,-selector:Notice.Selector> is Type:
  Next{next:H -> Notice.Reader<S,origin,selector> -> H & Notice.Reading<S,origin,selector>}
def Ops(~S:Data,~origin:Layout.Layout,~selector:Notice.Selector,H:Type) -> Type:
  Next<S,H,origin,selector>
def next(~S:Data,~H:Type,~origin:Layout.Layout,~selector:Notice.Selector,cap:Next<S,H,origin,selector>,owner:H,reader:Notice.Reader<S,origin,selector>) -> H & Notice.Reading<S,origin,selector>:
  match cap:
    case Next{invoke}:invoke(owner,reader)
def read(~S:Data,~C:Type,~R:Type,~origin:Layout.Layout,~selector:Notice.Selector,scope:State.Scope<S,C,R>,reader:Notice.Reader<S,origin,selector>) -> State.Scope<S,C,R> & Notice.Reading<S,origin,selector>:
  match scope:
    case State.Scope{store,resource,handles,tick,prior,+view}:(State.Scope{store,resource,handles,tick,prior,view},Notice.read(~S,~origin,~selector,view,reader))
def removed(~S:Data,~WC:Type,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{WC == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}) -> D.Declaration<S,C,R,Ops(~S,~(Layout.origin(layout,route)),~(Notice.Removed{Layout.key(layout,route)}))>:
  D.Declaration{Next{read(~S,~C,~R,~(Layout.origin(layout,route)),~(Notice.Removed{Layout.key(layout,route)}))},[D.Access{"removed/" ++ Layout.key(layout,route),D.LifecycleAccess{},D.SharedView{},D.ReadOnly{}}]}
def despawned(~S:Data,~C:Type,~R:Type) -> D.Declaration<S,C,R,Ops(~S,~(Layout.EmptyLayout{}),~(Notice.Despawned{}))>:
  D.Declaration{Next{read(~S,~C,~R,~(Layout.EmptyLayout{}),~(Notice.Despawned{}))},[D.Access{"despawn",D.LifecycleAccess{},D.SharedView{},D.ReadOnly{}}]}
