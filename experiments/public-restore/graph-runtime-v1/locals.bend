import Base
import ../../../src/ecs/local.bend as Core
import ./fixture.bend as F
import ../basic-world-statefree-v1/locals.bend as Old
import ../basic-world-statefree-v1/schema.bend as Original
import ../../../src/ecs/ordinary-schema.bend as Identity
import ../../../src/ecs/ordinary-resource-system.bend as Decl
import ../../../src/ecs/ordinary-app-local-fields.bend as Ordinary
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T

def identity(~S:Data) -> Identity.Resource<S,F.Resources(~S)>:Identity.resource(~S,~F.Resources(~S),"ApplicationResources")
def projected(~S:Data,machines:F.Machines(~S),result:Original.FullResources(~S) & U32) -> F.Resources(~S) & U32:
  match result:
    case (resources,value):(Product.Owner{resources,machines},value)
def project(~S:Data,resources:F.Resources(~S)) -> F.Resources(~S) & U32:
  match resources:
    case Product.Owner{resources,machines}:projected(~S,machines,Old.project(~S,resources))
def Ops(H:Type) -> Type:Cap.ValueRead<H,U32>
def declaration(~S:Data) -> Decl.Declaration<S,F.Resources(~S),T.Tx<F.World(~S),F.Events(~S)>,Ops(T.Tx<F.World(~S),F.Events(~S)>)>:Decl.read(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~U32,~project(~S),identity(~S))
def Capture() -> Type:Old.Capture()
def Owned(~S:Data) -> Type:Ordinary.Owner<S,F.Store(~S),F.Resources(~S),F.Events(~S),Capture(),Unit,Unit,U32,Ops,declaration(~S),Old.body>
def define(~S:Data,world:F.World(~S)) -> Ordinary.Registration<F.World(~S),Owned(~S),Capture()>:Ordinary.define(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Capture(),~Unit,~Unit,~U32,~Ops,~declaration(~S),~Old.body,world,"ExistingLocal",Old.initial())
def Returned(~S:Data) -> Type:Core.Run<S,F.Store(~S),F.Resources(~S),F.Events(~S),Capture(),Unit,Unit,U32,Ordinary.runner(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Capture(),~Unit,~Unit,~U32,~Ops,~declaration(~S),~Old.body)>
def run(~S:Data,owner:Owned(~S),world:F.World(~S)) -> Returned(~S):Ordinary.run(~S,~F.Store(~S),~F.Resources(~S),~F.Events(~S),~Capture(),~Unit,~Unit,~U32,~Ops,~declaration(~S),~Old.body,owner,world,Unit{})
