import Base
import ./execution-composer-layout.bend as Layout
import ./execution-relation-resource-publication.bend as Publication
import ./execution-relation-context.bend as Context
import ./execution-relation-store.bend as Store
import ./execution-relation-operation.bend as Operation
import ./execution-resource-policy.bend as Policy
import ./entity-allocator.bend as Allocator
import ./relation-types.bend as T
import ./change-tick.bend as Tick

type Outcome<-S:Data> is Data:
  Published{receipt:Store.Receipt<S>}
  Undeclared{operation:Operation.Operation<S>}
def Program(~S:Data,~resources:Layout.Layout) -> Type:
  U32 -> U32 -> Allocator.Allocator -> Layout.resources(~S,resources) -> Layout.Route -> Operation.Operation<S> -> Tick.Tick -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>)
def route_equal(left:Layout.Route,right:Layout.Route) -> Bool:
  match left right:
    case Layout.AtLeaf{} Layout.AtLeaf{}:True{}
    case Layout.InLeft{left} Layout.InLeft{right}:route_equal(left,right)
    case Layout.InRight{left} Layout.InRight{right}:route_equal(left,right)
    case _ _:False{}
def empty(~S:Data,~resources:Layout.Layout,_:U32,_:U32,allocator:Allocator.Allocator,owners:Layout.resources(~S,resources),_:Layout.Route,operation:Operation.Operation<S>,_:Tick.Tick) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  (allocator,(owners,Undeclared{operation}))
def published(~S:Data,~resources:Layout.Layout,result:Allocator.Allocator & (Layout.resources(~S,resources) & Store.Receipt<S>)) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  match result:
    case (allocator,(owners,receipt)):(allocator,(owners,Published{receipt}))
def selected(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},matches:Bool,previous:Program(~S,~resources),expected:U32,actual:U32,allocator:Allocator.Allocator,owners:Layout.resources(~S,resources),requested:Layout.Route,operation:Operation.Operation<S>,tick:Tick.Tick) -> Allocator.Allocator & (Layout.resources(~S,resources) & Outcome<S>):
  match matches:
    case False{}:previous(expected,actual,allocator,owners,requested,operation,tick)
    case True{}:published(~S,~resources,Publication.apply(~S,~Layout.resources(~S,resources),~resources,~{==},~route,~valid,~descriptor,~payload,~view,Context.Context{expected},actual,allocator,owners,operation,tick))
# Only the closed declaration's grant factory constructs these branches. Each
# branch captures lexical schema evidence and receives canonical resource owners;
# it cannot run an arbitrary World callback or bypass the existing graph logic.
def extend(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},previous:Program(~S,~resources)) -> Program(~S,~resources):
  expected => actual => allocator => owners => +requested => operation => tick => selected(~S,~resources,~route,~valid,~descriptor,~payload,~view,~protected,route_equal(requested,route),previous,expected,actual,allocator,owners,requested,operation,tick)
