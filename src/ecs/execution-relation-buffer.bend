import Base
import ./execution-command-buffer.bend as Buffer
import ./execution-command-permission.bend as Permission
import ./execution-relation-command.bend as Commands
import ./execution-relation-context.bend as Context
import ./execution-relation-world-publication.bend as Publication
import ./execution-relation-store.bend as Store
import ./execution-relation-operation.bend as Operation
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick
import ./world.bend as W
import ./relation-types.bend as T
import ./execution-resource-policy.bend as Policy

def commands(~S:Data,~P:Type,~D:Type,~route:Layout.Route) -> Commands.HierarchyCommands<Buffer.Buffer<S,P,D>,S>:
  Commands.hierarchy(~S,~Buffer.Buffer<S,P,D>,~route,~Buffer.relation(~S,~P,~D))
def route_equal(left:Layout.Route,right:Layout.Route) -> Bool:
  match left right:
    case Layout.AtLeaf{} Layout.AtLeaf{}:True{}
    case Layout.InLeft{left} Layout.InLeft{right}:route_equal(left,right)
    case Layout.InRight{left} Layout.InRight{right}:route_equal(left,right)
    case _ _:False{}
def published(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~Binding:Data,route:Layout.Route,result:W.World<S,C,WR,E> & (Binding & Store.Receipt<S>)) -> W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>:
  match result:
    case (world,(_,receipt)):(world,Buffer.RelationPublished{route,receipt})
type Attempt<-S:Data,-C:Type,-WR:Type,-E:Data,-P:Type,-D:Type> is Type:
  Miss{world:W.World<S,C,WR,E>,operation:Operation.Operation<S>}
  Hit{world:W.World<S,C,WR,E>,receipt:Buffer.Receipt<S,P,D>}
def attempted(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,result:W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>) -> Attempt<S,C,WR,E,P,D>:
  match result:
    case (world,receipt):Hit{world,receipt}
def try_selected(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~selected:Layout.Route,~valid:{Layout.grant_valid(~resources,~selected) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,selected) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,selected) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,selected) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},matches:Bool,context:Context.Context<S,WR,resources,same>,route:Layout.Route,operation:Operation.Operation<S>,world:W.World<S,C,WR,E>,tick:Tick.Tick) -> Attempt<S,C,WR,E,P,D>:
  match matches:
    case False{}:Miss{world,operation}
    case True{}:attempted(~S,~C,~WR,~E,~P,~D,published(~S,~C,~WR,~E,~P,~D,~Context.Binding<S,WR,resources,same,selected,descriptor,payload,view,protected>,route,Publication.apply(~S,~C,~WR,~E,~resources,~same,~selected,~valid,~descriptor,~payload,~view,~protected,Context.Binding{context},world,operation,tick)))
def try_grant(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},grants:Permission.Relations<S,resources>,context:Context.Context<S,WR,resources,same>,+route:Layout.Route,operation:Operation.Operation<S>,world:W.World<S,C,WR,E>,tick:Tick.Tick) -> Attempt<S,C,WR,E,P,D>:
  match grants:
    case Permission.NoRelations{}:Miss{world,operation}
    case Permission.RelationAllowed{selected,valid,descriptor,payload,view,protected,_}:try_selected(~S,~C,~WR,~E,~P,~D,~resources,~same,~selected,~valid,~descriptor,~payload,~view,~protected,route_equal(route,selected),context,route,operation,world,tick)
def scan(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},grants:Permission.Relations<S,resources>,+context:Context.Context<S,WR,resources,same>,+route:Layout.Route,+tick:Tick.Tick,result:Attempt<S,C,WR,E,P,D>) -> W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>:
  match grants result:
    case Permission.NoRelations{} Hit{world,receipt}:(world,receipt)
    case Permission.NoRelations{} Miss{world,operation}:(world,Buffer.RelationUndeclared{route,operation})
    case Permission.RelationAllowed{_,_,_,_,_,_,_} Hit{world,receipt}:(world,receipt)
    case Permission.RelationAllowed{selected,valid,descriptor,payload,view,protected,rest} Miss{world,operation}:scan(~S,~C,~WR,~E,~P,~D,~resources,~same,rest,context,route,tick,try_grant(~S,~C,~WR,~E,~P,~D,~resources,~same,Permission.RelationAllowed{selected,valid,descriptor,payload,view,protected,Permission.NoRelations{}},context,route,operation,world,tick))
def apply(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},grants:Permission.Relations<S,resources>,context:Context.Context<S,WR,resources,same>,route:Layout.Route,operation:Operation.Operation<S>,world:W.World<S,C,WR,E>,tick:Tick.Tick) -> W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>:
  scan(~S,~C,~WR,~E,~P,~D,~resources,~same,grants,context,route,tick,Miss{world,operation})
