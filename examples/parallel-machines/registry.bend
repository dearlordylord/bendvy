import Base
import ../../src/ecs/execution-builder.bend as Build
import ./declarations.bend as D
import ./bodies.bend as Body
import ./actor.bend as Actor
import ./exit.bend as Exit
import ./events.bend as Events
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/owner-product.bend as Product

def ApplyOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.Resources(~S),Unit,D.apply_ops(~S),Body.Local(),String,String,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~D.apply_ops(~S),~D.apply(~S)),Body.apply(~S)>
def RequestOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.Resources(~S),Unit,D.request_ops(~S),Body.Local(),String,String,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~D.request_ops(~S),~D.request(~S)),Body.request(~S)>
def ReadOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.Resources(~S),Unit,D.read_ops(~S),Body.Local(),String,String,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~D.read_ops(~S),~D.read(~S)),Body.read(~S)>
def ExitOwner(~S:Data) -> Type:Exit.Owner(~S)
def ActorOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.Resources(~S),Unit,Actor.Ops(~S),Actor.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Actor.Ops(~S),~Actor.declaration(~S)),Actor.body(~S)>
def Readers(~S:Data) -> Type:Product.Owner<ActorOwner(~S),Events.Owner(~S)>
def Tail(~S:Data) -> Type:Product.Owner<RequestOwner(~S),Readers(~S)>
def Phases(~S:Data) -> Type:Product.Owner<ReadOwner(~S),Tail(~S)>
def AfterApply(~S:Data) -> Type:Product.Owner<ExitOwner(~S),Phases(~S)>
def Owners(~S:Data) -> Type:Product.Owner<ApplyOwner(~S),AfterApply(~S)>
def pack(~S:Data,apply:ApplyOwner(~S),exit:ExitOwner(~S),transition:ReadOwner(~S),enter:RequestOwner(~S),read:ActorOwner(~S),events:Events.Owner(~S)) -> Owners(~S):
  Product.Owner{apply,Product.Owner{exit,Product.Owner{transition,Product.Owner{enter,Product.Owner{read,events}}}}}
def handlers(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owners:Owners(~S)) -> F(Owners(~S)):
  match owners:
    case Product.Owner{apply,Product.Owner{exit,Product.Owner{transition,Product.Owner{enter,Product.Owner{read,events}}}}}:
      join(ApplyOwner(~S),AfterApply(~S),leaf(D.apply_ops(~S),Body.Local(),Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~D.apply_ops(~S),~D.apply(~S)),Body.apply(~S),apply),join(ExitOwner(~S),Phases(~S),command(D.component_layout(~S),Exit.route(),{==},{==},Exit.Ops(~S),Exit.User<S>,Exit.declaration(~S),Exit.body(~S),exit),join(ReadOwner(~S),Tail(~S),leaf(D.read_ops(~S),Body.Local(),Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~D.read_ops(~S),~D.read(~S)),Body.read(~S),transition),join(RequestOwner(~S),Readers(~S),leaf(D.request_ops(~S),Body.Local(),Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~D.request_ops(~S),~D.request(~S)),Body.request(~S),enter),join(ActorOwner(~S),Events.Owner(~S),leaf(Actor.Ops(~S),Actor.Local<S>,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Actor.Ops(~S),~Actor.declaration(~S)),Actor.body(~S),read),leaf(Events.Ops(~S),Events.Local<S>,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Events.Ops(~S),~Events.declaration(~S)),Events.body(~S),events))))))
