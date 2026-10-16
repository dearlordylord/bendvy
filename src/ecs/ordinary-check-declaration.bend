import Base
import ./world.bend as W
import ./check.bend as K
import ./capabilities.bend as Cap
import ./ordinary-schema.bend as Schema
import ./ordinary-optional-resource.bend as O
import ./optional-resource-binding.bend as B
import ./owner-product.bend as Product

# Metadata belongs to the same operational read; no caller-authored access list.
type Category is Data:Resource{}
type Mode is Data:Read{}
type Use is Data:Use{category:Category,key:String,mode:Mode,required:Bool}
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type> is Type:
  Declaration{plan:K.Plan<S,C,R,E,Ops>,uses:List<&2,Use>}
type ResourceRead<-S:Data,-P:Type,-identity:Schema.Resource<S,P>,-H:Type,-V:Data> is Type:
  ResourceRead{read:Cap.ValueRead<H,Maybe<&2,V>>}
def Ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:ResourceRead<S,P,identity,H,V>
def read_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,value:ResourceRead<S,P,identity,H,V>) -> H -> H & Maybe<&2,V>:
  match value:
    case ResourceRead{read}:Cap.value_read_field(~H,~Maybe<&2,V>,read)
def read(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~value:ResourceRead<S,P,identity,H,V>,owner:H) -> H & Maybe<&2,V>:
  read_field(~S,~P,~identity,~H,~V,value)(owner)
def provided(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:(world,[])
def optional_resource(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~binding:B.Binding<S,R,P,Rest,identity,lens>,~view:P -> P & V) -> Declaration<S,C,R,E,Ops(~S,~P,~identity,~V)>:
  Declaration{K.Plan{provided(~S,~C,~R,~E),ResourceRead{O.condition(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{})}},[Use{Resource{},Schema.resource_key(~S,~P,identity),Read{},False{}}]}
def required_resource(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~binding:B.Binding<S,R,P,Rest,identity,lens>,~view:P -> P & V) -> Declaration<S,C,R,E,Ops(~S,~P,~identity,~V)>:
  Declaration{K.Plan{O.required(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{}),ResourceRead{O.condition(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{})}},[Use{Resource{},Schema.resource_key(~S,~P,identity),Read{},True{}}]}
def plan(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,value:Declaration<S,C,R,E,Ops>) -> K.Plan<S,C,R,E,Ops>:
  match value:
    case Declaration{plan,_}:plan
def uses(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,value:Declaration<S,C,R,E,Ops>) -> List<&2,Use>:
  match value:
    case Declaration{_,uses}:uses
