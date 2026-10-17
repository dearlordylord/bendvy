import Base
import model.bend as F
import factory.bend as Factory
import ../../../src/ecs/persistence-declaration.bend as Persist
import ../../../src/ecs/ordinary-schema.bend as Identity
import ../../../src/ecs/ordinary-resource-system.bend as Decl
import ../../../src/ecs/ordinary-app-local-fields.bend as Ordinary
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W

def identity(~S:Data) -> Identity.Resource<S,F.FullResources(~S)>:
  Identity.resource(~S,~F.FullResources(~S),"ApplicationResources")
def projected(~S:Data,unit:Unit,settings:F.ResourceResources(~S),logs:F.Logs(),declaration:Persist.Transient<S,Array<U32>,Factory.transient_identity(~S)>,observed:Array<U32> & U32) -> F.FullResources(~S) & U32:
  match observed:
    case (sentry,value):(Product.Owner{Product.Owner{unit,Product.Owner{settings,Leaf.TransientResource{sentry,declaration}}},logs},value)
def project(~S:Data,resource:F.FullResources(~S)) -> F.FullResources(~S) & U32:
  match resource:
    case Product.Owner{Product.Owner{unit,Product.Owner{settings,Leaf.TransientResource{sentry,declaration}}},logs}:projected(~S,unit,settings,logs,declaration,Array.get(U32,sentry,0))
def Ops(H:Type) -> Type:Cap.ValueRead<H,U32>
def declaration(~S:Data) -> Decl.Declaration<S,F.FullResources(~S),T.Tx<F.World(~S),F.Events(~S)>,Ops(T.Tx<F.World(~S),F.Events(~S)>)>:
  Decl.read(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~U32,~project(~S),identity(~S))
def Capture() -> Type:Product.Owner<Array<U32>,Array<U32>>
def updated(~H:Type,owner:H,observed:Array<U32> & U32,other:Array<U32> & U32,+value:U32) -> H & (Capture() & (T.Outcome<Unit> & U32)):
  (local,current)=observed
  (capture,captured)=other
  (owner,(Product.Owner{Array.set(U32,local,0,(current + 1 : U32)),Array.set(U32,capture,0,(captured + value : U32))},(T.Success{},value)))
def read(~H:Type,capture:Capture(),observed:H & U32) -> H & (Capture() & (T.Outcome<Unit> & U32)):
  match capture observed:
    case Product.Owner{local,capture},(owner,value):updated(~H,owner,Array.get(U32,local,0),Array.get(U32,capture,0),value)
def body(~H:Type,~caps:Ops(H),capture:Capture(),unit:Unit,owner:H) -> H & (Capture() & (T.Outcome<Unit> & U32)):
  read(~H,capture,Cap.value_read(~H,~U32,~caps,owner))
def Owned(~S:Data) -> Type:Ordinary.Owner<S,F.FullStore(~S),F.FullResources(~S),F.Events(~S),Capture(),Unit,Unit,U32,Ops,declaration(~S),body>
def initial() -> Capture():Product.Owner{ANode{ALeaf{600},ALeaf{601}},ANode{ALeaf{700},ALeaf{701}}}
def define(~S:Data,world:F.World(~S)) -> Ordinary.Registration<F.World(~S),Owned(~S),Capture()>:
  Ordinary.define(~S,~F.FullStore(~S),~F.FullResources(~S),~F.Events(~S),~Capture(),~Unit,~Unit,~U32,~Ops,~declaration(~S),~body,world,"ExistingLocal",initial())
