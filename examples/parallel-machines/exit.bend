import Base
import ./declarations.bend as D
import ./payloads.bend as P
import ./bodies.bend as Body
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Commands
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Ops(~S:Data,H:Type,Q:Type) -> Type:D.request_ops(~S)(H)
def declared(~S:Data,~H:Type,~Q:Type,~B:Type,~K:Type,permission:K,result:B & Ops(~S,H,Q)) -> B & (K & Ops(~S,H,Q)):
  match result:
    case (book,ops):(book,(permission,ops))
def declaration(~S:Data,~H:Type,~Q:Type,~commands:Commands.Commands<Q,S,P.Actor<S,D.Mode>>,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~H,~B),~K:Type,~entity:Permission.Grant(~S,~D.component_layout(~S),~Q,~K),book:B,permission:K) -> B & (K & Ops(~S,H,Q)):
  declared(~S,~H,~Q,~B,~K,permission,D.request(~S,~H,~B,~builder,book))
type User<-S:Data> is Type:
  User{handle:W.Handle<S>,retained:Body.Local()}
def authored(~S:Data,~H:Type,~Q:Type,~commands:Commands.Commands<Q,S,P.Actor<S,D.Mode>>,queue:Q,+handle:W.Handle<S>,result:H & (Body.Local() & Sys.Completion<String,String>)) -> H & (Q & (User<S> & Sys.Completion<String,String>)):
  match result:
    case (scope,(retained,completion)):(scope,(Commands.insert_field(~Q,~S,~P.Actor<S,D.Mode>,commands)(queue,handle,P.Actor{ALeaf{1001},D.Waiting{},ALeaf{"exit-authored"}}),(User{handle,retained},completion)))
def body(~S:Data,~H:Type,~Q:Type,~caps:Ops(~S,H,Q),~commands:Commands.Commands<Q,S,P.Actor<S,D.Mode>>,scope:H,queue:Q,user:User<S>) -> H & (Q & (User<S> & Sys.Completion<String,String>)):
  match user:
    case User{handle,retained}:authored(~S,~H,~Q,~commands,queue,handle,Body.exit(~S,~H,~caps,scope,retained))
def Owner(~S:Data) -> Type:Cmd.Owner<S,D.LeftStore(~S),D.Resources(~S),Unit,D.component_layout(~S),route(),Ops(~S),User<S>,String,String,declaration(~S),body(~S)>

def Captures(~S:Data) -> Type:Cmd.Captures(~S,~D.component_layout(~S),~route(),~User<S>)
