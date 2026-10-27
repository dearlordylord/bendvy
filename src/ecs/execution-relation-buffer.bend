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
def Interpreter(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type}) -> Type:
  Context.Context<S,WR,resources,same> -> Layout.Route -> Operation.Operation<S> -> W.World<S,C,WR,E> -> Tick.Tick -> W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>
def choose(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~selected:Layout.Route,~valid:{Layout.grant_valid(~resources,~selected) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,selected) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,selected) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,selected) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~next:Interpreter(~S,~C,~WR,~E,~P,~D,~resources,~same),matches:Bool,context:Context.Context<S,WR,resources,same>,route:Layout.Route,operation:Operation.Operation<S>,world:W.World<S,C,WR,E>,tick:Tick.Tick) -> W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>:
  match matches:
    case False{}:next(context,route,operation,world,tick)
    case True{}:published(~S,~C,~WR,~E,~P,~D,~Context.Binding<S,WR,resources,same,selected,descriptor,payload,view,protected>,route,Publication.apply(~S,~C,~WR,~E,~resources,~same,~selected,~valid,~descriptor,~payload,~view,~protected,Context.Binding{context},world,operation,tick))
# This function is evaluated only as the closed interpreter template argument
# below. Its input comes from the same closed Compilation witness as the caps.
# Runtime catalog inspection never promotes a selected route to a template.
def compile(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},grants:Permission.Relations<S,resources>) -> Interpreter(~S,~C,~WR,~E,~P,~D,~resources,~same):
  match grants:
    case Permission.NoRelations{}:context => route => operation => world => tick => (world,Buffer.RelationUndeclared{route,operation})
    case Permission.RelationAllowed{selected,valid,descriptor,payload,view,protected,rest}:context => +route => operation => world => tick => choose(~S,~C,~WR,~E,~P,~D,~resources,~same,~selected,~valid,~descriptor,~payload,~view,~protected,~compile(~S,~C,~WR,~E,~P,~D,~resources,~same,rest),route_equal(route,selected),context,route,operation,world,tick)
def run(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~interpreter:Interpreter(~S,~C,~WR,~E,~P,~D,~resources,~same),context:Context.Context<S,WR,resources,same>,route:Layout.Route,operation:Operation.Operation<S>,world:W.World<S,C,WR,E>,tick:Tick.Tick) -> W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>:
  interpreter(context,route,operation,world,tick)
def apply(~S:Data,~C:Type,~WR:Type,~E:Data,~P:Type,~D:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~grants:Permission.Relations<S,resources>,context:Context.Context<S,WR,resources,same>,route:Layout.Route,operation:Operation.Operation<S>,world:W.World<S,C,WR,E>,tick:Tick.Tick) -> W.World<S,C,WR,E> & Buffer.Receipt<S,P,D>:
  run(~S,~C,~WR,~E,~P,~D,~resources,~same,~compile(~S,~C,~WR,~E,~P,~D,~resources,~same,grants),context,route,operation,world,tick)
